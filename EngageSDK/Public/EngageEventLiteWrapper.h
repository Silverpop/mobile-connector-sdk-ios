//
//  EngageEventLiteWrapper.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/30/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngageEvent.h"

@interface EngageEventLiteWrapper : NSObject

- (id) initWithUBFEvent:(NSDictionary *)ubfEvent engageEvent:(EngageEvent *)engageEvent;

@property (strong, nonatomic) NSDictionary *ubfEvent;
@property (strong, nonatomic) NSURL *engageEventIdentifier;

@end
