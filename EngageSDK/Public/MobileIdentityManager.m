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

@implementation MobileIdentityManager

- (void)setupRecipientWithSuccess:(void (^)(SetupRecipientResult*))didSucceed
                          failure:(void (^)(SetupRecipientResult*))didFail
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
    // TODO: implement me
    
}

@end
