//
//  UBFWeatherAugmentationPlugin.m
//  EngageSDKDemo
//
//  Created by Jeremy Dyer on 6/27/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "UBFWeatherAugmentationPlugin.h"
#import "EngageConfig.h"
#import "EngageConfigManager.h"

@interface UBFWeatherAugmentationPlugin()

@property (nonatomic, strong) AFHTTPRequestOperation *httpOperation;
@property (nonatomic, strong) NSString *weatherString;

@property (nonatomic, strong) NSString *ubfLongitudeName;
@property (nonatomic, strong) NSString *ubfLatitudeName;

@property (assign) BOOL requestStarted;
@property (assign) BOOL __block requestCompleted;
@property (nonatomic, strong) NSDictionary *weatherJsonResponse;

@end

@implementation UBFWeatherAugmentationPlugin

BOOL requestCompleted;

const NSString *WEATHER_UNLOCKED_API_URL = @"http://api.weatherunlocked.com/api/trigger";
const NSString *WEATHER_UNLOCKED_APP_ID = @"cc7b8dc3";
const NSString *WEATHER_UNLOCKED_KEY = @"39317ce7635492ec10a4d56601826a4d";

-(id)init {
    self = [super init];
    if (self) {
        self.httpOperation = nil;
        self.weatherString = nil;
        
        self.ubfLatitudeName = [[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LATITUDE];
        self.ubfLongitudeName = [[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LONGITUDE];
        
        self.requestStarted = NO;
        self.requestCompleted = NO;
        
        //Register to receive the notifications.
        [[NSNotificationCenter defaultCenter] addObserverForName:WEATHER_DATA_AVAILABLE_NOTIFICATION
                                                          object:nil
                                                           queue:[NSOperationQueue mainQueue]
                                                      usingBlock:^(NSNotification *note) {
                                                          NSLog(@"Weather data completed here!");
                                                          self.requestCompleted = YES;
                                                          self.weatherJsonResponse = (NSDictionary *)note.object;
                                                      }];
    }
    return self;
}


-(BOOL)processSyncronously {
    return YES;
}


-(BOOL)isSupplementalDataReady:(UBF*)ubfEvent {
    //If the HTTPClient is not created we should initialize a request
    if (!self.requestStarted) {
        self.requestStarted = YES;
        [self invokeWeatherUnlockedAPI:ubfEvent];
        return NO;
    } else if (self.requestCompleted) {
        //If the weather string is set then the data is ready
        return YES;
    } else {
        //Still have not received a response from the Weather server yet.
        return NO;
    }
}


-(UBF*)process:(UBF*)ubfEvent {
    if (ubfEvent) {
        [ubfEvent setAttribute:HOT_WEATHER value:[self.weatherJsonResponse objectForKey:@"ConditionMatchedNum"]];
    }
    return ubfEvent;
}


- (void)invokeWeatherUnlockedAPI:(UBF *)ubfEvent {

    NSString *requestString = [[self buildRequestURLString:ubfEvent] stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];
    NSURL *url = [NSURL URLWithString:requestString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    self.httpOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    self.httpOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    
    [self.httpOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id JSON) {
        [[NSNotificationCenter defaultCenter] postNotificationName:WEATHER_DATA_AVAILABLE_NOTIFICATION object:JSON];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Weather operation failed! %@", error);
    }];
    
    [self.httpOperation start];
}

- (NSString *)buildRequestURLString:(UBF *)ubfEvent {
    NSNumberFormatter *numFormatter = [[NSNumberFormatter alloc] init];
    [numFormatter setMaximumFractionDigits:2];
    [numFormatter setRoundingMode:NSNumberFormatterRoundUp];
    
    NSNumber *longitude = [numFormatter numberFromString:[ubfEvent.attributes objectForKey:self.ubfLongitudeName]];
    NSNumber *latitude = [numFormatter numberFromString:[ubfEvent.attributes objectForKey:self.ubfLatitudeName]];
    
    NSString *roundedLongitude = [numFormatter stringFromNumber:longitude];
    NSString *roundedLatitude = [numFormatter stringFromNumber:latitude];
    NSString *query = @"current temperature lt 80 f";
    
    NSString *requestString = [NSString stringWithFormat:@"%@/%@, %@/%@?app_id=%@&app_key=%@", WEATHER_UNLOCKED_API_URL, roundedLatitude, roundedLongitude, query, WEATHER_UNLOCKED_APP_ID, WEATHER_UNLOCKED_KEY];
    return requestString;
}


@end
