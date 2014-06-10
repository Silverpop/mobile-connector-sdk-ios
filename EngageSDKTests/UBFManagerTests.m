//
//  UBFManagerTests.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/9/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UBFManager.h"
#import "sample-config.h"

@interface UBFManagerTests : XCTestCase

@end

@implementation UBFManagerTests

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

- (void)testExample
{
    __block dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    UBFManager *ubfManger = [UBFManager createClient:ENGAGE_CLIENT_ID
                                              secret:ENGAGE_SECRET
                                               token:ENGAGE_REFRESH_TOKEN
                                                host:ENGAGE_BASE_URL
                                      connectSuccess:^(AFOAuthCredential *credential) {
        dispatch_semaphore_signal(semaphore);
        NSLog(@"Successfully connected to Engage API : Credential %@", credential);
    } failure:^(NSError *error) {
        dispatch_semaphore_signal(semaphore);
        NSLog(@"Failed to connect to Silverpop API .... %@", [error description]);
    }];
    
    XCTAssertTrue(ubfManger != nil);
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:1000]];
}

@end
