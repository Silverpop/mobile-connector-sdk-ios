//
//  TestUtils.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "TestUtils.h"

@implementation TestUtils


+ (NSString *)getLastCampaignFromInstalledEvent:(id)ubfEvent {
    for (id val in [ubfEvent valueForKey:@"attributes"]) {
        if ([[val valueForKey:@"name"] isEqualToString:@"Last Campaign"]) {
            return [val valueForKey:@"value"];
        }
    }
    return @"";
}

+ (NSString *)getCurrentCampaignFromUBFEvent:(id)ubfEvent {
    for (id val in [ubfEvent valueForKey:@"attributes"]) {
        if ([[val valueForKey:@"name"] isEqualToString:@"Campaign Name"]) {
            return [val valueForKey:@"value"];
        }
    }
    return @"";
}

@end
