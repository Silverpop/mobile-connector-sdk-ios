//
//  EngageDeepLinkManager.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "EngageDeepLinkManager.h"
#import "EngageConfig.h"
#import "UBFClient.h"
#import "UBF.h"

@implementation EngageDeepLinkManager

__strong NSDictionary *urlParams;

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static EngageDeepLinkManager *sharedInstance = nil;
    dispatch_once(&pred, ^
    {
        sharedInstance = [[EngageDeepLinkManager alloc] init];
        
        //Register the MobileDeepLinking handlers.
        [[MobileDeepLinking sharedInstance] registerHandlerWithName:@"postSilverpop" handler:^(NSDictionary *properties) {
            urlParams = properties;
        }];
    });
    return sharedInstance;
}

- (NSDictionary *)parseDeepLinkURL:(NSURL *)deeplink {
    [[MobileDeepLinking sharedInstance] routeUsingUrl:deeplink];
    
    //Examine the URL Parameters
    if ([urlParams objectForKey:CURRENT_CAMPAIGN_PARAM_NAME] && [urlParams objectForKey:CAMPAIGN_EXTERNAL_EXPIRATION_DATETIME_PARAM]) {
        [EngageConfig storeCurrentCampaign:[urlParams objectForKey:CURRENT_CAMPAIGN_PARAM_NAME]
                   withExpirationTimestamp:[urlParams objectForKey:CAMPAIGN_EXTERNAL_EXPIRATION_DATETIME_PARAM]];
    } else if ([urlParams objectForKey:CURRENT_CAMPAIGN_PARAM_NAME]) {
        [EngageConfig storeCurrentCampaign:[urlParams objectForKey:CURRENT_CAMPAIGN_PARAM_NAME] withExpirationTimestamp:nil];
    }
    
    return urlParams;
}

@end