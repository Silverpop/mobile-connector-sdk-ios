//
//  EngageEventLocationManagerTests.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/27/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EngageEventLocationManager.h"

@interface EngageEventLocationManagerTests : XCTestCase

@property(strong, nonatomic) EngageEventLocationManager *engageEventLocationManager;

@end

@implementation EngageEventLocationManagerTests

- (void)setUp
{
    [super setUp];
    
    self.engageEventLocationManager = [EngageEventLocationManager sharedInstance];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCoordinatesAcquisitionTimeout
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[NSNotificationCenter defaultCenter] addObserverForName:LOCATION_ACQUIRE_LOCATION_TIMEOUT
                                                      object:nil
                                                       queue:[NSOperationQueue mainQueue]
                                                  usingBlock:^(NSNotification *note) {
                                                      XCTAssertTrue(true);
                                                      dispatch_semaphore_signal(semaphore);
                                                  }];
    
    [[EngageEventLocationManager sharedInstance] addLocationToUBFEvent:nil withEngageEvent:nil];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
            [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                     beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
    
}

- (void)testLocationName {
    XCTFail(@"No Yet implemented!");
}

- (void)testLocationServicesEnabled {
    XCTAssertTrue([[EngageEventLocationManager sharedInstance] locationServicesEnabled]);
}

@end
