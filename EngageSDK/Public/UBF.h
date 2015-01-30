//
//  UBF.h
//  EngageSDK
//
//  Created by Musa Siddeeq on 7/25/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UBF : NSObject

@property (readonly, nonatomic, strong) NSString *eventTypeCode;
@property (readonly, nonatomic, strong) NSString *eventTimeStamp;
@property (readonly, nonatomic, strong) NSMutableDictionary *attributes;
@property (readonly, nonatomic, strong) NSMutableDictionary *headerAttributes;

+ (UBF *)createEventWithCode:(NSString *)code params:(NSDictionary *)params;
+ (UBF *)installed:(NSDictionary *)params;
+ (UBF *)sessionStarted:(NSDictionary *)params withCampaign:(NSString *)campaignName;
+ (UBF *)sessionEnded:(NSDictionary *)params;
+ (UBF *)goalAbandoned:(NSString *)goalName params:(NSDictionary *)params;
+ (UBF *)goalCompleted:(NSString *)goalName params:(NSDictionary *)params;
+ (UBF *)namedEvent:(NSString *)eventName params:(NSDictionary *)params;
+ (UBF *)receivedLocalNotification:(UILocalNotification *)localNotification withParams:(NSDictionary *)params;
+ (UBF *)receivedPushNotification:(NSDictionary *)notification withParams:(NSDictionary *)params;
+ (UBF *)openedNotification:(NSDictionary *)notification withParams:(NSDictionary *)params;
+ (NSString *)traverseDictionary:(NSDictionary *)dict ForKey:(NSString *)key;
+ (NSString *)displayedMessageForNotification:(NSDictionary *)notification;

- (UBF *)initFromJSON:(NSString *)jsonString;
- (void)setAttribute:(NSString *)attributeName value:(NSString *)attributeValue;
- (NSDictionary *)dictionaryValue;
- (NSString *)jsonValue;

@end
