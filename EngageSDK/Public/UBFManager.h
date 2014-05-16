//
//  UBFManager.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface UBFManager : NSObject

+ (id)sharedInstance;

- (NSURL *) trackEvent:(NSDictionary *)event;
- (void) postEventCache;
- (NSURL *) enqueueEvent:(NSDictionary *)event;

- (NSURL *)handleLocalNotificationReceivedEvents:(UILocalNotification *)localNotification
                                      withParams:(NSDictionary *)params;
- (NSURL *)handlePushNotificationReceivedEvents:(NSDictionary *)pushNotification;
- (NSURL *)handleNotificationOpenedEvents:(NSDictionary *)params;
- (NSURL *)handleExternalURLOpenedEvents:(NSURL *)externalUrl;

@end
