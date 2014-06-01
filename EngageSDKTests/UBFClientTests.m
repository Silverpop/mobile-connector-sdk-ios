//
//  UBFClientTests.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/12/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UBFClient.h"
#import "UBF.h"
#import "EngageConfig.h"
#import "EngageLocalEventStore.h"
#import <MobileDeepLinking-iOS/MobileDeepLinking.h>
#import "TestUtils.h"
#import "EngageEventLiteWrapper.h"
#import "sample-config.h"

@interface UBFClientTests : XCTestCase

@property (nonatomic, strong) UBFClient *ubfClient;

@end

@implementation UBFClientTests

- (void)setUp
{
    [super setUp];
    
//    NSUInteger deletedEvents = [[EngageLocalEventStore sharedInstance] deleteAllUBFEvents];
//    NSLog(@"Deleted %lul", (unsigned long)deletedEvents);
}

- (void)tearDown
{
    [super tearDown];
    self.ubfClient = nil;
}

//- (void)testOAuthAuthentication {
//    
//    //dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    
//    self.ubfClient = [UBFClient createClient:ENGAGE_CLIENT_ID
//                                      secret:ENGAGE_SECRET
//                                       token:ENGAGE_REFRESH_TOKEN
//                                        host:ENGAGE_BASE_URL
//                              connectSuccess:^(AFOAuthCredential *credential) {
//                                  NSLog(@"Successfully connected to Engage API : Credential %@", credential);
//                                  XCTAssertTrue([self.ubfClient credential] != nil);
//                                  XCTAssertTrue(![[self.ubfClient credential] isExpired]);
//                                  XCTAssertTrue([[self.ubfClient operationQueue] isSuspended] == NO);
//                                  //dispatch_semaphore_signal(semaphore);
//                              } failure:^(NSError *error) {
//                                  NSLog(@"Failed to connect to Silverpop API .... %@", [error description]);
//                                  //dispatch_semaphore_signal(semaphore);
//                              }];
//    
//    XCTAssertTrue([self.ubfClient credential] == nil);
//    XCTAssertTrue([[self.ubfClient operationQueue] isSuspended] == YES);
//    
////    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
////        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
////                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
//}

/*
 
*/
-(void)testAFNetworkReachabilityQueueDrainage {
    
    self.ubfClient = [UBFClient createClient:ENGAGE_CLIENT_ID
                                      secret:ENGAGE_SECRET
                                       token:ENGAGE_REFRESH_TOKEN
                                        host:ENGAGE_BASE_URL
                              connectSuccess:^(AFOAuthCredential *credential) {
                                  NSLog(@"Successfully connected to Engage API : Credential %@", credential);
                              } failure:^(NSError *error) {
                                  NSLog(@"Failed to connect to Silverpop API .... %@", [error description]);
                              }];

    [self.ubfClient setReachabilityManager:[self createNonReachableManager]];
    
    [[self.ubfClient operationQueue] cancelAllOperations];
    NSLog(@"Current Queue Size %lu", (unsigned long)[[self.ubfClient operationQueue] operationCount]);
    XCTAssertTrue([[self.ubfClient operationQueue] operationCount] == 0, @"UBFClient Operations Queue must be 0 before starting test!");
    XCTAssertTrue([[self.ubfClient reachabilityManager] isReachable] == NO, @"Network must not be reachable to perform this test");
    
    //Stuff events in the UBFClient and make sure that they are not sent.
    id installedEvent = [UBF installed:nil];
    id sessionStarted = [UBF sessionStarted:nil withCampaign:@"Test Network Reachability Campaign"];
    id goalCompleted = [UBF goalAbandoned:@"UnitTestGoal" params:nil];
    id namedEvent = [UBF namedEvent:@"UnitTestNamedEvent" params:nil];
    id sessionEnded = [UBF sessionEnded:nil];
    
    NSUInteger previousCoreDataCount = [[EngageLocalEventStore sharedInstance] countForEventType:nil];
    NSLog(@"Previous Core Data Count %lul", (unsigned long)previousCoreDataCount);
    
    //Track the 5 events.
    
//    EngageEventLiteWrapper *wrapper = [[EngageEventLiteWrapper alloc] initWithUBFEvent:installedEvent engageEvent:[[EngageLocalEventStore sharedInstance] saveUBFEvent:installedEvent status:NOT_POSTED]];
//    [self.ubfClient postEngageEvent:wrapper];
//    
//    wrapper = [[EngageEventLiteWrapper alloc] initWithUBFEvent:sessionStarted engageEvent:[[EngageLocalEventStore sharedInstance] saveUBFEvent:sessionStarted status:NOT_POSTED]];
//    [self.ubfClient postEngageEvent:wrapper];
//    
//
//    wrapper = [[EngageEventLiteWrapper alloc] initWithUBFEvent:goalCompleted engageEvent:[[EngageLocalEventStore sharedInstance] saveUBFEvent:goalCompleted status:NOT_POSTED]];
//    [self.ubfClient postEngageEvent:wrapper];
//    
//    wrapper = [[EngageEventLiteWrapper alloc] initWithUBFEvent:namedEvent engageEvent:[[EngageLocalEventStore sharedInstance] saveUBFEvent:namedEvent status:NOT_POSTED]];
//    [self.ubfClient postEngageEvent:wrapper];
//    
//    wrapper = [[EngageEventLiteWrapper alloc] initWithUBFEvent:sessionEnded engageEvent:[[EngageLocalEventStore sharedInstance] saveUBFEvent:sessionEnded status:NOT_POSTED]];
//    [self.ubfClient postEngageEvent:wrapper];
    
//    [self.ubfClient postEngageEvent:[[EngageLocalEventStore sharedInstance] saveUBFEvent:installedEvent status:NOT_POSTED]];
//    [self.ubfClient postEngageEvent:[[EngageLocalEventStore sharedInstance] saveUBFEvent:sessionStarted status:NOT_POSTED]];
//    [self.ubfClient postEngageEvent:[[EngageLocalEventStore sharedInstance] saveUBFEvent:goalCompleted status:NOT_POSTED]];
//    [self.ubfClient postEngageEvent:[[EngageLocalEventStore sharedInstance] saveUBFEvent:namedEvent status:NOT_POSTED]];
//    [self.ubfClient postEngageEvent:[[EngageLocalEventStore sharedInstance] saveUBFEvent:sessionEnded status:NOT_POSTED]];
    
    //Check the Core Data store for the 5 UBF events were persisted.
    NSUInteger afterCoreDataCount = [[EngageLocalEventStore sharedInstance] countForEventType:nil];
    NSLog(@"After Core Data Count %lul", (unsigned long)afterCoreDataCount);
    XCTAssertTrue(previousCoreDataCount < afterCoreDataCount, @"After persisting 5 UBF Events Core Data store should have grown with those events");
    XCTAssertTrue((previousCoreDataCount + 5) == afterCoreDataCount, @"Not all 5 UBF events were saved to Core Data!");
    
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    while (true) {
        if ([[[EngageLocalEventStore sharedInstance] findUnpostedEvents] count] == 0) {
            dispatch_semaphore_signal(semaphore);
            break;
        }

        NSLog(@"Waiting on UBF events to post");
        
        while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    }
}


///*
// Take the UBF events that were persisted into Core Data and make sure that they are
// pushed back to the SilverPop Pilot once the app is restarted
//*/
//-(void)testResendNonPushedUBFEventsFromCoreData {
//    
//    //Directly inserts some unposted events into Core Data
//    NSArray *events = [self createSampleUBFEvents];
//    
//    for (id event in events) {
//        [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:NOT_POSTED];
//    }
//    
//    //Finds the unposted events.
//    NSArray *unpostedEvents = [[EngageLocalEventStore sharedInstance] findUnpostedEvents];
//     XCTAssertTrue([unpostedEvents count] == [events count], @"Expected to find %lu unposted UBF events in the Local Core Data Event Store", (unsigned long)[events count]);
//}


//Testing Utility methods
-(NSArray *)createSampleUBFEvents {
    NSMutableArray *events = [[NSMutableArray alloc] init];
    [events addObject:[UBF installed:nil]];
    //[events addObject:[UBF sessionStarted:nil]];
    [events addObject:[UBF goalAbandoned:@"" params:nil]];
    [events addObject:[UBF namedEvent:@"" params:nil]];
    [events addObject:[UBF sessionEnded:nil]];
    return events;
}

-(AFNetworkReachabilityManager *)createNonReachableManager {
    //Create non-routable address to ensure no network reachability.
    struct sockaddr_in zeroAddr;
    bzero(&zeroAddr, sizeof(zeroAddr));
	zeroAddr.sin_len = sizeof(zeroAddr);
	zeroAddr.sin_family = AF_INET;
    
    SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &zeroAddr);
    AFNetworkReachabilityManager *offlineReachManager = [[AFNetworkReachabilityManager alloc] initWithReachability:target];
    [offlineReachManager startMonitoring];
    return offlineReachManager;
}

@end
