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

@end

@implementation EngageEventLocationManagerTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testEngageEventLocationManagerInit {
    XCTAssertTrue([EngageEventLocationManager sharedInstance] != nil, @"EngageEventLocationManager is NOT initilized properly!");
}

- (void)testLocationServicesEnabled {
    XCTAssertTrue([[EngageEventLocationManager sharedInstance] locationServicesEnabled]);
}

@end
