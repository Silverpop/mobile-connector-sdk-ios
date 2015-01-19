//
//  EngageClient.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "EngageClient.h"
#import "MobileIdentityManager.h"

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
- (AFOAuthCredential*)credential {
    return [MobileIdentityManager sharedInstance].credential;
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
        [MobileIdentityManager createInstanceWithHost:host clientId:clientId secret: secret token:refreshToken];
        
//        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
//            AFOAuthCredential *credential = [self credential];
//            if (status == AFNetworkReachabilityStatusNotReachable || credential == nil || [credential isExpired]) {
//                [[self operationQueue] setSuspended:YES];
//            } else {
//                [[self operationQueue] setSuspended:NO];
//            }
//        }];
//        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    return self;
}

- (BOOL)isAuthenticated {
    return [[MobileIdentityManager sharedInstance] isAuthenticated];
}

- (void)authenticate:(void (^)(AFOAuthCredential *credential))success
               failure:(void (^)(NSError *error))failure {
    return [[MobileIdentityManager sharedInstance] authenticate: success failure: failure];
}

@end
