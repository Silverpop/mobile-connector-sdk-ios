//
//  TestUtils.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UBF.h"

@interface TestUtils : NSObject

+ (NSString *)getLastCampaignFromInstalledEvent:(UBF *)ubfEvent;
+ (NSString *)getCurrentCampaignFromUBFEvent:(UBF *)ubfEvent;

@end
