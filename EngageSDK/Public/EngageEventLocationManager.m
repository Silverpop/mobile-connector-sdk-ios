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

//Location Cache
@property (strong, nonatomic) NSDate *currentLocationCacheBirthday;
@property (strong, nonatomic) CLLocation *currentLocationCache;
@property (strong, nonatomic) CLPlacemark *currentPlacemarkCache;
@property (strong, nonatomic) NSDate *currentPlacemarkBirthday;
@property (strong, nonatomic) NSDate *currentPlacemarkExpirationDate;
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
        [self.geoCoder reverseGeocodeLocation:self.currentLocationCache completionHandler:^(NSArray *placemarks, NSError *error) {
            if (error) {
                NSLog(@"Silverpop Engage Geocode failed with error: %@", [error description]);
                return;
            }
            
            if ([placemarks count] > 0) {
                self.currentPlacemarkCache = [placemarks objectAtIndex:0];
                self.currentPlacemarkBirthday = [NSDate date];
                NSString *locAcqTimeout = [[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_LOCATION_CACHE_LIFESPAN];
                EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:locAcqTimeout fromDate:self.currentPlacemarkBirthday];
                self.currentPlacemarkExpirationDate = [exp expirationDate];
                
                NSLog(@"Geo Location : %@", self.currentPlacemarkCache);
                
                //Send a system wide NSNotificationCenter message notifing interested parties that the CLPlacemark has been determined.
                [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_UPDATED_NOTIFICATION object:nil];
                
                NSString *listId = [[EngageConfigManager sharedInstance] configForGeneralFieldName:PLIST_GENERAL_DATABASE_LIST_ID];
                XMLAPIClient *client = [XMLAPIClient client];
                XMLAPI *updateUserKnownLocation = [XMLAPI updateUserLastKnownLocation:self.currentPlacemarkCache listId:listId];
                [client postResource:updateUserKnownLocation success:^(ResultDictionary *ERXML) {
                    NSLog(@"Updated user last known location to %@", self.currentPlacemarkCache);
                } failure:nil];
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
    
    if (self.currentPlacemarkBirthday != nil) {
        if (self.currentPlacemarkExpirationDate == nil) {
            NSString *locAcqTimeout = [[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_LOCATION_CACHE_LIFESPAN];
            EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:locAcqTimeout fromDate:self.currentPlacemarkBirthday];
            self.currentPlacemarkExpirationDate = [exp expirationDate];
        }
        
        if ([[NSDate date] compare:self.currentPlacemarkExpirationDate] == NSOrderedDescending) {
            expired = YES;
            self.currentPlacemarkCache = nil;
            self.currentPlacemarkBirthday = nil;
            self.currentPlacemarkExpirationDate = nil;
        }
    }
    
    return expired;
}

-(void)locationManager:(CLLocationManager *)manager
      didFailWithError:(NSError *)error {
    
    NSLog(@"Failed to gather location %@", [error description]);
}


/** Add the location information to the UBF event. If the location information is not yet ready the information is queued locally
 and nil is returned. Once the location information has been obtained (or a timeout has been reached then a NSNotificationCenter message
 will be fired to update the event and then post it to Silverpop. 
*/
- (UBF *)addLocationToUBFEvent:(UBF *)ubfEvent
                        withEngageEvent:(EngageEvent *)engageEvent {
    
    if (self.currentLocationCache == nil) {
        //If the current CLLocation coordinates are null then we need to give up trying and allow the UBF events to continue on to Silverpop after the expiration time is reached.
        
        //Get the expiration time in seconds.
        NSString *locAcqTimeout = [[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_COORDINATES_ACQUISITION_TIMEOUT];
        EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:locAcqTimeout fromDate:[NSDate date]];
        long expirationSeconds = [exp secondsParsedFromExpiration];
        
        dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, expirationSeconds * NSEC_PER_SEC), queue, ^{
            
            //Make sure that the coordinates have not been acquired since this event was scheduled.
            if (self.currentLocationCache == nil) {
                EngageEventWrapper *eventWrapper = [[EngageEventWrapper alloc] initWithUBFEvent:ubfEvent engageEvent:engageEvent];
                [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_ACQUIRE_LOCATION_TIMEOUT object:eventWrapper];
            }
        });
        
        return nil;
    } else {
        if (self.currentPlacemarkCache == nil || [self placemarkCacheExpired]) {
            
            //Place a timeout value on how long it takes from the placemark to be acquired. If that expires then fire an event to post the UBF anyway.
            //Get the expiration time in seconds.
            NSString *locAcqTimeout = [[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_COORDINATES_PLACEMARK_TIMEOUT];
            EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:locAcqTimeout fromDate:[NSDate date]];
            long expirationSeconds = [exp secondsParsedFromExpiration];
            
            dispatch_queue_t placemarkQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, expirationSeconds * NSEC_PER_SEC), placemarkQueue, ^{
                //Make sure that the placemark hasn't been acquired since the expiration timer was set for this block.
                if (self.currentPlacemarkCache == nil || [self placemarkCacheExpired]) {
                    EngageEventWrapper *eventWrapper = [[EngageEventWrapper alloc] initWithUBFEvent:ubfEvent engageEvent:engageEvent];
                    [[NSNotificationCenter defaultCenter] postNotificationName:LOCATION_PLACEMARK_TIMEOUT object:eventWrapper];
                }
            });
            
            return nil;
        } else {
            EngageConfigManager *cm = [EngageConfigManager sharedInstance];
            
            //Sets the Longitude and Latitude
            if (self.currentLocationCache) {
                if (![[ubfEvent attributes] objectForKey:[cm fieldNameForUBF:PLIST_UBF_LONGITUDE]]) {
                    [ubfEvent setAttribute:[cm fieldNameForUBF:PLIST_UBF_LONGITUDE] value:[NSString stringWithFormat:@"%f", [self.currentLocationCache coordinate].longitude]];
                }
                
                if (![[ubfEvent attributes] objectForKey:[cm fieldNameForUBF:PLIST_UBF_LATITUDE]]) {
                    [ubfEvent setAttribute:[cm fieldNameForUBF:PLIST_UBF_LATITUDE] value:[NSString stringWithFormat:@"%f", [self.currentLocationCache coordinate].latitude]];
                }
                
            }
            
            //Sets the location name and address.
            if (self.currentPlacemarkCache) {
                
                if (![[ubfEvent attributes] objectForKey:[cm fieldNameForUBF:PLIST_UBF_LOCATION_NAME]]) {
                    [ubfEvent setAttribute:[cm fieldNameForUBF:PLIST_UBF_LOCATION_NAME] value:[NSString stringWithFormat:@"%@", [[self.currentPlacemarkCache addressDictionary] objectForKey:@"Name"]]];
                }
                
                NSString *location;
                if (![[ubfEvent attributes] objectForKey:[cm fieldNameForUBF:PLIST_UBF_LOCATION_ADDRESS]]) {
                    location = [NSString stringWithFormat:@"%@, %@ %@, %@ (%@)", [[self.currentPlacemarkCache addressDictionary] objectForKey:@"City"], [[self.currentPlacemarkCache addressDictionary] objectForKey:@"State"], [[self.currentPlacemarkCache addressDictionary] objectForKey:@"ZIP"], [[self.currentPlacemarkCache addressDictionary] objectForKey:@"Country"], [[self.currentPlacemarkCache addressDictionary] objectForKey:@"CountryCode"]];
                    [ubfEvent setAttribute:[cm fieldNameForUBF:PLIST_UBF_LOCATION_ADDRESS] value:location];
                }
            }
        }
    }
    return ubfEvent;
}

@end
