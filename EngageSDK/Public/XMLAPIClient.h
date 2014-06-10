//
//  XMLAPIClient.h
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "EngageClient.h"
#import "XMLAPI.h"
#import "ResultDictionary.h"

@interface XMLAPIClient : EngageClient

+ (instancetype)createClient:(NSString *)clientId
                      secret:(NSString *)secret
                       token:(NSString *)refreshToken
                        host:(NSString *)hostUrl
              connectSuccess:(void (^)(AFOAuthCredential *credential))success
                     failure:(void (^)(NSError *error))failure;


+ (instancetype)client;

- (void)postResource:(XMLAPI *)api
             success:(void (^)(ResultDictionary *ERXML))success
             failure:(void (^)(NSError *error))failure;

@end
