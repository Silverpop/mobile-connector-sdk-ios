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

@interface MobileIdentityManager_IT : EngageBaseTest_IT

@property (readonly) NSMutableArray *tearDownApiCalls;
@property (readonly) NSString *mobileUserIdColumn;


@end

@implementation MobileIdentityManager_IT


- (void)setUp {
    [super setUp];
    
    _tearDownApiCalls = [NSMutableArray new];
    _mobileUserIdColumn = [[EngageConfigManager sharedInstance] recipientMobileUserIdColumn];
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
        [removeRecipientXml listId:[EngageConfig engageListId]];
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




@end
