//
//  MobileIdentityManagerTests.m
//  EngageSDK
//
//  Created by andrew zuercher on 1/19/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "MobileIdentityManager.h"
#import "UBFClient.h"


@interface MobileIdentityManagerTests : XCTestCase
@property NSString *clientId, *secret, *refreshToken, *host;

@end

@implementation MobileIdentityManagerTests

- (void)setUp {
    [super setUp];
    self.clientId = @"02eb567b-3674-4c48-8418-dbf17e0194fc";
    self.secret = @"9c650c5b-bcb8-4eb3-bf0a-cc8ad9f41580";
    self.refreshToken = @"676476e8-2d1f-45f9-9460-a2489640f41a";
    self.host = @"https://apipilot.silverpop.com/";
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCreateMobileManagerViaClient {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Mobile Manager Created"];
    
    [UBFClient createClient:self.clientId secret:self.secret token:self.refreshToken host:self.host connectSuccess:^(AFOAuthCredential *credential) {
        NSLog(@"Mobile Manager created successfully!");
        XCTAssertNotNil([MobileIdentityManager sharedInstance]);
        [expectation fulfill];
        
    } failure:^(NSError *error) {
        NSLog(@"Mobile Manager creation failed");
        XCTFail("@Mobile manager creation failed");
    }];
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

- (void)testCreateMobileManagerDirect {
    // Create an expectation object.
    XCTestExpectation *successfulAuthExpectation = [self expectationWithDescription:@"Auth Successful"];
    
    [MobileIdentityManager createInstanceWithHost: self.host clientId:self.clientId secret:self.secret token:self.refreshToken];
    [[MobileIdentityManager sharedInstance] authenticate: ^(AFOAuthCredential *credential) {
        NSLog(@"Auth was successful!");
        XCTAssertTrue([[MobileIdentityManager sharedInstance] isAuthenticated]);
        [successfulAuthExpectation fulfill];
        
    } failure:^(NSError *error) {
        NSLog(@"Auth failed");
        XCTFail("Auth failed");
    }];
    
    // The test will pause here, running the run loop, until the timeout is hit
    // or all expectations are fulfilled.
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

@end
