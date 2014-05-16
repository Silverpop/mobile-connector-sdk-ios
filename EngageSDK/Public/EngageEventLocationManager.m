//
//  EngageEventLocationManager.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "EngageEventLocationManager.h"

@implementation EngageEventLocationManager

+ (id)sharedInstance
{
    static dispatch_once_t pred;
    static EngageEventLocationManager *sharedInstance = nil;
    dispatch_once(&pred, ^
                  {
                      sharedInstance = [[EngageEventLocationManager alloc] init];
                  });
    return sharedInstance;
}

- (id)geocodeUBFEvent:(NSDictionary *)ubfEvent {
    //TODO: 2.1 implementation
    NSLog(@"GEOCoding UBF event %@", ubfEvent);
    return ubfEvent;
}

@end
