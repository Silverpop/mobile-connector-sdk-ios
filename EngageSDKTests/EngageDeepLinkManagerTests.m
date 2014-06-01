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
#import "EngageConfigManager.h"
#import "UBF.h"
#import "TestUtils.h"

@interface EngageDeepLinkManagerTests : XCTestCase

@property (strong, nonatomic) NSString *currentCampaignParamName;
@property (strong, nonatomic) NSString *campaignValidForParamName;
@property (strong, nonatomic) NSString *campaignExpiresAtParamName;
@property (strong, nonatomic) NSString *callToActionParamName;

@end

@implementation EngageDeepLinkManagerTests

- (void)setUp
{
    [super setUp];
    
    self.currentCampaignParamName = [[EngageConfigManager sharedInstance] fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN];
    self.campaignValidForParamName = [[EngageConfigManager sharedInstance] fieldNameForParam:PLIST_PARAM_CAMPAIGN_VALID_FOR];
    self.campaignExpiresAtParamName = [[EngageConfigManager sharedInstance] fieldNameForParam:PLIST_PARAM_CAMPAIGN_EXPIRES_AT];
    self.callToActionParamName = [[EngageConfigManager sharedInstance] fieldNameForParam:PLIST_PARAM_CALL_TO_ACTION];
}

- (void)tearDown
{
    [super tearDown];
}

- (void)testParseCurrentCampaignFromURL {
    NSURL *sampleUrl = [NSURL URLWithString:[[[@"MakeAndBuild://test/5?" stringByAppendingString:self.currentCampaignParamName] stringByAppendingString:@"=UnitTestCampaign2"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *results = [[EngageDeepLinkManager sharedInstance] parseDeepLinkURL:sampleUrl];
    
    XCTAssertTrue([results count] == 1);
    XCTAssertTrue([[results objectForKey:self.currentCampaignParamName] isEqualToString:@"UnitTestCampaign2"]);
}


- (void)testParseCurrentCampaignFromURLValueWithSpace {
    NSURL *sampleUrl = [NSURL URLWithString:[[[@"MakeAndBuild://test/5?" stringByAppendingString:self.currentCampaignParamName] stringByAppendingString:@"=UnitTestCampaign 2"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *results = [[EngageDeepLinkManager sharedInstance] parseDeepLinkURL:sampleUrl];
    
    XCTAssertTrue([results count] == 1);
    XCTAssertTrue([[results objectForKey:self.currentCampaignParamName] isEqualToString:@"UnitTestCampaign 2"]);
}


- (void)testParseCurrentCampaignFromURLKeyWithSpace {
    NSURL *sampleUrl = [NSURL URLWithString:[[[@"MakeAndBuild://test/5?" stringByAppendingString:@"Current Campaign"] stringByAppendingString:@"=UnitTestCampaign2"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *results = [[EngageDeepLinkManager sharedInstance] parseDeepLinkURL:sampleUrl];
    
    XCTAssertTrue([results count] == 1);
    XCTAssertTrue([[results objectForKey:@"Current Campaign"] isEqualToString:@"UnitTestCampaign2"]);
}


- (void)testParseCurrentCampaignFromURLBothKeyAndValueWithSpace {
    NSURL *sampleUrl = [NSURL URLWithString:[[[@"MakeAndBuild://test/5?" stringByAppendingString:@"Current Campaign"] stringByAppendingString:@"=UnitTestCampaign 2"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    NSDictionary *results = [[EngageDeepLinkManager sharedInstance] parseDeepLinkURL:sampleUrl];
    
    XCTAssertTrue([results count] == 1);
    XCTAssertTrue([[results objectForKey:@"Current Campaign"] isEqualToString:@"UnitTestCampaign 2"]);
}


/*
 Since the CurrentCampaign should persist we want to set that CurrentCampaign and then ensure
 that all of the UBF created events contain that CurrentCampaign value.
 */
- (void)testSubsequentUBFEventsContainCurrentCampaign {
    //Test CurrentCampaign name of "Jeremy"
    NSURL *testUrl1 = [NSURL URLWithString:[[@"MakeAndBuild://test/5?" stringByAppendingString:self.currentCampaignParamName] stringByAppendingString:@"=Jeremy"]];
    [[EngageDeepLinkManager sharedInstance] parseDeepLinkURL:testUrl1];
    
    //Now create subsequent UBF events and make sure their CurrentCampaign value is "Jeremy"
    XCTAssertTrue([[TestUtils getLastCampaignFromInstalledEvent:[UBF installed:nil]] isEqualToString:@"Jeremy"], @"UBFResult did not have expected %@ value of Jeremy", self.currentCampaignParamName);
    XCTAssertTrue([[TestUtils getCurrentCampaignFromUBFEvent:[UBF sessionEnded:nil]] isEqualToString:@"Jeremy"], @"UBFResult did not have expected %@ value of Jeremy", self.currentCampaignParamName);
    XCTAssertTrue([[TestUtils getCurrentCampaignFromUBFEvent:[UBF goalAbandoned:@"" params:nil]] isEqualToString:@"Jeremy"], @"UBFResult did not have expected %@ value of Jeremy", self.currentCampaignParamName);
    XCTAssertTrue([[TestUtils getCurrentCampaignFromUBFEvent:[UBF goalCompleted:@"" params:nil]] isEqualToString:@"Jeremy"], @"UBFResult did not have expected %@ value of Jeremy", self.currentCampaignParamName);
    XCTAssertTrue([[TestUtils getCurrentCampaignFromUBFEvent:[UBF namedEvent:@"" params:nil]] isEqualToString:@"Jeremy"], @"UBFResult did not have expected %@ value of Jeremy", self.currentCampaignParamName);
}

@end
