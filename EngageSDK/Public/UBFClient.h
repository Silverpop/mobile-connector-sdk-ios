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

- (NSInteger) eventCacheSize;
- (NSArray *) cachedEvents;

//- (NSURL *) trackingEvent:(NSDictionary *)event;
- (void)trackEngageEvent:(EngageEvent *)engageEvent;
- (void) postEventCache;
- (NSURL *) enqueueEvent:(NSDictionary *)event;

@end
