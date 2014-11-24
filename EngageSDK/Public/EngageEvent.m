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

NSString *const EVENT_TYPE_INSTALLED = @"12";
NSString *const EVENT_TYPE_SESSION_STARTED = @"13";
NSString *const EVENT_TYPE_SESSION_ENDED = @"14";
NSString *const EVENT_TYPE_GOAL_ABANDONED = @"15";
NSString *const EVENT_TYPE_GOAL_COMPLETED = @"16";
NSString *const EVENT_TYPE_NAMED_EVENT = @"17";
NSString *const EVENT_TYPE_RECEIVED_LOCAL_NOTIFICATION = @"48";
NSString *const EVENT_TYPE_RECEIVED_PUSH_NOTIFICATION = @"48";
NSString *const EVENT_TYPE_OPENED_NOTIFICATION = @"49";

NSString *const UBF_CORE_VALUE_DEVICE_NAME = @"Device Name";
NSString *const UBF_CORE_VALUE_DEVICE_VERSION = @"Device Version";
NSString *const UBF_CORE_VALUE_OS_NAME = @"OS Name";
NSString *const UBF_CORE_VALUE_OS_VERSION = @"OS Version";
NSString *const UBF_CORE_VALUE_APP_NAME = @"App Name";
NSString *const UBF_CORE_VALUE_APP_VERSION = @"App Version";
NSString *const UBF_CORE_VALUE_DEVICE_ID = @"Device Id";
NSString *const UBF_CORE_VALUE_PRIMARY_USER_ID = @"Primary User Id";
NSString *const UBF_CORE_VALUE_ANONYMOUS_ID = @"Anonymous Id";


@dynamic eventType;
@dynamic eventStatus;
@dynamic eventDate;
@dynamic eventJson;

@end
