//
//  MobileIdentityManager.h
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/20/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import "SetupRecipientResult.h"
#import "SetupRecipientFailure.h"
#import "CheckIdentityResult.h"
#import "CheckIdentityFailure.h"

@interface MobileIdentityManager : NSObject

+ (instancetype)sharedInstance;

-(void)setupRecipientWithSuccess:(void (^)(SetupRecipientResult* result))didSucceed
                         failure:(void (^)(SetupRecipientFailure* failure))didFail;

-(void)checkIdentityForIds:(NSDictionary *)fieldsToIds
                   success:(void (^)(CheckIdentityResult* result))didSucceed
                   failure:(void (^)(CheckIdentityFailure* failure))didFail;

@end
