//
//  EngageDefaultUUIDGenerator.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/21/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngageDefaultUUIDGenerator.h"

@implementation EngageDefaultUUIDGenerator

- (NSString *) generateUUID {
    return [[NSUUID UUID] UUIDString];
}

@end
