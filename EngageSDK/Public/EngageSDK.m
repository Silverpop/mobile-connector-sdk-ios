//
//  EngageSDK.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/11/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "EngageSDK.h"

@implementation EngageSDK

+(void) initializeSDKClient:(NSString *)clientId
                     secret:(NSString *)secret
                      token:(NSString *)refreshToken
                       host:(NSString *)host
       engageDatabaseListId:(NSString *)engageListId {
    NSLog(@"EngageSDK - initializing SDK");
    
    NSLog(@"EngageSDK - loading configurations");
    @try {
        [EngageConfigManager sharedInstance];
    }
    @catch(NSException *ex) {
        NSLog(@"EngageSDK - ERROR loading configuration values. EngageSDK will not function properly!");
    }
    
    //Creates the shared instance of the UBFManager and begins the underlying authentication process.
    NSLog(@"EngageSDK - initializing UBFManager shared instance");
    [UBFManager createClient:clientId secret:secret token:refreshToken host:host engageDatabaseListId:engageListId connectSuccess:nil failure:nil];
    
    //Creates the shared instance of the XMLAPIManager and begins the underlying authentication process.
    NSLog(@"EngageSDK - initializing XMLAPIManager shared instance");
    [XMLAPIManager createClient:clientId secret:secret token:refreshToken host:host engageDatabaseListId:engageListId connectSuccess:nil failure:nil];
    
    
}

@end
