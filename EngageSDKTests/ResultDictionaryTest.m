//
//  ResultDictionaryTest.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/22/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "ResultDictionary.h"
#import "EngageResponseXML.h"

@interface ResultDictionaryTest : XCTestCase

@end

@implementation ResultDictionaryTest

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

// TODO: this doesn't work
//- (void)testFaultString {
//    NSString *errorResult =
//    @"<Envelope>"
//    "   <Body>"
//    "       <RESULT>"
//    "           <SUCCESS>false</SUCCESS>"
//    "       </RESULT>"
//    "       <Fault>"
//    "           <Request/>"
//    "           <FaultCode/>"
//    "           <FaultString><![CDATA[A List With This Name Already Exists.]]></FaultString>"
//    "           <detail>"
//    "               <error>"
//    "                   <errorid>256</errorid>"
//    "                   <module/>"
//    "                   <class>SP.ListManager</class>"
//    "                   <method/>"
//    "               </error>"
//    "           </detail>"
//    "       </Fault>"
//    "   </Body>"
//    "</Envelope>";
//    
//    ResultDictionary *ERXML = [EngageResponseXML decode:errorResult];
//    NSString *faultString = [ERXML valueForKey:@"Fault.FaultString"];
//    XCTAssertEqual(faultString, @"A List With This Name Already Exists.");
//    
//}

-(void)testGetColumnByName {
    
    NSString *selectRecipientXml =
    @"<Envelope>"
    "   <Body>"
    "       <RESULT>"
    "           <SUCCESS>TRUE</SUCCESS>"
    "           <EMAIL>somebody@domain.com</EMAIL>"
    "           <Email>somebody@domain.com</Email>"
    "           <RecipientId>33439394</RecipientId>"
    "           <EmailType>0</EmailType>"
    "           <LastModified>6/25/04 3:29 PM</LastModified>"
    "           <CreatedFrom>1</CreatedFrom>"
    "           <OptedIn>6/25/04 3:29 PM</OptedIn>"
    "           <OptedOut/>"
    "           <COLUMNS>￼￼￼"
	"               <COLUMN>"
    "                   <NAME>Lname</NAME>"
    "                   <VALUE>Special</VALUE>"
	"               </COLUMN>"
    "               <COLUMN>"
    "                   <NAME>Fname</NAME>"
    "                   <VALUE>Somebody</VALUE>"
    "               </COLUMN>"
    "           </COLUMNS>"
    "       </RESULT>"
    "   </Body>"
    "</Envelope>";
    

    NSData *xmlData = [selectRecipientXml dataUsingEncoding:NSUTF8StringEncoding];
    NSXMLParser *responseParser = [[NSXMLParser alloc] initWithData:xmlData];
    
    ResultDictionary *resultDictionary = [EngageResponseXML decode:responseParser];
    
    NSString *colVal = [resultDictionary valueForColumnName:@"Fname"];
    XCTAssertTrue([colVal isEqualToString:@"Somebody"]);
}

@end
