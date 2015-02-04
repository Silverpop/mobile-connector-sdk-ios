//
//  SetupRecipientResult.h
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/21/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//


@interface SetupRecipientResult : NSObject

@property (nonatomic) NSString *recipientId;

-(instancetype)initWithRecipientId :(NSString *)recipientId;

@end
