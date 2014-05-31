//
//  EngageEventLiteWrapper.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/30/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "EngageEventLiteWrapper.h"

@implementation EngageEventLiteWrapper

- (id) initWithUBFEvent:(NSDictionary *)ubfEvent
            engageEvent:(EngageEvent *)engageEvent {
    self = [super init];
    
    if (self) {
        self.ubfEvent = ubfEvent;
        self.engageEventIdentifier = [[engageEvent objectID] URIRepresentation];
    }
    
    return self;
}

@end
