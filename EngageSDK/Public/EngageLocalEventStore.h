//
//  EngageLocalEventStore.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 4/23/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "EngageEvent.h"

@interface EngageLocalEventStore : NSObject

+ (EngageLocalEventStore *)sharedInstance;

- (NSArray *) findUnpostedEvents;
- (void) deleteExpiredLocalEvents;
- (EngageEvent *)saveUBFEvent:(NSDictionary *)event;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistenceStoreCoordinator;

@end
