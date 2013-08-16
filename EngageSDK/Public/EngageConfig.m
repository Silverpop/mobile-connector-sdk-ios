//
//  EngageConfig.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/29/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "EngageConfig.h"
#import <UIKit/UIKit.h>

@implementation EngageConfig

+ (NSString *)deviceId {
    
    NSString *deviceId = [[[UIDevice currentDevice] identifierForVendor] UUIDString];
    
    if (!deviceId) {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        deviceId = [defaults objectForKey:@"deviceId"];
    }
    
    if (!deviceId) {
        CFUUIDRef theUUID = CFUUIDCreate(NULL);
        CFStringRef dId = CFUUIDCreateString(NULL, theUUID);
        CFRelease(theUUID);
        
        deviceId = (__bridge NSString *)dId;
        
        CFRelease(dId);
        
        // store deviceId in NSUserDefaults
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setObject:deviceId forKey:@"deviceId"];
        [defaults synchronize];
    }
    
    return deviceId;
}

+ (NSString *)anonymousId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults objectForKey:@"engageAnonymousId"];
    return userId ? userId : @"";
}

+ (void)storeAnonymousId:(NSString *)anonymousId {
    // store recipientId in NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:anonymousId forKey:@"engageAnonymousId"];
    [defaults synchronize];
}

+ (NSString *)primaryUserId {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *userId = [defaults objectForKey:@"engagePrimaryUserId"];
    return userId ? userId : @"";
}

+ (void)storePrimaryUserId:(NSString *)userId {
    // store userId in NSUserDefaults
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:userId forKey:@"engagePrimaryUserId"];
    [defaults synchronize];
}

@end
