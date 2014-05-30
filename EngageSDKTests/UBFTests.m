//
//  UBFTests.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 5/14/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import "UBF.h"
//#import "EngageConfig.h"

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

//-(void)testUBFGenerateInstalledEvent {
//    NSArray *tags = @[@"demo", @"unit test"];
//    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tags, @"Tags", nil];
//    id installedEvent = [UBF installed:params];
//    
//    //Test the requiredfields are present.
//    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Last Campaign"];
//    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address"];
//    
//    //Ensure required attribute values are present.
//    for (int i = 0; i < [expectedFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:installedEvent];
//        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
//    }
//    
//    //Ensure the optional fields are in the event payload.
//    for (int i = 0; i < [optionalFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:installedEvent];
//        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
//    }
//    
//    //Check that the eventTypeCode is correct.
//    XCTAssertTrue([[self getEventTypeCodeForEvent:installedEvent] isEqualToString:@"12"], @"Installed UBF EventTypeCode does not equal 12!");
//}
//
//-(void)testUBFGenerateSessionStartedEvent {
//    NSArray *tags = @[@"demo", @"unit test"];
//    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tags, @"Tags", nil];
//    id sessionStarted = [UBF sessionStarted:params withCampaign:@"testUBFGenerateSessionStartedEvent"];
//    
//    //Test the requiredfields are present.
//    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Campaign Name"];
//    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address"];
//    
//    //Ensure required attribute values are present.
//    for (int i = 0; i < [expectedFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:sessionStarted];
//        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
//    }
//    
//    //Ensure the optional fields are in the event payload.
//    for (int i = 0; i < [optionalFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:sessionStarted];
//        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
//    }
//    
//    //Check that the eventTypeCode is correct.
//    XCTAssertTrue([[self getEventTypeCodeForEvent:sessionStarted] isEqualToString:@"13"], @"Installed UBF EventTypeCode does not equal 13!");
//}
//
//-(void)testUBFGenerateSessionEndedEvent {
//    NSArray *tags = @[@"demo", @"unit test"];
//    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tags, @"Tags", nil];
//    id installedEvent = [UBF sessionEnded:params];
//    
//    //Test the requiredfields are present.
//    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Campaign Name"];
//    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address"];
//    
//    //Ensure required attribute values are present.
//    for (int i = 0; i < [expectedFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:installedEvent];
//        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
//    }
//    
//    //Ensure the optional fields are in the event payload.
//    for (int i = 0; i < [optionalFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:installedEvent];
//        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
//    }
//    
//    //Check that the eventTypeCode is correct.
//    XCTAssertTrue([[self getEventTypeCodeForEvent:installedEvent] isEqualToString:@"14"], @"Installed UBF EventTypeCode does not equal 14!");
//}
//
//-(void)testUBFGenerateAbandonedGoalEvent {
//    NSArray *tags = @[@"demo", @"unit test"];
//    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tags, @"Tags", nil];
//    id goalAbandoned = [UBF goalAbandoned:@"Unit Test Goal Abandoned" params:params];
//    
//    //Test the requiredfields are present.
//    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Campaign Name"];
//    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address"];
//    
//    //Ensure required attribute values are present.
//    for (int i = 0; i < [expectedFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:goalAbandoned];
//        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
//    }
//    
//    //Ensure the optional fields are in the event payload.
//    for (int i = 0; i < [optionalFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:goalAbandoned];
//        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
//    }
//    
//    //Check that the eventTypeCode is correct.
//    XCTAssertTrue([[self getEventTypeCodeForEvent:goalAbandoned] isEqualToString:@"15"], @"Installed UBF EventTypeCode does not equal 15!");
//}
//
//-(void)testUBFGenerateCompletedGoalEvent {
//    NSArray *tags = @[@"demo", @"unit test"];
//    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tags, @"Tags", nil];
//    id goalCompleted = [UBF goalCompleted:@"Unit Test Goal Completed" params:params];
//    
//    //Test the requiredfields are present.
//    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Campaign Name"];
//    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address"];
//    
//    //Ensure required attribute values are present.
//    for (int i = 0; i < [expectedFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:goalCompleted];
//        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
//    }
//    
//    //Ensure the optional fields are in the event payload.
//    for (int i = 0; i < [optionalFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:goalCompleted];
//        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
//    }
//    
//    //Check that the eventTypeCode is correct.
//    XCTAssertTrue([[self getEventTypeCodeForEvent:goalCompleted] isEqualToString:@"16"], @"Installed UBF EventTypeCode does not equal 16!");
//}
//
//-(void)testUBFGenerateNamedGoalEvent {
//    NSArray *tags = @[@"demo", @"unit test"];
//    NSDictionary *params = [[NSDictionary alloc] initWithObjectsAndKeys:tags, @"Tags", nil];
//    id namedEvent = [UBF namedEvent:@"Unit Test Named Event" params:params];
//    
//    //Test the requiredfields are present.
//    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Campaign Name"];
//    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address"];
//    
//    //Ensure required attribute values are present.
//    for (int i = 0; i < [expectedFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:namedEvent];
//        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
//    }
//    
//    //Ensure the optional fields are in the event payload.
//    for (int i = 0; i < [optionalFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:namedEvent];
//        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
//    }
//    
//    //Check that the eventTypeCode is correct.
//    XCTAssertTrue([[self getEventTypeCodeForEvent:namedEvent] isEqualToString:@"17"], @"Installed UBF EventTypeCode does not equal 17!");
//}
//
//-(void)testUBFGeneratePushNotificationReceived {
//    
//    NSArray *tags = @[@"demo", @"unit test"];
//    
//    NSMutableDictionary *aps = [[NSMutableDictionary alloc] init];
//    [aps setObject:@"Push Notification Alert Body" forKey:@"alert"];
//    [aps setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
//    [aps setObject:@"default sounds" forKey:@"sound"];
//    [aps setObject:[NSNumber numberWithInt:1] forKey:@"content-available"];
//    
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params setObject:aps forKey:@"aps"];
//    [params setObject:tags forKey:@"Tags"];
//    
//    id pushNotificationEvent = [UBF receivedPushNotification:params];
//    
//    //Test the requiredfields are present.
//    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Campaign Name"];
//    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address", @"Displayed Message", @"Call To Action"];
//    
//    //Ensure required attribute values are present.
//    for (int i = 0; i < [expectedFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:pushNotificationEvent];
//        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
//    }
//    
//    //Ensure the optional fields are in the event payload.
//    for (int i = 0; i < [optionalFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:pushNotificationEvent];
//        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
//    }
//    
//    //Check that the eventTypeCode is correct.
//    XCTAssertTrue([[self getEventTypeCodeForEvent:pushNotificationEvent] isEqualToString:@"48"], @"Installed UBF EventTypeCode does not equal 48!");
//}
//
//-(void)testUBFGenerateOpenedNotificationEvent {
//    NSArray *tags = @[@"demo", @"unit test"];
//    
//    NSMutableDictionary *aps = [[NSMutableDictionary alloc] init];
//    [aps setObject:@"Push Notification Alert Body" forKey:@"alert"];
//    [aps setObject:[NSNumber numberWithInt:1] forKey:@"badge"];
//    [aps setObject:@"default sounds" forKey:@"sound"];
//    [aps setObject:[NSNumber numberWithInt:1] forKey:@"content-available"];
//    
//    NSMutableDictionary *params = [[NSMutableDictionary alloc] init];
//    [params setObject:aps forKey:@"aps"];
//    [params setObject:tags forKey:@"Tags"];
//    
//    id openedNotificationEvent = [UBF openedNotification:params];
//    
//    //Test the requiredfields are present.
//    NSArray *expectedFields = @[@"Device Name", @"Device Version", @"OS Name", @"OS Version", @"App Name", @"App Version", @"Device Id", @"Campaign Name"];
//    NSArray *optionalFields = @[@"Primary User Id", @"Anonymous Id", @"Latitude", @"Longitude", @"Tags", @"Location Name", @"Location Address", @"Displayed Message", @"Call To Action"];
//    
//    NSLog(@"Opened Notification %@", openedNotificationEvent);
//    
//    //Ensure required attribute values are present.
//    for (int i = 0; i < [expectedFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:expectedFields[i] forEvent:openedNotificationEvent];
//        NSLog(@"Expecting Field %@", expectedFields[i]);
//        XCTAssertTrue((fieldValue != nil && [fieldValue length] > 0), @"Field %@ is a required field but is not present in UBF event", expectedFields[i]);
//    }
//    
//    //Ensure the optional fields are in the event payload.
//    for (int i = 0; i < [optionalFields count]; i++) {
//        NSString *fieldValue = [self getAttributeField:optionalFields[i] forEvent:openedNotificationEvent];
//        XCTAssertTrue(fieldValue != nil, @"Optional field %@ is not present in the UBF event payload. Value is not required but field presence is", expectedFields[i]);
//    }
//    
//    //Check that the eventTypeCode is correct.
//    XCTAssertTrue([[self getEventTypeCodeForEvent:openedNotificationEvent] isEqualToString:@"49"], @"Installed UBF EventTypeCode does not equal 49!");
//}
//
//-(void)testExtractCurrentCampaignFromEvent {
//    NSString *randomCampaignName = @"RaNdOMCAMPAIGN";
//    [UBF sessionStarted:nil withCampaign:randomCampaignName];
//    XCTAssertTrue([[EngageConfig currentCampaign] isEqualToString:randomCampaignName], @"Current Campaign parsed from Session Started is %@ but should be %@", [EngageConfig currentCampaign], randomCampaignName);
//}
//
//-(NSString *)getEventTypeCodeForEvent:(id)ubfEvent {
//    return [ubfEvent valueForKey:@"eventTypeCode"];
//}
//
//-(NSString *)getAttributeField:(NSString *)fieldName forEvent:(id)ubfEvent {
//    for (id val in [ubfEvent valueForKey:@"attributes"]) {
//        if ([[val valueForKey:@"name"] isEqualToString:fieldName]) {
//            return [val valueForKey:@"value"];
//        }
//    }
//    return @"";
//}

@end
