//
//  EngageDeepLinkManager.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "EngageDeepLinkManager.h"
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
    
    EngageConfigManager *ma = [EngageConfigManager sharedInstance];
    
    //Examine the URL Parameters
    if ([urlParams objectForKey:[ma fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]]
        && [urlParams objectForKey:[ma fieldNameForParam:PLIST_PARAM_CAMPAIGN_EXPIRES_AT]]) {
        
        //Parse the expiration timestamp from the hard datetime campaign end value.
        EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:[urlParams objectForKey:[ma fieldNameForParam:PLIST_PARAM_CAMPAIGN_EXPIRES_AT]] fromDate:[NSDate date]];
        
        [EngageConfig storeCurrentCampaign:[urlParams objectForKey:[ma fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]]
                   withExpirationTimestamp:[exp expirationTimeStamp]];
        
    } else if ([urlParams objectForKey:[ma fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]]
        && [urlParams objectForKey:[ma fieldNameForParam:PLIST_PARAM_CAMPAIGN_VALID_FOR]]) {
        
        //Parse the expiration timestamp from the current date plus the expiration valid for parameter specified.
        EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:[urlParams objectForKey:[ma fieldNameForParam:PLIST_PARAM_CAMPAIGN_VALID_FOR]] fromDate:[NSDate date]];
        
        [EngageConfig storeCurrentCampaign:[urlParams objectForKey:[ma fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]] withExpirationTimestamp:[exp expirationTimeStamp]];
        
    } else if ([urlParams objectForKey:[ma fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]]) {
        //Just set the Campaign value without an expiration.
        [EngageConfig storeCurrentCampaign:[urlParams objectForKey:[ma fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]] withExpirationTimestamp:-1];
    }
    
    return urlParams;
}

@end