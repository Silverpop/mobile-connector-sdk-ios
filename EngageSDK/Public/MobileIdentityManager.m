//
//  MobileIdentityManager.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/20/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import "MobileIdentityManager.h"
#import "EngageConfig.h"
#import "EngageConfigManager.h"
#import "EngageUUIDGenerating.h"
#import "EngageDefaultUUIDGenerator.h"
#import "XMLAPI.h"
#import "XMLAPIManager.h"
#import "XMLAPIErrorCode.h"
#import "XMLAPIOperation.h"
#import "EngageDateFormatter.h"


@interface MobileIdentityManager ()

@property (strong, nonatomic) EngageConfigManager *engageConfigManager;

@end

@implementation MobileIdentityManager

__strong static MobileIdentityManager *_sharedInstance = nil;

+ (instancetype)sharedInstance {
    static dispatch_once_t pred = 0;
    dispatch_once(&pred, ^{
        _sharedInstance = [MobileIdentityManager new];
        _sharedInstance.engageConfigManager = [EngageConfigManager sharedInstance];
    });
    return _sharedInstance;
}


- (void)setupRecipientWithSuccess:(void (^)(SetupRecipientResult* result))didSucceed
                          failure:(void (^)(SetupRecipientFailure* failure))didFail
{
    NSString* existingRecipientId = [EngageConfig recipientId];
    NSString* existingMobileUserId = [EngageConfig primaryUserId];

    if ([existingMobileUserId length] > 0 && [existingMobileUserId length] > 0) {
        // already configured, return existing values
        didSucceed(
            [[SetupRecipientResult alloc] initWithRecipientId:existingRecipientId]);
        return;
    }
  
    // validate that we can auto generate the recipient
    if ([existingMobileUserId length] == 0 && ![_engageConfigManager autoAnonymousTrackingEnabled]) {
        NSString *error = @"Cannot create user with empty mobileUserId.  mobileUserId must be set manually or enableAutoAnonymousTracking must be set to true";
        NSLog(@"%@", error);
        didFail([[SetupRecipientFailure alloc] initWithMessage:error]);
        return;
    }
    
    NSString *listId = [EngageConfig engageListId];
    if ([listId length] == 0) {
        NSString *error = @"ListId must be configured before recipient can be auto configured.";
        NSLog(@"%@", error);
        didFail([[SetupRecipientFailure alloc] initWithMessage:error]);
        return;
    }
    
    NSString *mobileUserIdColumn = [[EngageConfigManager sharedInstance] recipientMobileUserIdColumn];
    if ([mobileUserIdColumn length] == 0) {
        NSString *error = @"mobileUserIdColumn must be configured before recipient can be auto configured.";
        NSLog(@"%@", error);
        didFail([[SetupRecipientFailure alloc] initWithMessage:error]);
        return;
    }
    
    // validation passed!
    
    // create new recipient
    if ([existingRecipientId length] == 0) {
        
        // generate new mobile user id if needed
        NSString *newMobileUserId = [NSString stringWithString:existingMobileUserId];
        if ([newMobileUserId length] == 0) {
            newMobileUserId = [self generateMobileUserId];
            [EngageConfig storePrimaryUserId:newMobileUserId];
        }
        
        XMLAPI *addRecipientXml = [XMLAPI addRecipientWithMobileUserIdColumnName:mobileUserIdColumn mobileUserId:newMobileUserId list:listId];
        [[XMLAPIManager sharedInstance] postXMLAPI:addRecipientXml
                                           success:^(ResultDictionary *ERXML) {
                                               if ([ERXML isSuccess]) {
                                                   NSString *recipientId = [ERXML valueForShortPath:@"RecipientId"];
                                                   
                                                   if ([recipientId length] == 0) {
                                                       didFail([[SetupRecipientFailure alloc] initWithMessage:@"Empty recipientId returned from Silverpop" response:ERXML]);
                                                   } else {
                                                       [EngageConfig storeRecipientId:recipientId];
                                                       didSucceed([[SetupRecipientResult alloc] initWithRecipientId:recipientId]);
                                                   }
                                               } else {
                                                   didFail([[SetupRecipientFailure alloc] initWithMessage:[ERXML faultString] response:ERXML]);
                                               }
                                           }
                                           failure:^(NSError *error) {
                                               NSString *message = [@"Unexpected exception making update recipient API call to silverpop" stringByAppendingString:error.description];
                                               NSLog(@"%@", message);
                                               didFail([[SetupRecipientFailure alloc] initWithMessage:message
                                                                                                error:error]);
                                           }];
        
        
    }
    // we have existing existingRecipientId but not mobileUserId - this isn't expected but we need to handle if it happens
    else {
        // update the existing recipient with a mobile user id
        
        // generate new mobile user id
        NSString *newMoblieUserId = [self generateMobileUserId];
        // TODO: change to mobileUserId syntax
        [EngageConfig storePrimaryUserId:newMoblieUserId];
        
        XMLAPI *updateRecipientXml = [XMLAPI updateRecipient:existingRecipientId list:listId];
        [updateRecipientXml addColumns:@{ mobileUserIdColumn : newMoblieUserId }];
        
        [[XMLAPIManager sharedInstance] postXMLAPI:updateRecipientXml success:^(ResultDictionary *ERXML) {
            if ([ERXML isSuccess]) {
                NSString *recipientId = [ERXML valueForShortPath:@"RecipientId"];
                didSucceed([[SetupRecipientResult alloc] initWithRecipientId:recipientId]);
            } else {
                // TODO : pull fault string out to use as message
                NSString *message = @"";
                NSLog(@"%@", message);
                didFail([[SetupRecipientFailure alloc] initWithMessage:message response:ERXML]);
            }
        } failure:^(NSError *error) {
            NSString *message = [@"Unexpected error making update recipient API call to silverpop: " stringByAppendingString:error.description];
            NSLog(@"%@", message);
            didFail([[SetupRecipientFailure alloc] initWithMessage:message error:error]);
        }];
    
    }
    
    //TODO: handle all unexpected exceptions
    
}

- (NSString *) generateMobileUserId {
    NSString *uuidClassName = [[EngageConfigManager sharedInstance] mobileUserIdGeneratorClassName];
    NSString *mobileUserId = nil;
    @try {
        mobileUserId= [[[NSClassFromString(uuidClassName) alloc] init] generateUUID];
    }
    @catch (NSException *exception) {
        // ignore
    }
    
    if ([mobileUserId length] == 0) {
        mobileUserId = [[EngageDefaultUUIDGenerator new] generateUUID];
    }
    return mobileUserId;
}

-(void)checkIdentityForIds:(NSDictionary *) fieldsToIds success:(void (^)(CheckIdentityResult* result))didSucceed
                   failure:(void (^)(CheckIdentityFailure* failure))didFail {
    
    [self setupRecipientWithSuccess:^(SetupRecipientResult *result) {
        
        NSString *currentRecipientId = [result recipientId];
        [self checkForExistingRecipientAndUpdateIfNeededByIds:fieldsToIds currentRecipientId:currentRecipientId success:didSucceed failure:didFail];
        
    } failure:^(SetupRecipientFailure *failure) {
        NSLog([@"ERROR: " stringByAppendingString:[failure errorMessage]], [failure error]);
        if (didFail) {
            didFail([[CheckIdentityFailure alloc] initWithMessage:[failure errorMessage] error:[failure error]]);
        }
    }];
    
}

- (NSString *)mobileUserIdColumn
{
    NSString *mobileUserIdColumn = [[EngageConfigManager sharedInstance] recipientMobileUserIdColumn];
    return mobileUserIdColumn;
}

-(void)checkForExistingRecipientAndUpdateIfNeededByIds:(NSDictionary *)fieldsToIds
                                    currentRecipientId:(NSString *)currentRecipientId
                                               success:(void (^)(CheckIdentityResult* result))didSucceed
                                               failure:(void (^)(CheckIdentityFailure* failure))didFail {
    
    NSString *listId = [EngageConfig engageListId];
    
    // look up recipient from Sliverpop
    
    XMLAPI *selectRecipientXml = [XMLAPI resourceNamed:XMLAPI_OPERATION_SELECT_RECIPIENT_DATA];
    [selectRecipientXml listId:listId];
    [selectRecipientXml addColumns:fieldsToIds];
    
    [[XMLAPIManager sharedInstance] postXMLAPI:selectRecipientXml success:^(ResultDictionary *existingRecipientResult) {
        
        // scenario 1 - recipient not found
        if (![existingRecipientResult isSuccess]) {
            
            if ([existingRecipientResult errorId] == XMLAPI_ERROR_RECIPIENT_NOT_LIST_MEMBER) {
                // recipient doesn't exist
                [self updateRecipientWithCustomIds:fieldsToIds currentRecipientId:currentRecipientId listId:listId success:didSucceed failure:didFail];
                
            } else {
                // unexpected error with select recipient
                NSLog(@"%@", [@"ERROR" stringByAppendingString:[existingRecipientResult faultString]]);
                if (didFail) {
                    didFail([[CheckIdentityFailure alloc] initWithMessage:[existingRecipientResult faultString] error:nil]);
                }
            }
        }
        // we found an existing recipient - does it have a mobileUserId?
        else {
            
            NSString *existingRecipientId = [existingRecipientResult recipientId];
            NSString *mobileUserIdColumn = [self mobileUserIdColumn];
            NSString *existingMobileUserId = [existingRecipientResult valueForColumnName:mobileUserIdColumn];
            
            if ([existingRecipientId isEqualToString:[EngageConfig recipientId]]) {
                [self handleExistingRecipientIsSameAsInAppWithMobileUserId:existingMobileUserId success:didSucceed failure:didFail];
                
            } else {
                // scenario 2 - existing recipient doesn't have a mobileUserId
                if ([existingMobileUserId length] == 0) {
                    [self handleExistingRecipientWithoutRecipientId:existingRecipientResult success:didSucceed failure:didFail];
                    
                }
                // scenario 3 - existing recipient has a mobileUserId
                else {
                    [self handleExistingRecipientWithRecipientId:currentRecipientId existingMobileUserId:existingMobileUserId existingRecipientResult:existingRecipientResult success:didSucceed failure:didFail];
                }
            }
        }
    } failure:^(NSError *error) {
        //TODO: finish me
    }];
}

-(void)handleExistingRecipientIsSameAsInAppWithMobileUserId:(NSString *)existingMobileUserId
                                                    success:(void (^)(CheckIdentityResult* result))didSucceed
                                               failure:(void (^)(CheckIdentityFailure* failure))didFail {
    
    // It really shouldn't be possible to get here since the first thing CheckIdentity does
    // is call setupRecipient which would fill in the mobile user id for the recipient if
    // it was missing before we got here - but just in case let's handle it here again
    
    NSString *currentRecipientId = [EngageConfig recipientId];
    NSString *currentMobileUserId = [EngageConfig primaryUserId];
    
    if ([existingMobileUserId length] > 0) {
        // recipient on server already has mobile user id, nothing to do here
        if (didSucceed) {
            didSucceed([[CheckIdentityResult alloc] initWithRecipientId:currentRecipientId mergedRecipientId:nil mobileUserId:currentMobileUserId]);
        }
        
    } else {
        // update with mobile user id
        XMLAPI *updateExistingRecipientXml = [XMLAPI updateRecipient:currentRecipientId list:[EngageConfig engageListId]];
        [updateExistingRecipientXml addColumn:[[EngageConfigManager sharedInstance] recipientMobileUserIdColumn] :currentMobileUserId];
        [[XMLAPIManager sharedInstance] postXMLAPI:updateExistingRecipientXml success:^(ResultDictionary *ERXML) {
            if (didSucceed) {
                didSucceed([[CheckIdentityResult alloc] initWithRecipientId:currentRecipientId mergedRecipientId:nil mobileUserId:currentMobileUserId]);
            }
        } failure:^(NSError *error) {
            NSLog(@"%@", error);
            if (didFail) {
                didFail([[CheckIdentityFailure alloc] initWithMessage:[error description] error:error]);
            }
        }];
    }
    
}

/**
 *  Scenario 1 - no existing recipient
 */
-(void)updateRecipientWithCustomIds:(NSDictionary *)fieldsToIds
                 currentRecipientId:(NSString *)currentRecipientId
                             listId:(NSString *)listId
                            success:(void (^)(CheckIdentityResult* result))didSucceed
                            failure:(void (^)(CheckIdentityFailure* failure))didFail {
    
    // update recipient with custom id(s)
    XMLAPI *updateCurrentRecipientXml = [XMLAPI updateRecipient:currentRecipientId list:listId];
    [updateCurrentRecipientXml addColumns:fieldsToIds];
    
    [[XMLAPIManager sharedInstance] postXMLAPI:updateCurrentRecipientXml success:^(ResultDictionary *ERXML) {
        
        if ([ERXML isSuccess]) {
            if (didSucceed) {
                didSucceed([[CheckIdentityResult alloc] initWithRecipientId:[ERXML recipientId] mergedRecipientId:nil mobileUserId:[EngageConfig primaryUserId]]);
            }
            
        } else {
            if (didFail) {
                didFail([[CheckIdentityFailure alloc] initWithMessage:[ERXML faultString] error:nil]);
            }
        }
        
    } failure:^(NSError *error) {
        didFail([[CheckIdentityFailure alloc] initWithMessage:[error description] error:error]);
    }];

}

/**
 *  Scenario 2 - existing recipient doesn't have a mobileUserId
 */
-(void)handleExistingRecipientWithoutRecipientId:(ResultDictionary *)existingRecipientResult
                                         success:(void (^)(CheckIdentityResult* result))didSucceed
                                         failure:(void (^)(CheckIdentityFailure* failure))didFail {

    NSString *mobileUserIdFromApp = [EngageConfig primaryUserId];
    if ([mobileUserIdFromApp length] == 0) {
        NSString *message = @"Cannot find mobileUserId to update the existing recipient";
        NSLog(@"%@", message);
        if (didFail) {
            didFail([[CheckIdentityFailure alloc]initWithMessage:message error:nil]);
        }
    } else {
        
        // update existing recipient on server with new mobile user id
        XMLAPI *updateExistingRecipientXml = [XMLAPI updateRecipient:[existingRecipientResult recipientId] list:[EngageConfig engageListId]];
        [updateExistingRecipientXml addColumn:[self mobileUserIdColumn] :mobileUserIdFromApp];

        [[XMLAPIManager sharedInstance] postXMLAPI:updateExistingRecipientXml success:^(ResultDictionary *ERXML) {
            
            // clear mobile user id from recipient in app config, and set its merged_recipient_id_ and merged date
            
            // update recipient currently in the app config
            XMLAPI *updateCurrentRecipientXml = [XMLAPI updateRecipient:[EngageConfig recipientId] list:[EngageConfig engageListId]];
            [updateCurrentRecipientXml addColumn:[self mobileUserIdColumn] :@""];
            if ([[EngageConfigManager sharedInstance] recipientMergeHistoryInMarketingDatabase]) {
                [updateCurrentRecipientXml addColumn:[[EngageConfigManager sharedInstance] recipientMergedDateColumn] :[EngageDateFormatter nowGmtString]];
                [updateCurrentRecipientXml addColumn:[[EngageConfigManager sharedInstance] recipientMergedRecipientIdColumn] :[existingRecipientResult recipientId]];
            }
            
            [[XMLAPIManager sharedInstance] postXMLAPI:updateCurrentRecipientXml success:^(ResultDictionary *updateCurrentRecipientResult) {
               
                NSString *oldRecipientId = [EngageConfig recipientId];
                NSString *newRecipientId = [existingRecipientResult recipientId];
                [EngageConfig storeRecipientId:newRecipientId];
                
                //TODO: update audit table if needed
                
                if (didSucceed) {
                    didSucceed([[CheckIdentityResult alloc] initWithRecipientId:newRecipientId mergedRecipientId:oldRecipientId mobileUserId:[EngageConfig primaryUserId]]);
                }
                
                
            } failure:^(NSError *error) {
                NSLog(@"%@", error);
                if (didFail) {
                    didFail([[CheckIdentityFailure alloc] initWithMessage:nil error:error]);
                }
            }];
            
        } failure:^(NSError *error) {
            NSLog(@"%@", error);
            if (didFail) {
                didFail([[CheckIdentityFailure alloc] initWithMessage:nil error:error]);
            }
        }];
    }
}

/**
 *  Scenario 3 - existing recipient has a mobileUserId
 */
-(void)handleExistingRecipientWithRecipientId:(NSString *)currentRecipientId
                         existingMobileUserId:(NSString *)existingMobileUserId
                      existingRecipientResult:(ResultDictionary *)existingRecipientResult
                                      success:(void (^)(CheckIdentityResult* result))didSucceed
                                      failure:(void (^)(CheckIdentityFailure* failure))didFail {
    
    XMLAPI *updateCurrentRecipientXml = [XMLAPI updateRecipient:currentRecipientId list:[EngageConfig engageListId]];
    if ([[EngageConfigManager sharedInstance] recipientMergeHistoryInMarketingDatabase]) {
        [updateCurrentRecipientXml addColumn:[[EngageConfigManager sharedInstance] recipientMergedDateColumn] :[EngageDateFormatter nowGmtString]];
        [updateCurrentRecipientXml addColumn:[[EngageConfigManager sharedInstance] recipientMergedRecipientIdColumn] :[existingRecipientResult recipientId]];
    }
    
    [[XMLAPIManager sharedInstance] postXMLAPI:updateCurrentRecipientXml success:^(ResultDictionary *ERXML) {
        
        // start using existing recipient id instead
        NSString *oldRecipientId = [EngageConfig recipientId];
        NSString *newRecipientId = [existingRecipientResult recipientId];
        [EngageConfig storeRecipientId:newRecipientId];
        [EngageConfig storePrimaryUserId:existingMobileUserId];
        
        //TODO: update audit table if needed
        
        if (didSucceed) {
            didSucceed([[CheckIdentityResult alloc] initWithRecipientId:newRecipientId mergedRecipientId:oldRecipientId mobileUserId:existingMobileUserId]);
        }
        
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        if (didFail) {
            didFail([[CheckIdentityFailure alloc] initWithMessage:nil error:error]);
        }
    }];
    
}


@end
