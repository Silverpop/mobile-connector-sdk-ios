//
//  UBF.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "UBF.h"
#import "EngageConfig.h"
#import <sys/utsname.h>
#import <UIKit/UIKit.h>

@interface UBF ()

@property NSMutableDictionary *coreTemplate;

@end

@implementation UBF

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `createEventWithCode:params:` OR call the static wrappers instead.", NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (id)initCoreTemplate {
    if (self = [super init]) {
        struct utsname systemInfo;
        uname(&systemInfo);
        
        NSString *appName = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleDisplayName"];
        NSString *appVersion = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"CFBundleVersion"];
        
        if (!appName) {
            appName = @"__UNKNOWN__";
        }
        
        if (!appVersion) {
            appVersion = @"__UNKNOWN__";
        }
        
        NSString *deviceId = [EngageConfig deviceId];
        
        NSDictionary *template =  @{@"Device Name" : [[UIDevice currentDevice] model],
                                    @"Device Version" : [NSString stringWithCString:systemInfo.machine encoding:NSUTF8StringEncoding],
                                    @"OS Name" : [[UIDevice currentDevice] systemName],
                                    @"OS Version" : [[UIDevice currentDevice] systemVersion],
                                    @"App Name" : appName,
                                    @"App Version" : appVersion,
                                    @"Device Id" : deviceId,
                                    @"Primary User Id" : [EngageConfig primaryUserId],
                                    @"Anonymous Id" : [EngageConfig anonymousId] };
        
        self.coreTemplate = [NSMutableDictionary dictionaryWithDictionary:template];
    }
    return self;
}

+ (id)createEventWithCode:(NSString *)code params:(NSDictionary *)params {
    UBF *ubf = [[UBF alloc] initCoreTemplate];
    if (params && params.count > 0) {
        [ubf.coreTemplate addEntriesFromDictionary:params];
    }
    
    NSMutableArray *attributes = [NSMutableArray array];
    
    NSDate *date = [NSDate date];
    
    NSDateFormatter *dateFormatter = [NSDateFormatter new];
    [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd"];
    
    NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
    
    NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
    [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
    [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
    [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    
    NSString *eventTimestamp = [rfc3339DateFormatter stringFromDate:date];
    
    // reformat dictionary to universal format
    for (id key in ubf.coreTemplate) {
        id attribute = @{ @"name" : key,
                          @"value" : [ubf.coreTemplate objectForKey:key] };
        [attributes addObject:attribute];
    }
    
    return @{ @"eventTypeCode" : code,
              @"eventTimestamp" : eventTimestamp,
              @"attributes" : attributes };
}


+ (id)installed:(NSDictionary *)params {
    return [UBF createEventWithCode:@"12" params:params];
}

+ (id)sessionStarted:(NSDictionary *)params {
    return [UBF createEventWithCode:@"13" params:params];
}

+ (id)sessionEnded:(NSDictionary *)params {
    return [UBF createEventWithCode:@"14" params:params];
}

+ (id)goalAbandoned:(NSString *)goalName params:(NSDictionary *)params {
    NSMutableDictionary *goalAbandoned = [NSMutableDictionary dictionaryWithObject:goalName forKey:@"Goal Name"];
    [goalAbandoned addEntriesFromDictionary:params];
    return [UBF createEventWithCode:@"15" params:goalAbandoned];
}

+ (id)goalCompleted:(NSString *)goalName params:(NSDictionary *)params {
    NSMutableDictionary *goalCompleted = [NSMutableDictionary dictionaryWithObject:goalName forKey:@"Goal Name"];
    [goalCompleted addEntriesFromDictionary:params];
    return [UBF createEventWithCode:@"16" params:goalCompleted];
}

+ (id)namedEvent:(NSString *)eventName params:(NSDictionary *)params {
    NSMutableDictionary *namedEvent = [NSMutableDictionary dictionaryWithObject:eventName forKey:@"Event Name"];
    [namedEvent addEntriesFromDictionary:params];
    return [UBF createEventWithCode:@"17" params:namedEvent];
}

+ (id)receivedPushNotification:(NSDictionary *)params {
    
    NSString *displayedMessage = nil;
    if ([[[params objectForKey:@"aps"] objectForKey:@"alert"] isKindOfClass:[NSString class]]) {
        displayedMessage = [[params objectForKey:@"aps"] objectForKey:@"alert"];
    } else {
        displayedMessage = [[[params objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
    }
    
    NSMutableDictionary *namedEvent = [NSMutableDictionary dictionaryWithObject:displayedMessage forKey:@"Displayed Message"];
    [namedEvent setObject:@"" forKey:@"Latitude"];
    [namedEvent setObject:@"" forKey:@"Longitude"];
    [namedEvent setObject:@"" forKey:@"Call To Action"];
    [namedEvent setObject:params forKey:@"Payload"];
    [namedEvent setObject:@"" forKey:@"Tags"];
    [namedEvent setObject:@"" forKey:@"Current Campaign"];
    [namedEvent setObject:@"" forKey:@"Active Campaigns"];
    
    return [UBF createEventWithCode:@"18" params:namedEvent];
}

+ (id)openedNotification:(NSDictionary *)params {
    
    NSString *displayedMessage = nil;
    if ([[[params objectForKey:@"aps"] objectForKey:@"alert"] isKindOfClass:[NSString class]]) {
        displayedMessage = [[params objectForKey:@"aps"] objectForKey:@"alert"];
    } else {
        displayedMessage = [[[params objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
    }
    
    NSMutableDictionary *namedEvent = [NSMutableDictionary dictionaryWithObject:displayedMessage forKey:@"Displayed Message"];
    [namedEvent setObject:@"" forKey:@"Latitude"];
    [namedEvent setObject:@"" forKey:@"Longitude"];
    [namedEvent setObject:@"" forKey:@"Call To Action"];
    [namedEvent setObject:params forKey:@"Payload"];
    [namedEvent setObject:@"" forKey:@"Tags"];
    [namedEvent setObject:@"" forKey:@"Current Campaign"];
    [namedEvent setObject:@"" forKey:@"Active Campaigns"];
    
    return [UBF createEventWithCode:@"19" params:namedEvent];
}

+ (id)openedURL:(NSDictionary *)params {
    NSLog(@"HERE");
    return [UBF createEventWithCode:@"20" params:params];
}


+ (id)receivedLocalNotification:(UILocalNotification *)localNotification {
    
    NSMutableDictionary *namedEvent = [[NSMutableDictionary alloc] init];
    [namedEvent setObject:@"" forKey:@"Latitude"];
    [namedEvent setObject:@"" forKey:@"Longitude"];
    [namedEvent setObject:[localNotification alertAction] forKey:@"Call To Action"];
    [namedEvent setObject:[localNotification alertBody] forKey:@"Payload"];
    [namedEvent setObject:[localNotification userInfo] forKey:@"Tags"];
    [namedEvent setObject:@"" forKey:@"Current Campaign"];
    [namedEvent setObject:@"" forKey:@"Active Campaigns"];
    
    return [UBF createEventWithCode:@"21" params:namedEvent];
}

@end
