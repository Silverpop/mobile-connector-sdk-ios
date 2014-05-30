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
#import <MobileDeepLinking-iOS/MobileDeepLinking.h>
#import "EngageConfig.h"
#import "EngageEventLocationManager.h"
#import "EngageConfigManager.h"

@interface UBFClient ()

@property int maxNumRetries;
@property (nonatomic, strong) MobileDeepLinking *mobileDeepLinking;
@property (strong, nonatomic) NSMutableArray *eventCache;
@property (assign) int queueSize;

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
        _sharedClient.maxNumRetries = [[[EngageConfigManager sharedInstance] configForNetworkValue:PLIST_NETWORK_MAX_NUM_RETRIES] intValue];
        _sharedClient.eventCache = [[NSMutableArray alloc] init];
        _sharedClient.queueSize = [[[EngageConfigManager sharedInstance] numberConfigForGeneralFieldName:PLIST_GENERAL_UBF_EVENT_CACHE_SIZE] intValue];
        [_sharedClient authenticateInternal:success failure:failure];
        [[EngageLocalEventStore sharedInstance] deleteExpiredLocalEvents];
    });
    
    return _sharedClient;
}


+ (instancetype)client
{
    return _sharedClient;
}


- (void)authenticateInternal:(void (^)(AFOAuthCredential *credential))success
                     failure:(void (^)(NSError *error))failure {
    
    [[_sharedClient operationQueue] setSuspended:YES];
    
    //Perform the login to the system.
    [_sharedClient authenticate:^(AFOAuthCredential *credential) {
        success(credential);
        
        //Push the events that have queued up while the client was not authenticated
        [self pushEventCache];
        
        //Check for UBFEvents that have not yet been posted
        NSArray *unpostedLocalEvents = [[EngageLocalEventStore sharedInstance] findUnpostedEvents];
        NSLog(@"Re-queueing %lu unposted local events to Silverpop from events local store", (unsigned long)[unpostedLocalEvents count]);
        for (EngageEvent *unpostedEvent in unpostedLocalEvents) {
            [_sharedClient postEngageEvent:unpostedEvent];
        }
    } failure:^(NSError *error) {
        failure(error);
    }];
}


- (void)pushEventCache {
    if (self.credential != nil && ![self.credential isExpired]) {
        [self pushEventCacheInternal:0 withEvents:nil];
    } else {
        NSLog(@"Client is not authenticated yet. Unable to force event push");
    }
}


- (void)postEngageEvent:(EngageEvent *)engageEvent {
    
    [self.eventCache addObject:engageEvent];
    
    if ([self.eventCache count] >= self.queueSize
        && self.credential != nil && ![self.credential isExpired]) {
        [self pushEventCache];
    }
}


- (void)pushEventCacheInternal:(int)retryAttempt withEvents:(NSArray *)events {
    
    if (retryAttempt < self.maxNumRetries) {
        
        __block NSArray *eventCacheToPush = nil;
        __block int localRetryCount = retryAttempt;
        
        if (retryAttempt == 0) {
            //Grab the current cache and clean it out.
            eventCacheToPush = [self.eventCache copy];
            [self.eventCache removeAllObjects];
        } else {
            if (events == nil) {
                eventCacheToPush = [self.eventCache copy];
            } else {
                eventCacheToPush = events;
            }
        }
        
        //We need to convert the list of "tracked" EngageEvent objects back to their original format for submission
        NSError *error;
        NSMutableArray *eventsCache = [[NSMutableArray alloc] init];
        
        for (EngageEvent *ee in eventCacheToPush) {
            NSDictionary *originalEventData = [NSJSONSerialization JSONObjectWithData:[ee.eventJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                              options:kNilOptions
                                                                                error:&error];
            [eventsCache addObject:originalEventData];
        }
        
        NSDictionary *params = @{ @"events" : eventsCache };
        
        //Refresh the UBFClient OAuth2 Credentials if they have expired.
        if (self.isAuthenticated) {
            NSLog(@"Client was not authenticated so we could not push the cache events!");
            [self authenticateInternal:nil failure:nil];
        }
        
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [_sharedClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [_sharedClient.credential accessToken]] forHTTPHeaderField:@"Authorization"];
        
        [_sharedClient POST:@"/rest/events/submission" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            NSLog(@"%@",[operation debugDescription]);
            NSLog(@"%@",[responseObject debugDescription]);
            
            // Mark the EngageObjects as posted in the EngageLocalEventStore.
            for (EngageEvent *intEE in eventCacheToPush) {
                intEE.eventStatus = [NSNumber numberWithInt:SUCCESSFULLY_POSTED];
            }
            
            NSError *saveError;
            if (![[[EngageLocalEventStore sharedInstance] managedObjectContext] save:&saveError]) {
                NSLog(@"EngageUBFEvents were successfully posted to Silverpop but there was a problem marking them as posted in the EngageLocalEventStore: %@", [saveError description]);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",[operation debugDescription]);
            NSLog(@"%@",[error debugDescription]);
            
            NSLog(@"-----CACHED FAILED OPERATION-----");

            for (EngageEvent *intEE in eventCacheToPush) {
                intEE.eventStatus = [NSNumber numberWithInt:FAILED_POST];
            }
            
            NSError *saveError;
            if (![[[EngageLocalEventStore sharedInstance] managedObjectContext] save:&saveError]) {
                NSLog(@"Marked events as failed to post in EngageLocalEventStore : %@", [saveError description]);
            }
            
            [self pushEventCacheInternal:(localRetryCount++) withEvents:eventCacheToPush];
        }];
    } else {
        NSLog(@"Max number of retries %d was reached and event will not be posted", self.maxNumRetries);
    }
}

@end
