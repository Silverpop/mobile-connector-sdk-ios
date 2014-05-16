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

@implementation UBFManager

__strong static UBFManager *_sharedInstance = nil;

+ (instancetype)createClient:(NSString *)clientId
                      secret:(NSString *)secret
                       token:(NSString *)refreshToken
                        host:(NSString *)hostUrl
              connectSuccess:(void (^)(AFOAuthCredential *credential))success
                     failure:(void (^)(NSError *error))failure {
    
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedInstance = [[UBFManager alloc] init];
        
        [UBFClient createClient:clientId
                         secret:secret
                          token:refreshToken
                           host:hostUrl
                 connectSuccess:^(AFOAuthCredential *credential) {
                     NSLog(@"Successfully established connection to Engage API");
                 } failure:^(NSError *error) {
                     NSLog(@"Failed to establish connection to Engage API .... %@", error);
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

- (NSURL *) trackEvent:(NSDictionary *)event {
    return [[UBFClient client] trackingEvent:event];
}

- (void) postEventCache {
    [[UBFClient client] postEventCache];
}

- (NSURL *) enqueueEvent:(NSDictionary *)event {
    return [[UBFClient client] enqueueEvent:event];
}

- (NSURL *)handleLocalNotificationReceivedEvents:(UILocalNotification *)localNotification
                                      withParams:(NSDictionary *)params {
    return [[UBFClient client] trackingEvent:[UBF receivedLocalNotification:localNotification withParams:params]];
}

- (NSURL *)handlePushNotificationReceivedEvents:(NSDictionary *)pushNotification {
    //Examine the push notification for certain parameters that define sdk behavior.
    if ([pushNotification objectForKey:CURRENT_CAMPAIGN_PARAM_NAME] && [pushNotification objectForKey:CAMPAIGN_EXTERNAL_EXPIRATION_DATETIME_PARAM]) {
        [EngageConfig storeCurrentCampaign:[pushNotification objectForKey:CURRENT_CAMPAIGN_PARAM_NAME]
                   withExpirationTimestamp:[pushNotification objectForKey:CAMPAIGN_EXTERNAL_EXPIRATION_DATETIME_PARAM]];
    } else if ([pushNotification objectForKey:CURRENT_CAMPAIGN_PARAM_NAME]) {
        [EngageConfig storeCurrentCampaign:[pushNotification objectForKey:CURRENT_CAMPAIGN_PARAM_NAME] withExpirationTimestamp:nil];
    }
    
    return [[UBFClient client] trackingEvent:[UBF receivedPushNotification:pushNotification]];
}

- (NSURL *)handleNotificationOpenedEvents:(NSDictionary *)params {
    return [[UBFClient client] trackingEvent:[UBF openedNotification:params]];
}

- (NSURL *)handleExternalURLOpenedEvents:(NSURL *)externalUrl {
    
    NSDictionary *urlParams = [[EngageDeepLinkManager sharedInstance] parseDeepLinkURL:externalUrl];
    
    id ubfResult = nil;
    if ([urlParams objectForKey:CURRENT_CAMPAIGN_PARAM_NAME]) {
        ubfResult = [UBF sessionStarted:urlParams withCampaign:[urlParams objectForKey:CURRENT_CAMPAIGN_PARAM_NAME]];
    } else {
        ubfResult = [UBF sessionStarted:urlParams withCampaign:nil];
    }
    
    return [[UBFClient client] trackingEvent:ubfResult];
}

@end
