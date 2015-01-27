//
//  MobileIdentityManager_IT.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/26/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EngageBaseTest_IT.h"
#import "MobileIdentityManager.h"
#import "EngageConfigManager.h"
#import "EngageConfig.h"
#import "XMLAPI.h"
#import "XMLAPIManager.h"
#import "EngageDefaultUUIDGenerator.h"

@interface MobileIdentityManager_IT : EngageBaseTest_IT

@property (readonly) NSMutableArray *tearDownApiCalls;
@property (readonly) NSString *mobileUserIdColumn;


@end

@implementation MobileIdentityManager_IT


- (void)setUp {
    [super setUp];
    
    _tearDownApiCalls = [NSMutableArray new];
    _mobileUserIdColumn = [[EngageConfigManager sharedInstance] recipientMobileUserIdColumn];
    
    [EngageConfig storeRecipientId:@""];
    [EngageConfig storePrimaryUserId:@""];
}

- (void)tearDown {
    [super tearDown];
    
    for (XMLAPI *xml in _tearDownApiCalls) {
        [[XMLAPIManager sharedInstance] postXMLAPI:xml
                                           success:^(ResultDictionary *ERXML) {
                                              
                                           } failure:^(NSError *error) {
                                               NSLog(@"Error running cleanup");
                                           }];
        
    }
    [_tearDownApiCalls removeAllObjects];
}

- (void)testSetupRecipient_createNewRecipient {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Recipient Added"];
    
    XCTAssertTrue([[EngageConfig primaryUserId] length] == 0);
    XCTAssertTrue([[EngageConfig recipientId] length] == 0);
    
    [[MobileIdentityManager sharedInstance] setupRecipientWithSuccess:^(SetupRecipientResult *result) {
        NSString *recipientId = [result recipientId];
        
        //schedule cleanup
        XMLAPI *removeRecipientXml = [XMLAPI resourceNamed:@"RemoveRecipient"];
        [removeRecipientXml listId:[self listId]];
        [removeRecipientXml recipientId:recipientId];
        [removeRecipientXml addColumn:[self mobileUserIdColumn] :[EngageConfig primaryUserId]];
        [_tearDownApiCalls addObject:removeRecipientXml];
        
        
        XCTAssertTrue([recipientId length] > 0);
        [expectation fulfill];
        
    } failure:^(SetupRecipientFailure *failure) {
        XCTFail();
    }];
    
    
    [self waitForExpectationsWithTimeout:5.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
}

- (void)testSetupRecipient_recipientPreviouslySetup {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Recipient Setup"];
    
    NSString *prevMobileUserId = [[EngageDefaultUUIDGenerator new] generateUUID];
    NSString *prevRecipientId = @"000000";
    
    [EngageConfig storePrimaryUserId:prevMobileUserId];
    [EngageConfig storeRecipientId:prevRecipientId];
    
    XCTAssertTrue([prevMobileUserId isEqualToString:[EngageConfig primaryUserId]]);
    XCTAssertTrue([prevRecipientId isEqualToString:[EngageConfig recipientId]]);
    
    [[MobileIdentityManager sharedInstance] setupRecipientWithSuccess:^(SetupRecipientResult *result) {
        
        NSString *recipientId = [result recipientId];
        XCTAssertTrue([prevRecipientId isEqualToString: recipientId]);
        XCTAssertTrue([prevRecipientId isEqualToString:[EngageConfig recipientId]]);
        XCTAssertTrue([prevMobileUserId isEqualToString:[EngageConfig primaryUserId]]);
        
        [expectation fulfill];
        
    } failure:^(SetupRecipientFailure *failure) {
        XCTFail();
    }];
    
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

-(void)testSetupRecipient_existingRecipientIdButNoMobileUserId {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Recipient Setup"];
    
    NSString *email = [[[EngageDefaultUUIDGenerator new] generateUUID] stringByAppendingString:@"@test.com"];
    
    XMLAPI *setupExistingRecipientXml = [XMLAPI addRecipient:email list:[self listId]];
    
    [[XMLAPIManager sharedInstance] postXMLAPI:setupExistingRecipientXml success:^(ResultDictionary *ERXML) {
        
        NSString *existingRecipientId = [ERXML recipientId];
        
        //schedule cleanup
        XMLAPI *removeRecipientXml = [XMLAPI resourceNamed:@"RemoveRecipient"];
        [removeRecipientXml listId:[self listId]];
        [removeRecipientXml recipientId:existingRecipientId];
        [removeRecipientXml addParam:@"EMAIL" :email];
        [_tearDownApiCalls addObject:removeRecipientXml];

        [EngageConfig storeRecipientId:existingRecipientId];
        XCTAssertTrue([[EngageConfig primaryUserId] length] == 0);
        // setup complete, we now have an existing recipient with an email and recipient id only, not a mobile user id
        
        // start actual test
        [[MobileIdentityManager sharedInstance] setupRecipientWithSuccess:^(SetupRecipientResult *result) {
            
            NSString *recipientId = [result recipientId];
            // recipient should have been updated with mobile user id
            XCTAssertTrue([recipientId isEqualToString:existingRecipientId]);
            XCTAssertTrue([[EngageConfig primaryUserId] length] > 0);
            
            [expectation fulfill];
            
        } failure:^(SetupRecipientFailure *failure) {
            XCTFail();
        }];
        
    } failure:^(NSError *error) {
        XCTFail();
    }];
    
    
    [self waitForExpectationsWithTimeout:4.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}


@end
