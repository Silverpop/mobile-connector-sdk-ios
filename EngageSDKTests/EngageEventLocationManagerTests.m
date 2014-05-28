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

- (void)testExample
{
    NSLog(@"Getting the current location");
    [self.engageEventLocationManager currentLocation];
    NSLog(@"Done getting the current location");
}

@end
