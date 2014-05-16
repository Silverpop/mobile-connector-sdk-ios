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

@property NSString *clientId, *secret, *refreshToken;

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
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            if (status == AFNetworkReachabilityStatusNotReachable) {
                [[self operationQueue] setSuspended:YES];
            } else {
                [[self operationQueue] setSuspended:NO];
            }
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    
    return self;
}

- (void)connectSuccess:(void (^)(AFOAuthCredential *credential))success
               failure:(void (^)(NSError *error))failure {
    [self authenticateUsingOAuthWithURLString:@"/oauth/token"
                            refreshToken:_refreshToken
                                 success:^(AFOAuthCredential *credential) {
                                        self.credential = credential;
                                        success(credential);
                                 }
                                failure:failure];
}

@end
