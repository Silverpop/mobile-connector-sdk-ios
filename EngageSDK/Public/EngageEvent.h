//
//  EngageEvent.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 4/22/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#define NOT_POSTED 0
#define SUCCESSFULLY_POSTED 1
#define FAILED_POST 2
#define HOLD 3
#define EXPIRED 4

@interface EngageEvent : NSManagedObject

@property (nonatomic, retain) NSNumber *eventType;
@property (nonatomic, retain) NSString *eventJson;
@property (nonatomic, retain) NSNumber *eventStatus;
@property (nonatomic, retain) NSDate *eventDate;

@end
