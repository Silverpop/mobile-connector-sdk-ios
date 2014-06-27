//
//  UBFPlacemarkAugmentationPlugin.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/10/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "UBFPlacemarkAugmentationPlugin.h"
#import "EngageConfig.h"
#import "EngageConfigManager.h"
#import "EngageEventLocationManager.h"

@interface UBFPlacemarkAugmentationPlugin()

@property (nonatomic, strong) NSString *locationAddressUBFFieldName;

@end

@implementation UBFPlacemarkAugmentationPlugin

-(id)init {
    self = [super init];
    if (self) {
        self.locationAddressUBFFieldName = [[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LOCATION_ADDRESS];
    }
    return self;
}

-(BOOL)processSyncronously {
    return YES;
}


-(BOOL)isSupplementalDataReady:(UBF*)ubfEvent {
    EngageEventLocationManager *elm = [EngageEventLocationManager sharedInstance];
    if (elm && ![elm placemarkCacheExpiredOrEmpty]) {
        return YES;
    }
    return NO;
}


-(UBF*)process:(UBF*)ubfEvent {
    if (ubfEvent) {
        EngageEventLocationManager *elm = [EngageEventLocationManager sharedInstance];
        [ubfEvent setAttribute:self.locationAddressUBFFieldName value:[elm currentPlacemarkFormattedAddress]];
    }
    return ubfEvent;
}

@end
