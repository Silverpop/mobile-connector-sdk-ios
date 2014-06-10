//
//  UBFCoordinatesAugmentationPlugin.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/10/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "UBFCoordinatesAugmentationPlugin.h"

@implementation UBFCoordinatesAugmentationPlugin

-(BOOL)isSupplementalDataReady {
    return YES;
}

-(UBF*)process:(UBF*)ubfEvent {
    return ubfEvent;
}

@end
