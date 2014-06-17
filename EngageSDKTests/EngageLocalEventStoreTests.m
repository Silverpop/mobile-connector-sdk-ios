//
//  EngageLocalEventStoreTests.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/14/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EngageLocalEventStore.h"
#import "EngageConfig.h"
#import "UBF.h"

@interface EngageLocalEventStoreTests : XCTestCase

@end

@implementation EngageLocalEventStoreTests

- (void)setUp
{
    [super setUp];
    
    [[EngageLocalEventStore sharedInstance] deleteAllUBFEvents];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testFindLocalEngageEventWithIdentifier {
    
    //Test that no events exist period.
    XCTAssertTrue([[EngageLocalEventStore sharedInstance] countForEventType:ALL_EVENTS] == 0);
    
    id installed = [UBF installed:nil];
    NSURL *urlIdentifier = [[[[EngageLocalEventStore sharedInstance] saveUBFEvent:installed status:NOT_POSTED] objectID] URIRepresentation];
    EngageEvent *locatedEvent = [[EngageLocalEventStore sharedInstance] findEngageEventWithIdentifier:urlIdentifier];
    XCTAssertTrue(locatedEvent != nil, @"Unable to locate EngageEvent from local Event Store with identifier %@", urlIdentifier);
    
    //Tests that a single value is now present in the core data DB.
    XCTAssertTrue([[EngageLocalEventStore sharedInstance] countForEventType:ALL_EVENTS] == 1);
    XCTAssertTrue([[EngageLocalEventStore sharedInstance] countForEventType:12] == 1);
    
    [[[EngageLocalEventStore sharedInstance] managedObjectContext] deleteObject:locatedEvent];
    locatedEvent = [[EngageLocalEventStore sharedInstance] findEngageEventWithIdentifier:urlIdentifier];
    XCTAssertTrue([locatedEvent isDeleted], @"EngageEvent: expected deleted state in Core Data!");
}

-(void)testDeletingExpiredEventsFromCoreDataDB {
    
    //Create some Events that are older than the default expiration date of 30 days. Just dirty approach for testing.
    int daysAgo = 31;
    NSDate *date = [[NSDate alloc] init];
    date = [date dateByAddingTimeInterval:-(60*60*24*daysAgo)];
    
    //Save the events into Core Data
    NSMutableArray *engageEvents = [[NSMutableArray alloc] init];
    NSArray *events = [self createSampleUBFEvents];
    for (id event in events) {
        [engageEvents addObject:[[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:NOT_POSTED]];
    }
    
    for (EngageEvent *ea in engageEvents) {
        ea.eventDate = date;
    }
    
    NSError *error;
    [[[EngageLocalEventStore sharedInstance] managedObjectContext] save:&error];
    
    //Gets the count before the delete.
    NSUInteger count = [[EngageLocalEventStore sharedInstance] countForEventType:ALL_EVENTS];
    
    //Deletes the expired events.
    [[EngageLocalEventStore sharedInstance] deleteExpiredLocalEvents];
    
    NSUInteger afterDeleteCount = [[EngageLocalEventStore sharedInstance] countForEventType:ALL_EVENTS];
    
    XCTAssertTrue(((count - afterDeleteCount) == [events count]), @"Expired events were not deleted from the local event store");
}


-(void)testGenerateStateAndTokenForUBFModel {
    id installed = [UBF installed:nil];
    EngageEvent *event = [[EngageLocalEventStore sharedInstance] saveUBFEvent:installed status:[[NSNumber numberWithInt:NOT_POSTED] intValue]];
    
    XCTAssertTrue(![[event objectID] isTemporaryID], @"Saved EngageEvent reports having a temporary id!");
    XCTAssertTrue(![event isFault], @"Inserted EngageEvent is in a faulty state within CoreData");
    NSURL *token = [[event objectID] URIRepresentation];
    XCTAssertTrue(token != nil, @"Unique URI Token was not returned for EngageEvent");
}

-(void)testQueryCoreDataForUBFEventTypeCounts {
    
    //Directly inserts some unposted events into Core Data
    NSArray *events = [self createSampleUBFEvents];
    
    for (id event in events) {
        [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:[[NSNumber numberWithInt:NOT_POSTED] intValue]];
    }

    XCTAssertTrue([[EngageLocalEventStore sharedInstance] countForEventType:12] == 1, @"More than 1 Engage installed event was located in the local event store");
}

- (void)testCountUnpostedEventsInLocalStore {
    //Directly inserts some unposted events into Core Data
    NSArray *events = [self createSampleUBFEvents];
    
    for (id event in events) {
        [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:[[NSNumber numberWithInt:NOT_POSTED] intValue]];
    }
    
    //Finds the unposted events.
    XCTAssertTrue([[EngageLocalEventStore sharedInstance] unpostedEventsCount] == [events count], @"Expected to find %lu unposted UBF events in the Local Core Data Event Store", (unsigned long)[events count]);
}

-(void)testQueryLocalEventStoreForUnPostedUBFEvents {
    
    //Directly inserts some unposted events into Core Data
    NSArray *events = [self createSampleUBFEvents];
    
    for (id event in events) {
        [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:[[NSNumber numberWithInt:NOT_POSTED] intValue]];
    }
    
    //Finds the unposted events.
    NSArray *unpostedEvents = [[EngageLocalEventStore sharedInstance] findUnpostedEvents];
    XCTAssertTrue([unpostedEvents count] == [events count], @"Expected to find %lu unposted UBF events in the Local Core Data Event Store", (unsigned long)[events count]);
    
    NSError *saveError;
    
    //Mark 3 of the events as posted.
    EngageEvent *event0 = unpostedEvents[0];
    event0.eventStatus = [[NSNumber alloc] initWithInt:SUCCESSFULLY_POSTED];
    
    EngageEvent *event1 = unpostedEvents[1];
    event1.eventStatus = [[NSNumber alloc] initWithInt:SUCCESSFULLY_POSTED];
    
    EngageEvent *event2 = unpostedEvents[2];
    event2.eventStatus = [[NSNumber alloc] initWithInt:SUCCESSFULLY_POSTED];
    
    if (![[[EngageLocalEventStore sharedInstance] managedObjectContext] save:&saveError]) {
        XCTFail(@"Problem updating EngageEvents as posted %@", [saveError description]);
    }
    
    unpostedEvents = [[EngageLocalEventStore sharedInstance] findUnpostedEvents];
    XCTAssertTrue([unpostedEvents count] == ([events count] - 3), @"Expected an unposted event size of %lu", (unsigned long)[events count]);
}

-(NSArray *)createSampleUBFEvents {
    NSMutableArray *events = [[NSMutableArray alloc] init];
    [events addObject:[UBF installed:nil]];
    [events addObject:[UBF goalAbandoned:@"" params:nil]];
    [events addObject:[UBF namedEvent:@"" params:nil]];
    [events addObject:[UBF sessionEnded:nil]];
    return events;
}

@end
