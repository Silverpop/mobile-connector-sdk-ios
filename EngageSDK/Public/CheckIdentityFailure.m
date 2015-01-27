//
//  CheckIdentityFailure.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/26/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import "CheckIdentityFailure.h"

@implementation CheckIdentityFailure

-(instancetype)initWithMessage:(NSString *)message
                         error:(NSError *)error {
    if (self = [super init]) {
        _message= message;
        _error = error;
    }
    return self;
}

@end