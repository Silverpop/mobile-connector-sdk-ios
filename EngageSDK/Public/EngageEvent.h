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

@property (nonatomic, retain) NSNumber * eventType;
@property (nonatomic, retain) NSNumber * eventStatus;
@property (nonatomic, retain) NSDate * eventDate;
@property (nonatomic, retain) NSString * eventJson;

@end
