//
//  UBFAugmentationOperation.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/10/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "UBF.h"
#import "EngageEvent.h"

@interface UBFAugmentationOperation : NSOperation

-(id)initWithPlugins:(NSMutableArray *)augPlugins ubfEvent:(UBF *)ubfEvent engageEvent:(EngageEvent *)engageEvent;

@end
