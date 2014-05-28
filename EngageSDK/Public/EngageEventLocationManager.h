//
//  EngageEventLocationManager.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "EngageConfigManager.h"
#import "EngageConfig.h"

@interface EngageEventLocationManager : NSObject <CLLocationManagerDelegate>

+ (id)sharedInstance;

- (BOOL)locationServicesEnabled;
- (NSDictionary *)addLocationToUBFEvent:(NSDictionary *)ubfEvent;



@end
