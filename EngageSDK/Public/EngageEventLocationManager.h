//
//  EngageEventLocationManager.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EngageEventLocationManager : NSObject

+ (id)sharedInstance;

- (id)geocodeUBFEvent:(NSDictionary *)ubfEvent;

@end
