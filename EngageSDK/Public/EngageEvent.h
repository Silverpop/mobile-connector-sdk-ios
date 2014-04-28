//
//  EngageEvent.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 4/22/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface EngageEvent : NSManagedObject

@property (nonatomic, retain) NSNumber *eventType;
@property (nonatomic, retain) NSString *eventJson;
@property (nonatomic, retain) NSNumber *eventHasPosted;
@property (nonatomic, retain) NSDate *eventDate;

@end
