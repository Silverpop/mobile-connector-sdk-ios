//
//  UBFManager.h
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/15/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "EngageClient.h"
#import "UBF.h"

@interface UBFManager : NSObject

+ (instancetype)createClient:(NSString *)clientId
                      secret:(NSString *)secret
                       token:(NSString *)refreshToken
                        host:(NSString *)hostUrl
        engageDatabaseListId:(NSString *)engageListId
              connectSuccess:(void (^)(AFOAuthCredential *credential))success
                     failure:(void (^)(NSError *error))failure;

+ (id)sharedInstance;

- (NSURL *) trackEvent:(UBF *)event;
- (void) postEventCache;

- (NSURL *)handleLocalNotificationReceivedEvents:(UILocalNotification *)localNotification
                                      withParams:(NSDictionary *)params;
- (NSURL *)handlePushNotificationReceivedEvents:(NSDictionary *)pushNotification withParams:(NSDictionary *)params;
- (NSURL *)handleNotificationOpenedEvents:(NSDictionary *)notification withParams:(NSDictionary *)params;
- (NSURL *)handleExternalURLOpenedEvents:(NSURL *)externalUrl;

@end
