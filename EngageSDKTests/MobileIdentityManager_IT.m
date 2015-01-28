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
#import "XMLAPIOperation.h"
#import "EngageRecipient.h"

@interface MobileIdentityManager_IT : EngageBaseTest_IT

@property (readonly) NSMutableArray *tearDownApiCalls;
@property (readonly) EngageDefaultUUIDGenerator *uuidGenerator;

@property (readonly) NSString *mobileUserIdColumn;
@property (readonly) NSString *mergedRecipientIdColumn;
@property (readonly) NSString *mergedDateColumn;

@end

@implementation MobileIdentityManager_IT

static NSString * const CUSTOM_ID_COLUMN = @"Custom Integration Test Id";
static NSString * const CUSTOM_ID_COLUMN_2 = @"Custom Integration Test Id 2";

- (void)setUp {
    // clear needed preferences
    [EngageConfig storeRecipientId:@""];
    [EngageConfig storePrimaryUserId:@""];
    
    [super setUp];
    
    _tearDownApiCalls = [NSMutableArray new];
    _mobileUserIdColumn = [[EngageConfigManager sharedInstance] recipientMobileUserIdColumn];
    _mergedRecipientIdColumn = [[EngageConfigManager sharedInstance] recipientMergedRecipientIdColumn];
    _mergedDateColumn = [[EngageConfigManager sharedInstance] recipientMergedDateColumn];
    _uuidGenerator = [EngageDefaultUUIDGenerator new];
    
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
        XMLAPI *removeRecipientXml = [XMLAPI resourceNamed:XMLAPI_OPERATION_REMOVE_RECIPIENT];
        [removeRecipientXml listId:[self listId]];
        [removeRecipientXml recipientId:recipientId];
        [removeRecipientXml addColumn:[self mobileUserIdColumn] :[EngageConfig primaryUserId]];
        [_tearDownApiCalls addObject:removeRecipientXml];
        
        
        XCTAssertTrue([recipientId length] > 0);
        // verify recipient id and mobile user id are configured in app
        XCTAssertTrue([[EngageConfig recipientId] length] > 0);
        XCTAssertTrue([[EngageConfig primaryUserId] length] > 0);
        
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
    
    NSString *prevMobileUserId = [_uuidGenerator generateUUID];
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
    
    NSString *email = [[_uuidGenerator generateUUID] stringByAppendingString:@"@test.com"];
    
    XMLAPI *setupExistingRecipientXml = [XMLAPI addRecipient:email list:[self listId]];
    
    [[XMLAPIManager sharedInstance] postXMLAPI:setupExistingRecipientXml success:^(ResultDictionary *ERXML) {
        
        NSString *existingRecipientId = [ERXML recipientId];
        
        //schedule cleanup
        XMLAPI *removeRecipientXml = [XMLAPI resourceNamed:XMLAPI_OPERATION_REMOVE_RECIPIENT];
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

-(void)testCheckIdentity_s1_recipientNotFound {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Check Identity Success"];
    
    // setup recipient on server with recipientId and mobileUserId set
    [[MobileIdentityManager sharedInstance] setupRecipientWithSuccess:^(SetupRecipientResult *result) {
        NSString *createdRecipientId = [result recipientId];
        
        // schedule cleanup
        XMLAPI *removeRecipientXml = [XMLAPI resourceNamed:XMLAPI_OPERATION_REMOVE_RECIPIENT];
        [removeRecipientXml listId:[self listId]];
        [removeRecipientXml recipientId:createdRecipientId];
        [_tearDownApiCalls addObject:removeRecipientXml];
        
        // recipient is setup, we should have recipientId and mobileUserId now
        XCTAssertTrue([createdRecipientId length] > 0);
        XCTAssertTrue([[EngageConfig primaryUserId] length] > 0);
        
        // look for an existing recipient with the following
        NSString *nonExistingCustomIdValue = [_uuidGenerator generateUUID];
        
        NSDictionary *fieldsToIds = @{CUSTOM_ID_COLUMN : nonExistingCustomIdValue};
        
        [[MobileIdentityManager sharedInstance] checkIdentityForIds:fieldsToIds success:^(CheckIdentityResult *result) {
            NSString *recipientId = [result recipientId];
            NSString *mergedRecipientId = [result mergedRecipientId];
            NSString *mobileUserId = [result mobileUserId];
            
            // check that existing recipient was updated with a generated mobile user id
            XCTAssertTrue([recipientId length] > 0);
            XCTAssertTrue([mergedRecipientId length] == 0);
            XCTAssertTrue([mobileUserId length] > 0);
            
            XMLAPI *selectRecipientXml = [XMLAPI selectRecipientWithId:recipientId list:[self listId]];
            [[XMLAPIManager sharedInstance] postXMLAPI:selectRecipientXml success:^(ResultDictionary *selectRecipientResult) {
                
                NSString *foundMobileUserId = [selectRecipientResult valueForColumnName:_mobileUserIdColumn];
                NSString *foundCustomId = [selectRecipientResult valueForColumnName:CUSTOM_ID_COLUMN];
                
                // verify that mobileUserId and custom Id were actually saved to the server
                XCTAssertTrue([foundCustomId length] > 0);
                XCTAssertTrue([foundCustomId isEqualToString:nonExistingCustomIdValue]);
                XCTAssertTrue([foundMobileUserId length] > 0);
                XCTAssertTrue([foundMobileUserId isEqualToString:mobileUserId]);
                
                [expectation fulfill];
                
            } failure:^(NSError *error) {
                XCTFail();
            }];
            
        } failure:^(CheckIdentityFailure *failure) {
            XCTFail();
        }];
        
    } failure:^(SetupRecipientFailure *failure) {
        XCTFail();
    }];
    
    [self waitForExpectationsWithTimeout:3.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

-(void)setupScenario2:(void(^)(EngageRecipient *currentRecipient, EngageRecipient *existingRecipient))setupResult {
    
    // setup recipient on server with recipientId and mobileUserId set
    [[MobileIdentityManager sharedInstance] setupRecipientWithSuccess:^(SetupRecipientResult *result) {
        
        NSString *createdWithMobileUserId_RecipientId = [result recipientId];
        // schedule cleanup of first recipient
        XMLAPI *removeRecipientXml = [XMLAPI resourceNamed:XMLAPI_OPERATION_REMOVE_RECIPIENT];
        [removeRecipientXml listId:[self listId]];
        [removeRecipientXml recipientId:createdWithMobileUserId_RecipientId];
        [_tearDownApiCalls addObject:removeRecipientXml];
        
        NSString *originalMobileUserId = [EngageConfig primaryUserId];
        NSString *customId = [_uuidGenerator generateUUID];
        
        // setup existing recipient on server with custom id but not a mobile user id
        
        XMLAPI *addRecipientwithCustomIdXml = [XMLAPI addRecipientWithMobileUserIdColumnName:CUSTOM_ID_COLUMN mobileUserId:customId list:[self listId]];
        [[XMLAPIManager sharedInstance] postXMLAPI:addRecipientwithCustomIdXml success:^(ResultDictionary *addRecipientWithCustomIdResult) {
            NSString *createdWithCustomId_RecipientId = [addRecipientWithCustomIdResult recipientId];
            
            // schedule cleanup of second recipient
            XMLAPI *removeRecipientXml = [XMLAPI resourceNamed:XMLAPI_OPERATION_REMOVE_RECIPIENT];
            [removeRecipientXml listId:[self listId]];
            [removeRecipientXml recipientId:createdWithCustomId_RecipientId];
            [_tearDownApiCalls addObject:removeRecipientXml];
            
            // we now have 2 recipients configured as:
            // recipientId | mobileUserId | customId
            //    value    |     value    |
            //    value    |              |  value
            
            EngageRecipient *currentRecipient = [[EngageRecipient alloc] initWithRecipientId:createdWithMobileUserId_RecipientId mobileUserId:originalMobileUserId customIdFields:nil];
            EngageRecipient *existingRecipient = [[EngageRecipient alloc] initWithRecipientId:createdWithCustomId_RecipientId mobileUserId:nil customIdFields:@{CUSTOM_ID_COLUMN : customId }];
            
            setupResult(currentRecipient, existingRecipient);
            
        } failure:^(NSError *error) {
            XCTFail(@"Error adding recipient");
        }];
        
    } failure:^(SetupRecipientFailure *failure) {
        XCTFail(@"Error setting up recipient");
    }];
    
}

-(void)testCheckIdentity_s2_existingRecipientWithoutMobileUserId {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Check Identity Success"];
    
    [self setupScenario2:^(EngageRecipient *currentRecipient, EngageRecipient *existingRecipient) {
        // look for an existing recipient with customId
        NSString *customId = [[existingRecipient customIdFields] objectForKey:CUSTOM_ID_COLUMN];
        
        [[MobileIdentityManager sharedInstance] checkIdentityForIds:[existingRecipient customIdFields] success:^(CheckIdentityResult *result) {
            
            // verify correct values passed in result
            XCTAssertTrue([[result recipientId] isEqualToString:[EngageConfig recipientId]]);
            XCTAssertTrue([[result mergedRecipientId] length] > 0);
            XCTAssertFalse([[result mergedRecipientId] isEqualToString:[result recipientId]]);
            XCTAssertTrue([[result mobileUserId] isEqualToString:[EngageConfig primaryUserId]]);
            
            // verify the app is now using the existing recipient
            XCTAssertTrue([[EngageConfig recipientId] isEqualToString:[existingRecipient recipientId]]);
            XCTAssertTrue([[EngageConfig primaryUserId] isEqualToString:[currentRecipient mobileUserId]]);
            
            // check state of recipients on server
            // check first recipient
            XMLAPI *selectCurrentRecipientXml = [XMLAPI selectRecipientWithId:[currentRecipient recipientId] list:[self listId]];
            [[XMLAPIManager sharedInstance] postXMLAPI:selectCurrentRecipientXml success:^(ResultDictionary *selectCurrentRecipientResult) {
                
                // mobile id cleared
                XCTAssertTrue([[selectCurrentRecipientResult valueForColumnName:_mobileUserIdColumn] length] == 0);
                // merged properties set
                XCTAssertTrue([[selectCurrentRecipientResult valueForColumnName:_mergedRecipientIdColumn] isEqualToString:[existingRecipient recipientId]]);
                XCTAssertTrue([[selectCurrentRecipientResult valueForColumnName:_mergedDateColumn] length] > 0);
                
                // check second recipient
                XMLAPI *selectExistingRecipientXml = [XMLAPI selectRecipientWithId:[existingRecipient recipientId] list:[self listId]];
                [[XMLAPIManager sharedInstance] postXMLAPI:selectExistingRecipientXml success:^(ResultDictionary *selectExistingRecipientResult) {
                    
                    // mobile id set to merged recipient id
                    XCTAssertTrue([[selectExistingRecipientResult valueForColumnName:_mobileUserIdColumn] isEqualToString:[currentRecipient mobileUserId]]);
                    XCTAssertTrue([[selectExistingRecipientResult valueForColumnName:CUSTOM_ID_COLUMN] isEqualToString:customId]);
                    XCTAssertTrue([[selectExistingRecipientResult valueForColumnName:_mergedRecipientIdColumn] length] == 0);
                    XCTAssertTrue([[selectExistingRecipientResult valueForColumnName:_mergedDateColumn] length] == 0);
                    
                    [expectation fulfill];
                    
                } failure:^(NSError *error) {
                    XCTFail();
                }];
                
            } failure:^(NSError *error) {
                XCTFail();
            }];
            
        } failure:^(CheckIdentityFailure *failure) {
            XCTFail();
        }];
    }];
    
    [self waitForExpectationsWithTimeout:6.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

-(void)setupScenario3WithMultipleIds:(BOOL)twoCustomIds setupResult:(void(^)(EngageRecipient *currentRecipient, EngageRecipient *existingRecipient))setupResult {
    
    // setup recipient on server with recipientId and mobileUserId set
    [[MobileIdentityManager sharedInstance] setupRecipientWithSuccess:^(SetupRecipientResult *result) {
        NSString *createdWithMobileUserId_RecipientId = [result recipientId];
        
        // schedule cleanup of first recipient
        XMLAPI *removeRecipientXml = [XMLAPI resourceNamed:XMLAPI_OPERATION_REMOVE_RECIPIENT];
        [removeRecipientXml listId:[self listId]];
        [removeRecipientXml recipientId:createdWithMobileUserId_RecipientId];
        [_tearDownApiCalls addObject:removeRecipientXml];
        
        NSString *originalCurrentMobileUserId = [EngageConfig primaryUserId];
        
        NSString *customId = [_uuidGenerator generateUUID];
        NSString *originalExistingMobileUserId = [_uuidGenerator generateUUID];
        NSString *customId2 = [_uuidGenerator generateUUID];
        
        // setup existing recipient on server with custom id(s) and a different mobileUserId
        XMLAPI *addRecipientWithCustomIdXml = [XMLAPI addRecipientWithMobileUserIdColumnName:_mobileUserIdColumn mobileUserId:originalExistingMobileUserId list:[self listId]];
        [addRecipientWithCustomIdXml addColumn:CUSTOM_ID_COLUMN :customId];
        if (twoCustomIds) {
            [addRecipientWithCustomIdXml addColumn:CUSTOM_ID_COLUMN_2 :customId2];
        }
        
        [[XMLAPIManager sharedInstance] postXMLAPI:addRecipientWithCustomIdXml success:^(ResultDictionary *addRecipientResult) {
            NSString *createdWithCustomId_RecipientId = [addRecipientResult recipientId];
            
            // schedule cleanup of second recipient
            XMLAPI *removeRecipientXml = [XMLAPI resourceNamed:XMLAPI_OPERATION_REMOVE_RECIPIENT];
            [removeRecipientXml listId:[self listId]];
            [removeRecipientXml recipientId:createdWithCustomId_RecipientId];
            [_tearDownApiCalls addObject:removeRecipientXml];
            
            // we now have 2 recipients configured as:
            // recipientId | mobileUserId | customId
            //    value    |     value    |
            //    value    |     value    |  value
            
            EngageRecipient *currentRecipient = [[EngageRecipient alloc] initWithRecipientId:createdWithMobileUserId_RecipientId mobileUserId:originalCurrentMobileUserId customIdFields:nil];
            
            NSMutableDictionary *customIdFields = [NSMutableDictionary new];
            [customIdFields setValue:customId forKey:CUSTOM_ID_COLUMN];
            if (twoCustomIds) {
                [customIdFields setValue:customId2 forKey:CUSTOM_ID_COLUMN_2];
            }
            
            EngageRecipient *existingRecipient = [[EngageRecipient alloc] initWithRecipientId:createdWithCustomId_RecipientId mobileUserId:originalExistingMobileUserId customIdFields:customIdFields];
            
            setupResult(currentRecipient, existingRecipient);
            
        } failure:^(NSError *error) {
            XCTFail(@"Error setting up scenario 3");
        }];

        
    } failure:^(SetupRecipientFailure *failure) {
        XCTFail(@"Error setting up scenario 3");
    }];
    
}

-(void)testCheckIdentity_s3_existingRecipientWithMobileUserId {
    
    XCTestExpectation *expectation = [self expectationWithDescription:@"Check Identity Success"];
    
    [self setupScenario3WithMultipleIds:false setupResult:^(EngageRecipient *currentRecipient, EngageRecipient *existingRecipient) {
        
        // look for an existing recipient with customId
        NSDictionary *fieldsToIds = [existingRecipient customIdFields];
        
        [[MobileIdentityManager sharedInstance] checkIdentityForIds:fieldsToIds success:^(CheckIdentityResult *result) {
           
            // verify correct values passed in result
            XCTAssertTrue([[result recipientId] isEqualToString:[EngageConfig recipientId]]);
            XCTAssertTrue([[result mergedRecipientId] length] > 0);
            XCTAssertFalse([[result mergedRecipientId] isEqualToString:[result recipientId]]);
            XCTAssertTrue([[result mobileUserId] isEqualToString:[EngageConfig primaryUserId]]);
            
            // verify the app is now using the existing recipient
            XCTAssertTrue([[EngageConfig primaryUserId] isEqualToString:[existingRecipient mobileUserId]]);
            XCTAssertTrue([[EngageConfig recipientId] isEqualToString:[existingRecipient recipientId]]);
            
            // verify old recipient is marked as merged on the server
            XMLAPI *selectMergedRecipientXml = [XMLAPI selectRecipientWithId:[currentRecipient recipientId] list:[self listId]];
            [[XMLAPIManager sharedInstance] postXMLAPI:selectMergedRecipientXml success:^(ResultDictionary *mergedRecipientResult) {
                
                // check that properties didn't change
                XCTAssertTrue([[mergedRecipientResult valueForColumnName:_mobileUserIdColumn] isEqualToString:[currentRecipient mobileUserId]]);
                XCTAssertTrue([[mergedRecipientResult valueForColumnName:CUSTOM_ID_COLUMN] length] == 0);
                
                // check marked as merged
                XCTAssertTrue([[mergedRecipientResult valueForColumnName:_mergedRecipientIdColumn] isEqualToString:[existingRecipient recipientId]]);
                XCTAssertTrue([[mergedRecipientResult valueForColumnName:_mergedDateColumn] length] > 0);
                
                [expectation fulfill];
                
            } failure:^(NSError *error) {
                XCTFail();
            }];
            
        } failure:^(CheckIdentityFailure *failure) {
            XCTFail();
        }];
        
    }];
    
    [self waitForExpectationsWithTimeout:4.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
}

-(void)testCheckIdentity_s3_existingRecipientWithMobileUserId_multipleCustomIds {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Check Identity Success"];
    
    
    [self waitForExpectationsWithTimeout:4.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
 XCTFail();
    
}

-(void)testCheckIdentity_selfFoundAsExistingRecipient_WithMobileUserId {
    XCTestExpectation *expectation = [self expectationWithDescription:@"Check Identity Success"];
    
    
    [self waitForExpectationsWithTimeout:4.0 handler:^(NSError *error) {
        if (error) {
            NSLog(@"Timeout Error: %@", error);
        }
    }];
    
    XCTFail();
    
}

@end
