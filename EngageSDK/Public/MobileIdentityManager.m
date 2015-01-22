//
//  MobileIdentityManager.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/20/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import "MobileIdentityManager.h"
#import "EngageConfig.h"
#import "SetupRecipientResult.h"
#import "SetupRecipientFailure.h"
#import "EngageConfigManager.h"
#import "EngageUUIDGenerating.h"
#import "EngageDefaultUUIDGenerator.h"
#import "XMLAPI.h"
#import "XMLAPIManager.h"

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


- (void)setupRecipientWithSuccess:(void (^)(SetupRecipientResult*))didSucceed
                          failure:(void (^)(SetupRecipientFailure*))didFail
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
    
    NSString *mobileUserIdColumn = [EngageConfig primaryUserId];
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
                                                   
                                               }
                                               
                                           } failure:^(NSError *error) {
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

@end
