//
//  EngageConfig.h
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/29/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngageExpirationParser.h"

//Defines NotificaitonCenter event names
#define AUGMENTATION_SUCCESSFUL_EVENT @"AugmentationSuccessfulEvent"
#define AUGMENTATION_EXPIRED_EVENT @"AugmentationExpiredEvent"
#define PRIMARY_USER_ID_SET @"PrimaryUserIdSetEvent"


#define ENGAGE_CONFIG_BUNDLE @"EngageConfigPlist.bundle"

//Plist Param constants.
#define PLIST_PARAM_CURRENT_CAMPAIGN @"ParamCurrentCampaign"
#define PLIST_PARAM_CALL_TO_ACTION @"ParamCallToAction"
#define PLIST_PARAM_CAMPAIGN_EXPIRES_AT @"ParamCampaignExpiresAt"
#define PLIST_PARAM_CAMPAIGN_VALID_FOR @"ParamCampaignValidFor"

//Plist UBF Constants.
#define PLIST_UBF_LONGITUDE @"UBFLongitudeFieldName"
#define PLIST_UBF_LATITUDE @"UBFLatitudeFieldName"
#define PLIST_UBF_LOCATION_NAME @"UBFLocationNameFieldName"
#define PLIST_UBF_LOCATION_ADDRESS @"UBFLocationAddressFieldName"
#define PLIST_UBF_LAST_CAMPAIGN_NAME @"UBFLastCampaignFieldName"
#define PLIST_UBF_CURRENT_CAMPAIGN_NAME @"UBFCurrentCampaignFieldName"
#define PLIST_UBF_GOAL_NAME @"UBFGoalNameFieldName"
#define PLIST_UBF_EVENT_NAME @"UBFEventNameFieldName"
#define PLIST_UBF_CALL_TO_ACTION @"UBFCallToActionFieldName"
#define PLIST_UBF_DISPLAYED_MESSAGE @"UBFDisplayedMessageFieldName"
#define PLIST_UBF_TAGS @"UBFTagsFieldName"
#define PLIST_UBF_SESSION_DURATION @"UBFSessionDurationFieldName"

//Plist Networking constants.
#define PLIST_NETWORK_MAX_NUM_RETRIES @"maxNumRetries"

//Plist Session constants.
#define PLIST_SESSION_LIFECYCLE_EXPIRATION @"sessionLifecycleExpiration"

//Plist General constants.
#define PLIST_GENERAL_DEFAULT_CURRENT_CAMPAIGN_EXPIRATION @"defaultCurrentCampaignExpiration"
#define PLIST_GENERAL_UBF_EVENT_CACHE_SIZE @"ubfEventCacheSize"
//#define PLIST_GENERAL_DATABASE_LIST_ID @"databaseListId"

//Plist Location constants.
#define PLIST_LOCATION_COORDINATES_ACQUISITION_TIMEOUT @"coordinatesAcquisitionTimeout"
#define PLIST_LOCATION_COORDINATES_PLACEMARK_TIMEOUT @"coordinatesPlacemarkTimeout"
#define PLIST_LOCATION_LOCATION_PRECISION_LEVEL @"locationPrecisionLevel"
#define PLIST_LOCATION_LOCATION_CACHE_LIFESPAN @"locationCacheLifespan"
#define PLIST_LOCATION_LOCATION_DISTANCE_FILTER @"locationDistanceFilter"
#define PLIST_LOCATION_LAST_KNOWN_LOCATION @"lastKnownLocationColumn"
#define PLIST_LOCATION_LAST_KNOWN_LOCATION_TIME @"lastKnownLocationTimestampColumn"
#define PLIST_LOCATION_LAST_KNOWN_LOCATION_TIME_FORMAT @"lastKnownLocationDateFormat"

// Plist LocalEventStore constants.
#define PLIST_LOCAL_STORE_EVENTS_EXPIRE_AFTER_DAYS @"expireLocalEventsAfterNumDays"

// Plist Augmentation services.
#define PLIST_AUGMENTATION_SERVICE_TIMEOUT @"augmentationTimeout"

// PList recipient constants
#define PLIST_RECIPIENT_ENABLE_AUTO_ANONYMOUS_TRACKING @"enableAutoAnonymousTracking"
#define PLIST_RECIPIENT_MOBILE_USER_ID_CLASS_NAME @"mobileUserIdGeneratorClassName"
#define PLIST_RECIPIENT_MOBILE_USER_ID_COLUMN @"mobileUserIdColumn"
#define PLIST_RECIPIENT_MERGED_RECIPIENT_ID_COLUMN @"mergedRecipientIdColumn"
#define PLIST_RECIPIENT_MERGED_DATE_COLUMN @"mergedDateColumn"
#define PLIST_RECIPIENT_MERGE_HISTORY_IN_MARKETING_DB @"mergeHistoryInMarketingDatabase"

@interface EngageConfig : NSUserDefaults

+ (NSString *) deviceId;

+ (NSString *)primaryUserId __deprecated_msg("Primary User Id has been renamed to Mobile User Id for clarity");
+ (void)storePrimaryUserId:(NSString *)userId __deprecated_msg("Primary User Id has been renamed to Mobile User Id for clarity");

+ (NSString *)mobileUserId;
+ (void)storeMobileUserId:(NSString *)userId;

+ (NSString *)anonymousId;
+ (void)storeAnonymousId:(NSString *)anonymousId;

+ (NSString *)currentCampaign;
+ (void)storeCurrentCampaign:(NSString *)currentCampaign withExpirationTimestamp:(long)utcExpirationTimestamp;

+ (NSString *)lastCampaign;
+ (void)storeCurrentCampaign:(NSString *)currentCampaign withExpirationTimestampString:(NSString *)expirationTimestamp;

+ (void)storeEngageListId:(NSString *)engageListId;
+ (NSString *)engageListId;

+ (NSString *) recipientId;
+ (void) storeRecipientId:(NSString *)recipientId;

@end
