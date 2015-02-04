//
//  CheckIdentityResult.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/26/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import "CheckIdentityResult.h"

@implementation CheckIdentityResult

-(instancetype)initWithRecipientId :(NSString *)recipientId
                  mergedRecipientId:(NSString *)mergedRecipientId
                       mobileUserId:(NSString *)mobileUserId {
    if (self = [super init]) {
        _recipientId = recipientId;
        _mergedRecipientId = mergedRecipientId;
        _mobileUserId = mobileUserId;
    }
    return self;
}

@end
