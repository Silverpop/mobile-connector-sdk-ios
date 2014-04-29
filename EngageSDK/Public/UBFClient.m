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
                        host:(NSString *)hostUrl
              connectSuccess:(void (^)(AFOAuthCredential *credential))success
                     failure:(void (^)(NSError *error))failure {
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedClient = [[self alloc] initWithHost:hostUrl clientId:clientId secret:secret token:refreshToken];
        _sharedClient.events = [NSMutableArray array];
        _sharedClient.queueSize = 3; // three events trigger post
        _sharedClient.minCode = 15; // Session Ended event code
        _sharedClient.sessionTimeout = 30; // 5 minutes
        
        NSLog(@"Starting connection ...");
        
        //Perform the login to the system.
        [_sharedClient connectSuccess:^(AFOAuthCredential *credential) {
            NSLog(@"OK LETS TRY TO PUSH STUFF NOW!");
            [_sharedClient postEventCache];
            success(credential);
        } failure:failure];
        
        NSLog(@"Should not show up before connection success!!!");
        
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
        
        //Check for UBFEvents that have not yet been posted
        NSArray *unpostedLocalEvents = [[EngageLocalEventStore sharedInstance] findUnpostedEvents];
        NSLog(@"Re-queueing %lu unposted local events to Silverpop from events local store", (unsigned long)[unpostedLocalEvents count]);
        for (EngageEvent *unpostedEvent in unpostedLocalEvents) {
            [_sharedClient trackEngageEvent:unpostedEvent];
        }
        
        //Create MobileDeepLinking instance and register handler for capture URL data to post to Silverpop
        _sharedClient.mobileDeepLinking = [MobileDeepLinking sharedInstance];
        [_sharedClient.mobileDeepLinking registerHandlerWithName:@"postSilverpop" handler:^(NSDictionary *properties) {
            NSLog(@"POSTing to Silverpop as a result of handling OpenURL with Params -> %@", properties);
            id ubfResult = [UBF openedURL:properties];
            NSLog(@"UBFResult of %@", ubfResult);
            [_sharedClient trackingEvent:ubfResult];
        }];

    });
    return _sharedClient;
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
    EngageEvent *engageEvent = [[EngageLocalEventStore sharedInstance] saveUBFEvent:event];
    [self trackEngageEvent:engageEvent];
}

- (void)trackEngageEvent:(EngageEvent *)engageEvent {
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
    
    if (self.credential == nil || [self.credential isExpired]) {
        NSLog(@"Client is not currently logged in so we need to wait on posting for now ...");
        return;
    } else {
        NSLog(@"Client has valid credentials so we will continue and post to the engage API");
    }
    
    if ([engageEvents count] <= 0) {
        NSLog(@"No events available to be pushed to engage");
        return;
    }
    
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
    
    //[self setParameterEncoding:AFJSONParameterEncoding];
    
    [self POST:@"/rest/events/submission" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
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
}

- (void) routeUsingUrl:(NSURL *)url
{
    [_sharedClient.mobileDeepLinking routeUsingUrl:url];
}


- (void) addHandlersDictionaryToMobileDeepLinking:(NSDictionary *)handlers {
    NSLog(@"Registering %ld handlers to mobile deep linking library", (unsigned long)[handlers count]);
    for (id key in handlers) {
        [self.mobileDeepLinking registerHandlerWithName:key handler:[handlers objectForKey:key]];
    }
}

- (void) receivedNotification:(NSDictionary *)params {
    NSLog(@"Tracking UBF event from Received Notification with Params -> %@", params);
    [self trackingEvent:[UBF receivedNotification:params]];
}

- (void) openedNotification:(NSDictionary *)params {
    NSLog(@"Tracking UBF from Opened notification with params -> %@", params);
    [self trackingEvent:[UBF openedNotification:params]];
}


@end
