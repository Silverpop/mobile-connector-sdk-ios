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

#define LOCATION_UPDATED_NOTIFICATION @"LocationUpdated"
#define LOCATION_ACQUIRE_LOCATION_TIMEOUT @"LocationAcquisitionTimeout"
#define LOCATION_PLACEMARK_TIMEOUT @"LocationPlacemarkTimeout";
#define ENGAGE_CONFIG_BUNDLE @"EngageConfigPlist.bundle"

//Plist Constants.
#define PLIST_UBF_LONGITUDE @"UBFLongitudeFieldName"
#define PLIST_UBF_LATITUDE @"UBFLatitudeFieldName"
#define PLIST_UBF_LOCATION_NAME @"UBFLocationNameFieldName"
#define PLIST_UBF_LOCATION_ADDRESS @"UBFLocationAddressFieldName"
#define PLIST_UBF_LAST_CAMPAIGN_NAME @"UBFLastCampaignFieldName"
#define PLIST_UBF_CURRENT_CAMPAIGN_NAME @"UBFCurrentCampaignFieldName"

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
