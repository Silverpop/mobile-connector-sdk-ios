//
//  EngageClient.h
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "AFOAuth2Client.h"
#import "EngageLocalEventStore.h"

typedef enum {
    EngagePilot,
    EngagePilotSecure,
    EngageLiveSecure,
} EngageHostConfig;

@interface EngageClient : AFOAuth2Client

- (id)initWithHost:(NSString *)host
          clientId:(NSString *)clientId
            secret:(NSString *)secret
             token:(NSString *)refreshToken;

- (BOOL)isAuthenticated;
- (AFOAuthCredential*)credential;

- (void)authenticate:(void (^)(AFOAuthCredential *credential))success
               failure:(void (^)(NSError *error))failure;

//@property AFOAuthCredential *credential;

@end
