//
//  ExpirationParserTests.m
//  ExpirationParserTests
//
//  Created by Jeremy Dyer on 5/28/14.
//  Copyright (c) 2014 Jeremy Dyer. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EngageExpirationParser.h"

@interface ExpirationParserTests : XCTestCase

@property (strong, nonatomic) NSDate *beforeDate;

@end

@implementation ExpirationParserTests

- (void)setUp
{
    [super setUp];
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSTimeZone *timeZone = [[NSTimeZone alloc] initWithName:@"UTC"];
    [calendar setTimeZone:timeZone];
    NSDateComponents *comps = [[NSDateComponents alloc] init];
    [comps setYear:2014];
    [comps setMonth:1];
    [comps setDay:1];
    [comps setHour:0];
    [comps setMinute:0];
    [comps setSecond:0];
    
    self.beforeDate = [calendar dateFromComponents:comps];
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testFullExpirationString
{
    EngageExpirationParser *parser = [[EngageExpirationParser alloc] initWithExpirationString:@"1 day 7 hours 23 minutes 15 seconds" fromDate:self.beforeDate];
    NSDate *expirationDate = [parser expirationDate];
    XCTAssertTrue(expirationDate != nil, @"ExpirationDate cannot be null!");
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:expirationDate];
    
    XCTAssertTrue([components day] == 2, @"Expected day value to be 2");
    XCTAssertTrue([components hour] == 2, @"Expected hour value to be 2");//Testing in EST, 5 hours behind UTC
    XCTAssertTrue([components minute] == 23, @"Expected minute value to be 23");
    XCTAssertTrue([components second] == 15, @"Expected second value to be 15");
}

- (void)testFullExpirationStringNoSpaces
{
    EngageExpirationParser *parser = [[EngageExpirationParser alloc] initWithExpirationString:@"1day7hours23minutes15seconds" fromDate:self.beforeDate];
    NSDate *expirationDate = [parser expirationDate];
    XCTAssertTrue(expirationDate != nil, @"ExpirationDate cannot be null!");
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:expirationDate];
    
    XCTAssertTrue([components day] == 2, @"Expected day value to be 2");
    XCTAssertTrue([components hour] == 2, @"Expected hour value to be 2");//Testing in EST, 5 hours behind UTC
    XCTAssertTrue([components minute] == 23, @"Expected minute value to be 23");
    XCTAssertTrue([components second] == 15, @"Expected second value to be 15");
    
}

- (void)testOnlyDayValue
{
    EngageExpirationParser *parser = [[EngageExpirationParser alloc] initWithExpirationString:@"1day" fromDate:self.beforeDate];
    NSDate *expirationDate = [parser expirationDate];
    XCTAssertTrue(expirationDate != nil, @"ExpirationDate cannot be null!");
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:expirationDate];
    
    XCTAssertTrue([components day] == 1);
    XCTAssertTrue([components hour] == 19);
    XCTAssertTrue([components minute] == 0);
    XCTAssertTrue([components second] == 0);
    
}

- (void)testOnlyHour
{
    EngageExpirationParser *parser = [[EngageExpirationParser alloc] initWithExpirationString:@"9h" fromDate:self.beforeDate];
    NSDate *expirationDate = [parser expirationDate];
    XCTAssertTrue(expirationDate != nil, @"ExpirationDate cannot be null!");
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:expirationDate];
    
    XCTAssertTrue([components day] == 1, @"Expected day value to be 1");
    XCTAssertTrue([components hour] == 4);//Testing in EST, 5 hours behind UTC
    XCTAssertTrue([components minute] == 0);
    XCTAssertTrue([components second] == 0);
    
}

- (void)testShortHands
{
    EngageExpirationParser *parser = [[EngageExpirationParser alloc] initWithExpirationString:@"1d 7h 23m 15s" fromDate:self.beforeDate];
    NSDate *expirationDate = [parser expirationDate];
    XCTAssertTrue(expirationDate != nil, @"ExpirationDate cannot be null!");
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:expirationDate];
    
    XCTAssertTrue([components day] == 2, @"Expected day value to be 2");
    XCTAssertTrue([components hour] == 2, @"Expected hour value to be 2"); //Testing in EST, 5 hours behind UTC
    XCTAssertTrue([components minute] == 23, @"Expected minute value to be 23");
    XCTAssertTrue([components second] == 15, @"Expected second value to be 15");
    
}

- (void)testExpirationDate
{
    EngageExpirationParser *parser = [[EngageExpirationParser alloc] initWithExpirationString:@"2014/12/25 11:12:13" fromDate:self.beforeDate];
    NSDate *expirationDate = [parser expirationDate];
    XCTAssertTrue(expirationDate != nil, @"ExpirationDate cannot be null!");
    
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *components = [calendar components:(NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit) fromDate:expirationDate];
    XCTAssertTrue([components year] == 2014, @"Expected year value to be 2014");
    XCTAssertTrue([components month] == 12, @"Expected month value to be 12");
    XCTAssertTrue([components day] == 25, @"Expected day value to be 25");
    XCTAssertTrue([components hour] == 6, @"Expected hour value to be 6"); //Testing in EST, 5 hours behind UTC
    XCTAssertTrue([components minute] == 12, @"Expected minute value to be 12");
    XCTAssertTrue([components second] == 13, @"Expected second value to be 13");
    
}

@end
