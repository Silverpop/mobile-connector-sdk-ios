//
//  UBFClient.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "UBFClient.h"
#import "UBF.h"
#import <AFNetworking/AFHTTPRequestOperation.h>
#import <UIKit/UIKit.h>
#import "EngageEvent.h"

NSString * const kEngageClientInstalled = @"engageClientInstalled";

@interface UBFClient ()

@property NSMutableArray *events;
@property NSDictionary *sessionEnded;
@property NSDate *sessionExpires;
@property(nonatomic) NSDate *sessionBegan;
@property NSTimeInterval duration;

@property NSInteger queueSize;
@property NSInteger minCode;
@property(nonatomic) NSTimeInterval sessionTimeout;

@property (nonatomic, strong) MobileDeepLinking *mobileDeepLinking;

@end


@implementation UBFClient

__strong static UBFClient *_sharedClient = nil;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)createClient:(NSString *)clientId
                      secret:(NSString *)secret
                       token:(NSString *)refreshToken
                        host:(NSString *)hostUrl {
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedClient = [[self alloc] initWithHost:hostUrl clientId:clientId secret:secret token:refreshToken];
        _sharedClient.events = [NSMutableArray array];
        _sharedClient.queueSize = 3; // three events trigger post
        _sharedClient.minCode = 15; // Session Ended event code
        _sharedClient.sessionTimeout = 30; // 5 minutes
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *installed = [defaults objectForKey:kEngageClientInstalled];
        if (![installed boolValue]) { // nil or false
            // installed event
            [_sharedClient trackingEvent:[UBF installed:nil]];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"YES" forKey:kEngageClientInstalled];
            [defaults synchronize];
        }
        
        // start session
        [_sharedClient restartSession];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          NSLog(@"Engage resume session");
                                                          if ([_sharedClient sessionExpired]) {
                                                              NSLog(@"Engage Session Expired");
                                                              [_sharedClient restartSession];
                                                          }
                                                          else {
                                                              _sharedClient.sessionBegan = [NSDate date];
                                                          }
                                                      }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          NSLog(@"Engage pause session");
                                                          // now - start|resume + duration
                                                          _sharedClient.duration += [[NSDate date] timeIntervalSinceDate:_sharedClient.sessionBegan];
                                                          _sharedClient.sessionEnded = [UBF sessionEnded:@{@"Session Duration":[NSString stringWithFormat:@"%d",(int)_sharedClient.duration]}];
                                                          _sharedClient.sessionExpires = [NSDate dateWithTimeInterval:_sharedClient.sessionTimeout
                                                                                                            sinceDate:[NSDate date]];
                                                          [_sharedClient postEventCache];
                                                      }];
        
        
        [[EngageLocalEventStore sharedInstance] deleteExpiredLocalEvents];
        
        //Check for events that have not yet been posted
        NSArray *unpostedLocalEvents = [[EngageLocalEventStore sharedInstance] findUnpostedEvents];
        NSLog(@"Re-queueing %lu unposted local events to Silverpop from events local store", (unsigned long)[unpostedLocalEvents count]);
        for (EngageEvent *unpostedEvent in unpostedLocalEvents) {
            [_sharedClient trackEngageEvent:unpostedEvent];
        }
        
        NSLog(@"Creating MobileDeepLinking client");
        _sharedClient.mobileDeepLinking = [MobileDeepLinking sharedInstance];
        NSLog(@"Created the instance now applying some routes to it!");
        
        void (^handleOpenUrlBlock) (NSDictionary *params);
        //Creates the callback block that will be invoked on the app open url
        handleOpenUrlBlock = ^(NSDictionary * params) {
            NSLog(@"POSTing UBF event to Silverpop as a result of handling OpenURL with Params -> %@", params);
            NSLog(@"BOOM!!!");
        };
        
        [_sharedClient.mobileDeepLinking registerHandlerWithName:@"postSilverpop" handler:handleOpenUrlBlock];

    });
    return _sharedClient;
}

- (void) routeUsingUrl:(NSURL *)url
{
    NSLog(@"UBFClient routing url %@", url);
    [_sharedClient.mobileDeepLinking routeUsingUrl:url];
}
+ (instancetype)client
{
    return _sharedClient;
}

- (void)restartSession {
    if (_sharedClient.sessionEnded) [self trackingEvent:_sharedClient.sessionEnded];
    [self trackingEvent:[UBF sessionStarted:nil]];
    _sharedClient.sessionBegan = [NSDate date];
    self.duration = 0.0f;
}

- (BOOL)sessionExpired {
    return [_sessionExpires compare:[NSDate date]] == NSOrderedAscending;
}

- (void)trackingEvent:(NSDictionary *)event {
    NSLog(@"TrackingEvent %@", event.description);
    EngageEvent *engageEvent = [[EngageLocalEventStore sharedInstance] saveUBFEvent:event];
    NSLog(@"saveUBFEvent has successfully been invoked!");
    [self trackEngageEvent:engageEvent];
}

- (void)trackEngageEvent:(EngageEvent *)engageEvent {

    //This method won't work as is because the current core data table structure does not have a
//    NSLog(@"Checking if ManagedEvent has been inserted or not");
//    if (!engageEvent.isInserted) {
//        [[[EngageLocalEventStore sharedInstance] managedObjectContext] insertObject:engageEvent];
//        NSError *error;
//        if (![[[EngageLocalEventStore sharedInstance] managedObjectContext] save:&error]) {
//            NSLog(@"Unable to save UBFEvent %@ to EngageLocalEventStore. Silverpop HTTP Post will still be attempted.", engageEvent.description);
//        }
//        
//        //Debug logging to make sure this works as expected
//        NSLog(@"DEBUG ENGAGEEVENT SHOULD NOW BE INSERTED %s", engageEvent.isInserted ? "true" : "false");
//    }
//    NSLog(@"Done checking if the ManagedEvent has been inserted or not");
    
    [_events addObject:engageEvent];
    
    NSNumber *eventTypeCode = engageEvent.eventType;
    // if we have queued at least 3 events
    // or we have reached end of session
    if (_events.count > _queueSize || [eventTypeCode integerValue] > _minCode) {
        // post events to service
        [self postEventCache];
    }
}

- (void)postEventCache {
    if (_events.count == 0) return;
    NSArray *engageEventsCache = [_events copy];
    [_events removeAllObjects];
    [self enqueueEngageEvent:engageEventsCache];
}

- (void)enqueueEvent:(NSDictionary *)event {
    //Save event to EngageLocalEventStore
    [[EngageLocalEventStore sharedInstance] saveUBFEvent:event];
    
    [_events addObject:event];
    NSArray *engageEventsCache = [_events copy];
    [_events removeAllObjects];
    [self enqueueEngageEvent:engageEventsCache];
}

- (void)enqueueEngageEvent:(NSArray *)engageEvents {
    //We need to convert the list of "tracked" EngageEvent objects back to their original format for submission
    NSError *error;
    NSMutableArray *eventsCache = [[NSMutableArray alloc] init];
    for (EngageEvent *event in engageEvents) {
        NSDictionary *originalEventData = [NSJSONSerialization JSONObjectWithData:[event.eventJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                   options:kNilOptions
                                                                     error:&error];
        [eventsCache addObject:originalEventData];
    }
    
    NSDictionary *params = @{ @"events" : eventsCache };
    
    [self setParameterEncoding:AFJSONParameterEncoding];
    
    NSMutableURLRequest *request = [self requestWithMethod:@"POST" path:@"/rest/events/submission" parameters:params];
    AFHTTPRequestOperation *operation =
    [self HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"UBF EVENTS WERE SUCCESSFULLY POSTED TO SILVERPOP! With ResponseObject %@", responseObject);
        NSLog(@"%@",[operation debugDescription]);
        NSLog(@"%@",[responseObject debugDescription]);
        
        // Mark the EngageObjects as posted in the EngageLocalEventStore.
        for (EngageEvent *event in engageEvents) {
            event.eventHasPosted = [[NSNumber alloc] initWithInt:1];
        }
        NSError *saveError;
        if (![[[EngageLocalEventStore sharedInstance] managedObjectContext] save:&saveError]) {
            NSLog(@"EngageUBFEvents were successfully posted to Silverpop but there was a problem marking them as posted in the EngageLocalEventStore: %@", [saveError description]);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"%@",[operation debugDescription]);
        NSLog(@"%@",[error debugDescription]);
        
        NSLog(@"-----CACHED FAILED OPERATION-----");
        // requeue to be retried later
        [_events addObjectsFromArray:engageEvents];
    }];
    
    [self enqueueHTTPRequestOperation:operation];
}

@end
