//
//  UBFManagerTests.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/30/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>

@interface UBFManagerTests : XCTestCase

@end

@implementation UBFManagerTests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

///*
// Test should validate that when no network is present that UBF events are not attempted to be sent to SilverPop.
// The test will programmatically sent the network Reachability to false and then add 4 UBF events (3 are queued before delivery attempt)
// and then check the size of the NSOperationQueue to ensure a size of 4. After check will turn network reachability on and
// then check for proper drainage.
// */
//-(void)testUBFEventNetworkOffline {
//    
//    NSLog(@"Creating and setting new network reachability manager that is offline");
//    [[self.ubfClient operationQueue] setSuspended:YES];
//    
//    [[self.ubfClient operationQueue] cancelAllOperations];
//    NSLog(@"Current Queue Size %lu", (unsigned long)[[self.ubfClient operationQueue] operationCount]);
//    XCTAssertTrue([[self.ubfClient operationQueue] operationCount] == 0, @"UBFClient Operations Queue must be 0 before starting test!");
//    XCTAssertTrue([[self.ubfClient reachabilityManager] isReachable] == NO, @"Network must not be reachable to perform this test");
//    
//    NSLog(@"Current Queue Size After %lu", (unsigned long)[[self.ubfClient operationQueue] operationCount]);
//    
//    //Stuff events in the UBFClient and make sure that they are not sent.
//    id installedEvent = [UBF installed:nil];
//    id goalCompleted = [UBF goalAbandoned:@"" params:nil];
//    id namedEvent = [UBF namedEvent:@"" params:nil];
//    id sessionEnded = [UBF sessionEnded:nil];
//    
//    NSUInteger previousCoreDataCount = [[EngageLocalEventStore sharedInstance] countForEventType:nil];
//    NSLog(@"Previous Core Data Count %lul", (unsigned long)previousCoreDataCount);
//    
//    //Track the 4 new events (Note session started was automatically added so really there is 5).
//    [self.ubfClient trackingEvent:installedEvent];
//    [self.ubfClient trackingEvent:goalCompleted];
//    [self.ubfClient trackingEvent:namedEvent];
//    [self.ubfClient trackingEvent:sessionEnded];
//    
//    NSLog(@"Reachability Status here %ld", [[self.ubfClient reachabilityManager] networkReachabilityStatus]);
//    NSLog(@"OperationQueue should be suspended but is it?? %d", [[self.ubfClient operationQueue] isSuspended]);
//    
//    //Check to make sure that the NSOperationQueue has the 5 events queued in it.
//    NSLog(@"OperationQueue Count %lu", (unsigned long)[[self.ubfClient operationQueue] operationCount]);
//    XCTAssertTrue([[self.ubfClient operationQueue] operationCount] == floor(5 / [self.ubfClient eventCacheSize]), @"Expected NSOperationQueue to contain %f UBF Event Operations", floor(5 / [self.ubfClient eventCacheSize]));
//    
//    //Check the Core Data store for the 5 UBF events were persisted.
//    NSUInteger afterCoreDataCount = [[EngageLocalEventStore sharedInstance] countForEventType:nil];
//    NSLog(@"After Core Data Count %lul", (unsigned long)afterCoreDataCount);
//    XCTAssertTrue(previousCoreDataCount < afterCoreDataCount, @"After persisting 4 UBF Events Core Data store should have grown with those events");
//    XCTAssertTrue((previousCoreDataCount + 4) == afterCoreDataCount, @"Not all 4 UBF events were saved to Core Data!");
//}


///*
// Tests posting UBF events with an active network connection.
//*/
//-(void)testUBFEventNetworkOnline {
//
//    [[self.ubfClient operationQueue] setSuspended:NO];
//    [[self.ubfClient operationQueue] cancelAllOperations];
//    NSLog(@"Current Queue Size %lu", (unsigned long)[[self.ubfClient operationQueue] operationCount]);
//    XCTAssertTrue([[self.ubfClient operationQueue] operationCount] == 0, @"UBFClient Operations Queue must be 0 before starting test!");
//    NSLog(@"Reachability Status %ld", [[self.ubfClient reachabilityManager] networkReachabilityStatus]);
//
//    //Stuff events in the UBFClient and make sure that they are not sent.
//    id installedEvent = [UBF installed:nil];
//    id goalCompleted = [UBF goalAbandoned:@"" params:nil];
//    id namedEvent = [UBF namedEvent:@"" params:nil];
//    id sessionEnded = [UBF sessionEnded:nil];
//
//    NSUInteger previousCoreDataCount = [[EngageLocalEventStore sharedInstance] countForEventType:nil];
//    NSLog(@"Previous Core Data Count %lul", (unsigned long)previousCoreDataCount);
//
//    //Track the 4 new events (Note session started was automatically added so really there is 5).
//    [self.ubfClient trackingEvent:installedEvent];
//    [self.ubfClient trackingEvent:goalCompleted];
//    [self.ubfClient trackingEvent:namedEvent];
//    [self.ubfClient trackingEvent:sessionEnded];
//
//    //Check to make sure that the NSOperationQueue has the 5 events queued in it.
//    NSLog(@"OperationQueue Count %lu", (unsigned long)[[self.ubfClient operationQueue] operationCount]);
//    XCTAssertTrue([[self.ubfClient operationQueue] operationCount] == floor(5 / [self.ubfClient eventCacheSize]), @"Expected NSOperationQueue to contain %f UBF Event Operations", floor(5 / [self.ubfClient eventCacheSize]));
//
//    //Check the Core Data store for the 5 UBF events were persisted.
//    NSUInteger afterCoreDataCount = [[EngageLocalEventStore sharedInstance] countForEventType:nil];
//    NSLog(@"After Core Data Count %lul", (unsigned long)afterCoreDataCount);
//    XCTAssertTrue(previousCoreDataCount < afterCoreDataCount, @"After persisting 4 UBF Events Core Data store should have grown with those events");
//    XCTAssertTrue((previousCoreDataCount + 4) == afterCoreDataCount, @"Not all 4 UBF events were saved to Core Data!");
//
//    //Find how many of the events are in the queue. Should theoretically be
//    NSLog(@"QUEUE COUNT %lu", (unsigned long)[[self.ubfClient operationQueue] operationCount]);
//    [self.ubfClient postEventCache];
//
//    NSLog(@"Waiting until all current NSOperationQueue Operations have completed before continuing tests");
//
//    [[self.ubfClient operationQueue] addOperationWithBlock:^(void) {
//        NSLog(@"Last NSOperation has finished executing");
//    }];
//
//    [[self.ubfClient operationQueue] waitUntilAllOperationsAreFinished];
//    XCTAssertTrue([[self.ubfClient operationQueue] operationCount] == 0, @"NSOperationQueue should be completed drained by now");
//    NSLog(@"Number of Unposted Events %ld", [[[EngageLocalEventStore sharedInstance] findUnpostedEvents] count]);
//}

@end
