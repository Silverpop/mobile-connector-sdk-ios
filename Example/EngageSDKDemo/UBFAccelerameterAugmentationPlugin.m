//
//  UBFAccelerameterAugmentationPlugin.m
//  EngageSDKDemo
//
//  Created by Jeremy Dyer on 6/27/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "UBFAccelerameterAugmentationPlugin.h"
#import "EngageMotionManager.h"

@interface UBFAccelerameterAugmentationPlugin()

@property (nonatomic, strong) EngageMotionManager *engageMotionManager;

@end

@implementation UBFAccelerameterAugmentationPlugin

-(id)init {
    self = [super init];
    if (self) {
        self.engageMotionManager = [EngageMotionManager sharedInstance];
    }
    return self;
}


-(BOOL)processSyncronously {
    return YES;
}


-(BOOL)isSupplementalDataReady:(UBF*)ubfEvent {
    return YES;
}


-(UBF*)process:(UBF *)ubfEvent {
    if (ubfEvent) {
        EngageMotionManager *emm = [EngageMotionManager sharedInstance];
        [ubfEvent setAttribute:DEVICE_YAW_DEGREES value:[[NSNumber numberWithDouble:emm.yawDegrees] stringValue]];
        [ubfEvent setAttribute:DEVICE_PITCH_DEGREES value:[[NSNumber numberWithDouble:emm.pitchDegrees] stringValue]];
        [ubfEvent setAttribute:DEVICE_ROLL_DEGREES value:[[NSNumber numberWithDouble:emm.rollDegrees] stringValue]];
    }
    return ubfEvent;
}

@end
