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
#import "EngageConnectionManager.h"

@interface UBFClientTests : XCTestCase

@property (nonatomic, strong) UBFClient *ubfClient;

@property NSString *clientId;
@property NSString *secret;
@property NSString *refreshToken;
@property NSString *host;
@property NSString *listId;

@end

//DISABLED BECAUSE TEST CANNOT WORK WITHOUT CLIENT ACCESS KEYS
@implementation UBFClientTests

- (void)setUp {
    [super setUp];
    
    //TODO: move to a single place
    self.clientId = @"02eb567b-3674-4c48-8418-dbf17e0194fc";
    self.secret = @"9c650c5b-bcb8-4eb3-bf0a-cc8ad9f41580";
    self.refreshToken = @"676476e8-2d1f-45f9-9460-a2489640f41a";
    self.host = @"https://apipilot.silverpop.com/";
    self.listId = @"23949";
    
    NSUInteger deletedEvents = [[EngageLocalEventStore sharedInstance] deleteAllUBFEvents];
    NSLog(@"Deleted %lul", (unsigned long)deletedEvents);
}

- (void)tearDown {
    [super tearDown];
    self.ubfClient = nil;
}

- (void)testOAuthAuthentication {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Authenticated through UBFClient"];

    
    self.ubfClient = [UBFClient createClient:self.clientId
                                      secret:self.secret
                                       token:self.refreshToken
                                        host:self.host
                              connectSuccess:^(AFOAuthCredential *credential) {
                                  NSLog(@"Successfully connected to Engage API : Credential %@", credential);
                                  
                                  XCTAssertNotNil([[EngageConnectionManager sharedInstance] credential]);
                                  XCTAssertFalse([[[EngageConnectionManager sharedInstance] credential] isExpired]);
                                  XCTAssertFalse([[[EngageConnectionManager sharedInstance] operationQueue] isSuspended]);
                                  
                                  [expectation fulfill];
                              } failure:^(NSError *error) {
                                  NSLog(@"Failed to connect to Silverpop API .... %@", [error description]);
                              }];
    
//    XCTAssertNil([[EngageConnectionManager sharedInstance] credential]);
//    XCTAssertTrue([[[EngageConnectionManager sharedInstance]operationQueue] isSuspended]);
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

///*
// 
//*/
//-(void)testAFNetworkReachabilityQueueDrainage {
//    
//    self.ubfClient = [UBFClient createClient:ENGAGE_CLIENT_ID
//                                      secret:ENGAGE_SECRET
//                                       token:ENGAGE_REFRESH_TOKEN
//                                        host:ENGAGE_BASE_URL
//                              connectSuccess:^(AFOAuthCredential *credential) {
//                                  NSLog(@"Successfully connected to Engage API : Credential %@", credential);
//                              } failure:^(NSError *error) {
//                                  NSLog(@"Failed to connect to Silverpop API .... %@", [error description]);
//                              }];
//
//    [self.ubfClient setReachabilityManager:[self createNonReachableManager]];
//    
//    [[self.ubfClient operationQueue] cancelAllOperations];
//    NSLog(@"Current Queue Size %lu", (unsigned long)[[self.ubfClient operationQueue] operationCount]);
//    XCTAssertTrue([[self.ubfClient operationQueue] operationCount] == 0, @"UBFClient Operations Queue must be 0 before starting test!");
//    XCTAssertTrue([[self.ubfClient reachabilityManager] isReachable] == NO, @"Network must not be reachable to perform this test");
//    
//    //Stuff events in the UBFClient and make sure that they are not sent.
//    id installedEvent = [UBF installed:nil];
//    id sessionStarted = [UBF sessionStarted:nil withCampaign:@"Test Network Reachability Campaign"];
//    id goalCompleted = [UBF goalAbandoned:@"UnitTestGoal" params:nil];
//    id namedEvent = [UBF namedEvent:@"UnitTestNamedEvent" params:nil];
//    id sessionEnded = [UBF sessionEnded:nil];
//    
//    NSUInteger previousCoreDataCount = [[EngageLocalEventStore sharedInstance] countForEventType:ALL_EVENTS];
//    NSLog(@"Previous Core Data Count %lul", (unsigned long)previousCoreDataCount);
//    
//    //Save the events.
//    [[EngageLocalEventStore sharedInstance] saveUBFEvent:installedEvent status:NOT_POSTED];
//    [[EngageLocalEventStore sharedInstance] saveUBFEvent:sessionStarted status:NOT_POSTED];
//    [[EngageLocalEventStore sharedInstance] saveUBFEvent:goalCompleted status:NOT_POSTED];
//    [[EngageLocalEventStore sharedInstance] saveUBFEvent:namedEvent status:NOT_POSTED];
//    [[EngageLocalEventStore sharedInstance] saveUBFEvent:sessionEnded status:NOT_POSTED];
//    
//    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    
//    [[UBFClient client] postUBFEngageEvents:^(AFHTTPRequestOperation *operation, id responseObject) {
//        dispatch_semaphore_signal(semaphore);
//        XCTAssertTrue(true);
//    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//        dispatch_semaphore_signal(semaphore);
//        XCTFail(@"Network failure while posting UBFEvents");
//    }];
//    
//    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
//        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
//                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
//    
//    //Check the Core Data store for the 5 UBF events were persisted.
//    NSUInteger afterCoreDataCount = [[EngageLocalEventStore sharedInstance] countForEventType:ALL_EVENTS];
//    NSLog(@"After Core Data Count %lul", (unsigned long)afterCoreDataCount);
//    XCTAssertTrue(previousCoreDataCount < afterCoreDataCount, @"After persisting 5 UBF Events Core Data store should have grown with those events");
//    XCTAssertTrue((previousCoreDataCount + 5) == afterCoreDataCount, @"Not all 5 UBF events were saved to Core Data!");
//}

/*
 Take the UBF events that were persisted into Core Data and make sure that they are
 pushed back to the SilverPop Pilot once the app is restarted
*/
-(void)testResendNonPushedUBFEventsFromCoreData {
    
    //Directly inserts some unposted events into Core Data
    NSArray *events = [self createSampleUBFEvents];
    
    for (id event in events) {
        [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:NOT_POSTED];
    }
    
    //Finds the unposted events.
    NSArray *unpostedEvents = [[EngageLocalEventStore sharedInstance] findUnpostedEvents];
    XCTAssertTrue([unpostedEvents count] == [events count], @"Expected to find %lu unposted UBF events in the Local Core Data Event Store", (unsigned long)[events count]);
}


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
//
//-(AFNetworkReachabilityManager *)createNonReachableManager {
//    //Create non-routable address to ensure no network reachability.
//    struct sockaddr_in zeroAddr;
//    bzero(&zeroAddr, sizeof(zeroAddr));
//	zeroAddr.sin_len = sizeof(zeroAddr);
//	zeroAddr.sin_family = AF_INET;
//    
//    SCNetworkReachabilityRef target = SCNetworkReachabilityCreateWithAddress(NULL, (struct sockaddr *) &zeroAddr);
//    AFNetworkReachabilityManager *offlineReachManager = [[AFNetworkReachabilityManager alloc] initWithReachability:target];
//    [offlineReachManager startMonitoring];
//    return offlineReachManager;
//}

//-(void)testPostUBFEngageEvents {
//    
//    XCTestExpectation *expectation = [self expectationWithDescription:@"Post events"];
//    
//    
//    self.ubfClient = [UBFClient createClient:self.clientId
//                                      secret:self.secret
//                                       token:self.refreshToken
//                                        host:self.host
//                              connectSuccess:^(AFOAuthCredential *credential) {
//                                  NSLog(@"Successfully connected to Engage API : Credential %@", credential);
//                                  
//                                  // we're connected, create some events so we can test posting them
//                                  NSArray *events = [self createSampleUBFEvents];
//                                  for (id event in events) {
//                                      [[EngageLocalEventStore sharedInstance] saveUBFEvent:event status:NOT_POSTED];
//                                  }
//                                  
//                                  [_ubfClient postUBFEngageEvents:^(AFHTTPRequestOperation *operation, id responseObject) {
//                                      
//                                      NSLog(@"Events posted successfully");
//                                      [expectation fulfill];
//                                      
//                                      
//                                  } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
//                                      NSLog(@"%@", error);
//                                  }];
//                                  
//                                  
//                              } failure:^(NSError *error) {
//                                  NSLog(@"Failed to connect to Silverpop API .... %@", [error description]);
//                              }];
//    
//    
//    
//    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
//        if (error) {
//            NSLog(@"Timeout Error: %@", error);
//        }
//    }];
//}

@end
