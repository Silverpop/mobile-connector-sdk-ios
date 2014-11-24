//
//  EngageEvent.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/12/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EngageEvent : NSManagedObject

extern const int ALL_EVENTS;
extern const int NOT_POSTED;
extern const int SUCCESSFULLY_POSTED;
extern const int FAILED_POST;
extern const int HOLD;
extern const int EXPIRED;
extern const int PROCESSING;

extern NSString * const EVENT_TYPE_INSTALLED;
extern NSString * const EVENT_TYPE_SESSION_STARTED;
extern NSString * const EVENT_TYPE_SESSION_ENDED;
extern NSString * const EVENT_TYPE_GOAL_ABANDONED;
extern NSString * const EVENT_TYPE_GOAL_COMPLETED;
extern NSString * const EVENT_TYPE_NAMED_EVENT;
extern NSString * const EVENT_TYPE_RECEIVED_LOCAL_NOTIFICATION;
extern NSString * const EVENT_TYPE_RECEIVED_PUSH_NOTIFICATION;
extern NSString * const EVENT_TYPE_OPENED_NOTIFICATION;

extern NSString * const UBF_CORE_VALUE_DEVICE_NAME;
extern NSString * const UBF_CORE_VALUE_DEVICE_VERSION;
extern NSString * const UBF_CORE_VALUE_OS_NAME;
extern NSString * const UBF_CORE_VALUE_OS_VERSION;
extern NSString * const UBF_CORE_VALUE_APP_NAME;
extern NSString * const UBF_CORE_VALUE_APP_VERSION;
extern NSString * const UBF_CORE_VALUE_DEVICE_ID;
extern NSString * const UBF_CORE_VALUE_PRIMARY_USER_ID;
extern NSString * const UBF_CORE_VALUE_ANONYMOUS_ID;

@property (nonatomic, retain) NSNumber * eventType;
@property (nonatomic, retain) NSNumber * eventStatus;
@property (nonatomic, retain) NSDate * eventDate;
@property (nonatomic, retain) NSString * eventJson;

@end
