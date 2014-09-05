//
//  UBFAugmentationPluginTests.m
//  EngageSDK
//
//  Created by Jeremy Dyer on 6/25/14.
//  Copyright (c) 2014 Silverpop. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "EngageEventLocationManager.h"
#import "EngageConfig.h"
#import "EngageConfigManager.h"
#import "UBF.h"
#import "EngageEvent.h"
#import "EngageLocalEventStore.h"
#import "UBFCoordinatesAugmentationPlugin.h"
#import "UBFPlacemarkAugmentationPlugin.h"
#import "UBFLocationNameAugmentationPlugin.h"
#import "UBFAugmentationManager.h"

@interface UBFAugmentationPluginTests : XCTestCase

@property (nonatomic, strong) EngageEventLocationManager *elm;
@property (nonatomic, strong) UBFAugmentationManager *augMan;

@property (nonatomic, strong) NSString *longitudeUBFFieldName;
@property (nonatomic, strong) NSString *latitudeUBFFieldName;
@property (nonatomic, strong) NSString *locationAddressUBFFieldName;
@property (nonatomic, strong) NSString *locationNameUBFFieldName;

@property (assign) CLLocationDegrees dummyLongitude;
@property (assign) CLLocationDegrees dummyLatitude;

@end

@implementation UBFAugmentationPluginTests

- (void)setUp
{
    [super setUp];
    self.augMan = [UBFAugmentationManager sharedInstance];
    self.elm = [EngageEventLocationManager sharedInstance];
    
    //Pulls the needed values from the ConfigurationManager.
    self.longitudeUBFFieldName = [[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LONGITUDE];
    self.latitudeUBFFieldName = [[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LATITUDE];
    self.locationAddressUBFFieldName = [[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LOCATION_ADDRESS];
    self.locationNameUBFFieldName = [[EngageConfigManager sharedInstance] fieldNameForUBF:PLIST_UBF_LOCATION_NAME];
    
    self.dummyLongitude = 10.12345;
    self.dummyLatitude = 24.12345;
    
    //Location manager won't actually pick up data for the test so lets place some dummy coordinates in there.
    CLLocation *dummyLocation = [[CLLocation alloc] initWithLatitude:self.dummyLatitude longitude:self.dummyLongitude];
    self.elm.currentLocationCache = dummyLocation;
}

- (void)tearDown
{
    [super tearDown];
    
    //Removes any stale EngageEvents that might have been saved in the database.
    [[EngageLocalEventStore sharedInstance] deleteAllUBFEvents];
    
    //Clear the dummy data in the LocationManager cache.
    self.elm.currentLocationCache = nil;
}

- (void)testAugmentationManagerInitilization
{
    XCTAssertTrue(self.elm != nil, @"Expected EngageEventLocationManager to not be nil!");
}

- (void)testAugmentationManagerPluginsLoaded
{
    XCTAssertTrue(self.augMan != nil);
    XCTAssertTrue(self.augMan.augmentationPlugins != nil);
    XCTAssertTrue([self.augMan.augmentationPlugins count] == 3, @"Expected 3 Augmentation Plugins. Did you change the Augmentation plugins in the plist file?");
}

- (void)testCoordinatesPlugin
{
    //Creates the dummy event data.
    UBF *ubfEvent = [UBF installed:nil];
    
    UBFCoordinatesAugmentationPlugin *coordPlugin = [[UBFCoordinatesAugmentationPlugin alloc] init];
    ubfEvent = [coordPlugin process:ubfEvent];
    
    XCTAssertTrue([ubfEvent.attributes objectForKey:self.longitudeUBFFieldName], @"Expected Longitude value not present UBF event");
    XCTAssertTrue([ubfEvent.attributes objectForKey:self.latitudeUBFFieldName], @"Expected Latitude value not present UBF event");
}

- (void)testPlacemarkPlugin
{
    //Creates the dummy event data.
    UBF *ubfEvent = [UBF installed:nil];
    
    UBFPlacemarkAugmentationPlugin *placemarkPlugin = [[UBFPlacemarkAugmentationPlugin alloc] init];
    ubfEvent = [placemarkPlugin process:ubfEvent];
    
    XCTAssertTrue([ubfEvent.attributes objectForKey:self.locationAddressUBFFieldName], @"Expected Location Address not present in UBF event");
    
    NSLog(@"Something please show up ....");
}

- (void)testLocationNamePlugin
{
    //Creates the dummy event data.
    UBF *ubfEvent = [UBF installed:nil];
    
    UBFLocationNameAugmentationPlugin *locNamePlugin = [[UBFLocationNameAugmentationPlugin alloc] init];
    ubfEvent = [locNamePlugin process:ubfEvent];
    
    XCTAssertTrue([ubfEvent.attributes objectForKey:self.locationNameUBFFieldName] == nil, @"UBF Location Name should be nil");
    
    NSString *testLocationName = @"Test Location Name";
    [ubfEvent setAttribute:self.locationNameUBFFieldName value:testLocationName];
    ubfEvent = [locNamePlugin process:ubfEvent];
    NSString *value = [ubfEvent.attributes objectForKey:self.locationNameUBFFieldName];
    XCTAssertTrue([value isEqualToString:testLocationName], @"UBF Location Name should be the originally passed UBF value");
}

@end
