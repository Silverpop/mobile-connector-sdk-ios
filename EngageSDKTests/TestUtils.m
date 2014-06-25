//
//  TestUtils.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "TestUtils.h"
#import "EngageConfig.h"
#import "EngageConfigManager.h"

@implementation TestUtils


+ (NSString *)getLastCampaignFromInstalledEvent:(UBF *)ubfEvent {
    if (ubfEvent) {
        NSString *lastCampaignFieldName = [[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LAST_CAMPAIGN_NAME];
        return [ubfEvent.attributes objectForKey:lastCampaignFieldName];
    }
    return @"";
}

+ (NSString *)getCurrentCampaignFromUBFEvent:(UBF *)ubfEvent {
    if (ubfEvent) {
        NSString *campaignFieldName = [[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
        return [ubfEvent.attributes objectForKey:campaignFieldName];
    }
    return @"";
}

@end
