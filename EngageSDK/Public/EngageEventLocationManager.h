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
#import "EngageEvent.h"
#import "UBF.h"

@interface EngageEventLocationManager : NSObject <CLLocationManagerDelegate>

+ (id)sharedInstance;

- (BOOL)locationServicesEnabled;
- (UBF *)addLocationToUBFEvent:(UBF *)ubfEvent withEngageEvent:(EngageEvent *)engageEvent;



@end
