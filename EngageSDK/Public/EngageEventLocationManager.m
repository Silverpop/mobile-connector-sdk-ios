//
//  EngageEventLocationManager.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "EngageEventLocationManager.h"

@interface EngageEventLocationManager ()

@property (strong, nonatomic) CLLocationManager *locManager;
@property (strong, nonatomic) CLGeocoder *geoCoder;
@property (assign) BOOL locationServicesSupported;

//Location Cache
@property (strong, nonatomic) NSDate *currentLocationCacheBirthday;
@property (strong, nonatomic) CLLocation *currentLocationCache;
@property (strong, nonatomic) CLPlacemark *currentPlacemarkCache;
@property (strong, nonatomic) NSDate *currentPlacemarkBirthday;
@property (strong, nonatomic) CLLocation *locationUsedToDeterminePlacemark;     //Helps ensure we only update the CLPlacemark if the CLLocation has changed.

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
            self.locManager.desiredAccuracy = kCLLocationAccuracyBest;
            self.locManager.distanceFilter = 1;
            
            [self.locManager startUpdatingLocation];
            [self.locManager startMonitoringSignificantLocationChanges];
            
            self.locationServicesSupported = YES;
        } else {
            //Location services are not enabled
            self.locationServicesSupported = NO;
            NSLog(@"LocationServices are not enabled!");
        }
    }
    return self;
}

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static EngageEventLocationManager *sharedInstance = nil;
    
    dispatch_once(&pred, ^{
        sharedInstance = [[EngageEventLocationManager alloc] init];
    });
    
    return sharedInstance;
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
    
    self.currentLocationCache = [locations lastObject];
    self.currentLocationCacheBirthday = [NSDate date];
    NSLog(@"Longitude %f & Latitude %f", [self.currentLocationCache coordinate].longitude, [self.currentLocationCache coordinate].latitude);
    
    if (self.currentPlacemarkCache == nil || [self placemarkCacheExpired]) {
        NSLog(@"Geocoding Location");
        [self.geoCoder reverseGeocodeLocation:self.currentLocationCache completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"Silverpop Engage Geocode failed with error: %@", [error description]);
                return;
            }
            
            if ([placemarks count] > 0) {
                self.currentPlacemarkCache = [placemarks objectAtIndex:0];
                self.currentPlacemarkBirthday = [NSDate date];
                
                //Send a system wide NSNotificationCenter message notifing interested parties that the CLPlacemark has been determined.
                [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_UPDATED_NOTIFICATION object:nil];
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
    BOOL update = NO;
    
    
    
    return update;
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to gather location %@", [error description]);
}


/** Add the location information to the UBF event. If the location information is not yet ready the information is queued locally
 and nil is returned. Once the location information has been obtained (or a timeout has been reached then a NSNotificationCenter message
 will be fired to update the event and then post it to Silverpop. 
*/
- (NSDictionary *)addLocationToUBFEvent:(NSDictionary *)ubfEvent {
    if (self.currentLocationCache == nil) {
        //If the current CLLocation coordinates are null then we need to give up trying and allow the UBF events to continue on to Silverpop after the expiration time is reached.
        
        //Get the expiration time in seconds.
        int expirationSeconds = 15;
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, expirationSeconds * NSEC_PER_SEC), queue, ^{
            
            //Send a system wide NSNotificationCenter message letting the application know that this UBF event should be sent without the notification information.
            [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_ACQUIRE_LOCATION_TIMEOUT object:nil];
        });
    } else {
        if (self.currentPlacemarkCache == nil || ![self placemarkCacheExpired]) {
            
//            //Place a timeout value on how long it takes from the placemark to be acquired. If that expires then fire an event to post the UBF anyway.
//            //Get the expiration time in seconds.
//            int expirationSeconds = 15;
//            dispatch_queue_t placemarkQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
//            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, expirationSeconds * NSEC_PER_SEC), placemarkQueue, ^{
//                [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_PLACEMARK_TIMEOUT object:nil userInfo:nil];
//            });
            
            return nil;
        } else {
            NSMutableDictionary *event = [ubfEvent mutableCopy];
            EngageConfigManager *cm = [EngageConfigManager sharedInstance];
            
            //Sets the Longitude and Latitude
            if (self.currentLocationCache) {
                if (![event objectForKey:[cm fieldNameForUBF:PLIST_UBF_LONGITUDE]]) {
                    [event setValue:[NSString stringWithFormat:@"%f", [self.currentLocationCache coordinate].longitude] forKey:[cm fieldNameForUBF:PLIST_UBF_LONGITUDE]];
                }
                
                if (![event objectForKey:[cm fieldNameForUBF:PLIST_UBF_LATITUDE]]) {
                    [event setValue:[NSString stringWithFormat:@"%f", [self.currentLocationCache coordinate].latitude] forKey:[cm fieldNameForUBF:PLIST_UBF_LATITUDE]];
                }
                
            }
            
            //Sets the location name and address.
            if (self.currentPlacemarkCache) {
                
                if (![event objectForKey:[cm fieldNameForUBF:PLIST_UBF_LOCATION_NAME]]) {
                    [event setValue:[NSString stringWithFormat:@"%@", [[self.currentPlacemarkCache addressDictionary] objectForKey:@"Name"]] forKey:[cm fieldNameForUBF:PLIST_UBF_LOCATION_NAME]];
                }
                
                if (![event objectForKey:[cm fieldNameForUBF:PLIST_UBF_LOCATION_ADDRESS]]) {
                    [event setValue:[NSString stringWithFormat:@"%@, %@ %@", [[self.currentPlacemarkCache addressDictionary] objectForKey:@"City"], [[self.currentPlacemarkCache addressDictionary] objectForKey:@"State"], [[self.currentPlacemarkCache addressDictionary] objectForKey:@"ZIP"]] forKey:[cm fieldNameForUBF:PLIST_UBF_LOCATION_ADDRESS]];
                }
            }
            
            return event;
        }
    }
}

@end
