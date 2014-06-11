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
#import <MobileDeepLinking-iOS/MDLConstants.h>

@interface EngageDeepLinkManager()

@property (strong, nonatomic) MobileDeepLinking *mobileDeepLinking;

@end

@implementation EngageDeepLinkManager

__strong NSMutableDictionary *urlParams;
__strong static EngageDeepLinkManager *_sharedInstance = nil;

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    dispatch_once(&pred, ^
    {
        _sharedInstance = [[EngageDeepLinkManager alloc] init];
        _sharedInstance.mobileDeepLinking = nil;
        
        //Checks for the existance of the MobileDeepLinking.org library configuration file.
        NSString *configFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:MOBILEDEEPLINKING_CONFIG_NAME ofType:@"json"];
        bool mobileDeepLinkConfigFileExists = [[NSFileManager defaultManager] fileExistsAtPath:configFilePath];
        
        if (mobileDeepLinkConfigFileExists) {
            //Register the MobileDeepLinking handlers.
            _sharedInstance.mobileDeepLinking = [MobileDeepLinking sharedInstance];
            [_sharedInstance.mobileDeepLinking registerHandlerWithName:@"postSilverpop" handler:^(NSDictionary *properties) {
                urlParams = [properties mutableCopy];
            }];
        } else {
            NSLog(@"%@ deep linking configuration file not found. Default to query parameters only parsing", MOBILEDEEPLINKING_CONFIG_NAME);
        }
    });
    return _sharedInstance;
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
                    [dict setObject:[inCom[1] stringByRemovingPercentEncoding] forKey:[inCom[0] stringByRemovingPercentEncoding]];
                }
            }
        }
    }
    return dict;
}

- (NSDictionary *)parseDeepLinkURL:(NSURL *)deeplink {
    
    if (self.mobileDeepLinking) {
        [self.mobileDeepLinking routeUsingUrl:deeplink];
    } else {
        urlParams = [[NSMutableDictionary alloc] init];
    }
    
    NSDictionary *queryParams = [self parseURLQueryParams:deeplink];
    
    //Merge the MobileDeepLinking library dictionary with the query params we parsed.
    if (!urlParams) {
        urlParams = [[NSMutableDictionary alloc] init];
    }
    [urlParams addEntriesFromDictionary:queryParams];
    
    return urlParams;
}

@end