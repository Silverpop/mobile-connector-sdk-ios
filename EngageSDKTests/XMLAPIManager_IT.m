//
//  XMLAPIManager_IT.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/22/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EngageBaseTest_IT.h"
#import "XMLAPIManager.h"
#import "XMLAPI.h"
#import "ResultDictionary.h"
#import "EngageConfig.h"
#import "EngageConfigManager.h"
#import "EngageDefaultUUIDGenerator.h"

@interface XMLAPIManager_IT : EngageBaseTest_IT

@property (readonly) NSMutableArray *tearDownApiCalls;
@property (readonly) NSString *mobileUserIdColumn;

@end

@implementation XMLAPIManager_IT

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
                                               NSLog(@"Success running cleanup");
                                           } failure:^(NSError *error) {
                                               NSLog(@"Error running cleanup");
                                           }];
        
    }
    [_tearDownApiCalls removeAllObjects];
}

- (void)testAddRecipient_success {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Recipient Added"];
    
    NSString *email = [[[EngageDefaultUUIDGenerator new] generateUUID] stringByAppendingString:@"@test.com"];
    NSString *listId = [EngageConfig engageListId];
    
    XMLAPI *addRecipientXml = [XMLAPI addRecipient:email list:listId];
    
    [[XMLAPIManager sharedInstance] postXMLAPI:addRecipientXml
                                       success:^(ResultDictionary *ERXML) {
                                           NSLog(@"Got a response");
                                           
                                           NSString *recipientId = [ERXML valueForShortPath:@"recipientId"];
                                           
                                           if ([ERXML isSuccess]) {
                                               //schedule cleanup
                                               XMLAPI *removeRecipientXml = [XMLAPI resourceNamed:@"RemoveRecipient"];
                                               [removeRecipientXml listId:listId];
                                               [removeRecipientXml recipientId:recipientId];
                                               [removeRecipientXml addColumn:[self mobileUserIdColumn] :[EngageConfig primaryUserId]];
                                               [_tearDownApiCalls addObject:removeRecipientXml];
                                           }
                                           
                                           XCTAssertTrue([ERXML isSuccess]);
                                           XCTAssertNotNil(recipientId);
                                           [expectation fulfill];
                                       }
                                       failure:^(NSError *unexpectedError) {
                                           NSLog(@"%@",[unexpectedError localizedDescription]);
                                           XCTFail();
                                       }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

//- (void)testAddRecipientWithMobileUserId_success {
//    
//    NSString *mobileUserIdColumn = [[EngageConfigManager sharedInstance] recipientMobileUserIdColumn];
//    NSString *mobileUserI
//    
//    XMLAPI *addRecipientXml = [XMLAPI addRecipientWithMobileUserIdColumnName:mobileUserIdColumn mobileUserId:newMobileUserId list:listId];
//    [[XMLAPIManager sharedInstance] postXMLAPI:addRecipientXml
//                                       success:^(ResultDictionary *ERXML) {
//                                           if ([ERXML isSuccess]) {
//                                               NSString *recipientId = [ERXML valueForShortPath:@"RecipientId"];
//                                               
//                                               if ([recipientId length] == 0) {
//                                                   didFail([[SetupRecipientFailure alloc] initWithMessage:@"Empty recipientId returned from Silverpop" response:ERXML]);
//                                               } else {
//                                                   [EngageConfig storeRecipientId:recipientId];
//                                                   didSucceed([[SetupRecipientResult alloc] initWithRecipientId:recipientId]);
//                                               }
//                                           }
//                                       }
//                                       failure:^(NSError *error) {
//                                           NSString *message = [@"Unexpected exception making update recipient API call to silverpop" stringByAppendingString:error.description];
//                                           NSLog(@"%@", message);
//                                           didFail([[SetupRecipientFailure alloc] initWithMessage:message
//                                                                                            error:error]);
//                                       }];
//
//}

- (void)testFailure {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Recipient Added Failed"];
    
    NSString *listId = [EngageConfig engageListId];
    
    // select recipient without email should come back with a success of false
    XMLAPI *addRecipientXml = [XMLAPI selectRecipientData:@"hklhjkhkljh" list:listId];
    
    [[XMLAPIManager sharedInstance] postXMLAPI:addRecipientXml
                                       success:^(ResultDictionary *ERXML) {
                                           NSLog(@"Got a response");
                                           XCTAssertFalse([ERXML isSuccess]);
                                           
                                           NSString *faultString = [ERXML faultString];
                                           XCTAssertTrue([faultString length] > 0);
                                           [expectation fulfill];
                                       }
                                       failure:^(NSError *unexpectedError) {
                                           NSLog(@"%@",[unexpectedError localizedDescription]);
                                           XCTFail();
                                       }];
    
    [self waitForExpectationsWithTimeout:10.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

@end
