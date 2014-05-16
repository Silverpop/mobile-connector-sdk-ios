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

+ (id)createEventWithCode:(NSString *)code params:(NSDictionary *)params;
+ (id)installed:(NSDictionary *)params;
+ (id)sessionStarted:(NSDictionary *)params withCampaign:(NSString *)campaignName;
+ (id)sessionEnded:(NSDictionary *)params;
+ (id)goalAbandoned:(NSString *)goalName params:(NSDictionary *)params;
+ (id)goalCompleted:(NSString *)goalName params:(NSDictionary *)params;
+ (id)namedEvent:(NSString *)eventName params:(NSDictionary *)params;
+ (id)receivedLocalNotification:(UILocalNotification *)localNotification withParams:(NSDictionary *)params;
+ (id)receivedPushNotification:(NSDictionary *)params;
+ (id)openedNotification:(NSDictionary *)params;

@end
