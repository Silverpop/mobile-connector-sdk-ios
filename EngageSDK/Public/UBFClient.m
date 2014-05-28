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

@property NSInteger minCode;
@property (assign) int maxNumRetries;

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
        _sharedClient.minCode = 15; // Session Ended event code
        _sharedClient.maxNumRetries = 3;
        
        dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
        
        //Perform the login to the system.
        [_sharedClient connectSuccess:^(AFOAuthCredential *credential) {
            success(credential);
            
            dispatch_semaphore_signal(semaphore);
            
            //Check for UBFEvents that have not yet been posted
            NSArray *unpostedLocalEvents = [[EngageLocalEventStore sharedInstance] findUnpostedEvents];
            NSLog(@"Re-queueing %lu unposted local events to Silverpop from events local store", (unsigned long)[unpostedLocalEvents count]);
            for (EngageEvent *unpostedEvent in unpostedLocalEvents) {
                [_sharedClient postEngageEvent:unpostedEvent retryCount:0];
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


- (void)postEngageEvent:(EngageEvent *)engageEvent retryCount:(int)numRetries {
    
    __block int localRetryCount = numRetries;
    
    if (numRetries < self.maxNumRetries) {
        //We need to convert the list of "tracked" EngageEvent objects back to their original format for submission
        NSError *error;
        NSMutableArray *eventsCache = [[NSMutableArray alloc] init];
        NSDictionary *originalEventData = [NSJSONSerialization JSONObjectWithData:[engageEvent.eventJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                          options:kNilOptions
                                                                            error:&error];
        [eventsCache addObject:originalEventData];
        
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
            engageEvent.eventStatus = [NSNumber numberWithInt:SUCCESSFULLY_POSTED];
            
            NSError *saveError;
            if (![[[EngageLocalEventStore sharedInstance] managedObjectContext] save:&saveError]) {
                NSLog(@"EngageUBFEvents were successfully posted to Silverpop but there was a problem marking them as posted in the EngageLocalEventStore: %@", [saveError description]);
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSLog(@"%@",[operation debugDescription]);
            NSLog(@"%@",[error debugDescription]);
            
            NSLog(@"-----CACHED FAILED OPERATION-----");
        
            [self postEngageEvent:engageEvent retryCount:(localRetryCount++)];
            engageEvent.eventStatus = [NSNumber numberWithInt:FAILED_POST];
            
            NSError *saveError;
            if (![[[EngageLocalEventStore sharedInstance] managedObjectContext] save:&saveError]) {
                NSLog(@"Marked events as failed to post in EngageLocalEventStore : %@", [saveError description]);
            }
        }];
    } else {
        NSLog(@"Max number of retries %d was reached and event will not be posted", self.maxNumRetries);
    }
}

@end
