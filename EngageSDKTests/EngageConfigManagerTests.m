//
//  EngageConfigManagerTests.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/9/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EngageConfig.h"
#import "EngageConfigManager.h"

@interface EngageConfigManagerTests : XCTestCase

@end

@implementation EngageConfigManagerTests

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

- (void)testExample
{
    NSDate *now = [NSDate date];
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:[[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_LAST_KNOWN_LOCATION_TIME_FORMAT]];
    NSString *currentDateString = [dateFormatter stringFromDate:now];
    XCTAssertTrue(currentDateString != nil);
}

@end
