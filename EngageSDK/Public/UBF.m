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

@implementation UBF

@synthesize attributes = _attributes;
@synthesize eventTimeStamp = _eventTimeStamp;
@synthesize eventTypeCode = _eventTypeCode;

- (id)init {
    @throw [NSException exceptionWithName:NSInternalInconsistencyException
                                   reason:[NSString stringWithFormat:@"%@ Failed to call designated initializer. Invoke `createEventWithCode:params:` OR call the static wrappers instead.", NSStringFromClass([self class])]
                                 userInfo:nil];
}

- (id)initFromJSON:(NSString *)jsonString {
    self = [super init];
    
    if (self) {
        NSError *error;
        NSDictionary *originalEventData = [NSJSONSerialization JSONObjectWithData:[jsonString dataUsingEncoding:NSUTF8StringEncoding]
                                                                          options:kNilOptions
                                                                            error:&error];
        _eventTimeStamp = [originalEventData objectForKey:@"eventTimestamp"];
        _eventTypeCode = [originalEventData objectForKey:@"eventTypeCode"];
        _attributes = [[NSMutableDictionary alloc] init];
        NSArray *keyValues = [originalEventData objectForKey:@"attributes"];
        if (keyValues) {
            for (NSDictionary *obj in keyValues) {
                if ([obj objectForKey:@"name"] && [obj objectForKey:@"value"]) {
                    [_attributes setObject:[obj objectForKey:@"value"] forKey:[obj objectForKey:@"name"]];
                }
            }
        }
    }
    return self;
}

-(id)initEventOfType:(NSString *)eventType withParams:(NSMutableDictionary *)params {
    self = [super init];
    
    if (self) {
        _attributes = [[NSMutableDictionary alloc] init];
        _eventTypeCode = eventType;
        
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
        
        NSDate *date = [NSDate date];
        
        NSDateFormatter *dateFormatter = [NSDateFormatter new];
        [dateFormatter setDateFormat:@"yyyy'-'MM'-'dd"];
        
        NSLocale *enUSPOSIXLocale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        
        NSDateFormatter *rfc3339DateFormatter = [[NSDateFormatter alloc] init];
        [rfc3339DateFormatter setLocale:enUSPOSIXLocale];
        [rfc3339DateFormatter setDateFormat:@"yyyy'-'MM'-'dd'T'HH':'mm':'ss'.'SSS'Z'"];
        [rfc3339DateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
        
        _eventTimeStamp = [rfc3339DateFormatter stringFromDate:date];
        
        [_attributes addEntriesFromDictionary:template];
        if (params) {
            for (id key in params) {
                id ob = [params objectForKey:key];
                if (![ob isKindOfClass:[NSDictionary class]]) {
                    [_attributes setObject:ob forKey:key];
                }
            }
        }
    }
    
    return self;
}

+ (UBF *)createEventWithCode:(NSString *)code params:(NSDictionary *)params {
    return [[UBF alloc] initEventOfType:code withParams:[params mutableCopy]];
}

- (NSDictionary *)dictionaryValue {
    NSMutableArray *jsonKeyValueAttributes = [NSMutableArray array];
    
    for (id key in _attributes) {
        id attribute = @{@"name" : key,
                         @"value" : [_attributes objectForKey:key]};
        [jsonKeyValueAttributes addObject:attribute];
    }
    
    NSDictionary *data = @{ @"eventTypeCode" : _eventTypeCode,
                            @"eventTimestamp" : _eventTimeStamp,
                            @"attributes" : jsonKeyValueAttributes };
    return data;
}

- (NSString *) jsonValue {
    
    NSDictionary *data = [self dictionaryValue];
    
    NSError *error;
    NSString *jsonString;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:data
                                                       options:0
                                                         error:&error];
    if (!jsonData) {
        NSLog(@"Error converting UBF to JSON: %@", error);
    } else {
        jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    }
    return jsonString;
}

- (void)setAttribute:(NSString *)attributeName value:(NSString *)attributeValue {
    if (_attributes && attributeValue && attributeName) {
        [_attributes setObject:attributeValue forKey:attributeName];
    }
}


+ (UBF *)installed:(NSDictionary *)params {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    if (![mutParams objectForKey:[[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LAST_CAMPAIGN_NAME]]) {
        [mutParams setObject:[EngageConfig lastCampaign]
                      forKey:[[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LAST_CAMPAIGN_NAME]];
    }
    return [[UBF alloc] initEventOfType:@"12" withParams:mutParams];
}


+ (UBF *)sessionStarted:(NSDictionary *)params withCampaign:(NSString *)campaignName {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    
    //Process the contents of the notification for important information
    [self locatedAndProcessImportantValuesInDictionary:params];

    //If a CurrentCampaign was present in the params and the user passes in a campaignName value the user value takes precedence
    if (campaignName != nil && [campaignName length] > 0) {
        long expirationTimestamp = [self expirationTimestampFromParams:params];
        [EngageConfig storeCurrentCampaign:campaignName withExpirationTimestamp:expirationTimestamp];
    }

    mutParams = [self setValue:[EngageConfig currentCampaign] forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    return [[UBF alloc] initEventOfType:@"13" withParams:mutParams];
}


+ (UBF *)sessionEnded:(NSDictionary *)params {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    mutParams = [self setValue:[EngageConfig currentCampaign] forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    return [[UBF alloc] initEventOfType:@"14" withParams:mutParams];
}

+ (UBF *)goalAbandoned:(NSString *)goalName params:(NSDictionary *)params {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    mutParams = [self setValue:goalName forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_GOAL_NAME];
    mutParams = [self setValue:[EngageConfig currentCampaign] forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    return [[UBF alloc] initEventOfType:@"15" withParams:mutParams];
}

+ (UBF *)goalCompleted:(NSString *)goalName params:(NSDictionary *)params {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    mutParams = [self setValue:goalName forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_GOAL_NAME];
    mutParams = [self setValue:[EngageConfig currentCampaign] forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    return [[UBF alloc] initEventOfType:@"16" withParams:mutParams];
}

+ (UBF *)namedEvent:(NSString *)eventName params:(NSDictionary *)params {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    mutParams = [self setValue:eventName forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_EVENT_NAME];
    mutParams = [self setValue:[EngageConfig currentCampaign] forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    return [[UBF alloc] initEventOfType:@"17" withParams:mutParams];
}

+ (UBF *)receivedLocalNotification:(UILocalNotification *)localNotification withParams:(NSDictionary *)params {
    NSMutableDictionary *locNotEvent = [self populateEventCommonParams:params];
    locNotEvent = [self setValue:[EngageConfig currentCampaign] forDictionary:locNotEvent withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    locNotEvent = [self setValue:[localNotification alertAction] forDictionary:locNotEvent withPlistUBFFieldName:PLIST_UBF_CALL_TO_ACTION];
    locNotEvent = [self setValue:[localNotification alertBody] forDictionary:locNotEvent withPlistUBFFieldName:PLIST_UBF_DISPLAYED_MESSAGE];
    return [[UBF alloc] initEventOfType:@"48" withParams:locNotEvent];
}

+ (UBF *)receivedPushNotification:(NSDictionary *)notification withParams:(NSDictionary *)params {
    
    //Process the contents of the notification for important information
    [self locatedAndProcessImportantValuesInDictionary:notification];
    
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    NSString *displayedMessage = [self displayedMessageForNotification:notification];
    if (displayedMessage) {
        mutParams = [self setValue:displayedMessage forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_DISPLAYED_MESSAGE];
    } else {
        mutParams = [self setValue:@"" forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_DISPLAYED_MESSAGE];
    }
    
    mutParams = [self setValue:[EngageConfig currentCampaign] forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    //Call To Action must be provided by the SDK user in this case.
    
    return [[UBF alloc] initEventOfType:@"48" withParams:mutParams];
}

+ (UBF *)openedNotification:(NSDictionary *)notification withParams:(NSDictionary *)params {
    
    //Process the contents of the notification for important information
    [self locatedAndProcessImportantValuesInDictionary:notification];
    
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    NSString *displayedMessage = [self displayedMessageForNotification:notification];
    if (displayedMessage) {
        mutParams = [self setValue:displayedMessage forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_DISPLAYED_MESSAGE];
    } else {
        mutParams = [self setValue:@"" forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_DISPLAYED_MESSAGE];
    }
    
    mutParams = [self setValue:[EngageConfig currentCampaign] forDictionary:mutParams withPlistUBFFieldName:PLIST_UBF_CURRENT_CAMPAIGN_NAME];
    //Call To Action must be provided by the SDK user in this case.
    
    return [[UBF alloc] initEventOfType:@"49" withParams:mutParams];
}


+ (NSMutableDictionary *) populateEventCommonParams:(NSDictionary *)params {
    
    NSMutableDictionary *mutParams;
    if (params) {
        mutParams = [self addDelimitedTagsFromParams:params toDictionary:mutParams];
    } else {
        mutParams = [[NSMutableDictionary alloc] init];
    }
    return mutParams;
}


+ (NSMutableDictionary *) addDelimitedTagsFromParams:(NSDictionary *)params toDictionary:(NSMutableDictionary *)mutParams
{
    if (params) {
        if ([params objectForKey:[[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_TAGS]]) {
            id tagsParam = [params objectForKey:[[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_TAGS]];
            if ([tagsParam isKindOfClass:[NSArray class]]) {
                [mutParams setObject:[tagsParam componentsJoinedByString:@","] forKey:[[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_TAGS]];
            } else {
                [mutParams setObject:@"" forKey:[[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_TAGS]];
            }
        }
    }
    return mutParams;
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

//We would like to be able to use KVC for a particular KeyPath but
//unfortunatly we don't have the luxury of knowing the full path for the key
+ (NSString *)traverseDictionary:(NSDictionary *)dict ForKey:(NSString *)lookingForKey {
    
    __block NSString *keyValue;
    [dict enumerateKeysAndObjectsWithOptions:NSEnumerationConcurrent
                                  usingBlock:^(id key, id object, BOOL *stop) {
                                      if ([object isKindOfClass:[NSString class]]) {
                                          if ([key isEqualToString:lookingForKey]) {
                                              keyValue = (NSString *)object;
                                              *stop = YES;
                                          }
                                      } else if ([object isKindOfClass:[NSDictionary class]]) {
                                          NSString *response = [self traverseDictionary:object ForKey:lookingForKey];
                                          if (response) {
                                              keyValue = response;
                                              *stop = YES;
                                          }
                                      } else {
                                          NSLog(@"EngageSDK - located key '%@' but unsupported object type in dictionary was found! Expected NSString. Object will be ignored and no result returned", lookingForKey);
                                      }
    }];
    
    return keyValue;
}


+ (NSString *)displayedMessageForNotification:(NSDictionary *)notification {
    NSString *displayedMessage = nil;
    
    displayedMessage = [notification valueForKeyPath:@"aps.alert"];
    if (!displayedMessage || ![displayedMessage isKindOfClass:[NSString class]]) {
        displayedMessage = [notification valueForKeyPath:@"aps.alert.body"];
    }

    return displayedMessage;
}


+ (long)expirationTimestampFromParams:(NSDictionary *)dictionary {
    if (dictionary) {
        NSString *expiresAt = [UBF traverseDictionary:dictionary ForKey:[[EngageConfigManager sharedInstance] fieldNameForParam:PLIST_PARAM_CAMPAIGN_EXPIRES_AT]];
        NSString *validFor = [UBF traverseDictionary:dictionary ForKey:[[EngageConfigManager sharedInstance] fieldNameForParam:PLIST_PARAM_CAMPAIGN_VALID_FOR]];
        
        long expirationTimestamp = -1;
        if (expiresAt) {
            //Current campaign with a expires at value.
            EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:validFor fromDate:[NSDate date]];
            expirationTimestamp = [exp expirationTimeStamp];
            
        } else if (validFor) {
            //Current campaign wiht a valid for value.
            EngageExpirationParser *exp = [[EngageExpirationParser alloc] initWithExpirationString:expiresAt fromDate:[NSDate date]];
            expirationTimestamp = [exp expirationTimeStamp];
        }
        return expirationTimestamp;
    } else {
        return -1;
    }
}


+ (void)locatedAndProcessImportantValuesInDictionary:(NSDictionary *) dictionary {
    
    if (dictionary) {
        //Locate the Current Campaign value if it is present in the notification
        NSString *currentCampaign = [UBF traverseDictionary:dictionary ForKey:[[EngageConfigManager sharedInstance] fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]];
        
        if (currentCampaign) {
            long expirationTimestamp = [self expirationTimestampFromParams:dictionary];
            [EngageConfig storeCurrentCampaign:currentCampaign withExpirationTimestamp:expirationTimestamp];
            
        } else {
            NSLog(@"EngageSDK - No %@ specified in push notification", [[EngageConfigManager sharedInstance] fieldNameForParam:PLIST_PARAM_CURRENT_CAMPAIGN]);
        }
    }
}

@end
