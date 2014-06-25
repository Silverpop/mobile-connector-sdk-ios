//
//  UBFAugmentationPluginProtocol.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/10/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UBF.h"

@protocol UBFAugmentationPluginProtocol <NSObject>

@required
-(BOOL)processSyncronously;
-(BOOL)isSupplementalDataReady;
-(UBF*)process:(UBF*)ubfEvent;

@end
