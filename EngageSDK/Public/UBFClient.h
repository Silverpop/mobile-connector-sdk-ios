//
//  UBFClient.h
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "EngageClient.h"
#import <MobileDeepLinking-iOS/MobileDeepLinking.h>

@interface UBFClient : EngageClient

+ (instancetype)createClient:(NSString *)clientId
                      secret:(NSString *)secret
                       token:(NSString *)refreshToken
                        host:(NSString *)hostUrl
              connectSuccess:(void (^)(AFOAuthCredential *credential))success
                     failure:(void (^)(NSError *error))failure;

+ (instancetype)client;

- (void)trackingEvent:(NSDictionary *)event;
- (void)postEventCache;
- (void)enqueueEvent:(NSDictionary *)event;

- (void)routeUsingUrl:(NSURL *)url;
- (void) addHandlersDictionaryToMobileDeepLinking:(NSDictionary *)handlers;

- (void) receivedLocalNotification:(UILocalNotification *)localNotification;
- (void) receivedPushNotification:(NSDictionary *)params;
- (void) openedNotification:(NSDictionary *)params;

@end
