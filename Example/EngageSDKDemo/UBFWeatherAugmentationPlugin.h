//
//  UBFWeatherAugmentationPlugin.h
//  EngageSDKDemo
//
//  Created by Jeremy Dyer on 6/27/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UBFAugmentationPluginProtocol.h"

#define WEATHER_DATA_AVAILABLE_NOTIFICATION @"WEATHER_DATA_AVAILABLE"
#define HOT_WEATHER @"HotterThan80Fahrenheit"

@interface UBFWeatherAugmentationPlugin : NSObject <UBFAugmentationPluginProtocol>

@end