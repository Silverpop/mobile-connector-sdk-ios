//
//  EngageDeepLinkManagerTests.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EngageDeepLinkManager.h"
#import "EngageConfig.h"
#import "UBF.h"
#import "TestUtils.h"

@interface EngageDeepLinkManagerTests : XCTestCase

@end

@implementation EngageDeepLinkManagerTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testParsingURLParameters {
    NSURL *sampleUrl = [NSURL URLWithString:@"MakeAndBuild://test/5"];
    NSDictionary *params = [[EngageDeepLinkManager sharedInstance] parseDeepLinkURL:sampleUrl];
    XCTAssertTrue([params count] == 1, @"Only expecting 1 parameter for URL %@", sampleUrl);
    XCTAssertTrue([[params objectForKey:@"testId"] isEqualToString:@"5"], @"Expecting testId value of 5");
}

-(void)testCurrentCampaignParseFromRESTStyleURL {
    //Test CurrentCampaign name of "Jeremy"
    NSURL *testUrl1 = [NSURL URLWithString:@"MakeAndBuild://campaign/Jeremy"];
    NSDictionary *params = [[EngageDeepLinkManager sharedInstance] parseDeepLinkURL:testUrl1];
    XCTAssertTrue([params count] == 1, @"Only expecting 1 parameter for URL %@", testUrl1);
    XCTAssertTrue([[params objectForKey:@"CurrentCampaign"] isEqualToString:@"Jeremy"], @"Expecting CurrentCampaign value of 'Jeremy'");
}


-(void)testMobileDeepLinking {
    NSURL *testUrl1 = [NSURL URLWithString:@"MakeAndBuild://test/5?utmSource=EST"];
    
    NSDictionary *params = [[EngageDeepLinkManager sharedInstance] parseDeepLinkURL:testUrl1];
    XCTAssertTrue([params count] == 2, @"Only expecting 2 parameter for URL %@", testUrl1);
    XCTAssertTrue([[params objectForKey:@"testId"] isEqualToString:@"5"], @"Expecting testId value of 5");
    XCTAssertTrue([[params objectForKey:@"utmSource"] isEqualToString:@"EST"], @"Expecting utmSource value of 'EST'");
}

-(void)testParseCurrentCampaignFromDeepLinkOpened {
    //Test CurrentCampaign name of "Jeremy"
    NSURL *testUrl1 = [NSURL URLWithString:@"MakeAndBuild://test/5?CurrentCampaign=Jeremy"];
    NSDictionary *params = [[EngageDeepLinkManager sharedInstance] parseDeepLinkURL:testUrl1];
    XCTAssertTrue([params count] == 2, @"Only expecting 2 parameter for URL %@", testUrl1);
    XCTAssertTrue([[params objectForKey:@"testId"] isEqualToString:@"5"], @"Expecting testId value of 5");
    XCTAssertTrue([[params objectForKey:@"CurrentCampaign"] isEqualToString:@"Jeremy"], @"Expecting CurrentCampaign value of 'Jeremy'");
}


/*
 Since the CurrentCampaign should persist we want to set that CurrentCampaign and then ensure
 that all of the UBF created events contain that CurrentCampaign value.
 */
- (void)testSubsequentUBFEventsContainCurrentCampaign {
    //Test CurrentCampaign name of "Jeremy"
    NSURL *testUrl1 = [NSURL URLWithString:@"MakeAndBuild://test/5?CurrentCampaign=Jeremy"];
    [[EngageDeepLinkManager sharedInstance] parseDeepLinkURL:testUrl1];
    
    //Now create subsequent UBF events and make sure their CurrentCampaign value is "Jeremy"
    XCTAssertTrue([[TestUtils getLastCampaignFromInstalledEvent:[UBF installed:nil]] isEqualToString:@"Jeremy"], @"UBFResult did not have expected %@ value of Jeremy", CURRENT_CAMPAIGN_PARAM_NAME);
    XCTAssertTrue([[TestUtils getCurrentCampaignFromUBFEvent:[UBF sessionEnded:nil]] isEqualToString:@"Jeremy"], @"UBFResult did not have expected %@ value of Jeremy", CURRENT_CAMPAIGN_PARAM_NAME);
    XCTAssertTrue([[TestUtils getCurrentCampaignFromUBFEvent:[UBF goalAbandoned:@"" params:nil]] isEqualToString:@"Jeremy"], @"UBFResult did not have expected %@ value of Jeremy", CURRENT_CAMPAIGN_PARAM_NAME);
    XCTAssertTrue([[TestUtils getCurrentCampaignFromUBFEvent:[UBF goalCompleted:@"" params:nil]] isEqualToString:@"Jeremy"], @"UBFResult did not have expected %@ value of Jeremy", CURRENT_CAMPAIGN_PARAM_NAME);
    XCTAssertTrue([[TestUtils getCurrentCampaignFromUBFEvent:[UBF namedEvent:@"" params:nil]] isEqualToString:@"Jeremy"], @"UBFResult did not have expected %@ value of Jeremy", CURRENT_CAMPAIGN_PARAM_NAME);
}

@end
