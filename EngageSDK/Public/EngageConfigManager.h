//
//  EngageConfigManager.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/28/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngageConfig.h"

@interface EngageConfigManager : NSObject

+ (instancetype) sharedInstance;

- (BOOL)locationServicesEnabled;
- (NSString *)fieldNameForUBF:(NSString *)ubfFieldConstantName;
- (NSNumber *)configForNetworkValue:(NSString *)networkFieldConstantName;
- (long)longConfigForSessionValue:(NSString *)sessionFieldConstantName;
- (NSString *)fieldNameForParam:(NSString *)paramFieldConstantName;
- (NSString *)configForGeneralFieldName:(NSString *)generalFieldConstantName;
- (NSNumber *)numberConfigForGeneralFieldName:(NSString *)generalFieldConstantName;
- (NSString *)configForLocationFieldName:(NSString *)locationFieldConstantName;
- (NSNumber *)numberConfigForLocalStoreFieldName:(NSString *)localStoreFieldConstantName;
- (NSString *)configForAugmentationServiceFieldName:(NSString *)augmentationServiceFieldConstantName;
- (NSArray *)augmentationPluginClassNames;
- (BOOL)autoAnonymousTrackingEnabled;
- (NSString *) mobileUserIdGeneratorClassName;
- (NSString *) recipientMobileUserIdColumn;
- (NSString *) recipientMergedRecipientIdColumn;
- (NSString *) recipientMergedDateColumn;

@end
