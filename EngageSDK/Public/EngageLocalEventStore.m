//
//  EngageLocalEventStore.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 4/23/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "EngageLocalEventStore.h"
#import "EngageConfigManager.h"

@interface EngageLocalEventStore()

@property (nonatomic, strong)NSNumberFormatter *f;

@end

@implementation EngageLocalEventStore

__strong NSString* ENGAGE_EVENT_CORE_DATA = @"EngageEvent";

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistenceStoreCoordinator = _persistenceStoreCoordinator;

- (id) init {
    self = [super init];
    if (self) {
        //Setup core data
        [self managedObjectContext];
        
        //Creates the NumberFormatter instance.
        self.f = [[NSNumberFormatter alloc] init];
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

- (NSUInteger) countForEventType:(int)eventType {
    NSError *error;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ENGAGE_EVENT_CORE_DATA inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *countEventsRequest = [[NSFetchRequest alloc] init];
    [countEventsRequest setEntity:entityDescription];
    NSPredicate *predicateTemplate = nil;
    
    if (eventType > 0) {
        predicateTemplate = [NSPredicate predicateWithFormat:@"eventType == %d", [[NSNumber numberWithInt:eventType] intValue]];
        [countEventsRequest setPredicate:predicateTemplate];
    }
    
    return [self.managedObjectContext countForFetchRequest:countEventsRequest error:&error];
}

- (NSUInteger) unpostedEventsCount {
    NSError *error;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ENGAGE_EVENT_CORE_DATA inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *countEventsRequest = [[NSFetchRequest alloc] init];
    [countEventsRequest setEntity:entityDescription];
    NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"(eventStatus == %d) OR (eventStatus == %d)",
                                      NOT_POSTED, EXPIRED];
    [countEventsRequest setPredicate:predicateTemplate];
    NSUInteger count = [self.managedObjectContext countForFetchRequest:countEventsRequest error:&error];
    return count;
}

- (NSUInteger) deleteAllUBFEvents {
    NSError *error;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ENGAGE_EVENT_CORE_DATA inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *deleteUBFEventsRequest = [[NSFetchRequest alloc] init];
    [deleteUBFEventsRequest setEntity:entityDescription];
    
    NSUInteger deletedCount = 0;
    NSArray *results = [[EngageLocalEventStore sharedInstance].managedObjectContext executeFetchRequest:deleteUBFEventsRequest error:&error];
    for (NSManagedObject *managedObj in results) {
        [self.managedObjectContext deleteObject:managedObj];
        deletedCount++;
    }
    
    return deletedCount;
}

- (EngageEvent *)findEngageEventWithIdentifier:(NSURL *)urlIdentifier {
    NSManagedObjectID *managedObjectId = [[self persistenceStoreCoordinator] managedObjectIDForURIRepresentation:urlIdentifier];
    
    if (!managedObjectId) {
        return nil;
    }
    
    EngageEvent *engageEvent = (EngageEvent *)[self.managedObjectContext objectWithID:managedObjectId];
    if (![engageEvent isFault]) {
        return engageEvent;
    }
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    request.returnsObjectsAsFaults = NO;
    [request setEntity:[managedObjectId entity]];
    
    NSPredicate *predicate = [NSComparisonPredicate predicateWithLeftExpression:[NSExpression expressionForEvaluatedObject]
                                                                rightExpression:[NSExpression expressionForConstantValue:engageEvent]
                                                                       modifier:NSDirectPredicateModifier
                                                                           type:NSEqualToPredicateOperatorType
                                                                        options:0];
    [request setPredicate:predicate];
    
    NSArray *results = [self.managedObjectContext executeFetchRequest:request error:nil];
    if ([results count] > 0 )
    {
        return [results objectAtIndex:0];
    }
    
    return nil;
}


- (NSArray *)findEngageEventsWithStatus:(int)eventStatus {
    NSError *error;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ENGAGE_EVENT_CORE_DATA inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *eventsWithStatusRequest = [[NSFetchRequest alloc] init];
    [eventsWithStatusRequest setEntity:entityDescription];
    NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"(eventStatus = %d)", eventStatus];
    [eventsWithStatusRequest setPredicate:predicateTemplate];
    return [self.managedObjectContext executeFetchRequest:eventsWithStatusRequest error:&error];
}


- (NSArray *) findUnpostedEvents {
    NSError *error;
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:ENGAGE_EVENT_CORE_DATA inManagedObjectContext:self.managedObjectContext];
    NSFetchRequest *unpostedEventsRequest = [[NSFetchRequest alloc] init];
    [unpostedEventsRequest setEntity:entityDescription];
    [unpostedEventsRequest setReturnsObjectsAsFaults:NO];
    NSPredicate *predicateTemplate = [NSPredicate predicateWithFormat:@"(eventStatus = %d) OR (eventStatus = %d)", NOT_POSTED, EXPIRED];
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
    
    int deletedEvents = 0;
    for (NSManagedObject *managedObj in results) {
        [self.managedObjectContext deleteObject:managedObj];
        deletedEvents++;
    }
    
    if ([self.managedObjectContext save:&error]) {
        NSLog(@"%d expired local events were purged from the local events store : %@ days old from today %@",
              deletedEvents, [[EngageConfigManager sharedInstance] numberConfigForLocalStoreFieldName:PLIST_LOCAL_STORE_EVENTS_EXPIRE_AFTER_DAYS], [[NSDate alloc] init]);
    } else {
        NSLog(@"Error while deleting expired ubf events from local events store %@", error);
    }
}


- (void)saveEvents {
    NSError *saveError;
    if (![[self managedObjectContext] save:&saveError]) {
        NSLog(@"Failure saving UBFEngageEvents: %@", [saveError description]);
    }
}


-(EngageEvent *)saveUBFEvent:(UBF *)event status:(int) status {
    EngageEvent *engageEvent = [NSEntityDescription insertNewObjectForEntityForName:@"EngageEvent" inManagedObjectContext:self.managedObjectContext];
    
    NSNumber *eventTypeNumber = [self.f numberFromString:[event eventTypeCode]];
    engageEvent.eventType = eventTypeNumber;
    engageEvent.eventJson = [event jsonValue];
    engageEvent.eventStatus = [NSNumber numberWithInt:status];
    engageEvent.eventDate = [NSDate date];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Unable to save UBFEvent %@ to EngageLocalEventStore. Silverpop HTTP Post will still be attempted.", engageEvent.description);
    }
    
    return engageEvent;
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
    
//    //NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Engage" withExtension:@"momd"];
//    //_managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
//    _managedObjectModel = [NSManagedObjectModel mergedModelFromBundles:nil];
//    return _managedObjectModel;
    
    //Create the managed object model programmatically.
    NSManagedObjectModel *mom = [[NSManagedObjectModel alloc] init];
    NSEntityDescription *engageEventEntity = [[NSEntityDescription alloc] init];
    [engageEventEntity setName:@"EngageEvent"];
    [engageEventEntity setManagedObjectClassName:ENGAGE_EVENT_CORE_DATA];
    
    NSMutableArray *engageEventProperties = [NSMutableArray array];
    
    NSAttributeDescription *eventDateAttribute = [[NSAttributeDescription alloc] init];
    [eventDateAttribute setName:@"eventDate"];
    [eventDateAttribute setAttributeType:NSDateAttributeType];
    [eventDateAttribute setOptional:NO];
    [engageEventProperties addObject:eventDateAttribute];
    
    NSAttributeDescription *eventTypeAttribute = [[NSAttributeDescription alloc] init];
    [eventTypeAttribute setName:@"eventType"];
    [eventTypeAttribute setAttributeType:NSInteger32AttributeType];
    [eventTypeAttribute setOptional:NO];
    //[eventTypeAttribute set]
    [engageEventProperties addObject:eventTypeAttribute];
    
    NSAttributeDescription *eventJsonAttribute= [[NSAttributeDescription alloc] init];
    [eventJsonAttribute setName:@"eventJson"];
    [eventJsonAttribute setAttributeType:NSStringAttributeType];
    [eventJsonAttribute setOptional:NO];
    [engageEventProperties addObject:eventJsonAttribute];
    
    NSAttributeDescription *eventStatusAttribute = [[NSAttributeDescription alloc] init];
    [eventStatusAttribute setName:@"eventStatus"];
    [eventStatusAttribute setAttributeType:NSInteger32AttributeType];
    [eventStatusAttribute setOptional:NO];
    [eventStatusAttribute setDefaultValue:0];
    [engageEventProperties addObject:eventStatusAttribute];
    
    [engageEventEntity setProperties:engageEventProperties];
    
    [mom setEntities:@[engageEventEntity]];
    _managedObjectModel = mom;
    return mom;
}


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
    [offsetComponents setDay:-[[[EngageConfigManager sharedInstance] numberConfigForLocalStoreFieldName:PLIST_LOCAL_STORE_EVENTS_EXPIRE_AFTER_DAYS] longValue]];
    NSDate *oldestDate = [gregorian dateByAddingComponents:offsetComponents toDate:thisDate options:0];
    
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
    
    NSURL *storeUrl = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"EngageEventLocalStore2.sqlite"];
    
//    NSString *modelPath = [[NSBundle mainBundle]
//                           pathForResource:@"Engage" ofType:@"mom"];
//    NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
//    [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
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
