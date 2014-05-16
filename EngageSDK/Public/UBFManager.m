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
#import "sample-config.h"           //You must create a "sample-config.h" file following the guidelines from the README

@implementation UBFManager

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static UBFManager *sharedInstance = nil;
    dispatch_once(&pred, ^
    {
        sharedInstance = [[UBFManager alloc] init];
        
        [UBFClient createClient:ENGAGE_CLIENT_ID
                         secret:ENGAGE_SECRET
                          token:ENGAGE_REFRESH_TOKEN
                           host:ENGAGE_BASE_URL
                 connectSuccess:^(AFOAuthCredential *credential) {
                     NSLog(@"Successfully established connection to Engage API");
                 } failure:^(NSError *error) {
                     NSLog(@"Failed to establish connection to Engage API .... %@", error);
                 }];
        
        
    });
    return sharedInstance;
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
