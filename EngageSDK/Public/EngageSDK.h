//
//  EngageSDK.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/11/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "UBFCoordinatesAugmentationPlugin.h"
#import "UBFAugmentationPluginProtocol.h"
#import "UBFPlacemarkAugmentationPlugin.h"
#import "UBFLocationNameAugmentationPlugin.h"
#import "UBFAugmentationManager.h"
#import "UBFAugmentationOperation.h"
#import "EngageLocalEventStore.h"
#import "EngageClient.h"
#import "UBFClient.h"
#import "XMLAPIClient.h"
#import "EngageDeepLinkManager.h"
#import "UBF.h"
#import "XMLAPI.h"
#import "ResultDictionary.h"
#import "EngageEvent.h"
#import "EngageEventWrapper.h"
#import "EngageExpirationParser.h"
#import "EngageEventLocationManager.h"
#import "EngageConfig.h"
#import "EngageConfigManager.h"
#import "UBFManager.h"
#import "XMLAPIManager.h"
#import "MobileIdentityManager.h"
#import "EngageDefaultUUIDGenerator.h"
#import "EngageUUIDGenerating.h"
#import "EngageDateFormatter.h"
#import "XMLAPIOperation.h"
#import "XMLAPIErrorCode.h"
#import "SetupRecipientResult.h"
#import "SetupRecipientFailure.h"
#import "CheckIdentityResult.h"
#import "CheckIdentityFailure.h"
#import "EngageConnectionManager.h"

@interface EngageSDK : NSObject


+(void) initializeSDKClient:(NSString *)clientId
                     secret:(NSString *)secret
                      token:(NSString *)refreshToken
                       host:(NSString *)host
       engageDatabaseListId:(NSString *)engageListId;

@end
