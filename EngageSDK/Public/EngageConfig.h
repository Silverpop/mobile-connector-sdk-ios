//
//  EngageConfig.h
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/29/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifndef CURRENT_CAMPAIGN_PARAM_NAME
    #define CURRENT_CAMPAIGN_PARAM_NAME @"CurrentCampaign"
#endif

#ifndef CALL_TO_ACTION_PARAM_NAME
    #define CALL_TO_ACTION_PARAM_NAME @"CallToAction"
#endif

#ifndef CAMPAIGN_EXTERNAL_EXPIRATION_DATETIME_PARAM
    #define CAMPAIGN_EXTERNAL_EXPIRATION_DATETIME_PARAM @"CampaignEndTimeStamp"
#endif

@interface EngageConfig : NSUserDefaults

+ (NSString *) deviceId;
+ (NSString *)primaryUserId;
+ (void)storePrimaryUserId:(NSString *)userId;
+ (NSString *)anonymousId;
+ (void)storeAnonymousId:(NSString *)anonymousId;
+ (NSString *)currentCampaign;
+ (NSString *)lastCampaign;
+ (void)storeCurrentCampaign:(NSString *)currentCampaign withExpirationTimestamp:(NSString *)expirationTimestamp;

@end
