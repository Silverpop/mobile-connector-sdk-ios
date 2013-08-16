//
//  EngageConfig.h
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/29/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EngageConfig : NSUserDefaults

+ (NSString *) deviceId;
+ (NSString *)primaryUserId;
+ (void)storePrimaryUserId:(NSString *)userId;
+ (NSString *)anonymousId;
+ (void)storeAnonymousId:(NSString *)anonymousId;

@end
