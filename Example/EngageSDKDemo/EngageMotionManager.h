//
//  EngageMotionManager.h
//  EngageSDKDemo
//
//  Created by Jeremy Dyer on 6/27/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>

@interface EngageMotionManager : NSObject

+ (id)sharedInstance;

@property (assign) double yawDegrees;
@property (assign) double pitchDegrees;
@property (assign) double rollDegrees;
@property (assign) BOOL dataReceived;

@end
