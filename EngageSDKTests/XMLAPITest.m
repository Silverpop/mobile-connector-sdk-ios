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
#import "XMLAPIManager.h"
#import "XMLAPIOperation.h"

@interface XMLAPITest : XCTestCase

@end

@implementation XMLAPITest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testAddListColumn {
    NSString *lastKnownLocationColumnName = [[EngageConfigManager sharedInstance] configForLocationFieldName:PLIST_LOCATION_LAST_KNOWN_LOCATION];
    XMLAPI *addListColumn = [XMLAPI addColumn:lastKnownLocationColumnName toDatabase:@"12345" ofColumnType:COLUMN_TYPE_DATE];
    NSLog(@"AddListColumn XMLAPI : %@", addListColumn);
}

- (void)testUpdateRecipientLastKnownLocation {
    XMLAPI *addLastKnownLocation = [XMLAPI updateUserLastKnownLocation:nil listId:@"12345"];
    NSString *xmlEnvelope = [addLastKnownLocation envelope];
    XCTAssertTrue(xmlEnvelope != nil);
}

- (void)testInsertUpdateRelationalTable {
    
    XMLAPI *insertRowXml = [XMLAPI resourceNamed:XMLAPI_OPERATION_INSERT_UPDATE_RELATIONAL_TABLE];
    [insertRowXml addParam:@"TABLE_ID" :@"00000"];
    
    NSMutableArray *rows = [[NSMutableArray alloc] initWithObjects:@{
                                                                     @"id" : @"1",
                                                                     @"date created" : @"01/01/2015",
                                                                     @"active" : @"true"
                                                                     },
                                                                    @{
                                                                    @"id" : @"2",
                                                                    @"date created" : @"01/02/2015",
                                                                    @"active" : @"false"
                                                                    }, nil];
    [insertRowXml addParams:@{ @"ROWS" : rows }];
    
    NSString *envelope = [insertRowXml envelope];
    
    NSString *expected = @"<Envelope><Body><InsertUpdateRelationalTable><ROWS><ROW><COLUMN name=\"id\"><![CDATA[1]]></COLUMN><COLUMN name=\"active\"><![CDATA[true]]></COLUMN><COLUMN name=\"date created\"><![CDATA[01/01/2015]]></COLUMN></ROW><ROW><COLUMN name=\"id\"><![CDATA[2]]></COLUMN><COLUMN name=\"active\"><![CDATA[false]]></COLUMN><COLUMN name=\"date created\"><![CDATA[01/02/2015]]></COLUMN></ROW></ROWS><TABLE_ID>00000</TABLE_ID></InsertUpdateRelationalTable></Body></Envelope>";
    XCTAssertEqualObjects(envelope, expected);
}

@end
