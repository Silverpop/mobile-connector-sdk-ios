//
//  EngageRecipient.h
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/28/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

@interface EngageRecipient : NSObject

@property NSString *recipientId;
@property NSString *mobileUserId;
@property NSDictionary *customIdFields;

-(instancetype)initWithRecipientId:(NSString *)recipientId mobileUserId:(NSString *)mobileUserId customIdFields:(NSDictionary *)customIdFields;

@end
