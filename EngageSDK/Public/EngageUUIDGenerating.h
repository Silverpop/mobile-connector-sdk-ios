//
//  EngageUUIDGenerator.h
//  EngageSDK
//
//  Created by Lindsay Thurmond on 1/21/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol EngageUUIDGenerating <NSObject>

- (NSString *)generateUUID;

@end
