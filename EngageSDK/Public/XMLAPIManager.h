//
//  XMLAPIManager.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/9/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngageClient.h"
#import "XMLAPI.h"
#import "ResultDictionary.h"

@interface XMLAPIManager : NSObject

+ (instancetype)createClient:(NSString *)clientId
                      secret:(NSString *)secret
                       token:(NSString *)refreshToken
                        host:(NSString *)hostUrl
              connectSuccess:(void (^)(AFOAuthCredential *credential))success
                     failure:(void (^)(NSError *error))failure;

+ (id)sharedInstance;

- (void)postXMLAPI:(XMLAPI *)xmlapi;
- (void)postXMLAPI:(XMLAPI *)xmlapi
             success:(void (^)(ResultDictionary *ERXML))success
             failure:(void (^)(NSError *error))failure;


- (void)createAnonymousUserToList:(NSString *)listId
                          success:(void (^)(ResultDictionary *ERXML))success
                          failure:(void (^)(NSError *error))failure;

- (void)updateAnonymousToPrimaryUser:(NSString *)userId
                                list:(NSString *)listId
                   primaryUserColumn:(NSString *)primaryUserColumn
                         mergeColumn:(NSString *)mergeColumn
                             success:(void (^)(ResultDictionary *ERXML))success
                             failure:(void (^)(NSError *error))failure;

@end
