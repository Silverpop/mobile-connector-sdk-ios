//
//  MobileIdentityManager.h
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/20/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import "SetupRecipientResult.h"
#import "SetupRecipientFailure.h"

@interface MobileIdentityManager : NSObject

+ (instancetype)sharedInstance;

-(void)setupRecipientWithSuccess:(void (^)(SetupRecipientResult*))didSucceed
                         failure:(void (^)(SetupRecipientFailure*))didFail;

@end
