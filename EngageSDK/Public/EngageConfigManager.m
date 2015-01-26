//
//  EngageConfigManager.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/28/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngageConfigManager.h"
#import "EngageConfig.h"

@interface EngageConfigManager ()

@property (strong, nonatomic) NSDictionary *configs;

@end

@implementation EngageConfigManager

NSString *const LOCATION_SERVICES_GROUP = @"LocationServices";
NSString *const UBF_FIELD_NAMES_GROUP = @"UBFFieldNames";
NSString *const NETWORKING_GROUP = @"Networking";
NSString *const SESSION_GROUP = @"Session";
NSString *const PARAM_FIELD_NAMES_GROUP = @"ParamFieldNames";
NSString *const GENERAL_GROUP = @"General";
NSString *const LOCAL_EVENT_STORE_GROUP = @"LocalEventStore";
NSString *const AUGMENTATION_GROUP = @"Augmentation";
NSString *const RECIPIENT_GROUP = @"Recipient";

- (id) init {
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EngageConfigDefaults" ofType:@"plist" inDirectory:ENGAGE_CONFIG_BUNDLE];
        if (path == nil) {
            path  = [[NSBundle mainBundle] pathForResource:@"EngageConfigDefaults" ofType:@"plist"];
            if (path == nil) {
                NSBundle *unitTestBundle = [NSBundle bundleForClass:[self class]];
                path = [unitTestBundle pathForResource:@"EngageConfigDefaults" ofType:@"plist"];
            }
        }
        
        if (path) {
            self.configs = [[NSDictionary alloc] initWithContentsOfFile:path];
            NSLog(@"EngageSDK - %lu SDK defaults loaded from EngageConfigDefaults.plist file at path %@", (unsigned long)[self.configs count], path);
        } else {
            [NSException raise:@"Invalid EngageSDK configuration" format:@"Unable to locate required EngageConfigDefaults.plist default configuration file!"];
        }
        
        //Looks for a SDK user defined plist file as well and merges those into the
        //existing configurations with the SDK defined configs taking precedence
        NSString *sdkPath = [[NSBundle mainBundle] pathForResource:@"EngageConfig" ofType:@"plist"];
        if (sdkPath) {
            NSDictionary *userConfigs = [[NSDictionary alloc] initWithContentsOfFile:sdkPath];
            if (userConfigs) {
                NSMutableDictionary *engageConfigs;
                if (self.configs) {
                    engageConfigs = [self.configs mutableCopy];
                } else {
                    engageConfigs = [[NSMutableDictionary alloc] init];
                }
                
                [engageConfigs addEntriesFromDictionary:userConfigs];
                self.configs = engageConfigs;
                
                NSLog(@"EngageSDK - EngageConfig.plist configurations loaded and merged with precedence over EngageConfigDefaults.plist values");
                NSLog(@"%@", self.configs);
            }
        } else {
            NSLog(@"EngageSDK - No user defined EngageConfig.plist file found in main bundle EngageSDK defaults will be used.");
        }
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t p = 0;
    
    __strong static EngageConfigManager *_configManager = nil;
    
    dispatch_once(&p, ^{
        _configManager = [[self alloc] init];
    });
    
    return _configManager;
}

// private
- propertyConfig:(NSString *)groupName :(NSString *) property {
    return [[self plistConfigGroup:groupName] objectForKey:property];
}

// private
- plistConfigGroup:(NSString *)key {
    return [self.configs objectForKey:key];
}

- (BOOL)locationServicesEnabled {
    return (BOOL)[self propertyConfig:LOCATION_SERVICES_GROUP :@"enabled"];
}

- (NSString *)fieldNameForUBF:(NSString *)ubfFieldConstantName {
    return (NSString *)[self propertyConfig:UBF_FIELD_NAMES_GROUP :ubfFieldConstantName];
}

- (NSNumber *)configForNetworkValue:(NSString *)networkFieldConstantName {
    return (NSNumber *)[self propertyConfig:NETWORKING_GROUP :networkFieldConstantName];
}

- (long)longConfigForSessionValue:(NSString *)sessionFieldConstantName {
    return (long)[self propertyConfig:SESSION_GROUP :sessionFieldConstantName];
}

- (NSString *)fieldNameForParam:(NSString *)paramFieldConstantName {
    return (NSString *)[self propertyConfig:PARAM_FIELD_NAMES_GROUP :paramFieldConstantName];
}

- (NSString *)configForGeneralFieldName:(NSString *)generalFieldConstantName {
    return (NSString *)[self propertyConfig:GENERAL_GROUP :generalFieldConstantName];
}

- (NSNumber *)numberConfigForGeneralFieldName:(NSString *)generalFieldConstantName {
    return (NSNumber *)[self propertyConfig:GENERAL_GROUP :generalFieldConstantName];
}

- (NSString *)configForLocationFieldName:(NSString *)locationFieldConstantName {
    return (NSString *)[self propertyConfig:LOCATION_SERVICES_GROUP :locationFieldConstantName];
}

- (NSNumber *)numberConfigForLocalStoreFieldName:(NSString *)localStoreFieldConstantName {
    return (NSNumber *)[self propertyConfig:LOCAL_EVENT_STORE_GROUP :localStoreFieldConstantName];
}

- (NSString *)configForAugmentationServiceFieldName:(NSString *)augmentationServiceFieldConstantName {
    return (NSString *)[self propertyConfig:AUGMENTATION_GROUP :augmentationServiceFieldConstantName];
}

- (NSArray *)augmentationPluginClassNames {
    return (NSArray *) [self propertyConfig:AUGMENTATION_GROUP:@"augmentationPluginClasses"];
}

- (BOOL)autoAnonymousTrackingEnabled {
    return (BOOL)[self propertyConfig:RECIPIENT_GROUP :PLIST_RECIPIENT_ENGALE_AUTO_ANONYMOUS_TRACKING];
}

- (NSString *) mobileUserIdGeneratorClassName {
    return (NSString *) [self propertyConfig:RECIPIENT_GROUP :PLIST_RECIPIENT_MOBILE_USER_ID_CLASS_NAME];
}

- (NSString *) recipientMobileUserIdColumn {
    return (NSString *) [self propertyConfig:RECIPIENT_GROUP :PLIST_RECIPIENT_MOBILE_USER_ID_COLUMN];
}

- (NSString *) recipientMergedRecipientIdColumn {
    return (NSString *) [self propertyConfig:RECIPIENT_GROUP :PLIST_RECIPIENT_MERGED_RECIPIENT_ID_COLUMN];
}

- (NSString *) recipientMergedDateColumn {
    return (NSString *) [self propertyConfig:RECIPIENT_GROUP :PLIST_RECIPIENT_MERGED_DATE_COLUMN];
}

@end
