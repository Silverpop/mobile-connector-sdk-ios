//
//  UBFManager.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "UBFManager.h"
#import "UBF.h"
#import "XMLAPI.h"
#import "XMLAPIClient.h"
#import "UBFClient.h"
#import "EngageConfig.h"
#import "EngageDeepLinkManager.h"
#import "EngageEventLocationManager.h"
#import "EngageEventWrapper.h"
#import "UBFAugmentationManager.h"

NSString * const kEngageClientInstalled = @"engageClientInstalled";

@interface UBFManager ()

@property (strong, nonatomic) EngageLocalEventStore *engageLocalEventStore;
@property (strong, nonatomic) EngageEventLocationManager *engageEventLocationManager;
@property (strong, nonatomic) EngageConfigManager *ecm;
@property (assign) int eventsToCacheBeforePost;
@property (assign) int eventsCached;

//Session Management.
@property UBF *sessionEnded;
@property NSDate *sessionExpires;
@property(nonatomic) NSDate *sessionBegan;
@property NSTimeInterval duration;
@property(nonatomic) NSTimeInterval sessionTimeout;

@end

@implementation UBFManager

__strong static UBFManager *_sharedInstance = nil;

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

+ (instancetype)createClient:(NSString *)clientId
                      secret:(NSString *)secret
                       token:(NSString *)refreshToken
                        host:(NSString *)hostUrl
              connectSuccess:(void (^)(AFOAuthCredential *credential))success
                     failure:(void (^)(NSError *error))failure {
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedInstance = [[UBFManager alloc] init];
        _sharedInstance.sessionTimeout = [[EngageConfigManager sharedInstance] longConfigForSessionValue:PLIST_SESSION_LIFECYCLE_EXPIRATION];
        
        [UBFClient createClient:clientId
                         secret:secret
                          token:refreshToken
                           host:hostUrl
                 connectSuccess:^(AFOAuthCredential *credential) {
                     NSLog(@"Successfully authenticated UBFManager connection to Engage API");
                     if (success) {
                         success(credential);
                     }
                 } failure:^(NSError *error) {
                     NSLog(@"Failed to authenticate UBFManager connection to Engage API%@", error);
                     if (failure) {
                         failure(error);
                     }
                 }];
        
        _sharedInstance.engageEventLocationManager = [[EngageEventLocationManager alloc] init];
        _sharedInstance.engageLocalEventStore = [[EngageLocalEventStore alloc] init];
        _sharedInstance.ecm = [EngageConfigManager sharedInstance];
        _sharedInstance.eventsToCacheBeforePost = [[[EngageConfigManager sharedInstance] numberConfigForGeneralFieldName:PLIST_GENERAL_UBF_EVENT_CACHE_SIZE] intValue];
        
        //If location services are enabled then we want to listen for location updated events.
        if ([_sharedInstance.engageEventLocationManager locationServicesEnabled]) {
            [self registerForLocationServiceNotifications];
        } else {
            NSLog(@"Notifications are not enabled so we are not setting up a location event listener");
        }
        
        
        //Handles the session
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *installed = [defaults objectForKey:kEngageClientInstalled];
        if (![installed boolValue]) { // nil or false
            // installed event
            [_sharedInstance trackEvent:[UBF installed:nil]];
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [defaults setObject:@"YES" forKey:kEngageClientInstalled];
            [defaults synchronize];
            
            //If LocationServices are enabled then we need to add the Last known location fields to the database.
            if ([[EngageConfigManager sharedInstance] locationServicesEnabled]) {
                XMLAPIClient *xmlApiClient = [XMLAPIClient createClient:clientId secret:secret token:refreshToken host:hostUrl connectSuccess:nil failure:nil];
                
                NSString *lastKnownLocationColumnName = [_sharedInstance.ecm configForLocationFieldName:PLIST_LOCATION_LAST_KNOWN_LOCATION];
                NSString *lastKnownLocationTime = [_sharedInstance.ecm configForLocationFieldName:PLIST_LOCATION_LAST_KNOWN_LOCATION_TIME];
                
                XMLAPI *addLastKnownLocationColumn = [XMLAPI addColumn:lastKnownLocationColumnName toDatabase:[_sharedInstance.ecm configForGeneralFieldName:PLIST_GENERAL_DATABASE_LIST_ID] ofColumnType:COLUMN_TYPE_TEXT];
                XMLAPI *addLastKnownLocationTimeColumn = [XMLAPI addColumn:lastKnownLocationTime toDatabase:[_sharedInstance.ecm configForGeneralFieldName:PLIST_GENERAL_DATABASE_LIST_ID] ofColumnType:COLUMN_TYPE_DATE];
                
                [xmlApiClient postResource:addLastKnownLocationColumn success:nil failure:nil];
                [xmlApiClient postResource:addLastKnownLocationTimeColumn success:nil failure:nil];
            }
            
            
        }
        
        // start session
        [_sharedInstance restartSession];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          if ([_sharedInstance sessionExpired]) {
                                                              NSLog(@"Session restarted");
                                                              [_sharedInstance restartSession];
                                                          }
                                                          else {
                                                              NSLog(@"Session resumed");
                                                              _sharedInstance.sessionBegan = [NSDate date];
                                                          }
                                                      }];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillResignActiveNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          // now - start|resume + duration
                                                          _sharedInstance.duration += [[NSDate date] timeIntervalSinceDate:_sharedInstance.sessionBegan];
                                                          _sharedInstance.sessionEnded = [UBF sessionEnded:@{[[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_SESSION_DURATION]:[NSString stringWithFormat:@"%d",(int)_sharedInstance.duration]}];
                                                          _sharedInstance.sessionExpires = [NSDate dateWithTimeInterval:_sharedInstance.sessionTimeout
                                                                                                            sinceDate:[NSDate date]];
                                                          
                                                          NSLog(@"Session paused");
                                                      }];
    });
    
    return _sharedInstance;
}


/**
 Registers the LocationService notifications if they are enabled for the application.
*/
+ (void)registerForLocationServiceNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LOCATION_UPDATED_NOTIFICATION
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      
                                                      //Locate all events with "HOLD" status in Core Data
                                                      NSArray *holdEngagedEvents = [_sharedInstance.engageLocalEventStore findEngageEventsWithStatus:[[NSNumber numberWithInt:HOLD] intValue]];
                                                      
                                                      //Update their payload to have the new coordinates.
                                                      for (EngageEvent *ee in holdEngagedEvents) {
                                                          
                                                          if (ee.eventJson != nil) {
                                                              UBF *originalEvent = [[UBF alloc] initFromJSON:ee.eventJson];
                                                              
                                                              //Updates the UBF event with the LocationManager.
                                                              UBF *newEvent = [_sharedInstance.engageEventLocationManager addLocationToUBFEvent:originalEvent withEngageEvent:ee];
                                                              
                                                              if (newEvent) {
                                                                  ee.eventJson = [newEvent jsonValue];
                                                                  ee.eventStatus = [[NSNumber alloc] initWithInt:NOT_POSTED];
                                                              } else {
                                                                  ee.eventStatus = [[NSNumber alloc] initWithInt:NOT_POSTED];
                                                              }
                                                          } else {
                                                              ee.eventStatus = [[NSNumber alloc] initWithInt:NOT_POSTED];
                                                          }
                                                      }
                                                      
                                                      [[EngageLocalEventStore sharedInstance] saveEvents];
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LOCATION_ACQUIRE_LOCATION_TIMEOUT
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"Location Coordinate acquisition timed out. Sending UBF event without coordinates!");
                                                      
                                                      //Acquiring coordinates has timed out so we need to go ahead and push the UBF event to Silverpop.
                                                      [[UBFClient client] postUBFEngageEvents:nil failure:nil];
                                                  }];
    
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LOCATION_PLACEMARK_TIMEOUT
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      NSLog(@"Location Placemark acquisition timed out. Sending UBF event without Placemark location!");
                                                      
                                                      //Acquiring CLPlacemark has timed out so we need to go ahead and push the UBF event to Silverpop.
                                                      [[UBFClient client] postUBFEngageEvents:nil failure:nil];
                                                  }];
}


+ (id)sharedInstance
{
    if (_sharedInstance == nil) {
        [NSException raise:@"UBFManager sharedInstance is null" format:@"UBFManager sharedInstance is null. You must first create an UBFManager instance"];
    }
    return _sharedInstance;
}


- (NSURL *) trackEvent:(UBF *)event {
    
    EngageEvent *engageEvent = nil;
    
    //Does the event need to be fired now or wait?
    if ([self.engageEventLocationManager locationServicesEnabled]) {
        
        engageEvent = [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:[[NSNumber numberWithInt:HOLD] intValue]];
        
        //Pass the UBF event through the user defined Augmentors.
        [[UBFAugmentationManager sharedInstance] augmentUBFEvent:event withEngageEvent:engageEvent];
    } else {
        //Location Services are not enabled so continue with the normal flow.
        engageEvent = [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:[[NSNumber numberWithInt:NOT_POSTED] intValue]];
    }
    
    //Save and post the event.
    [[EngageLocalEventStore sharedInstance] saveEvents];
    
    self.eventsCached++;
    if (self.eventsCached >= self.eventsToCacheBeforePost) {
        [[UBFClient client] postUBFEngageEvents:nil failure:nil];
    }
    
    return [[engageEvent objectID] URIRepresentation];
}

- (void)postEventCache {
    self.eventsCached = 0;
    [[UBFClient client] postUBFEngageEvents:nil failure:nil];
}

- (NSURL *)handleLocalNotificationReceivedEvents:(UILocalNotification *)localNotification
                                      withParams:(NSDictionary *)params {
    return [self trackEvent:[UBF receivedLocalNotification:localNotification withParams:params]];
}

- (NSURL *)handlePushNotificationReceivedEvents:(NSDictionary *)pushNotification
                                     withParams:(NSDictionary *)params {
    return [self trackEvent:[UBF receivedPushNotification:pushNotification withParams:params]];
}

- (NSURL *)handleNotificationOpenedEvents:(NSDictionary *)notification withParams:(NSDictionary *)params {
    return [self trackEvent:[UBF openedNotification:notification withParams:params]];
}

- (NSURL *)handleExternalURLOpenedEvents:(NSURL *)externalUrl {
    
    NSDictionary *urlParams = [[EngageDeepLinkManager sharedInstance] parseDeepLinkURL:externalUrl];
    return [self trackEvent:[UBF sessionStarted:urlParams withCampaign:nil]];
}

- (void)restartSession {
    if (self.sessionEnded) [self trackEvent:self.sessionEnded];
    [self trackEvent:[UBF sessionStarted:nil withCampaign:[EngageConfig currentCampaign]]];
    self.sessionBegan = [NSDate date];
    self.duration = 0.0f;
}

- (BOOL)sessionExpired {
    return [self.sessionExpires compare:[NSDate date]] == NSOrderedAscending;
}

@end
