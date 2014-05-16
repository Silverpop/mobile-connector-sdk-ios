//
//  NotificationTests.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/14/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UBFClient.h"
#import "UBF.h"
#import "EngageConfig.h"
#import "EngageLocalEventStore.h"
#import <MobileDeepLinking-iOS/MobileDeepLinking.h>
#import "TestUtils.h"
#import "sample-config.h"

@interface NotificationTests : XCTestCase


@end

@implementation NotificationTests

- (void)setUp
{
    [super setUp];
    
    NSUInteger deletedEvents = [[EngageLocalEventStore sharedInstance] deleteAllUBFEvents];
    NSLog(@"Deleted %lul", (unsigned long)deletedEvents);
}

- (void)tearDown
{
    [super tearDown];
}

-(void)testApplicationOpenedFromNotificationEvent {
    NSArray *tags = @[@"demo", @"unit test"];
    
    NSMutableDictionary *aps = [[NSMutableDictionary alloc] init];
    [aps setObject:@"Push Notification Alert Body" forKey:@"alert"];
    [aps setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
    [aps setObject:@"default sounds" forKey:@"sound"];
    [aps setObject:[NSNumber numberWithInt:1] forKey:@"content-available"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:aps forKey:@"aps"];
    [params setObject:tags forKey:@"Tags"];
    
    id openedNotificationEvent = [UBF openedNotification:params];
    XCTAssertTrue(openedNotificationEvent != nil, @"Opened NotificationEvent cannot be null");
}

-(void)testPushNotificationReceivedEvent {
    NSArray *tags = @[@"demo", @"unit test"];
    
    NSMutableDictionary *aps = [[NSMutableDictionary alloc] init];
    [aps setObject:@"Push Notification Alert Body" forKey:@"alert"];
    [aps setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
    [aps setObject:@"default sounds" forKey:@"sound"];
    [aps setObject:[NSNumber numberWithInt:1] forKey:@"content-available"];
    
    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
    [params setObject:aps forKey:@"aps"];
    [params setObject:tags forKey:@"Tags"];
    
    id pushNotificationReceivedEvent = [UBF receivedPushNotification:params];
    XCTAssertTrue(pushNotificationReceivedEvent != nil, @"Received PushNotification event cannot be null");
}

@end
