//
//  MobileIdentityManager.h
//  EngageSDK
//
//  Created by andrew zuercher on 1/19/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//
#import "AFOAuth2Client.h"

#import <Foundation/Foundation.h>

@interface EngageConnectionManager : AFOAuth2Client

+ (EngageConnectionManager*)sharedInstance;
+ (EngageConnectionManager*)createInstanceWithHost:(NSString *)host
          clientId:(NSString *)clientId
            secret:(NSString *)secret
             token:(NSString *)refreshToken;

- (BOOL)isAuthenticated;

- (void)authenticate:(void (^)(AFOAuthCredential *credential))success
             failure:(void (^)(NSError *error))failure;

- (id)initWithHost:(NSString *)host
          clientId:(NSString *)clientId
            secret:(NSString *)secret
             token:(NSString *)refreshToken;

- (void)postJsonRequest:(NSString *)URLString
         parameters:(id)parameters
            success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
            failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

- (void)postXmlRequest:(NSString *)URLString
            parameters:(id)parameters
               success:(void (^)(AFHTTPRequestOperation *operation, id responseObject))success
               failure:(void (^)(AFHTTPRequestOperation *operation, NSError *error))failure;

@property AFOAuthCredential *credential;

@end
