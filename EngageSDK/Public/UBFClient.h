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
                        host:(NSString *)hostUrl;

+ (instancetype)client;

- (void)trackingEvent:(NSDictionary *)event;
- (void)postEventCache;
- (void)enqueueEvent:(NSDictionary *)event;

- (void)routeUsingUrl:(NSURL *)url;

@end
