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

@property (strong, nonatomic) NSDate *currentLocationCacheBirthday;
@property (strong, nonatomic) CLLocation *currentLocationCache;
@property (strong, nonatomic) CLPlacemark *currentPlacemarkCache;
@property (strong, nonatomic) NSDate *currentPlacemarkBirthday;
@property (strong, nonatomic) NSDate *currentPlacemarkExpirationDate;
@property (strong, nonatomic) CLLocation *locationUsedToDeterminePlacemark;

+ (id)sharedInstance;

- (BOOL)locationServicesEnabled;
- (BOOL) placemarkCacheExpiredOrEmpty;
- (NSString *) currentPlacemarkFormattedAddress;

@end
