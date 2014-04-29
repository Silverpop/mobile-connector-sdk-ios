//
//  EngageLocalEventStore.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 4/23/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "EngageLocalEventStore.h"

#define MAX_EVENTS_AGE_IN_DAYS 0
#define ENGAGE_EVENT_CORE_DATA @"EngageEvent"
#define UNPOSTED_EVENT_REQUEST_NAME @"UnpostedEvents"
#define EXPIRED_EVENT_REQUEST_NAME @"ExpiredEvents"

@implementation EngageLocalEventStore

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistenceStoreCoordinator = _persistenceStoreCoordinator;


- (id) init {
    self = [super init];
    if (self) {
        //Setup core data
        [self managedObjectContext];
    }
    return self;
}

+ (EngageLocalEventStore *)sharedInstance
{
    static EngageLocalEventStore *sharedInstance = nil;
    static dispatch_once_t isDispatched;
    
    dispatch_once(&isDispatched, ^{
        sharedInstance = [[EngageLocalEventStore alloc] init];
    });
    
    return sharedInstance;
}


- (NSArray *) findUnpostedEvents {
    NSError *error;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ENGAGE_EVENT_CORE_DATA inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *unpostedEventsRequest = [[NSFetchRequest alloc] init];
    [unpostedEventsRequest setEntity:entityDescription];
    NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"(eventHasPosted < 1) OR (eventHasPosted = nil)"];
    [unpostedEventsRequest setPredicate:predicateTemplate];

    return [self.managedObjectContext executeFetchRequest:unpostedEventsRequest error:&error];
}


- (void)deleteExpiredLocalEvents {
    NSError *error;
    
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ENGAGE_EVENT_CORE_DATA inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *expiredEventsFetchRequest = [[NSFetchRequest alloc] init];
    [expiredEventsFetchRequest setEntity:entityDescription];
    [expiredEventsFetchRequest setPredicate:[self predicateToRetrieveExpiredEventsFromDate:[[NSDate alloc] init]]];
    NSArray *results = [[EngageLocalEventStore sharedInstance].managedObjectContext executeFetchRequest:expiredEventsFetchRequest error:&error];
    
    uint deletedEvents = 0;
    for (NSManagedObject *managedObj in results) {
        [self.managedObjectContext deleteObject:managedObj];
    }

    if ([self.managedObjectContext save:&error]) {
        NSLog(@"%du expired local events were purged from the local events store : %d days old from today %@",
              deletedEvents, MAX_EVENTS_AGE_IN_DAYS, [[NSDate alloc] init]);
    } else {
        NSLog(@"Error while deleting expired ubf events from local events store %@", error);
    }
}

-(EngageEvent *)saveUBFEvent:(NSDictionary *)event {
    EngageEvent *engageEvent = [NSEntityDescription insertNewObjectForEntityForName:@"EngageEvent" inManagedObjectContext:[EngageLocalEventStore sharedInstance].managedObjectContext];

    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    NSNumber *myNumber = [f numberFromString:[event objectForKey:@"eventTypeCode"]];
    engageEvent.eventType = myNumber;
    engageEvent.eventJson = [self createJsonStringFromDictionary:event];
    engageEvent.eventHasPosted = [[NSNumber alloc] initWithInt:0];
    engageEvent.eventDate = [NSDate date];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unable to save UBFEvent %@ to EngageLocalEventStore. Silverpop HTTP Post will still be attempted.", engageEvent.description);
    }
    
    return engageEvent;
}


- (NSString *)createJsonStringFromDictionary:(NSDictionary *)dictionary {
    NSError *error;
    NSString *jsonString;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dictionary
                                                       options:0
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Got an error: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}


#pragma mark - Core Data stack

// Returns the managed object context for hte application.
// If the context doesn't already exist, it is create and bound to the persistent store coordinator for the application.
- (NSManagedObjectContext *)managedObjectContext
{
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistenceStoreCoordinator];
    if (coordinator != nil) {
        _managedObjectContext = [[NSManagedObjectContext alloc] init];
        [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
    return _managedObjectContext;
}

// In lue of IOS SDK modules not having to copy as many resources to the target destination we create a simple managed object model programmatically
- (NSManagedObjectModel *)managedObjectModel
{
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    
    //Create the managed object model programmatically.
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] init];
    NSEntityDescription *engageEventEntity = [[NSEntityDescription alloc] init];
    [engageEventEntity setName:@"EngageEvent"];
    [engageEventEntity setManagedObjectClassName:ENGAGE_EVENT_CORE_DATA];
    [mom setEntities:@[engageEventEntity]];
    
    NSMutableArray *engageEventProperties = [NSMutableArray array];
    
    NSAttributeDescription *eventDateAttribute = [[NSAttributeDescription alloc] init];
    [engageEventProperties addObject:eventDateAttribute];
    [eventDateAttribute setName:@"eventDate"];
    [eventDateAttribute setAttributeType:NSDateAttributeType];
    [eventDateAttribute setOptional:NO];
    
    NSAttributeDescription *eventTypeAttribute = [[NSAttributeDescription alloc] init];
    [engageEventProperties addObject:eventTypeAttribute];
    [eventTypeAttribute setName:@"eventType"];
    [eventTypeAttribute setAttributeType:NSInteger16AttributeType];
    [eventTypeAttribute setOptional:NO];
    
    NSAttributeDescription *eventJsonAttribute= [[NSAttributeDescription alloc] init];
    [engageEventProperties addObject:eventJsonAttribute];
    [eventJsonAttribute setName:@"eventJson"];
    [eventJsonAttribute setAttributeType:NSStringAttributeType];
    [eventJsonAttribute setOptional:NO];
    
    NSAttributeDescription *eventHasPostedAttribute = [[NSAttributeDescription alloc] init];
    [engageEventProperties addObject:eventHasPostedAttribute];
    [eventHasPostedAttribute setName:@"eventHasPosted"];
    [eventHasPostedAttribute setAttributeType:NSInteger16AttributeType];
    [eventHasPostedAttribute setOptional:NO];
    [eventHasPostedAttribute setDefaultValue:0];
    
    [engageEventEntity setProperties:engageEventProperties];
    
    _managedObjectModel = mom;
    return mom;
}


//- (void)createFetchRequestTemplates:(NSManagedObjectModel *)managedObjectModel {
//    NSFetchRequest *unpostedEventsTemplate = [[NSFetchRequest alloc] init];
//    NSEntityDescription *engageEventEntity = [[managedObjectModel entitiesByName] objectForKey:ENGAGE_EVENT_CORE_DATA];
//    [unpostedEventsTemplate setEntity:engageEventEntity];
//    
//    NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"(eventHasPosted < 1) OR (eventHasPosted = nil)"];
//    [unpostedEventsTemplate setPredicate:predicateTemplate];
//    
//    NSFetchRequest *expiredEventsTemplate = [[NSFetchRequest alloc] init];
//    [expiredEventsTemplate setEntity:engageEventEntity];
//    [expiredEventsTemplate setPredicate:[self predicateToRetrieveExpiredEventsFromDate:[[NSDate alloc] init]]];
//    
//    [managedObjectModel setFetchRequestTemplate:unpostedEventsTemplate forName:UNPOSTED_EVENT_REQUEST_NAME];
//    [managedObjectModel setFetchRequestTemplate:expiredEventsTemplate forName:EXPIRED_EVENT_REQUEST_NAME];
//}


- (NSPredicate *) predicateToRetrieveExpiredEventsFromDate:(NSDate *)aDate {
    
    // start by retrieving day, weekday, month and year components for the given day
    NSCalendar *gregorian = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSDateComponents *todayComponents = [gregorian components:(NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit) fromDate:aDate];
    NSInteger theDay = [todayComponents day];
    NSInteger theMonth = [todayComponents month];
    NSInteger theYear = [todayComponents year];
    
    NSDateComponents *components = [[NSDateComponents alloc] init];
    [components setDay:theDay];
    [components setMonth:theMonth];
    [components setYear:theYear];
    NSDate *thisDate = [gregorian dateFromComponents:components];
    
    // build a NSDate for oldest date we want to keep in the local store
    NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
    //[offsetComponents setDay:-MAX_EVENTS_AGE_IN_DAYS];
    [offsetComponents setDay:-100];
    NSDate *oldestDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
    
    NSLog(@"Oldest Date is %@", oldestDate);
    
    // build the predicate
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"eventDate <= %@", oldestDate];
    
    return predicate;
}


// Returns the persistent store coordinator for the application
// If the coordinator doesn't already exist, it is created and the application's store added to it.
- (NSPersistentStoreCoordinator *)persistenceStoreCoordinator {
    if (_persistenceStoreCoordinator != nil) {
        return _persistenceStoreCoordinator;
    }
    
    NSURL *storeUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"EngageLatest8.sqlite"];
    
    NSError *error = nil;
    _persistenceStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    if (![_persistenceStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeUrl options:@{NSMigratePersistentStoresAutomaticallyOption:@YES, NSInferMappingModelAutomaticallyOption:@YES} error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistenceStoreCoordinator;
}

- (NSURL *)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

@end
