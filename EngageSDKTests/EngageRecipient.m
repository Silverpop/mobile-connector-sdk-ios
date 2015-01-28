//
//  EngageRecipient.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/28/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EngageRecipient.h"

@implementation EngageRecipient

-(instancetype)initWithRecipientId:(NSString *)recipientId mobileUserId:(NSString *)mobileUserId customIdFields:(NSDictionary *)customIdFields {
    
    if (self = [super init]) {
        _recipientId = recipientId;
        _mobileUserId = mobileUserId;
        _customIdFields = customIdFields;
    }
    return self;
}

@end
