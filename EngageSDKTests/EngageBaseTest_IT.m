//
//  EngageBaseTest_IT.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/22/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import "EngageBaseTest_IT.h"
#import "UBFManager.h"
#import "XMLAPIManager.h"
#import "EngageConnectionManager.h"
#import "EngageConfigManager.h"
#import "EngageLocalEventStore.h"

@implementation EngageBaseTest_IT

- (void)setUp {
    [super setUp];
    
    // clear ubf database
//    [[EngageLocalEventStore sharedInstance] deleteAllUBFEvents];
    
    //TODO: move to properties file
    self.clientId = @"02eb567b-3674-4c48-8418-dbf17e0194fc";
    self.secret = @"9c650c5b-bcb8-4eb3-bf0a-cc8ad9f41580";
    self.refreshToken = @"676476e8-2d1f-45f9-9460-a2489640f41a";
    self.host = @"https://apipilot.silverpop.com/";
    self.listId = @"23949";
    
    
    XCTestExpectation *expectation1 = [self expectationWithDescription:@"Connect success 1"];
    XCTestExpectation *expectation2 = [self expectationWithDescription:@"Connect success 2"];
    
    [EngageConfigManager sharedInstance];
    
    //Creates the shared instance of the UBFManager and begins the underlying authentication process.
    NSLog(@"EngageSDK - initializing UBFManager shared instance");
    [UBFManager createClient:_clientId
                      secret:_secret
                       token:_refreshToken
                        host:_host
        engageDatabaseListId:_listId
              connectSuccess: ^(AFOAuthCredential *credential) {
                  NSLog(@"UBFManager connection success");
                  [expectation1 fulfill];
              }
                     failure:^(NSError *error) {
                         NSLog(@"UBFManager connection failed");
                     }];
    
    //Creates the shared instance of the XMLAPIManager and begins the underlying authentication process.
    NSLog(@"EngageSDK - initializing XMLAPIManager shared instance");
    [XMLAPIManager createClient:_clientId
                         secret:_secret
                          token:_refreshToken
                           host:_host
           engageDatabaseListId:_listId
                 connectSuccess:^(AFOAuthCredential *credential) {
                     NSLog(@"XMLAPIManager connection success");
                     [expectation2 fulfill];
                 }
                        failure:^(NSError *error) {
                            NSLog(@"XMLAPIManager connection failed");
                        }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Authentiation Timeout Error: %@", error);
        }
    }];
}

@end



