//
//  EngageConfig.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/29/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "EngageConfig.h"
#import <UIKit/UIKit.h>

#define DEFAULT_CURRENT_CAMPAIGN_EXPIRATION_SECONDS 86400

@implementation EngageConfig

__strong static NSDate *currentCampaignExpirationDate = nil;

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


+ (NSString *)currentCampaign {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentCampaign = [defaults objectForKey:@"engageCurrentCampaign"];
    
    //Make sure that the current campaign has not already expired.
    if (currentCampaignExpirationDate != nil) {
        NSDate *now = [[NSDate alloc] init];
        if ([now compare:currentCampaignExpirationDate] == NSOrderedDescending) {
            //Current Campaign has expired
            return @"";
        } else {
            //Current Campaign is still active.
            return currentCampaign ? currentCampaign : @"";
        }
    } else {
        return currentCampaign ? currentCampaign : @"";
    }
}

/*
 Retrieves the last active value of the current campaign value.
*/
+ (NSString *)lastCampaign {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSString *currentCampaign = [defaults objectForKey:@"engageCurrentCampaign"];
    return currentCampaign;
}

+ (void)storeCurrentCampaign:(NSString *)currentCampaign withExpirationTimestamp:(NSString *)expirationTimestamp {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (expirationTimestamp) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterNoStyle];
        NSNumber *expirationTimestampNumber = [f numberFromString:expirationTimestamp];
        currentCampaignExpirationDate = [NSDate dateWithTimeIntervalSince1970:[expirationTimestampNumber longValue]];
    } else {
        //Creates a default expiration date.
        currentCampaignExpirationDate = [NSDate dateWithTimeInterval:DEFAULT_CURRENT_CAMPAIGN_EXPIRATION_SECONDS sinceDate:[NSDate date]];
    }
    NSLog(@"Setting CurrentCampaign to %@ with expiration of %@", currentCampaign, currentCampaignExpirationDate);
    [defaults setObject:currentCampaign forKey:@"engageCurrentCampaign"];
    [defaults synchronize];
}

@end
