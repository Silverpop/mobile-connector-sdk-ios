//
//  EngageEventWrapper.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/30/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngageEvent.h"
#import "UBF.h"

@interface EngageEventWrapper : NSObject

- (id) initWithUBFEvent:(UBF *)ubfEvent engageEvent:(EngageEvent *)engageEvent;

@property (strong, nonatomic) UBF *ubfEvent;
@property (strong, nonatomic) EngageEvent *engageEvent;

@end
