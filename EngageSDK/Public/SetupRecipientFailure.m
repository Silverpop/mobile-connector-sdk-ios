//
//  SetupRecipientFailure.m
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/22/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import "SetupRecipientFailure.h"

@implementation SetupRecipientFailure


-(id) initWithMessage:(NSString *)errorMessage {
    if (self = [super init]) {
        self.errorMessage = errorMessage;
    }
    return self;
}

-(id) initWithMessage:(NSString *)errorMessage
             response:(ResultDictionary *)failureResponse {
    if (self = [super init]) {
        self.errorMessage = errorMessage;
        self.responseDictionary = failureResponse;
    }
    return self;
}

-(id) initWithMessage:(NSString *)errorMessage
                error:(NSError *)error {
    if (self = [super init]) {
        self.errorMessage = errorMessage;
        self.error = error;
    }
    return self;
}

@end
