//
//  EngageConfigManager.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/28/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "EngageConfigManager.h"
#import "EngageConfig.h"

@interface EngageConfigManager ()

@property (strong, nonatomic) NSDictionary *configs;

@end

@implementation EngageConfigManager

- (id) init {
    self = [super init];
    if (self) {
        NSString *path = [[NSBundle mainBundle] pathForResource:@"EngageConfig" ofType:@"plist" inDirectory:ENGAGE_CONFIG_BUNDLE];
        self.configs = [[NSDictionary alloc] initWithContentsOfFile:path];
    }
    return self;
}

+ (instancetype)sharedInstance {
    static dispatch_once_t p = 0;
    
    __strong static EngageConfigManager *_configManager = nil;
    
    dispatch_once(&p, ^{
        _configManager = [[self alloc] init];
    });
    
    return _configManager;
}

- (BOOL)locationServicesEnabled {
    return (BOOL)[[self.configs objectForKey:@"LocationServices"] objectForKey:@"enabled"];
}

- (NSString *)fieldNameForUBF:(NSString *)ubfFieldConstantName {
    return (NSString *)[[self.configs objectForKey:@"UBFFieldNames"] objectForKey:ubfFieldConstantName];
}

- (NSInteger)configForNetworkValue:(NSString *)networkFieldConstantName {
    return (NSInteger)[[self.configs objectForKey:@"Networking"] objectForKey:networkFieldConstantName];
}

- (long)longConfigForSessionValue:(NSString *)sessionFieldConstantName {
    return (long)[[self.configs objectForKey:@"Session"] objectForKey:sessionFieldConstantName];
}

- (NSString *)fieldNameForParam:(NSString *)paramFieldConstantName {
    return (NSString *)[[self.configs objectForKey:@"ParamFieldNames"] objectForKey:paramFieldConstantName];
}

- (NSString *)configForGeneralFieldName:(NSString *)generalFieldConstantName {
    return (NSString *)[[self.configs objectForKey:@"General"] objectForKey:generalFieldConstantName];
}

@end
