//
//  UBFManager.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "UBFManager.h"
#import "UBF.h"
#import "UBFClient.h"
#import "EngageConfig.h"
#import "EngageDeepLinkManager.h"
#import "EngageEventLocationManager.h"

NSString * const kEngageClientInstalled = @"engageClientInstalled";

@interface UBFManager ()

@property (strong, nonatomic) EngageLocalEventStore *engageLocalEventStore;
@property (strong, nonatomic) EngageEventLocationManager *engageEventLocationManager;
@property (strong, nonatomic) EngageConfigManager *ecm;

//Session Management.
@property NSDictionary *sessionEnded;
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

- (void)restartSession {
    if (self.sessionEnded) [self trackEvent:self.sessionEnded];
    [self trackEvent:[UBF sessionStarted:nil withCampaign:[EngageConfig currentCampaign]]];
    self.sessionBegan = [NSDate date];
    self.duration = 0.0f;
}

- (BOOL)sessionExpired {
    return [self.sessionExpires compare:[NSDate date]] == NSOrderedAscending;
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
                     NSLog(@"Successfully established connection to Engage API");
                 } failure:^(NSError *error) {
                     NSLog(@"Failed to establish connection to Engage API .... %@", error);
                 }];
        
        _sharedInstance.engageEventLocationManager = [[EngageEventLocationManager alloc] init];
        _sharedInstance.engageLocalEventStore = [[EngageLocalEventStore alloc] init];
        _sharedInstance.ecm = [EngageConfigManager sharedInstance];
        
        //If location services are enabled then we want to listen for location updated events.
        if ([_sharedInstance.engageEventLocationManager locationServicesEnabled]) {
            [[NSNotificationCenter defaultCenter] addObserverForName:LOCATION_UPDATED_NOTIFICATION
                                                              object:nil
                                                               queue:[NSOperationQueue mainQueue]
                                                          usingBlock:^(NSNotification *note) {
                                                              
                                                              //Locate all events with "HOLD" status in Core Data
                                                              NSArray *holdEngagedEvents = [_sharedInstance.engageLocalEventStore findEngageEventsWithStatus:HOLD];
                                                              NSLog(@"%ld hold events were found", [holdEngagedEvents count]);
                                                              
                                                              //Update their payload to have the new coordinates.
                                                              NSError *jsonError;
                                                              for (EngageEvent *ee in holdEngagedEvents) {
                                                                  
                                                                  if (ee.eventJson != nil) {
                                                                      NSDictionary *originalEventData = [NSJSONSerialization JSONObjectWithData:[ee.eventJson dataUsingEncoding:NSUTF8StringEncoding]
                                                                                                                                        options:kNilOptions
                                                                                                                                          error:&jsonError];
                                                                      
                                                                      //Updates the UBF event with the LocationManager.
                                                                      NSDictionary *newEvent = [_sharedInstance.engageEventLocationManager addLocationToUBFEvent:originalEventData];
                                                                      
                                                                      if (newEvent) {
                                                                          ee.eventJson = [_sharedInstance.engageLocalEventStore createJsonStringFromDictionary:newEvent];
                                                                          ee.eventStatus = [[NSNumber alloc] initWithInt:NOT_POSTED];
                                                                      } else {
                                                                          ee.eventStatus = [[NSNumber alloc] initWithInt:NOT_POSTED];
                                                                      }
                                                                  }
                                                              }
                                                              
                                                              NSError *saveError;
                                                              if (![[[EngageLocalEventStore sharedInstance] managedObjectContext] save:&saveError]) {
                                                                  NSLog(@"EngageUBFEvents were successfully posted to Silverpop but there was a problem marking them as posted in the EngageLocalEventStore: %@", [saveError description]);
                                                              }
                                                              
                                                              //Posts all of the updated events now.
                                                              for (EngageEvent *ee in holdEngagedEvents) {
                                                                  NSLog(@"TODO: UPDATE THE EVENT TO NOT_POSTED!!!!!");
                                                              }
                                                          }];
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
        }
        
        // start session
        [_sharedInstance restartSession];
        
        [[NSNotificationCenter defaultCenter] addObserverForName:UIApplicationWillEnterForegroundNotification
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          if ([_sharedInstance sessionExpired]) {
                                                              [_sharedInstance restartSession];
                                                          }
                                                          else {
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
                                                      }];
    });
    
    return _sharedInstance;
}


+ (id)sharedInstance
{
    if (_sharedInstance == nil) {
        [NSException raise:@"UBFManager sharedInstance is null" format:@"UBFManager sharedInstance is null. You must first create an UBFManager instance"];
    }
    return _sharedInstance;
}


- (void)postEngageEvent:(EngageEvent *)engageEvent {
    
}


- (NSURL *) trackEvent:(NSDictionary *)event {
    
    EngageEvent *engageEvent = nil;
    
    //Does the event need to be fired now or wait?
    if ([self.engageEventLocationManager locationServicesEnabled]) {
        //Ask the location Manager for the current CLLocation and CLPlacemark information
        NSDictionary *eventWithLocation = [self.engageEventLocationManager addLocationToUBFEvent:event];
        if (eventWithLocation == nil) {
            //Location information is not yet ready so save with a hold state in the database.
            engageEvent = [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:HOLD];
        } else {
            engageEvent = [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:NOT_POSTED];
            [[UBFClient client] postEngageEvent:engageEvent retryCount:0];
        }
    } else {
        //Location Services are not enabled so continue with the normal flow.
        engageEvent = [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:NOT_POSTED];
        [[UBFClient client] postEngageEvent:engageEvent retryCount:0];
    }
    
    return [[engageEvent objectID] URIRepresentation];
}

- (NSURL *)handleLocalNotificationReceivedEvents:(UILocalNotification *)localNotification
                                      withParams:(NSDictionary *)params {
    return [self trackEvent:[UBF receivedLocalNotification:localNotification withParams:params]];
}

- (NSURL *)handlePushNotificationReceivedEvents:(NSDictionary *)pushNotification
                                     withParams:(NSDictionary *)params {
    
    //Examine the push notification for certain parameters that define sdk behavior.
    if ([pushNotification objectForKey:[self.ecm fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]]
        && [pushNotification objectForKey:[self.ecm fieldNameForParam:PLIST_PARAM_CAMPAIGN_EXPIRES_AT]]) {
        
        //Parse the expiration timestamp from the hard datetime campaign end value.
        EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:[pushNotification objectForKey:[self.ecm fieldNameForParam:PLIST_PARAM_CAMPAIGN_EXPIRES_AT]] fromDate:[NSDate date]];
        
        [EngageConfig storeCurrentCampaign:[pushNotification objectForKey:[self.ecm fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]]
                   withExpirationTimestamp:[exp expirationTimeStamp]];
        
    } else if ([pushNotification objectForKey:[self.ecm fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]]
               && [pushNotification objectForKey:[self.ecm fieldNameForParam:PLIST_PARAM_CAMPAIGN_VALID_FOR]]) {
        
        //Parse the expiration timestamp from the current date plus the expiration valid for parameter specified.
        EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:[pushNotification objectForKey:[self.ecm fieldNameForParam:PLIST_PARAM_CAMPAIGN_VALID_FOR]] fromDate:[NSDate date]];
        
        [EngageConfig storeCurrentCampaign:[pushNotification objectForKey:[self.ecm fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]] withExpirationTimestamp:[exp expirationTimeStamp]];
        
    } else if ([pushNotification objectForKey:[self.ecm fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]]) {
        [EngageConfig storeCurrentCampaign:[pushNotification objectForKey:[self.ecm fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]] withExpirationTimestamp:-1];
    } else {
        NSLog(@"Unable to determine CurrentCampaign from push notification!");
    }
    
    return [self trackEvent:[UBF receivedPushNotification:pushNotification withParams:params]];
}

- (NSURL *)handleNotificationOpenedEvents:(NSDictionary *)notification withParams:(NSDictionary *)params {
    return [self trackEvent:[UBF openedNotification:notification withParams:params]];
}

- (NSURL *)handleExternalURLOpenedEvents:(NSURL *)externalUrl {
    
    NSDictionary *urlParams = [[EngageDeepLinkManager sharedInstance] parseDeepLinkURL:externalUrl];
    
    id ubfResult = nil;
    if ([urlParams objectForKey:[self.ecm fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]]) {
        ubfResult = [UBF sessionStarted:urlParams withCampaign:[urlParams objectForKey:[self.ecm fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]]];
    } else {
        ubfResult = [UBF sessionStarted:urlParams withCampaign:nil];
    }
    
    return [self trackEvent:ubfResult];
}

@end
