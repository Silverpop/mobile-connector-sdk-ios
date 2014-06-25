//
//  EngageEvent.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/12/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "EngageEvent.h"


@implementation EngageEvent

const int ALL_EVENTS = -1;
const int NOT_POSTED = 1;
const int SUCCESSFULLY_POSTED = 2;
const int FAILED_POST = 3;
const int HOLD = 4;
const int EXPIRED = 5;
const int PROCESSING = 6;


@dynamic eventType;
@dynamic eventStatus;
@dynamic eventDate;
@dynamic eventJson;

@end
