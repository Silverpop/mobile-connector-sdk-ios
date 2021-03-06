//
//  CheckIdentityResult.h
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/26/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CheckIdentityResult : NSObject

@property (nonatomic) NSString *recipientId;
@property (nonatomic) NSString *mobileUserId;
@property (nonatomic) NSString *mergedRecipientId;

-(instancetype)initWithRecipientId :(NSString *)recipientId
                  mergedRecipientId:(NSString *)mergedRecipientId
                       mobileUserId:(NSString *)mobileUserId;

@end
