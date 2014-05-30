//
//  EngageClient.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "EngageClient.h"

#define EXCEPTION(msg) \
    ([NSException exceptionWithName:NSInternalInconsistencyException \
                             reason:[NSString stringWithFormat:msg, NSStringFromClass([self class])] \
                           userInfo:nil])

@interface EngageClient ()

@property NSString *clientId, *secret, *refreshToken, *host;

@end


@implementation EngageClient

- (id)init {
    @throw EXCEPTION(@"%@ Failed to call designated initializer. Invoke `+createClient:secret:token:` instead.");
}

- (id)initWithBaseURL:(NSURL *)url
             clientID:(NSString *)clientID
               secret:(NSString *)secret
{
    @throw EXCEPTION(@"%@ Failed to call designated initializer. Invoke `+createClient:secret:token:` instead.");
}

- (id)initWithHost:(NSString *)host
          clientId:(NSString *)clientId
            secret:(NSString *)secret
             token:(NSString *)refreshToken
{
    
    NSURL *baseUrl = [NSURL URLWithString:host];
    
    if (self = [super initWithBaseURL:baseUrl clientID:clientId secret:secret]) {
        _clientId = clientId;
        _secret = secret;
        _refreshToken = refreshToken;
        _host = host;
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status == AFNetworkReachabilityStatusNotReachable || [self credential] == nil || [[self credential] isExpired]) {
                [[self operationQueue] setSuspended:YES];
            } else {
                [[self operationQueue] setSuspended:NO];
            }
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    
    return self;
}

- (BOOL)isAuthenticated {
    if (self.credential != nil && ![self.credential isExpired]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)authenticate:(void (^)(AFOAuthCredential *credential))success
               failure:(void (^)(NSError *error))failure {
    
    [self authenticateUsingOAuthWithURLString:@"http://apipilot.silverpop.com/oauth/token"
                            refreshToken:_refreshToken
                                 success:^(AFOAuthCredential *credential) {
                                     
                                     self.credential = credential;
                                     
                                     success(credential);
                                     
                                     //Checks the network status and if its active open up the queue.
                                     if ([[AFNetworkReachabilityManager sharedManager] networkReachabilityStatus] == AFNetworkReachabilityStatusNotReachable) {
                                         [[self operationQueue] setSuspended:YES];
                                     } else {
                                         [[self operationQueue] setSuspended:NO];
                                     }
                                 }
                                failure:^(NSError *error) {
                                    [[self operationQueue] setSuspended:YES];
                                    failure(error);
                                }];
    
    //Suspend the operation queue until the login is successful
    [[self operationQueue] setSuspended:YES];
}

@end
