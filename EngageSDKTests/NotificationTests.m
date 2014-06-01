//
//  NotificationTests.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/14/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UBF.h"
#import "EngageLocalEventStore.h"

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
    
    NSMutableDictionary *notification = [[NSMutableDictionary alloc] init];
    [notification setObject:aps forKey:@"aps"];
    [notification setObject:tags forKey:@"Tags"];
    
    id openedNotificationEvent = [UBF openedNotification:notification withParams:nil];
    XCTAssertTrue(openedNotificationEvent != nil, @"Opened NotificationEvent cannot be null");
}

-(void)testPushNotificationReceivedEvent {
    NSArray *tags = @[@"demo", @"unit test"];
    
    NSMutableDictionary *aps = [[NSMutableDictionary alloc] init];
    [aps setObject:@"Push Notification Alert Body" forKey:@"alert"];
    [aps setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
    [aps setObject:@"default sounds" forKey:@"sound"];
    [aps setObject:[NSNumber numberWithInt:1] forKey:@"content-available"];
    
    NSMutableDictionary *notification = [[NSMutableDictionary alloc] init];
    [notification setObject:aps forKey:@"aps"];
    [notification setObject:tags forKey:@"Tags"];
    
    id pushNotificationReceivedEvent = [UBF receivedPushNotification:notification withParams:nil];
    XCTAssertTrue(pushNotificationReceivedEvent != nil, @"Received PushNotification event cannot be null");
}

@end
