//
//  XMLAPITest.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/9/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EngageConfig.h"
#import "XMLAPI.h"
#import "EngageConfigManager.h"
#import "sample-config.h"

@interface XMLAPITest : XCTestCase

@end

@implementation XMLAPITest

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

- (void)testAddListColumn
{
    
    NSString *lastKnownLocationColumnName = [[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_LAST_KNOWN_LOCATION];
    NSString *lastKnownLocationTime = [[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_LAST_KNOWN_LOCATION_TIME];
    NSString *lastKnownLocationTimeFormat = [[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_LAST_KNOWN_LOCATION_TIME_FORMAT];
    
    XMLAPI *addListColumn = [XMLAPI addColumn:lastKnownLocationColumnName toDatabase:ENGAGE_LIST_ID ofColumnType:COLUMN_TYPE_DATE];
    NSLog(@"AddListColumn XMLAPI : %@", addListColumn);
}

- (void)testUpdateRecipientLastKnownLocation {
    XMLAPI *addLastKnownLocation = [XMLAPI updateUserLastKnownLocation:nil listId:ENGAGE_LIST_ID];
    NSString *xmlEnvelope = [addLastKnownLocation envelope];
    XCTAssertTrue(xmlEnvelope != nil);
}

@end
