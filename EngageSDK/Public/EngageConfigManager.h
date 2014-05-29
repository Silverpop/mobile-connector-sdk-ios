//
//  EngageConfigManager.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/28/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface EngageConfigManager : NSObject

+ (instancetype) sharedInstance;

- (BOOL)locationServicesEnabled;
- (NSString *)fieldNameForUBF:(NSString *)ubfFieldConstantName;
- (NSInteger)configForNetworkValue:(NSString *)networkFieldConstantName;
- (long)longConfigForSessionValue:(NSString *)sessionFieldConstantName;
- (NSString *)fieldNameForParam:(NSString *)paramFieldConstantName;
- (NSString *)configForGeneralFieldName:(NSString *)generalFieldConstantName;

@end
