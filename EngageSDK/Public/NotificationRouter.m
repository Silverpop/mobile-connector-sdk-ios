//
//  NotificationRouter.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 4/25/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import "NotificationRouter.h"
#import "UBF.h"
#import "UBFClient.h"

@interface NotificationRouter ()

//@property (nonatomic, strong) Routable *routable;

@end

@implementation NotificationRouter

//void (^handleOpenUrlBlock) (NSDictionary *params);
//__strong static NotificationRouter *_sharedNotificationRouter = nil;
//__strong static UBFClient *_ubfClient = nil;
//
//
//- (id) init {
//    self = [super init];
//    if (self) {
//        
//        //Creates the callback block that will be invoked on the app open url
//        handleOpenUrlBlock = ^(NSDictionary * params) {
//            NSLog(@"POSTing UBF event to Silverpop as a result of handling OpenURL with Params -> %@", params);
//            [_ubfClient trackingEvent:[UBF openedURL:params]];
//        };
//    }
//    return self;
//}
//
//
//+ (instancetype)createRouter:(UBFClient *)ubfClient {
//    
//    static dispatch_once_t isDispatched;
//    dispatch_once(&isDispatched, ^{
//        _sharedNotificationRouter = [[NotificationRouter alloc] init];
//        _ubfClient = ubfClient;
//    });
//
//    return _sharedNotificationRouter;
//}
//
//+ (instancetype)router
//{
//    return _sharedNotificationRouter;
//}
//
//
//- (void) openedUrl:(NSURL *)url {
//    NSLog(@"Handling URL %@", url);
//    NSString *replacementSchema = [[url scheme] stringByAppendingString:@"://"];
//    NSLog(@"Schema to replace -> %@", replacementSchema);
//    NSString *deepLink = [[url absoluteString] stringByReplacingOccurrencesOfString:replacementSchema withString:@""];
//    NSLog(@"DeepLink -> %@", deepLink);
//    @try {
//        [[Routable sharedRouter] open:deepLink];
//    } @catch(NSException *exception) {
//        NSLog(@"Exception while handling opened url %@", exception);
//    }
//    
//}
//
//- (void) receivedNotification:(NSDictionary *)params {
//    NSLog(@"Tracking UBF event from Received Notification with Params -> %@", params);
//    [_ubfClient trackingEvent:[UBF receivedNotification:params]];
//}
//
//
//- (void) openedNotification:(NSDictionary *)params {
//    NSLog(@"Tracking UBF from Opened notification with params -> %@", params);
//    [_ubfClient trackingEvent:[UBF openedNotification:params]];
//}
//
//
//- (void) addRoutesToHandler:(NSArray *)routes {
//    for (NSString *route in routes) {
//        NSLog(@"Adding Handler Route -> %@", route);
//        [[Routable sharedRouter] map:route toCallback:handleOpenUrlBlock];
//    }
//}

@end
