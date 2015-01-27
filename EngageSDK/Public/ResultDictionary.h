//
//  ResultDictionary.h
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ResultDictionary : NSObject

- (id)initWithDictionary:(NSDictionary *)dictionary;
- (id)valueForShortPath:(NSString *)shortPath;

- (BOOL) isSuccess;
- (NSString *)faultString;
- (NSString *)recipientId;

@end
