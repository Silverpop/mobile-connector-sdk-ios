//
//  XMLAPIClientTests.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "XMLAPIClient.h"
#import "EngageConfig.h"
#import "sample-config.h"

@interface XMLAPIClientTests : XCTestCase

@end

@implementation XMLAPIClientTests

- (void)setUp
{
    [super setUp];
    
    [XMLAPIClient createClient:ENGAGE_CLIENT_ID
                        secret:ENGAGE_SECRET
                         token:ENGAGE_REFRESH_TOKEN
                          host:ENGAGE_BASE_URL
                connectSuccess:^(AFOAuthCredential *credential) {
                    NSLog(@"Successfully connected to Engage API : Credential %@", credential);
                } failure:^(NSError *error) {
                    NSLog(@"Failed to connect to Silverpop API .... %@", [error description]);
                }];
}

- (void)tearDown
{
    [super tearDown];
}

-(void)validateAuthentication {
    XCTAssertTrue([[XMLAPIClient client] isAuthenticated], @"XMLAPI Client Credentials are invalid!");
}

- (void)testCreateAnonymousUserToList
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    [[XMLAPIClient client] createAnonymousUserToList:ENGAGE_LIST_ID success:^(ResultDictionary *ERXML){
        NSLog(@"Created Anonymous Contact with recipientid of %@", [[ERXML valueForKey:@"recipientid"] objectForKey:@"text"]);
        NSString *recipientId = [[ERXML valueForKey:@"recipientid"] objectForKey:@"text"];
        XCTAssertTrue(recipientId == [EngageConfig anonymousId], @"RecipientId from createAnonymousUser should match anonymousId stored locally at this point!");
        dispatch_semaphore_signal(semaphore);
    } failure:^(NSError *error) {
        dispatch_semaphore_signal(semaphore);
        XCTFail(@"TestCreateAnonymousUserToList Failed with error %@", [error description]);
    }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

- (void)testUgradeAnonymousUserToPrimaryUser {
    //Now lets upgrade this anonymous user to a primary user.
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    [[XMLAPIClient client] updateAnonymousToPrimaryUser:@"jeremy.dyer@makeandbuild.com"
                                                   list:ENGAGE_LIST_ID
                                      primaryUserColumn:@"App User Id"
                                            mergeColumn:@"App User Merge Id"
                                                success:^(ResultDictionary *ERXML){
                                                    dispatch_semaphore_signal(semaphore);
                                                }
                                                failure:^(NSError *error) {
                                                    XCTFail(@"Failed to upgrade anonymous user to primary user with error %@", [error description]);
                                                    dispatch_semaphore_signal(semaphore);
                                                }];
    
    while (dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW))
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:10]];
}

@end
