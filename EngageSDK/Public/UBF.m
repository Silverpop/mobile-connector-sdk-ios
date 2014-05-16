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
#import <CoreLocation/CoreLocation.h>
#import <CoreLocation/CLLocationManager.h>


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
    [mutParams setObject:[EngageConfig lastCampaign] forKey:@"Last Campaign"];
    return [UBF createEventWithCode:@"12" params:mutParams];
}

+ (id)sessionStarted:(NSDictionary *)params withCampaign:(NSString *)campaignName {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];

    if (campaignName != nil && [campaignName length] > 0) {
        [EngageConfig storeCurrentCampaign:campaignName withExpirationTimestamp:nil];
    } else {
        NSLog(@"SessionStarted with empty CampaignName. Not storing value and using previous campaign name value");
    }

    [mutParams setObject:[EngageConfig currentCampaign] forKey:@"Campaign Name"];
    return [UBF createEventWithCode:@"13" params:mutParams];
}

+ (id)sessionEnded:(NSDictionary *)params {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    [mutParams setObject:[EngageConfig currentCampaign] forKey:@"Campaign Name"];
    return [UBF createEventWithCode:@"14" params:mutParams];
}

+ (id)goalAbandoned:(NSString *)goalName params:(NSDictionary *)params {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    [mutParams setObject:goalName forKey:@"Goal Name"];
    [mutParams setObject:[EngageConfig currentCampaign] forKey:@"Campaign Name"];
    return [UBF createEventWithCode:@"15" params:mutParams];
}

+ (id)goalCompleted:(NSString *)goalName params:(NSDictionary *)params {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    [mutParams setObject:goalName forKey:@"Goal Name"];
    [mutParams setObject:[EngageConfig currentCampaign] forKey:@"Campaign Name"];
    return [UBF createEventWithCode:@"16" params:mutParams];
}

+ (id)namedEvent:(NSString *)eventName params:(NSDictionary *)params {
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    [mutParams setObject:eventName forKey:@"Event Name"];
    [mutParams setObject:[EngageConfig currentCampaign] forKey:@"Campaign Name"];
    return [UBF createEventWithCode:@"17" params:mutParams];
}

+ (id)receivedLocalNotification:(UILocalNotification *)localNotification withParams:(NSDictionary *)params {
    NSMutableDictionary *locNotEvent = [self populateEventCommonParams:params];
    [locNotEvent setObject:[EngageConfig currentCampaign] forKey:@"Campaign Name"];
    [locNotEvent setObject:[localNotification alertAction] forKey:@"Call To Action"];
    [locNotEvent setObject:[localNotification alertBody] forKey:@"Displayed Message"];
    return [UBF createEventWithCode:@"48" params:locNotEvent];
}

+ (id)receivedPushNotification:(NSDictionary *)params {
    
    NSString *displayedMessage = nil;
    if ([[[params objectForKey:@"aps"] objectForKey:@"alert"] isKindOfClass:[NSString class]]) {
        displayedMessage = [[params objectForKey:@"aps"] objectForKey:@"alert"];
    } else {
        displayedMessage = [[[params objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
    }
    
    NSMutableDictionary *mutParams = [self populateEventCommonParams:params];
    [mutParams setObject:[EngageConfig currentCampaign] forKey:@"Campaign Name"];
    [mutParams setObject:displayedMessage forKey:@"Displayed Message"];
    if ([params objectForKey:CALL_TO_ACTION_PARAM_NAME]) {
        [mutParams setObject:[params objectForKey:CALL_TO_ACTION_PARAM_NAME] forKey:@"Call To Action"];
    } else {
        [mutParams setObject:@"" forKey:@"Call To Action"];
    }
    
    return [UBF createEventWithCode:@"48" params:mutParams];
}

+ (id)openedNotification:(NSDictionary *)params {
    
    NSString *displayedMessage = nil;
    if ([[[params objectForKey:@"aps"] objectForKey:@"alert"] isKindOfClass:[NSString class]]) {
        displayedMessage = [[params objectForKey:@"aps"] objectForKey:@"alert"];
    } else {
        displayedMessage = [[[params objectForKey:@"aps"] objectForKey:@"alert"] objectForKey:@"body"];
    }
    
    NSMutableDictionary *openedNotificationEvent = [self populateEventCommonParams:params];
    [openedNotificationEvent setObject:[EngageConfig currentCampaign] forKey:@"Campaign Name"];
    [openedNotificationEvent setObject:displayedMessage forKey:@"Displayed Message"];
    if ([params objectForKey:CALL_TO_ACTION_PARAM_NAME]) {
        [openedNotificationEvent setObject:[params objectForKey:CALL_TO_ACTION_PARAM_NAME] forKey:@"Call To Action"];
    } else {
        [openedNotificationEvent setObject:@"" forKey:@"Call To Action"];
    }
    
    return [UBF createEventWithCode:@"49" params:openedNotificationEvent];
}

+ (NSMutableDictionary *) populateEventCommonParams:(NSDictionary *)params {
    NSMutableDictionary *mutParams = [[NSMutableDictionary alloc] init];
    mutParams = [self addLocationToParams:mutParams];
    mutParams = [self addDelimitedTagsToParams:mutParams];
    return mutParams;
}

+ (NSMutableDictionary *) addDelimitedTagsToParams:(NSMutableDictionary *)params
{
    if (params) {
        if ([params objectForKey:@"Tags"]) {
            id tagsParam = [params objectForKey:@"Tags"];
            if ([tagsParam isKindOfClass:[NSArray class]]) {
                [params setObject:[tagsParam componentsJoinedByString:@","] forKey:@"Tags"];
            } else {
                [params setObject:@"" forKey:@"Tags"];
            }
        }
    }
    return params;
}

+ (NSMutableDictionary *) addLocationToParams:(NSMutableDictionary *)existingParams {
    
    CLLocationManager *locationManager = [[CLLocationManager alloc] init];
    //locationManager.delegate = self;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    [locationManager startUpdatingLocation];
    CLLocation *location = [locationManager location];
    CLLocationCoordinate2D coordinate = [location coordinate];
    
    NSString *latitude = [NSString stringWithFormat:@"%f", coordinate.latitude];
    NSString *longitude = [NSString stringWithFormat:@"%f", coordinate.longitude];
    
    if (![existingParams objectForKey:@"Longitude"]) {
        [existingParams setObject:longitude forKey:@"Longitude"];
    }
    if (![existingParams objectForKey:@"Latitude"]) {
        [existingParams setObject:latitude forKey:@"Latitude"];
    }
    
//    if (![existingParams objectForKey:@"Location Name"]) {
//        [existingParams setObject:@"" forKey:@"Location Name"];
//    }
//    if (![existingParams objectForKey:@"Location Address"]) {
//        [existingParams setObject:@"" forKey:@"Location Address"];
//    }
    
    return existingParams;
}


@end
