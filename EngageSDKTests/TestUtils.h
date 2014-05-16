//
//  TestUtils.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TestUtils : NSObject

+ (NSString *)getLastCampaignFromInstalledEvent:(id)ubfEvent;

+ (NSString *)getCurrentCampaignFromUBFEvent:(id)ubfEvent;

@end
