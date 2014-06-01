//
//  UBF.m
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "UBF.h"
#import <sys/utsname.h>
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>
#import "EngageConfig.h"
#import "EngageConfigManager.h"

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
                                    @"Anonymous Id" : [EngageConfig anonymousId]};
        
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
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    if (![mutParams objectForKey:[[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LAST_CAMPAIGN_NAME]]) {
        [mutParams setObject:[EngageConfig lastCampaign]
                      forKey:[[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LAST_CAMPAIGN_NAME]];
    }
    return [UBF createEventWithCode:@"12" params:mutParams];
}

+ (id)sessionStarted:(NSDictionary *)params withCampaign:(NSString *)campaignName {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];

    if (campaignName != nil && [campaignName length] > 0) {
        [EngageConfig storeCurrentCampaign:campaignName withExpirationTimestamp:-1];
    } else {
        NSLog(@"SessionStarted with empty CampaignName. Not storing value and using previous campaign name value");
    }

    mutParams = [self setValue:[EngageConfig currentCampaign] forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    return [UBF createEventWithCode:@"13" params:mutParams];
}

+ (id)sessionEnded:(NSDictionary *)params {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    mutParams = [self setValue:[EngageConfig currentCampaign] forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    return [UBF createEventWithCode:@"14" params:mutParams];
}

+ (id)goalAbandoned:(NSString *)goalName params:(NSDictionary *)params {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    mutParams = [self setValue:goalName forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_GOAL_NAME];
    mutParams = [self setValue:[EngageConfig currentCampaign] forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    return [UBF createEventWithCode:@"15" params:mutParams];
}

+ (id)goalCompleted:(NSString *)goalName params:(NSDictionary *)params {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    mutParams = [self setValue:goalName forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_GOAL_NAME];
    mutParams = [self setValue:[EngageConfig currentCampaign] forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    return [UBF createEventWithCode:@"16" params:mutParams];
}

+ (id)namedEvent:(NSString *)eventName params:(NSDictionary *)params {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    mutParams = [self setValue:eventName forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_EVENT_NAME];
    mutParams = [self setValue:[EngageConfig currentCampaign] forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    return [UBF createEventWithCode:@"17" params:mutParams];
}

+ (id)receivedLocalNotification:(UILocalNotification *)localNotification withParams:(NSDictionary *)params {
    NSMutableDictionary *locNotEvent = [self populateEventCommonParams:params];
    locNotEvent = [self setValue:[EngageConfig currentCampaign] forDictionary:locNotEvent withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    locNotEvent = [self setValue:[localNotification alertAction] forDictionary:locNotEvent withPlistUBFFieldName:PLIST_UBF_CALL_TO_ACTION];
    locNotEvent = [self setValue:[localNotification alertBody] forDictionary:locNotEvent withPlistUBFFieldName:PLIST_UBF_DISPLAYED_MESSAGE];
    return [UBF createEventWithCode:@"48" params:locNotEvent];
}

+ (id)receivedPushNotification:(NSDictionary *)notification withParams:(NSDictionary *)params {
    
    NSString *displayedMessage = nil;
    if ([[[params objectForKey:@"aps"] objectForKey:@"alert"] isKindOfClass:[NSString class]]) {
        displayedMessage = [[params objectForKey:@"aps"] objectForKey:@"alert"];
    } else {
        displayedMessage = [[[params objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
    }
    
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    mutParams = [self setValue:[EngageConfig currentCampaign] forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    mutParams = [self setValue:displayedMessage forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_DISPLAYED_MESSAGE];
    //Call To Action must be provided by the SDK user in this case.
    
    return [UBF createEventWithCode:@"48" params:mutParams];
}

+ (id)openedNotification:(NSDictionary *)notification withParams:(NSDictionary *)params {
    
    NSString *displayedMessage = nil;
    if ([[[params objectForKey:@"aps"] objectForKey:@"alert"] isKindOfClass:[NSString class]]) {
        displayedMessage = [[params objectForKey:@"aps"] objectForKey:@"alert"];
    } else {
        displayedMessage = [[[params objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
    }
    
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    mutParams = [self setValue:[EngageConfig currentCampaign] forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    mutParams = [self setValue:displayedMessage forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_DISPLAYED_MESSAGE];
    //Call To Action must be provided by the SDK user in this case.
    
    return [UBF createEventWithCode:@"49" params:mutParams];
}

+ (NSMutableDictionary *) populateEventCommonParams:(NSDictionary *)params {
    NSMutableDictionary *mutParams = nil;
    if (params) {
        mutParams = [params mutableCopy];
        mutParams = [self addDelimitedTagsToParams:mutParams];
    } else {
        mutParams = [[NSMutableDictionary alloc] init];
    }
    
    return mutParams;
}

+ (NSMutableDictionary *) addDelimitedTagsToParams:(NSMutableDictionary *)params
{
    if (params) {
        if ([params objectForKey:[[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_TAGS]]) {
            id tagsParam = [params objectForKey:[[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_TAGS]];
            if ([tagsParam isKindOfClass:[NSArray class]]) {
                [params setObject:[tagsParam componentsJoinedByString:@","] forKey:[[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_TAGS]];
            } else {
                [params setObject:@"" forKey:[[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_TAGS]];
            }
        }
    }
    return params;
}

+ (NSMutableDictionary *)setValue:(id)value
                      forDictionary:(NSMutableDictionary *)dictionary
                        withPlistUBFFieldName:(NSString *)ubfFieldName {
    
    if (value) {
        if (![dictionary objectForKey:[[EngageConfigManager sharedInstance] fieldNameForUBF:ubfFieldName]]) {
            [dictionary setObject:value
                           forKey:[[EngageConfigManager sharedInstance] fieldNameForUBF:ubfFieldName]];
        }
    }
    
    return dictionary;
}

@end
