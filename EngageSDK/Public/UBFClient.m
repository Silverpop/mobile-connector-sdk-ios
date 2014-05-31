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
        _sharedClient.requestSerializer = [AFJSONRequestSerializer serializer];
        [_sharedClient.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [_sharedClient authenticateInternal:success failure:failure];
        [[EngageLocalEventStore sharedInstance] deleteExpiredLocalEvents];
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
        if (success) {
            success(credential);
        }
        
        //Posts all of the pending EngageEvents.
        [self postUBFEngageEvents];
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
}

- (void) postUBFEngageEvents {
    if (self.isAuthenticated) {
        
        __block NSArray *unpostedUbfEvents = [[EngageLocalEventStore sharedInstance] findUnpostedEvents];
        
        //We need to convert the list of "tracked" EngageEvent objects back to their original format for submission
        NSError *error;
        NSMutableArray *eventsCache = [[NSMutableArray alloc] init];
        
        for (EngageEvent *ee in unpostedUbfEvents) {
            if (![ee isFault]) {
                NSDictionary *originalEventData = [NSJSONSerialization JSONObjectWithData:[ee.eventJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                                  options:kNilOptions
                                                                                    error:&error];
                [eventsCache addObject:originalEventData];
            } else {
                NSLog(@"EngageEvent is in a fault state");
            }
        }
        
        NSDictionary *params = @{ @"events" : eventsCache };
        
        [_sharedClient.requestSerializer setValue:[NSString stringWithFormat:@"Bearer %@", [_sharedClient.credential accessToken]] forHTTPHeaderField:@"Authorization"];
        
        [_sharedClient POST:@"/rest/events/submission" parameters:params success:^(AFHTTPRequestOperation *operation, id responseObject) {
            
            // Mark the EngageObjects as posted in the EngageLocalEventStore.
            for (EngageEvent *intEE in unpostedUbfEvents) {
                intEE.eventStatus = [NSNumber numberWithInt:SUCCESSFULLY_POSTED];
            }
            
            [[EngageLocalEventStore sharedInstance] saveEvents];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            
            NSLog(@"Posting UBFEngageEvents failed with error:%@", [error description]);
            
            for (EngageEvent *intEE in unpostedUbfEvents) {
                intEE.eventStatus = [NSNumber numberWithInt:FAILED_POST];
            }
            
            [[EngageLocalEventStore sharedInstance] saveEvents];
        }];
        
    } else {
        NSLog(@"UBFClient is not authenticated yet. Events will be posted once authentication is complete.");
    }
}

@end
