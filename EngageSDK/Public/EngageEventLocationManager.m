//
//  EngageEventLocationManager.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "EngageEventLocationManager.h"
#import "EngageExpirationParser.h"
#import "EngageEventWrapper.h"
#import "XMLAPIClient.h"

@interface EngageEventLocationManager ()

@property (strong, nonatomic) CLLocationManager *locManager;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (assign) BOOL locationServicesSupported;

@end

@implementation EngageEventLocationManager


- (id) init {
    self = [super init];
    if (self) {
        
        //Checks if Location services are enabled.
        if ([CLLocationManager locationServicesEnabled]) {
            //Startup the Location Services.
            self.locManager = [[CLLocationManager alloc] init];
            self.geoCoder = [[CLGeocoder alloc] init];
            
            //Sets the Delegate to this class.
            self.locManager.delegate = self;
            
            NSString *locAcc = [[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_LOCATION_PRECISION_LEVEL];
            if([locAcc caseInsensitiveCompare:@"kCLLocationAccuracyBestForNavigation"] == NSOrderedSame ) {
                self.locManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
            } else if ([locAcc caseInsensitiveCompare:@"kCLLocationAccuracyBest"] == NSOrderedSame) {
                self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
            } else if ([locAcc caseInsensitiveCompare:@"kCLLocationAccuracyNearestTenMeters"] == NSOrderedSame) {
                self.locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            } else if ([locAcc caseInsensitiveCompare:@"kCLLocationAccuracyHundredMeters"] == NSOrderedSame) {
                self.locManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
            } else if ([locAcc caseInsensitiveCompare:@"kCLLocationAccuracyKilometer"] == NSOrderedSame) {
                self.locManager.desiredAccuracy = kCLLocationAccuracyKilometer;
            } else if ([locAcc caseInsensitiveCompare:@"kCLLocationAccuracyThreeKilometers"] == NSOrderedSame) {
                self.locManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
            } else {
                //Default to some value since there must be a typo in the configuration.
                NSLog(@"No match for GPS precision configuration %@. Defaulting to GPS Accuracy mode of kCLLocationAccuracyNearestTenMeters", locAcc);
                self.locManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
            }
            
            self.locManager.distanceFilter = [[[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_LOCATION_DISTANCE_FILTER] doubleValue];
            
            //[self.locManager startUpdatingLocation];
            [self.locManager startMonitoringSignificantLocationChanges]; //Only delivers location events for things like cell tower change MUCH lower power use.
            
            self.locationServicesSupported = YES;
        } else {
            //Location services are not enabled
            self.locationServicesSupported = NO;
            NSLog(@"LocationServices are not enabled!");
        }
    }
    return self;
}

__strong static EngageEventLocationManager *_sharedInstance = nil;

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    
    dispatch_once(&pred, ^{
        _sharedInstance = [[EngageEventLocationManager alloc] init];
    });
    
    return _sharedInstance;
}


- (BOOL)locationServicesEnabled {
    if ([[EngageConfigManager sharedInstance] locationServicesEnabled] && self.locationServicesSupported) {
        return YES;
    } else {
        return NO;
    }
}


- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    
    _sharedInstance.currentLocationCache = [locations lastObject];
    _sharedInstance.currentLocationCacheBirthday = [NSDate date];
    NSLog(@"Longitude %f & Latitude %f", [_sharedInstance.currentLocationCache coordinate].longitude, [_sharedInstance.currentLocationCache coordinate].latitude);
    
    if (_sharedInstance.currentPlacemarkCache == nil || [_sharedInstance placemarkCacheExpired]) {
        [_sharedInstance.geoCoder reverseGeocodeLocation:_sharedInstance.currentLocationCache completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"Silverpop Engage Geocode failed with error: %@", [error description]);
                return;
            }
            
            if ([placemarks count] > 0) {
                _sharedInstance.currentPlacemarkCache = [placemarks objectAtIndex:0];
                _sharedInstance.currentPlacemarkBirthday = [NSDate date];
                NSString *locAcqTimeout = [[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_LOCATION_CACHE_LIFESPAN];
                EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:locAcqTimeout fromDate:_sharedInstance.currentPlacemarkBirthday];
                _sharedInstance.currentPlacemarkExpirationDate = [exp expirationDate];
                
                NSLog(@"Geo Location : %@", _sharedInstance.currentPlacemarkCache);
                
                if ([EngageConfig primaryUserId]) {
                    NSString *listId = [EngageConfig engageListId];
                    XMLAPIClient *client = [XMLAPIClient client];
                    XMLAPI *updateUserKnownLocation = [XMLAPI updateUserLastKnownLocation:_sharedInstance.currentPlacemarkCache listId:listId];
                    [client postResource:updateUserKnownLocation success:^(ResultDictionary *ERXML) {
                        NSLog(@"Updated user last known location to %@", _sharedInstance.currentPlacemarkCache);
                    } failure:nil];
                }
            }
        }];
    } else {
        NSLog(@"Using cached Placemark location");
    }
}

/*
 Determines if the placemark cache is valid or not
 */
- (BOOL) placemarkCacheExpired {
    BOOL expired = NO;
    
    if (_sharedInstance.currentPlacemarkBirthday != nil) {
        if (_sharedInstance.currentPlacemarkExpirationDate == nil) {
            NSString *locAcqTimeout = [[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_LOCATION_CACHE_LIFESPAN];
            EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:locAcqTimeout fromDate:_sharedInstance.currentPlacemarkBirthday];
            _sharedInstance.currentPlacemarkExpirationDate = [exp expirationDate];
        }
        
        if ([[NSDate date] compare:_sharedInstance.currentPlacemarkExpirationDate] == NSOrderedDescending) {
            expired = YES;
            _sharedInstance.currentPlacemarkCache = nil;
            _sharedInstance.currentPlacemarkBirthday = nil;
            _sharedInstance.currentPlacemarkExpirationDate = nil;
        }
    }
    
    return expired;
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to gather location %@", [error description]);
}

- (NSString *) currentPlacemarkFormattedAddress {
    if (_sharedInstance.currentPlacemarkCache) {
        NSString *add = [NSString stringWithFormat:@"%@, %@ %@, %@ (%@)", [[_sharedInstance.currentPlacemarkCache addressDictionary] objectForKey:@"City"], [[_sharedInstance.currentPlacemarkCache addressDictionary] objectForKey:@"State"], [[_sharedInstance.currentPlacemarkCache addressDictionary] objectForKey:@"ZIP"], [[_sharedInstance.currentPlacemarkCache addressDictionary] objectForKey:@"Country"], [[_sharedInstance.currentPlacemarkCache addressDictionary] objectForKey:@"CountryCode"]];
        return add;
    } else {
        return @"";
    }
}

@end
