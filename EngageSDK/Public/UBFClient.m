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
#import "EngageConfig.h"
#import "EngageEventLocationManager.h"
#import "EngageConfigManager.h"

@interface UBFClient ()

@property NSMutableArray *events;
@property NSInteger queueSize;
@property NSInteger minCode;

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
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        //Perform the login to the system.
        [_sharedClient connectSuccess:^(AFOAuthCredential *credential) {
            success(credential);
            
            dispatch_semaphore_signal(semaphore);
            
            [_sharedClient postEventCache];
            
            //Check for UBFEvents that have not yet been posted
            NSArray *unpostedLocalEvents = [[EngageLocalEventStore sharedInstance] findUnpostedEvents];
            NSLog(@"Re-queueing %lu unposted local events to Silverpop from events local store", (unsigned long)[unpostedLocalEvents count]);
            for (EngageEvent *unpostedEvent in unpostedLocalEvents) {
                [_sharedClient trackEngageEvent:unpostedEvent];
            }
        } failure:^(NSError *error) {
            failure(error);
            dispatch_semaphore_signal(semaphore);
        }];
        
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        
        NSLog(@"OAuth2 authentication complete");
        
        [[EngageLocalEventStore sharedInstance] deleteExpiredLocalEvents];
    });
    
    return _sharedClient;
}

+ (instancetype)client
{
    return _sharedClient;
}

- (NSInteger)eventCacheSize {
    return self.queueSize;
}

- (NSArray *) cachedEvents {
    return self.events;
}


//- (NSURL *)trackingEvent:(NSDictionary *)event {
////    EngageEvent *engageEvent = nil;
////    
////    //Does the event need to be fired now or wait?
////    if ([self.engageEventLocationManager locationServicesEnabled]) {
////        //Ask the location Manager for the current CLLocation and CLPlacemark information
////        NSDictionary *eventWithLocation = [self.engageEventLocationManager addLocationToUBFEvent:event];
////        if (eventWithLocation == nil) {
////            //Location information is not yet ready so save with a hold state in the database.
////            engageEvent = [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:HOLD];
////        } else {
////            engageEvent = [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:NOT_POSTED];
////            [self trackEngageEvent:engageEvent];
////        }
////    } else {
////        //Location Services are not enabled so continue with the normal flow.
////        engageEvent = [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:NOT_POSTED];
////        [self trackEngageEvent:engageEvent];
////    }
////    
////    return [[engageEvent objectID] URIRepresentation];
//}

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

- (NSURL *)enqueueEvent:(NSDictionary *)event {
    //Save event to EngageLocalEventStore
    EngageEvent *engageEvent = [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:NOT_POSTED];
    
    [_events addObject:event];
    NSArray *engageEventsCache = [_events copy];
    [_events removeAllObjects];
    [self enqueueEngageEvent:engageEventsCache];
    return [[engageEvent objectID] URIRepresentation];
}

- (void)enqueueEngageEvent:(NSArray *)engageEvents {
    
    if ([engageEvents count] <= 0) {
        NSLog(@"No events available to be pushed to engage");
        return;
    }
    
    //We need to convert the list of "tracked" EngageEvent objects back to their original format for submission
    NSError *error;
    NSMutableArray *eventsCache = [[NSMutableArray alloc] init];
    for (EngageEvent *event in engageEvents) {
        if (event.eventJson != nil) {
            NSDictionary *originalEventData = [NSJSONSerialization JSONObjectWithData:[event.eventJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                              options:kNilOptions
                                                                                error:&error];
            [eventsCache addObject:originalEventData];
        }
    }
    
    NSDictionary *params = @{ @"events" : eventsCache };
    
    //Refresh the UBFClient OAuth2 Credentials if they have expired.
    if ([[_sharedClient credential] isExpired]) {
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        //Perform the login to the system.
        [_sharedClient connectSuccess:^(AFOAuthCredential *credential) {
            dispatch_semaphore_signal(semaphore);
        } failure:^(NSError *error) {
            NSLog(@"Failure refreshing UBFclient OAuth2 credentials! %@", [error description]);
            dispatch_semaphore_signal(semaphore);
        }];
        
        NSLog(@"Refreshing expired UBFClient OAuth2 credentials");
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
        NSLog(@"Refreshing expired UBFClient OAuth2 credentials - Completed");
    }
    
    _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
    [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [_sharedClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [_sharedClient.credential accessToken]] forHTTPHeaderField:@"Authorization"];
    
    [_sharedClient POST:@"/rest/events/submission" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"%@",[operation debugDescription]);
        NSLog(@"%@",[responseObject debugDescription]);
        
        // Mark the EngageObjects as posted in the EngageLocalEventStore.
        for (EngageEvent *event in engageEvents) {
            if (event != nil && ![event isFault]) {
                event.eventStatus = [NSNumber numberWithInt:SUCCESSFULLY_POSTED];
            }
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
        
        // Mark the EngageObjects as posted in the EngageLocalEventStore.
        for (EngageEvent *event in engageEvents) {
            if (event != nil && ![event isFault]) {
                event.eventStatus = [NSNumber numberWithInt:FAILED_POST];
            }
        }
        
        NSError *saveError;
        if (![[[EngageLocalEventStore sharedInstance] managedObjectContext] save:&saveError]) {
            NSLog(@"Marked events as failed to post in EngageLocalEventStore : %@", [saveError description]);
        }
    }];

}

@end
