//
//  MobileIdentityManagerTests.m
//  EngageSDK
//
//  Created by andrew zuercher on 1/19/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>
#import "EngageConnectionManager.h"
#import "UBFClient.h"
#import "EngageBaseTest_IT.h"


@interface EngageConnectionManager_IT : EngageBaseTest_IT

@end

@implementation EngageConnectionManager_IT

- (void)setUp {
    [super setUp];
}

- (void)tearDown {
    [super tearDown];
}

- (void)testCreateMobileManagerViaClient {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Mobile Manager Created"];
    
    [UBFClient createClient:self.clientId secret:self.secret token:self.refreshToken host:self.host connectSuccess:^(AFOAuthCredential *credential) {
        NSLog(@"Mobile Manager created successfully!");
        XCTAssertNotNil([EngageConnectionManager sharedInstance]);
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
    
    [EngageConnectionManager createInstanceWithHost: self.host clientId:self.clientId secret:self.secret token:self.refreshToken];
    [[EngageConnectionManager sharedInstance] authenticate: ^(AFOAuthCredential *credential) {
        NSLog(@"Auth was successful!");
        XCTAssertTrue([[EngageConnectionManager sharedInstance] isAuthenticated]);
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
