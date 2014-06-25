//
//  UBFLocationNameAugmentationPlugin.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/25/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UBFAugmentationPluginProtocol.h"
#import "UBF.h"

@interface UBFLocationNameAugmentationPlugin : NSObject<UBFAugmentationPluginProtocol>

-(BOOL)processSyncronously;
-(BOOL)isSupplementalDataReady;
-(UBF*)process:(UBF*)ubfEvent;

@end
