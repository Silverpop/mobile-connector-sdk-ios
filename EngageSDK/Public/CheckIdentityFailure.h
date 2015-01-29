//
//  CheckIdentityFailure.h
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/26/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckIdentityFailure : NSObject

@property (nonatomic) NSError *error;
@property (nonatomic) NSString *message;

-(instancetype)initWithMessage:(NSString *)message
                         error:(NSError *)error;

@end
