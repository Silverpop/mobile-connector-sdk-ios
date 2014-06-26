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
        
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setMaximumFractionDigits:10];
        [numberFormatter setRoundingMode:NSNumberFormatterRoundUp];
        
        NSString *roundedLongitude = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:elm.currentLocationCache.coordinate.longitude]];
        NSString *roundedLatitude = [numberFormatter stringFromNumber:[NSNumber numberWithDouble:elm.currentLocationCache.coordinate.latitude]];
        
        [ubfEvent setAttribute:self.longitudeUBFFieldName value:roundedLongitude];
        [ubfEvent setAttribute:self.latitudeUBFFieldName value:roundedLatitude];
    }
    
    return ubfEvent;
}

@end
