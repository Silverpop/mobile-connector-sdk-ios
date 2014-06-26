//
//  UBFClient.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/25/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "UBFClient.h"
#import "EngageEvent.h"
#import "EngageConfigManager.h"
#import "UBFAugmentationManager.h"

@interface UBFClient ()

@property int maxNumRetries;

@end


@implementation UBFClient

__strong static UBFClient *_sharedClient = nil;

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
        [[EngageLocalEventStore sharedInstance] deleteExpiredLocalEvents];
        [_sharedClient authenticateInternal:success failure:failure];
    });
    
    return _sharedClient;
}

+ (instancetype)client
{
    return _sharedClient;
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


- (void)authenticateInternal:(void (^)(AFOAuthCredential *credential))success
                     failure:(void (^)(NSError *error))failure {
    
    [[_sharedClient operationQueue] setSuspended:YES];
    
    //Perform the login to the system.
    [_sharedClient authenticate:^(AFOAuthCredential *credential) {
        NSLog(@"EngageSDK UBFClient successfully authenticated");
        if (success) {
            success(credential);
        }
        
        //Posts all of the pending EngageEvents.
        [self applicationStartupPostStaleEvents];
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

//When the application starts up there may be stale events that never completed and those need to be posted.
- (void) applicationStartupPostStaleEvents {
    //Lookup all of the events that are still "HOLD" meaning they didn't complete Augmentation and try again.
    NSArray *holdEngageEvents = [[EngageLocalEventStore sharedInstance] findEngageEventsWithStatus:HOLD];
    for (EngageEvent *engageEvent in holdEngageEvents) {
        UBF *ubfEvent = [[UBF alloc] initFromJSON:engageEvent.eventJson];
        [[UBFAugmentationManager sharedInstance] augmentUBFEvent:ubfEvent withEngageEvent:engageEvent];
    }
    
    //Lookup all events in "PROCESSING" which means the app was killed before they were successfully POSTed to Silverpop
    NSArray *engageEvents = [[EngageLocalEventStore sharedInstance] findEngageEventsWithStatus:PROCESSING];
    for (EngageEvent *engageEvent in engageEvents) {
        engageEvent.eventStatus = [NSNumber numberWithInt:NOT_POSTED];
    }
    
    [[EngageLocalEventStore sharedInstance] saveEvents];
    [self postUBFEngageEvents:nil failure:nil];
}


- (void) postUBFEngageEvents:(void (^)(AFHTTPRequestOperation *operation, id responseObject)) success
                     failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure {
    
    if (self.isAuthenticated) {
        
        __block NSArray *unpostedUbfEvents = [[EngageLocalEventStore sharedInstance] findUnpostedEvents];
        [[UBFAugmentationManager sharedInstance] zeroOutLocalCacheSize];
        
        if (unpostedUbfEvents && [unpostedUbfEvents count] > 0) {
            
            //Mark all of the "unpostedUbfEvents" as in progress so they won't be picked up again if this is invoked again for HTTP response of success or failure. We don't have to "Save commit" as this in memory representation should do.
            for (EngageEvent *intEE in unpostedUbfEvents) {
                intEE.eventStatus = [NSNumber numberWithInt:PROCESSING];
            }
            
            //We need to convert the list of "tracked" EngageEvent objects back to their original format for submission
            NSMutableArray *eventsCache = [[NSMutableArray alloc] init];
            
            for (EngageEvent *ee in unpostedUbfEvents) {
                if (![ee isFault]) {
                    NSDictionary *originalEventData = [[[UBF alloc] initFromJSON:ee.eventJson] dictionaryValue];
                    [eventsCache addObject:originalEventData];
                } else {
                    NSLog(@"EngageEvent is in a fault state");
                }
            }
            
            NSDictionary *params = @{ @"events" : eventsCache };
            
            NSLog(@"POSTing %@", params.description);
            
            _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
            [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
            [_sharedClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [_sharedClient.credential accessToken]] forHTTPHeaderField:@"Authorization"];
            
            [_sharedClient POST:@"/rest/events/submission" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
                
                // Mark the EngageObjects as posted in the EngageLocalEventStore.
                for (EngageEvent *intEE in unpostedUbfEvents) {
                    intEE.eventStatus = [NSNumber numberWithInt:SUCCESSFULLY_POSTED];
                }
                
                [[EngageLocalEventStore sharedInstance] saveEvents];
                
                if (success) {
                    success(operation, responseObject);
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                
                NSLog(@"Posting UBFEngageEvents failed with error:%@", [error description]);
                
                for (EngageEvent *intEE in unpostedUbfEvents) {
                    intEE.eventStatus = [NSNumber numberWithInt:FAILED_POST];
                }
                
                [[EngageLocalEventStore sharedInstance] saveEvents];
                
                if (failure) {
                    failure(operation, error);
                }
            }];
        } else {
            NSLog(@"No UBFEvents to post");
        }
        
    } else {
        NSLog(@"UBFClient is not authenticated yet. Events will be posted once authentication is complete.");
    }
}

@end
