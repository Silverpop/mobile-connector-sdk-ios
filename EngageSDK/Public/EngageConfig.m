//
//  EngageConfig.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/29/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "EngageConfig.h"
#import <UIKit/UIKit.h>
#import "EngageConfigManager.h"

@implementation EngageConfig

__strong static NSDate *currentCampaignExpirationDate = nil;
__strong static NSString *engageListId = nil;


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
    
    return deviceId ? deviceId : @"";
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

    // broadcast that the primary user id is now known
    [[NSNotificationCenter defaultCenter] postNotificationName:PRIMARY_USER_ID_SET object:nil];
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
    if (currentCampaign) {
        return currentCampaign;
    } else {
        return @"";
    }
}

+ (void)storeCurrentCampaign:(NSString *)currentCampaign withExpirationTimestamp:(long)utcExpirationTimestamp {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (utcExpirationTimestamp > 0) {
        currentCampaignExpirationDate = [NSDate dateWithTimeIntervalSince1970:utcExpirationTimestamp];
    } else {
        //Creates a default expiration date.
        NSString *expirationString = [[EngageConfigManager sharedInstance] configForGeneralFieldName:PLIST_GENERAL_DEFAULT_CURRENT_CAMPAIGN_EXPIRATION];
        EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:expirationString fromDate:[NSDate date]];
        currentCampaignExpirationDate = [NSDate dateWithTimeInterval:[exp secondsParsedFromExpiration] sinceDate:[NSDate date]];
    }
    NSLog(@"Setting CurrentCampaign to %@ with expiration of %@", currentCampaign, currentCampaignExpirationDate);
    [defaults setObject:currentCampaign forKey:@"engageCurrentCampaign"];
    [defaults synchronize];
}

+ (void)storeCurrentCampaign:(NSString *)currentCampaign withExpirationTimestampString:(NSString *)expirationTimestamp {
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    if (expirationTimestamp) {
        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterNoStyle];
        NSNumber *expirationTimestampNumber = [f numberFromString:expirationTimestamp];
        currentCampaignExpirationDate = [NSDate dateWithTimeIntervalSince1970:[expirationTimestampNumber longValue]];
    } else {
        //Creates a default expiration date.
        NSString *expirationString = [[EngageConfigManager sharedInstance] configForGeneralFieldName:PLIST_GENERAL_DEFAULT_CURRENT_CAMPAIGN_EXPIRATION];
        EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:expirationString fromDate:[NSDate date]];
        currentCampaignExpirationDate = [NSDate dateWithTimeInterval:[exp secondsParsedFromExpiration] sinceDate:[NSDate date]];
    }
    NSLog(@"Setting CurrentCampaign to %@ with expiration of %@", currentCampaign, currentCampaignExpirationDate);
    [defaults setObject:currentCampaign forKey:@"engageCurrentCampaign"];
    [defaults synchronize];
}


+ (void)storeEngageListId:(NSString *)paramEngageListId {
    engageListId = paramEngageListId;
}

+ (NSString *)engageListId {
    if (engageListId) {
        return engageListId;
    } else {
        NSLog(@"WARNING : No EngageListID has been set by SDK user yet. XMLAPI operation will fail!");
        return @"";
    }
}

@end
