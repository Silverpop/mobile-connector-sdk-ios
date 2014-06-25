//
//  UBFCoordinatesAugmentationPlugin.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/10/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "UBFCoordinatesAugmentationPlugin.h"
#import "EngageConfig.h"
#import "EngageConfigManager.h"
#import "EngageEventLocationManager.h"

@interface UBFCoordinatesAugmentationPlugin()

@property (nonatomic, strong) NSString *longitudeUBFFieldName;
@property (nonatomic, strong) NSString *latitudeUBFFieldName;

@end

@implementation UBFCoordinatesAugmentationPlugin

-(id)init {
    self = [super init];
    if (self) {
        self.longitudeUBFFieldName = [[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LONGITUDE];
        self.latitudeUBFFieldName = [[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LATITUDE];
    }
    return self;
}

-(BOOL)processSyncronously {
    return YES;
}

-(BOOL)isSupplementalDataReady {
    EngageEventLocationManager *elm = [EngageEventLocationManager sharedInstance];
    if (elm && elm.currentLocationCache) {
        return YES;
    } else {
        return NO;
    }
}

-(UBF*)process:(UBF*)ubfEvent {
    
    if (ubfEvent && self.longitudeUBFFieldName && self.latitudeUBFFieldName) {
        EngageEventLocationManager *elm = [EngageEventLocationManager sharedInstance];
        [ubfEvent setAttribute:self.longitudeUBFFieldName value:[[NSNumber numberWithDouble:elm.currentLocationCache.coordinate.longitude] stringValue]];
        [ubfEvent setAttribute:self.latitudeUBFFieldName value:[[NSNumber numberWithDouble:elm.currentLocationCache.coordinate.latitude] stringValue]];
    }
    
    return ubfEvent;
}

@end
