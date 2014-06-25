//
//  UBFLocationNameAugmentationPlugin.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/25/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "UBFLocationNameAugmentationPlugin.h"
#import "EngageConfig.h"
#import "EngageConfigManager.h"
#import "EngageEventLocationManager.h"

@interface UBFLocationNameAugmentationPlugin()

@property (nonatomic, strong) NSString *locationNameUBFFieldName;

@end

@implementation UBFLocationNameAugmentationPlugin

-(id)init {
    self = [super init];
    if (self) {
        self.locationNameUBFFieldName = [[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LOCATION_NAME];
    }
    return self;
}

-(BOOL)processSyncronously {
    return NO;
}


-(BOOL)isSupplementalDataReady {
    EngageEventLocationManager *elm = [EngageEventLocationManager sharedInstance];
    if (elm && ![elm placemarkCacheExpired]) {
        return YES;
    }
    return NO;
}


-(UBF*)process:(UBF*)ubfEvent {
    //If the user has not already specified the Location Name then pull that information from the Placemark cache.
    if (ubfEvent && ![ubfEvent.attributes objectForKey:self.locationNameUBFFieldName]) {
        EngageEventLocationManager *elm = [EngageEventLocationManager sharedInstance];
        [ubfEvent setAttribute:self.locationNameUBFFieldName value:elm.currentPlacemarkCache.name];
    }
    return ubfEvent;
}

@end
