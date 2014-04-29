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
        self.requestSerializer = [AFJSONRequestSerializer serializer];
        NSLog(@"InitWithBaseURL has finished");
        _clientId = clientId;
        _secret = secret;
        _refreshToken = refreshToken;
        
        [[AFNetworkReachabilityManager sharedManager] setReachabilityStatusChangeBlock:^(AFNetworkReachabilityStatus status) {
            NSLog(@"NetworkReachability status has changed! AFNetworkReachabilityManager is reporting a Status of %ld for base url %@", status, [self baseURL]);
            if (status == AFNetworkReachabilityStatusNotReachable) {
                NSLog(@"Suspending HTTP Operations for UBF events since we don't have network access");
                [[self operationQueue] setSuspended:YES];
            } else {
                NSLog(@"Resuming HTTP Operations for UBF as we have regained internet access");
                [[self operationQueue] setSuspended:NO];
            }
        }];
        [[AFNetworkReachabilityManager sharedManager] startMonitoring];
    }
    
    return self;
}

- (void)connectSuccess:(void (^)(AFOAuthCredential *credential))success
               failure:(void (^)(NSError *error))failure {
    NSLog(@"Attempting to perform OAuth2 authentication now");
    [self authenticateUsingOAuthWithURLString:@"https://loginpilot.silverpop.com/oauth/token"
                            refreshToken:_refreshToken
                                 success:^(AFOAuthCredential *credential) {
                                        self.credential = credential;
                                        success(credential);
                                 }
                                failure:failure];
}

@end
