//
//  SetupRecipientResult.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/21/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import "SetupRecipientResult.h"

@implementation SetupRecipientResult

-(instancetype)initWithRecipientId :(NSString *)recipientId {
    if (self = [super init]) {
        _recipientId = recipientId;
    }
    return self;
}

@end


