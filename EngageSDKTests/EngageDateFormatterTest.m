//
//  EngageDateFormatterTest.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/27/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EngageDateFormatter.h"

@interface EngageDateFormatterTest : XCTestCase

@end

@implementation EngageDateFormatterTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testNowGmtString {
    
    // example format "2015-01-28 01:39:53 GMT"
    NSString *gmtString = [EngageDateFormatter nowGmtString];
    
    XCTAssertTrue([gmtString length] > 0);
    XCTAssertTrue([gmtString containsString:@"GMT"]);
}


@end
