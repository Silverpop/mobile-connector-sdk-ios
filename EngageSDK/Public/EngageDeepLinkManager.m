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
#import "EngageConfigManager.h"
#import "EngageExpirationParser.h"

@implementation EngageDeepLinkManager

__strong NSMutableDictionary *urlParams;

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static EngageDeepLinkManager *sharedInstance = nil;
    dispatch_once(&pred, ^
    {
        sharedInstance = [[EngageDeepLinkManager alloc] init];
        
        //Register the MobileDeepLinking handlers.
        [[MobileDeepLinking sharedInstance] registerHandlerWithName:@"postSilverpop" handler:^(NSDictionary *properties) {
            urlParams = [properties mutableCopy];
        }];
    });
    return sharedInstance;
}

- (NSDictionary *)parseURLQueryParams:(NSURL *)url {
    NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
    if (url) {
        NSString *query = [url query];
        if (query) {
            NSArray *components = [query componentsSeparatedByString:@"&"];
            for (NSString *component in components) {
                NSArray *inCom = [component componentsSeparatedByString:@"="];
                if ([inCom count] == 2) {
                    NSString *value = inCom[1];
                    value = [value stringByRemovingPercentEncoding];
                    [dict setObject:value forKey:inCom[0]];
                }
            }
        }
    }
    return dict;
}

- (NSDictionary *)parseDeepLinkURL:(NSURL *)deeplink {
    [[MobileDeepLinking sharedInstance] routeUsingUrl:deeplink];
    NSDictionary *queryParams = [self parseURLQueryParams:deeplink];
    
    //Merge the MobileDeepLinking library dictionary with the query params we parsed.
    if (urlParams == nil) {
        urlParams = [[NSMutableDictionary alloc] init];
    }
    [urlParams addEntriesFromDictionary:queryParams];
    
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