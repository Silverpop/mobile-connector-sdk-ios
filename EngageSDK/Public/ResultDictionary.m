//
//  ResultDictionary.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "ResultDictionary.h"

@implementation ResultDictionary

{
    NSDictionary* _proxy;
}

- (id)initWithDictionary:(NSDictionary *)dictionary {
    if (self = [super init]) {
        _proxy = [NSDictionary dictionaryWithDictionary:dictionary];
    }
    return self;
}

- (id)forwardingTargetForSelector:(SEL)aSelector
{
    NSLog(@"FORWARDING_____: %s",sel_getName(aSelector));
    return _proxy;
}

- (id)valueForKey:(NSString *)key {
    return [_proxy valueForKey:key];
}

- (id)columnValue:(NSDictionary *)column {
    id value = [column objectForKey:@"value"];
    return [value objectForKey:@"text"];
}

- (id)valueForShortPath:(NSString *)shortPath {
    NSArray *keyPathArray = [[shortPath lowercaseString] componentsSeparatedByString:@"."];
    NSString *rootPath = [keyPathArray objectAtIndex:0];
    if ([rootPath isEqualToString:@"columns"]) {
        NSArray *columns = [_proxy valueForKeyPath:@"columns.column"];
        for (NSDictionary *col in columns) {
            if ([[[col valueForKeyPath:@"name.text"] lowercaseString] isEqualToString:[keyPathArray objectAtIndex:1] ]) {
                return [self columnValue:col];
            }
        }
    }
    else {
        
        id pathObject = nil;
        for (int i=0; i<keyPathArray.count; i++) {
            
            if (i == 0) {
                pathObject = [_proxy objectForKey:[keyPathArray objectAtIndex:i]];
            }
            else {
                pathObject = [pathObject objectForKey:[keyPathArray objectAtIndex:i]];
            }
            
            // collection on path
            if ([pathObject isKindOfClass:[NSArray class]]) {
                return pathObject;
            }
            
            // last path segment
            if (i == keyPathArray.count-1) {
                return [pathObject objectForKey:@"text"] ? [pathObject objectForKey:@"text"] : @"";
            }
        }
    }
    
    return [_proxy valueForKeyPath:shortPath];
}

- (id)valueForKeyPath:(NSString *)keyPath {
    return [_proxy valueForKeyPath:keyPath];
}

- (id)valueForUndefinedKey:(NSString *)key {
    NSLog(@"_______ResultDictionary.valueForUndefinedKey:%@",key);
    return [_proxy valueForUndefinedKey:key];
}

- (NSString *)debugDescription {
    return [_proxy debugDescription];
}

- (NSString *)description {
    return [_proxy description];
}

@end
