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

//- (void)testCreateMobileManagerViaClient {
//    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
//    [UBFClient createClient:self.clientId secret:self.secret token:self.refreshToken host:self.host connectSuccess:^(AFOAuthCredential *credential) {
//        NSLog(@"yay it passed");
//        dispatch_semaphore_signal(semaphore);
//    } failure:^(NSError *error) {
//        NSLog(@"boo it failed");
//        dispatch_semaphore_signal(semaphore);
//    }];
//    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
//
//    MobileIdentityManager* instance = [MobileIdentityManager sharedInstance];
//    XCTAssert(instance != nil, @"Pass");
//    XCTAssert(YES, @"Pass");
//}
- (void)testCreateMobileManagerDirect {
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [MobileIdentityManager createInstanceWithHost: self.host clientId:self.clientId secret:self.secret token:self.refreshToken];
    [[MobileIdentityManager sharedInstance] authenticate: ^(AFOAuthCredential *credential) {
        NSLog(@"yay it passed");
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSError *error) {
        NSLog(@"boo it failed");
        dispatch_semaphore_signal(semaphore);
    }];
    dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
    
    MobileIdentityManager* instance = [MobileIdentityManager sharedInstance];
    XCTAssert(instance != nil, @"Pass");
    XCTAssert(YES, @"Pass");
}

@end
