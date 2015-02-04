//
//  SetupRecipientFailure.h
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/22/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ResultDictionary.h"

@interface SetupRecipientFailure: NSObject

@property (nonatomic) NSString* errorMessage;
@property (nonatomic) ResultDictionary* responseDictionary;
@property (nonatomic) NSError* error;

-(id) initWithMessage:(NSString *)errorMessage;
-(id) initWithMessage:(NSString *)errorMessage response:(ResultDictionary *)failureResponse;
-(id) initWithMessage:(NSString *)errorMessage error:(NSError *)error;

@end
