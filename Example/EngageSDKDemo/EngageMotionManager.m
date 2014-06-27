//
//  EngageMotionManager.m
//  EngageSDKDemo
//
//  Created by Jeremy Dyer on 6/27/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "EngageMotionManager.h"

@interface EngageMotionManager()

@property (nonatomic, strong) CMMotionManager *motionManager;

@end

@implementation EngageMotionManager

__strong static EngageMotionManager *_sharedInstance = nil;

-(id) init {
    self = [super init];
    if (self) {
        self.motionManager = [[CMMotionManager alloc] init];
        self.dataReceived = NO;
        
        [self.motionManager startDeviceMotionUpdatesToQueue:[[NSOperationQueue alloc] init] withHandler:^(CMDeviceMotion *motion, NSError *error) {
            CMAttitude *attitude = [motion attitude];
            self.dataReceived = YES;
            self.yawDegrees = ([attitude yaw] * 180) / M_PI;
            self.pitchDegrees = ([attitude pitch] * 180) / M_PI;
            self.rollDegrees = ([attitude roll] * 180) / M_PI;
        }];
    }
    return self;
}


+ (id)sharedInstance {
    if (_sharedInstance == nil) {
        static dispatch_once_t pred = 0;
        dispatch_once(&pred, ^{
            _sharedInstance = [[EngageMotionManager alloc] init];
        });
    }
    return _sharedInstance;
}

@end
