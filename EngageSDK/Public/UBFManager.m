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
        engageDatabaseListId:(NSString *)engageListId
              connectSuccess:(void (^)(AFOAuthCredential *credential))success
                     failure:(void (^)(NSError *error))failure {
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedInstance = [[UBFManager alloc] init];
        [EngageConfig storeEngageListId:engageListId];
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
                
                XMLAPI *addLastKnownLocationColumn = [XMLAPI addColumn:lastKnownLocationColumnName toDatabase:[EngageConfig engageListId] ofColumnType:COLUMN_TYPE_TEXT];
                XMLAPI *addLastKnownLocationTimeColumn = [XMLAPI addColumn:lastKnownLocationTime toDatabase:[EngageConfig engageListId] ofColumnType:COLUMN_TYPE_DATE];
                
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
                                                          
                                                          //Also save the EngageLocalEventStore state.
                                                          [[EngageLocalEventStore sharedInstance] saveEvents];
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


- (NSURL *) trackEvent:(UBF *)event {
    
    EngageEvent *engageEvent = nil;
    engageEvent = [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:[[NSNumber numberWithInt:HOLD] intValue]];
    [[UBFAugmentationManager sharedInstance] augmentUBFEvent:event withEngageEvent:engageEvent];
    return [[engageEvent objectID] URIRepresentation];
}

- (void)postEventCache {
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
