//
//  UBFTests.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/14/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "UBF.h"
#import "EngageConfig.h"

@interface UBFTests : XCTestCase

@end

@implementation UBFTests

- (void)setUp
{
    [super setUp];
}

- (void)tearDown
{
    [super tearDown];
}

- (void) testCreateUBFWithDictionaryInvalidParameter {
    NSArray *tags = @[@"demo", @"unit test"];
    NSMutableDictionary *params = [[NSMutableDictionary alloc] initWithObjectsAndKeys:tags, @"Tags", nil];
    
    NSDictionary *invalidParamDict = @{@"root" : @{@"key" : @"value"}};
    [params setObject:invalidParamDict forKey:@"root"];
    
    UBF *installedEvent = [UBF installed:params];
    
    XCTAssertTrue(installedEvent != nil);
    XCTAssertTrue([installedEvent jsonValue] != nil);
    XCTAssertTrue([[installedEvent attributes] objectForKey:@"root"] == nil);
}

- (void) testCreateFromJSON {
    NSArray *tags = @[@"demo", @"unit test"];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tags, @"Tags", nil];
    UBF *installedEvent = [UBF installed:params];
    
    UBF *newEvent = [[UBF alloc] initFromJSON:[installedEvent jsonValue]];
    NSLog(@"%@", [newEvent jsonValue]);
    
    XCTAssertTrue(newEvent != nil);
    XCTAssertTrue([newEvent jsonValue] != nil);
}

-(void)testUBFGenerateInstalledEvent {
    NSArray *tags = @[@"demo", @"unit test"];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tags, @"Tags", nil];
    UBF *installedEvent = [UBF installed:params];
    
    //Test the requiredfields are present.
    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Last Campaign"];
    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address"];
    
    //Ensure required attribute values are present.
    for (int i = 0; i < [expectedFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:installedEvent];
        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
    }
    
    //Ensure the optional fields are in the event payload.
    for (int i = 0; i < [optionalFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:installedEvent];
        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
    }
    
    //Check that the eventTypeCode is correct.
    XCTAssertTrue([[self getEventTypeCodeForEvent:installedEvent] isEqualToString:@"12"], @"Installed UBF EventTypeCode does not equal 12!");
}


- (void)testUBFGenerateInstalledEventAndAddLocationAfter {
    NSArray *tags = @[@"demo", @"unit test"];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tags, @"Tags", nil];
    id installedEvent = [UBF installed:params];
    
    //Test the requiredfields are present.
    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Last Campaign"];
    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address"];
    
    //Ensure required attribute values are present.
    for (int i = 0; i < [expectedFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:installedEvent];
        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
    }
    
    //Ensure the optional fields are in the event payload.
    for (int i = 0; i < [optionalFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:installedEvent];
        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
    }
    
    //Check that the eventTypeCode is correct.
    XCTAssertTrue([[self getEventTypeCodeForEvent:installedEvent] isEqualToString:@"12"], @"Installed UBF EventTypeCode does not equal 12!");
}

-(void)testUBFGenerateSessionEndedEvent {
    NSArray *tags = @[@"demo", @"unit test"];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tags, @"Tags", nil];
    id installedEvent = [UBF sessionEnded:params];
    
    //Test the requiredfields are present.
    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Campaign Name"];
    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address"];
    
    //Ensure required attribute values are present.
    for (int i = 0; i < [expectedFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:installedEvent];
        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
    }
    
    //Ensure the optional fields are in the event payload.
    for (int i = 0; i < [optionalFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:installedEvent];
        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
    }
    
    //Check that the eventTypeCode is correct.
    XCTAssertTrue([[self getEventTypeCodeForEvent:installedEvent] isEqualToString:@"14"], @"Installed UBF EventTypeCode does not equal 14!");
}

-(void)testUBFGenerateAbandonedGoalEvent {
    NSArray *tags = @[@"demo", @"unit test"];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tags, @"Tags", nil];
    id goalAbandoned = [UBF goalAbandoned:@"Unit Test Goal Abandoned" params:params];
    
    //Test the requiredfields are present.
    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Campaign Name"];
    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address"];
    
    //Ensure required attribute values are present.
    for (int i = 0; i < [expectedFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:goalAbandoned];
        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
    }
    
    //Ensure the optional fields are in the event payload.
    for (int i = 0; i < [optionalFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:goalAbandoned];
        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
    }
    
    //Check that the eventTypeCode is correct.
    XCTAssertTrue([[self getEventTypeCodeForEvent:goalAbandoned] isEqualToString:@"15"], @"Installed UBF EventTypeCode does not equal 15!");
}

-(void)testUBFGenerateCompletedGoalEvent {
    NSArray *tags = @[@"demo", @"unit test"];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tags, @"Tags", nil];
    id goalCompleted = [UBF goalCompleted:@"Unit Test Goal Completed" params:params];
    
    //Test the requiredfields are present.
    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Campaign Name"];
    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address"];
    
    //Ensure required attribute values are present.
    for (int i = 0; i < [expectedFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:goalCompleted];
        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
    }
    
    //Ensure the optional fields are in the event payload.
    for (int i = 0; i < [optionalFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:goalCompleted];
        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
    }
    
    //Check that the eventTypeCode is correct.
    XCTAssertTrue([[self getEventTypeCodeForEvent:goalCompleted] isEqualToString:@"16"], @"Installed UBF EventTypeCode does not equal 16!");
}

-(void)testUBFGenerateNamedGoalEvent {
    NSArray *tags = @[@"demo", @"unit test"];
    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tags, @"Tags", nil];
    id namedEvent = [UBF namedEvent:@"Unit Test Named Event" params:params];
    
    //Test the requiredfields are present.
    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Campaign Name"];
    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address"];
    
    //Ensure required attribute values are present.
    for (int i = 0; i < [expectedFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:namedEvent];
        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
    }
    
    //Ensure the optional fields are in the event payload.
    for (int i = 0; i < [optionalFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:namedEvent];
        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
    }
    
    //Check that the eventTypeCode is correct.
    XCTAssertTrue([[self getEventTypeCodeForEvent:namedEvent] isEqualToString:@"17"], @"Installed UBF EventTypeCode does not equal 17!");
}

-(void)testUBFGeneratePushNotificationReceived {
    
    NSArray *tags = @[@"demo", @"unit test"];
    
    NSMutableDictionary *aps = [[NSMutableDictionary alloc] init];
    [aps setObject:@"Push Notification Alert Body" forKey:@"alert"];
    [aps setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
    [aps setObject:@"default sounds" forKey:@"sound"];
    [aps setObject:[NSNumber numberWithInt:1] forKey:@"content-available"];
    
    NSMutableDictionary *notification = [[NSMutableDictionary alloc] init];
    [notification setObject:aps forKey:@"aps"];
    [notification setObject:tags forKey:@"Tags"];
    
    id pushNotificationEvent = [UBF receivedPushNotification:notification withParams:nil];
    
    //Test the requiredfields are present.
    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Campaign Name"];
    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address", @"Displayed Message", @"Call To Action"];
    
    //Ensure required attribute values are present.
    for (int i = 0; i < [expectedFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:pushNotificationEvent];
        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
    }
    
    //Ensure the optional fields are in the event payload.
    for (int i = 0; i < [optionalFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:pushNotificationEvent];
        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
    }
    
    //Check that the eventTypeCode is correct.
    XCTAssertTrue([[self getEventTypeCodeForEvent:pushNotificationEvent] isEqualToString:@"48"], @"Installed UBF EventTypeCode does not equal 48!");
}

-(void)testUBFGenerateOpenedNotificationEvent {
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
    
    //Test the requiredfields are present.
    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Campaign Name"];
    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address", @"Displayed Message", @"Call To Action"];
    
    NSLog(@"Opened Notification %@", openedNotificationEvent);
    
    //Ensure required attribute values are present.
    for (int i = 0; i < [expectedFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:openedNotificationEvent];
        NSLog(@"Expecting Field %@", expectedFields[i]);
        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
    }
    
    //Ensure the optional fields are in the event payload.
    for (int i = 0; i < [optionalFields count]; i++) {
        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:openedNotificationEvent];
        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
    }
    
    //Check that the eventTypeCode is correct.
    XCTAssertTrue([[self getEventTypeCodeForEvent:openedNotificationEvent] isEqualToString:@"49"], @"Installed UBF EventTypeCode does not equal 49!");
}

-(void)testExtractCurrentCampaignFromEvent {
    NSString *randomCampaignName = @"RaNdOMCAMPAIGN";
    [UBF sessionStarted:nil withCampaign:randomCampaignName];
    XCTAssertTrue([[EngageConfig currentCampaign] isEqualToString:randomCampaignName], @"Current Campaign parsed from Session Started is %@ but should be %@", [EngageConfig currentCampaign], randomCampaignName);
}

-(void)testTraversePushNotificationDictionaryForKey {
    
    //Creates some sample push notification dictionaries for testing.
    NSDictionary *pushNotification = @{@"aps" : @{@"alert" : @"Alert Value"},
                                       @"Current Campaign" : @"5OFF"};
    
    NSString *value = [UBF traverseDictionary:pushNotification ForKey:@"Current Campaign"];
    XCTAssertTrue([value isEqualToString:@"5OFF"]);
    
    pushNotification = @{@"aps" : @{@"alert" : @"Alert Value", @"Current Campaign" : @"6OFF"}};
    
    value = [UBF traverseDictionary:pushNotification ForKey:@"Current Campaign"];
    XCTAssertTrue([value isEqualToString:@"6OFF"]);
    
    pushNotification = @{@"aps" : @{@"alert" : @"Alert Value", @"Nested" : @{@"Current Campaign" : @"7OFF"}}};
    
    value = [UBF traverseDictionary:pushNotification ForKey:@"Current Campaign"];
    XCTAssertTrue([value isEqualToString:@"7OFF"]);
}

-(void)testGettingDisplayedMessageFromNotification {
    NSDictionary *pushNotification = @{@"aps" : @{@"alert" : @"HELLO!!"},
                                       @"Current Campaign" : @"5OFF"};
    
    NSString *displayedMessage = [UBF displayedMessageForNotification:pushNotification];
    XCTAssertTrue([displayedMessage isEqualToString:@"HELLO!!"]);
    
    pushNotification = @{@"aps" : @{@"alert" : @{@"body" : @"HELLO!!"}},
                                       @"Current Campaign" : @"5OFF"};
    
    displayedMessage = [UBF displayedMessageForNotification:pushNotification];
    XCTAssertTrue([displayedMessage isEqualToString:@"HELLO!!"]);
}

-(NSString *)getEventTypeCodeForEvent:(id)ubfEvent {
    return [ubfEvent valueForKey:@"eventTypeCode"];
}

-(NSString *)getAttributeField:(NSString *)fieldName forEvent:(UBF *)ubfEvent {
    NSDictionary *atts = [ubfEvent attributes];
    if ([atts objectForKey:fieldName]) {
        return [atts objectForKey:fieldName];
    } else {
        return @"";
    }
}

@end
