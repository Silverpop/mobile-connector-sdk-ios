engage-sdk-ios
==============

Silverpop Engage SDK for iOS (a.k.a. the "Silverpop Mobile Connector")

## Simple Engage Database wrapper for iOS 

EngageSDK is a Engage API wrapper library for iOS development.
The goal is to provide a library that is simple to setup and use for communicating remotely with our Silverpop Engage Database system.

## Features

EngageSDK is a wrapper for the Engage Database XMLAPI and JSON Universal Events. The SDK assists developers in interacting with both the XMLAPI and JSON Universal Events (UBF) web services. All interaction with the Engage web services require that you first establish a secure connection with Engage via the OAuth 2 credentials you receive from the Engage Portal. Although XMLAPI and UBF share certain components the SDK divides the interaction with each module into separate components namely UBFManager and XMLAPIManager. 

## Installing SDK

## Before You Release Your App

### Important Note: Increase Token Limits for Production Apps

There are currently limits placed on the number of Access Tokens that can be generated per hour per instance of Engage.  This number is easily increased, however, before deploying your app publicly, you must contact your Relationship Manager or Sales Rep regarding your intention to use this connector and that you will need to have your OAuth Access Token rate limit increased.

## Demos

### 1.1.0 Demo

    $ gem install cocoapods # If necessary
    $ git clone git@github.com:Silverpop/engage-sdk-ios.git
    $ cd engage-sdk-ios/EngageSDK-1-1-0-Demo-ios
    $ pod install
    $ open EngageSDK-1-1-0-Demo-ios.xcworkspace

This demo app demonstrates the process of managing the mobile identity of the recipient.

For more info refer to the [README](https://github.com/makeandbuild/mobile-connector-sdk-ios/tree/master/EngageSDK-1-1-0-Demo-ios) for the demo app.

### 1.0.0 Demo
EngageSDK includes a sample project within the Example subdirectory. In order to build the project, you must install the dependencies via CocoaPods. To do so:

    $ gem install cocoapods # If necessary
    $ git clone git@github.com:Silverpop/engage-sdk-ios.git
    $ cd engage-sdk-ios/Example
    $ pod install
    $ touch EngageSDKDemo/sample-config.h
    $ open EngageSDKDemo.xcworkspace

Open the EngageSDKDemo/sample-config.h file and paste the `#define` code from [Environment Setup](#environment-setup) below.

Once installation has finished, you can build and run the EngageSDKDemo project within your simulator or iPhone device.

Once you understand how the Demo project is configured via CocoaPods and implemented using the EngageSDK, you are ready to integrate the EngageSDK with your new or existing Xcode iPhone project.

## Getting Started 
The first thing you will want to do is contact your Relationship Manager at Sidlverpop and ask for the "Silverpop Mobile Connector".  They will assist in getting your Engage account provisioned for Universal Behaviors -- the new flexible event tracking system that is the backbone of tracked mobile app behaviors.

Next, you can follow the instructions in this readme file, or as an additional offer, we've put together a short 10 minute tutorial that will walk you through the download, installation, and configuration process to get your app up and running.  [Click here](https://kb.silverpop.com/kb/engage/Silverpop_Mobile_Connector_-_***NEW***/Video_Tutorial%3A_Up_and_Running_in_10_mins!) to watch that video tutorial within our KnowledgeBase.

## Environment Setup
The best way to begin is by using [CocoaPods](https://github.com/cocoapods/cocoapods). Follow the instructions offered at the CocoaPods website to install CocoaPods using Ruby Gems. 


Using an new or existing iPhone project within Xcode, create a new C header file. We will use this file to define important constant configuration data for the EngageSDK library. Copy and paste the following lines between `#define` and `#endif`:

```objective-c
#define ENGAGE_BASE_URL (@"YOUR ENGAGE POD API URL")
#define ENGAGE_CLIENT_ID (@"YOUR CLIENT ID GOES HERE")
#define ENGAGE_SECRET (@"YOUR SECRET GOES HERE")
#define ENGAGE_REFRESH_TOKEN (@"YOUR REFRESH TOKEN HERE")
#define ENGAGE_LIST_ID (@"YOUR LIST ID")
```

Configure the defines with your values and save changes and close your project if it is open. 

Open the terminal and open the project folder. 

```
touch Podfile
```

Edit this file to add the EngageSDK dependency

```
pod 'EngageSDK', '~> 1.1.0'
```

Save and close. 
Install the Pod dependencies.

```
pod install
```

CocoaPods clones the EngageSDK files from github and creates an Xcode workspace configured with all dependencies (AFNetworking, AFOAuth2) and linking your existing project to a 'Pods' project that organizes and manages your dependencies and builds them as static libraries linked into your project.

Open the Xcode workspace and import the public headers of the EngageSDK library by adding the following line to your code:
 
```
#import "YOURSUPERSECRETCONFIGFILE.h"
#import <EngageSDK/EngageSDK.h>
```

## Tips
You may want to add the following lines to your .gitignore file

```
#CocoaPods
*/Pods/*
*/Podfile.lock
*/YOURSUPERSECRETCONFIGFILE.h
```

Some developers may need to install Xcode Command Line Tools before installing CocoaPods

If you are having trouble with ruby gems, try performing a gem system update: `gem update --system`

### <a name="EngageSDK"/>Engage SDK
To initalize the EngageSDK including the (XMLAPIManager)[#XMLAPIManager) and (UBFManager)[UBFManager] make the following call in your AppDelegage class.

```objective-c
[EngageSDK initializeSDKClient:ENGAGE_CLIENT_ID secret:ENGAGE_SECRET token:ENGAGE_REFRESH_TOKEN host:ENGAGE_BASE_URL engageDatabaseListId:ENGAGE_LIST_ID];
```

### <a name="UBFManager"/>UBFManager

The ```UBFManager``` manages posting UBF events through the Engage JSON Universal Events web services. A ```UBFManager``` singleton instance should be created in your ```AppDelegate``` class. Failing to initialize the ```UBFManager``` in your ```AppDelegate``` and rather somewhere else in your application may lead to certain UBF events such as "installed" or "session started" from being captured since they may occur before anywhere else in your application has the opportunity to initialize an instance of the ```UBFManager```. 

####Purpose

The goal of ```UBFManager``` is serve the simple purpose of posting UBF Universal Events to Engage while masking the more complicated management tasks such as (network reachability, persistence, and authentication) from the SDK user. 

* tracking UBF events - Posts your individual events to Engage. Local cache is taken into consideration and events are not posted until "ubfEventCacheSize" configuration value is reached. Once that value is reached then the events are batched and sent to Engage to reduce network traffic. You may set the value of "ubfEventCacheSize" if you do not wish for local caching to take palce. 
* handleLocalNotification - utility method invoked SDK user invokes when their application receives a local notificaiton
* handlePushNotificationReceived - utility method for received push notification. This method also handles searching the notification for EngageSDK parameter values like Current Campaign (configurable).
* handleNotificationOpened - utility method for opened notifications. Method handles searching the notifications for EngageSDK parameter values like Current Campaign (configurable)
* handleExternalURLOpened - utility method for external URL opened (email or website deeplink on the device for example) and handles searching the notifications for EngageSDK parameter values like Current Campaign (configurable)

####Notes
Notes about UBFManager creation. The UBFManager transparently handles network reachability, event persistence, and client authentication. Initial creation of the UBFManager will establish the OAuth 2 connection to the Engage service using the credentials that you provide which you received from the Engage portal. UBF events may be immediately posted to the UBFManager even before a successful authentication connection has been established. UBF events that are posted to the manager are simply queued and persisted until the authentication is successful and then they are flushed to Engage. The UBFManager will also queue and persist the events locally if an event is posted while the device does not currently have network reachability. If the application is closed or the device powered down before network reachability has been regained then the events will be posted the next time the application is opened. The local events are durable under all circumstances other than the application being deleted from the device or the SDK user deleting them from the EngageLocalEventStore. 

After initial UBFManager creation (see [EngageSDK](#EngageSDK)) you may reference your singleton anytime with
```objective-c
UBFManager *ubfManager = [UBFManager sharedInstance];
```

## UBF Event Augmentation Plugin Service

After a UBF event is created and sent the the UBFManager the UBF may also be further augmented with
data received from IOS hardware or user defined external services. This functionality maintains
maximum SDK flexibility as it allows the user to define their own Augmentation plugins that augment
the UBF event before it is posted to the Engage API. The SDK by default uses this framework for augmenting
the UBF events with location coordinates and location name for example. Any plugin can be created by the user
by implementing the ```UBFAugmentationPluginProtocol``` interface. Here is a 
simple example of a "weather UBF augmentation plugin"

UBFWeatherAugmentationPlugin.h
```objective-c
@interface UBFWeatherAugmentationPlugin : NSObject <UBFAugmentationPluginProtocol>

-(BOOL)processSyncronously;
-(BOOL)isSupplementalDataReady;
-(UBF*)process:(UBF*)ubfEvent;

@end
```

UBFWeatherAugmentationPlugin.m
```objective-c
@implementation UBFWeatherAugmentationPlugin

-(id)init {
    self = [super init];
    if (self) {
        //Custom init logic
    }
    return self;
}

-(BOOL)processSyncronously {
    return YES; //Other plugins depend on this Plugins output for processing
}

-(BOOL)isSupplementalDataReady {
    // Your logic to decide if the data needed for the plugin to process is ready or not. Lets assume our fake weather data is.
    return YES;
}

-(UBF*)process:(UBF*)ubfEvent {
    if (ubfEvent) {
        [ubfEvent setAttribute:@"Temperatue In Celsius" value:@"100"];
        [ubfEvent setAttribute:@"Temperatue In Fahrenheit" value:@"212"];
    }
    return ubfEvent;
}

@end
```

To prevent UBF events from becoming stagnant or waiting indefinitely for augmentation data a configurable
augmentation timeout is placed for a single UBF augmentation. The same timeout applies if you have 1 plugin
or 1000 plugins so tuning to match your needs is expected. After the timeout is reached the UBF event
will be posted to Engage API in the same state as when it was handed off to the augmentation plugin service.

## Universal Behaviors API

Before connecting and sending Universal Behaviors, you should assume a valid user identity specified identity via XMLAPI.  Refer to the [MobileIdentityManager](#MobileIdentityManager).


#### Goal Completed
```objective-c
[[UBFManager sharedInstance] trackEvent:[UBF goalCompleted:@"LISTENED TO MVSTERMIND" params:nil]];
```

#### Goal Abandoned
```objective-c
[[UBFManager sharedInstance] trackEvent:[UBF goalAbandoned:@"LISTENED TO MVSTERMIND" params:nil]];
```

#### Named Event with params
```objective-c
[[UBFManager sharedInstance] trackEvent:[UBF namedEvent:@"PLAYER LOADED" params:@{ @"Event Source View" : @"HomeViewController", @"Event Tags" : @"MVSTERMIND,Underground" }]];
```

### <a name="XMLAPIManager"/>XMLAPIManager

The XMLAPIManager manages posting XMLAPI messages to the Engage web services. A XMLAPIManager singleton instance should be created in your AppDelegate class.

After initial XMLAPIManager creation (see [EngageSDK](#EngageSDK)) you may reference your singleton anytime with
```objective-c
XMLAPIManager *xmlapiManager = [XMLAPIManager sharedInstance];
```

### ~~Creating an anonymous user~~ (depreciated)
*Depreciated in favor of recipient setup methods in* [MobileIdentityManager](#MobileIdentityManager)
```objective-c
// Conveniently calls addRecipient and stores anonymousId within EngageConfig
[[XMLAPIManager sharedInstance] createAnonymousUserToList:ENGAGE_LIST_ID success:^(ResultDictionary *ERXML) {
    if ([ERXML isSuccess]) {
        NSLog(@"SUCCESS");
    }
    else {
        NSLog(@"%@",[ERXML faultString]);
    }
} failure:^(NSError *error) {
    NSLog(@"SERVICE FAIL");
}];
```

### Identifying a registered user

```objective-c
XMLAPI *selectRecipientData = [XMLAPI selectRecipientData:@"somebody@somedomain.com" list:ENGAGE_LIST_ID];

[[XMLAPIManager sharedInstance] postXMLAPI:selectRecipientData success:^(ResultDictionary *ERXML) {
        if ([ERXML isSuccess]) {
            NSLog(@"SUCCESS");
            // VERY IMPORTANT!!!
            // Universal Behaviors reads this value
            [EngageConfig storeMobileUserId:[ERXML valueForShortPath:@"RecipientId"]];
        }
        else {
            NSLog(@"%@",[ERXML faultString]);
        }
    } failure:^(NSError *error) {
        NSLog(@"SERVICE FAIL");
    }];
```

### ~~Convert anonymous user to registered user~~ (depreciated)
*Depreciated in favor of recipient setup methods in* [MobileIdentityManager](#MobileIdentityManager)
```objective-c
// Conveniently links anonymous user record with the primary user record according to the mergeColumn
[[XMLAPIManager sharedInstance] updateAnonymousToPrimaryUser:[EngageConfig primaryUserId]
                                                   list:ENGAGE_LIST_ID
                                      primaryUserColumn:@"CONTACT_ID"
                                            mergeColumn:@"MERGE_CONTACT_ID"
                                                success:^(ResultDictionary *ERXML) {
                                                    if ([[ERXML valueForShortPath:@"SUCCESS"] boolValue]) {
                                                        NSLog(@"SUCCESS");
                                                    }
                                                    else {
                                                        NSLog(@"%@",[ERXML valueForShortPath:@"Fault.FaultString"]);
                                                    }
                                                } failure:^(NSError *error) {
                                                    NSLog(@"SERVICE FAIL");
                                                }];
```


### <a name="MobileIdentityManager"/>MobileIdentityManager

The ```MobileIdentityManager``` can be used to manage user identities.  It can auto create new user identities 
as well as merge existing identities if needed.  This functionality is intended to replace the 
manual process of creating an anonymous user.
 
In addition to the normal app security token configuration, the following setup must be configured prior to 
using the ```MobileIdentityManager``` methods.
- Recipient list should already be created and the ```listId``` should be setup in the configuration.
- ```EngageConfig.plist``` should be configured with the columns names representing the _Mobile User Id_, _Merged Recipient Id_, and _Merged Date_.  The ```EngageConfigDefaults.plist``` defines default values if you prefer to use those.
- The _Mobile User Id_, _Merged Recipient Id_, and _Merged Date_ columns must be created in the recipient list with names that match your ```EngageConfig.plist``` settings
- Optional: If you prefer to save the merge history in a separate AuditRecord relational table you can 
set ```mergeHistoryInAuditRecordTable``` to ```YES```.  If enabled you are responsible for creating the AuditRecord
 table with the columns for _Audit Record Id_, _Old Recipient Id_, _New Recipient Id_, and _Create Date_ prior to
 calling ```checkIdentityForIds```.

##### Setup recipient identity

```objective-c
/**
 * Checks if the mobile user id has been configured yet.  If not
 * and the 'enableAutoAnonymousTracking' flag is set to true it is auto generated
 * using either the {@link EngageDefaultUUIDGenerator} or
 * the generator configured as the 'mobileUserIdGeneratorClassName'.  If
 * 'enableAutoAnonymousTracking' is 'NO' you are responsible for
 * manually setting the id using {@code EngageConfig#storeMobileUserId}.
 * <p/>
 * Once we have a mobile user id (generated or manually set) a new recipient is
 * created with the mobile user id.
 * <p/>
 * On successful completion of this method the EngageConfig will contain the
 * mobile user id and new recipient id.
 *
 * @param didSucceed custom behavior to run on success of this method
 * @param didFail custom behavior to run on failure of this method
 */
-(void)setupRecipientWithSuccess:(void (^)(SetupRecipientResult* result))didSucceed
                         failure:(void (^)(SetupRecipientFailure* failure))didFail;
```

##### Setup Recipient Usage

```objective-c
[[MobileIdentityManager sharedInstance] setupRecipientWithSuccess:^(SetupRecipientResult *result) {
    
    NSString *messageFormat = @"Recipient Id: %@\nMobile User Id: %@";
    NSString *message = [NSString stringWithFormat:messageFormat, [result recipientId], [EngageConfig mobileUserId]];
    NSLog(@"%@", message);
    
    // do any other custom behavior
    
} failure:^(SetupRecipientFailure *failure) {
    NSLog(@"Setup Recipient failure");
    
    // do any other custom behavior
}];
```

##### Check identity and merge recipients

```objective-c
/**
 * Checks for an existing recipient with all the specified ids.  If a matching recipient doesn't exist
 * the currently configured recipient is updated with the searched ids.  If an existing recipient
 * does exist the two recipients are merged and the engage app config is switched to the existing
 * recipient.
 * <p/>
 * When recipients are merged a history of the merged recipients is recorded.  By default it uses the
 * Mobile User Id, Merged Recipient Id, and Merged Date columns, however if you prefer to store
 * the merge history in a separate AuditRecord table you can set you EngageConfig.plist properties accordingly.
 * <p/>
 * WARNING: The merge process is not currently transactional.  If this method errors the data is likely to
 * be left in an inconsistent state.
 *
 * @param fieldsToIds Dictionary of column name to id value for that column.  Searches for an
 *                             existing recipient that contains ALL of the columns in the dictionary.
 *                             <p/>
 *                             Examples:
 *                             - Key: facebook_id, Value: 100
 *                             - Key: twitter_id, Value: 9999
 * @param didSucceed custom behavior to run on success of this method
 * @param didFail custom behavior to run on failure of this method
 */
 -(void)checkIdentityForIds:(NSDictionary *)fieldsToIds
                   success:(void (^)(CheckIdentityResult* result))didSucceed
                   failure:(void (^)(CheckIdentityFailure* failure))didFail;
```
 
##### Check Identity Usage

```objective-c
[[MobileIdentityManager sharedInstance] checkIdentityForIds:@{ @"facebook_id" : @"fbuser" } success:^(CheckIdentityResult *result) {
    
    NSString *newRecipientId = [result recipientId];
    NSString *mergedRecipientId = [result mergedRecipientId];
    NSString *mobileUserId = [result mobileUserId];
    
    NSString *messageFormat = @"Current recipient id: %@\nMerged recipient id: %@\nMobile user id: %@";
    NSString *message = [NSString stringWithFormat:messageFormat, newRecipientId, mergedRecipientId, mobileUserId];
    NSLog(@"%@", message);
    
    // do any other custom behavior
    
} failure:^(CheckIdentityFailure *failure) {
    NSLog(@"Check Identity failure");
    
    // do any other custom behavior
}];
```

## Local Event Storage

UBF events are persisted to a local SQLite DB on the user's device. The event can have 1 of 5 statuses. ```NOT_POSTED```, ```SUCCESSFULLY_POSTED```, ```FAILED_POST```, ```HOLD```, or ```EXPIRED```. 

* NOT_POSTED 
    * UBF events that are ready to be sent to Engage but currently cannot due to network not being reachable or queue cache size not being met yet.
* SUCCESSFULLY_POSTED
    * UBF events that have already been successfully posted to Engage. These events will be purged after the configurable amount of time has been reached.
* FAILED_POST
    * UBF events that were attempted to be posted to Engage for the maximum number of retries. Once in this state no further attempts to post the UBF event will be made.
* HOLD 
    * UBF events in this state have been initially created but have still not had all of their data set by the augmentation service. UBF events that fail to be ran successfully through the augmentation service before their timeouts have been reached will be moved to the NOT_POSTED state and sent to Engage on the next flush. Providing timeouts helps ensure that the events do not become stuck in the HOLD state if certain external augmentation events are never received.
* EXPIRED
    * UBF events that fail to complete their augmenation before the time out is reached are placed in the EXPIRED state. EXPIRED events are eligible to be POSTed to Engage just like NOT_POSTED events.

## EngageSDK Models

EngageSDK has 2 primary models that SDK users should concerns themselves with

### <a name="UBF"/>UBF

Utility class for generating JSON Universal Events that are posted to the UBFManager and ultimately sent to Engage. The class maintains a NSDictionary of attributes that are different depending on the event type that is created. Any NSDictionary values that you provide to the utility methods will take precedence over the values that the utility methods pull from the device.

#### <a name="UBFCoreValues"/>UBF Core Values

* Device Version
* OS Name
* OS Version
* App Name
* App Version
* Device Id
* Mobile User Id / Primary User Id
* Anonymous Id
* Recipient Id

### <a name="XMLAPI"/>XMLAPI

Post an XMLAPI resource using a helper e.g. SelectRecipientData

```objective-c
// create a resource encapsulating your request to select by email address
XMLAPI *selectRecipientData = [XMLAPI selectRecipientData:@"somebody@somedomain.com" list:ENGAGE_LIST_ID];

[[XMLAPIManager sharedInstance] postXMLAPI:selectRecipientData success:^(ResultDictionary *ERXML) {
    // SUCCESS = TRUE
    if ([ERXML isSuccess]) {
        NSLog(@"SUCCESS");
    }
    // SUCCESS = FALSE
    // This is a specific XMLAPI failure, status 2xx
    else {
        NSLog(@"%@",[ERXML faultString]);
    }
} failure:^(NSError *error) {
    // This is a status > 400
    NSLog(@"SERVICE FAIL");
}];
```

## XMLAPI Resources

### Example 1

```xml
<Envelope>
    <Body>
        <SelectRecipientData>
            <LIST_ID>45654</LIST_ID>
            <EMAIL>someone@adomain.com</EMAIL>
            <COLUMN>
                <NAME>Customer Id</NAME>
                <VALUE>123-45-6789</VALUE>
            </COLUMN>
        </SelectRecipientData>
    </Body>
</Envelope>
```

is equivalent to:

```objective-c
XMLAPI *selectRecipientData = [XMLAPI resourceNamed:XMLAPI_OPERATION_SELECT_RECIPIENT_DATA
                                             params:@{
                               @"LIST_ID" : @"45654",
                               @"EMAIL" : @"someone@adomain.com",
                               @"COLUMNS" : @{ @"Customer Id" : @"123-45-6789" } }];
```

or alternately:

```objective-c
XMLAPI *selectRecipientData = [XMLAPI resourceNamed:XMLAPI_OPERATION_SELECT_RECIPIENT_DATA];
[selectRecipientData addParams:@{ @"LIST_ID" : @"45654", @"EMAIL" : @"someone@adomain.com" }];
[selectRecipientData addColumns:@{ @"Customer Id" : @"123-45-6789" }];
```

### Example 2

```xml
<Envelope>
    <Body>
        <SelectRecipientData>
            <LIST_ID>45654</LIST_ID>
            <RECIPIENT_ID>702003</RECIPIENT_ID>
        </SelectRecipientData>
    </Body>
</Envelope>
```

is equivalent to:

```objective-c
XMLAPI *selectRecipientData = [XMLAPI resourceNamed:XMLAPI_OPERATION_SELECT_RECIPIENT_DATA params:@{@"RECIPIENT_ID" : @"702003"}];
```

### Example 3

```xml
<Envelope>
    <Body>
        <SelectRecipientData>
            <LIST_ID>45654</LIST_ID>
            <EMAIL>someone@adomain.com</EMAIL>
        </SelectRecipientData>
    </Body>
</Envelope>
```

is equivalent to:

```objective-c
XMLAPI *selectRecipientData = [XMLAPI selectRecipientData:@"someone@adomain.com" list:@"45654"];
```
### XMLAPIOperation
For your convenience constants for the supported XMLAPI operations can be found in the ```XMLAPIOperation``` class.

## Deeplinking


## Configuration

The EngageSDK is configured via 2 plist files. One plist file (EngageConfigDefaults.plist) is provided in the SDK itself and in populated with the values from the Configuration Values table below to promote a turn key SDK approach. The second plist file is a file caused EngageConfig.plist that you (optionally) provide in the supporting files of your project. The EngageConfig.plist values you define always take precedence over the configuration values defined in the EngageConfigDefaults.plist files. It is recommended that you simply copy the EngageConfigDefaults.plist file and rename it to EngageConfig.plist in your project and change the configurations to their desired values.

### EngageConfigManager

The EngageSDK configuration values are stored in memory in a NSDictionary after the application starts up. Receiving those individual configuration values is managed via the EngageConfigManager. The manager queries the NSDictionary for the requested field. EngageConfigManager accepts constants defined in EngageConfig which provide more description names that point to the actual configuration values specified in the Configuration Values table below.

### Configuration Values

The configuration 

|Configuration Name|Default Value|Meaning|Format|
|------------------|-------------|-------|------|
|LocalEventStore->expireLocalEventsAfterNumDays|30 days|Number of days before engage events are purged from local storage|Number|
|General->databaseListId|{YOUR_LIST_ID}|Engage Database ListID from Engage Portal|String|
|General->ubfEventCacheSize|3|Events to cache locally before batch post|Number|
|General->defaultCurrentCampaignExpiration|1 day|time before current campaign expires by default|EngageExpirationParser String|
|ParamFieldNames->ParamCampaignValidFor|CampaignValidFor|External event parameter name to parse Campaign valid from|String|
|ParamFieldNames->ParamCampaignExpiresAt|CampaignExpiresAt|External event parameter name to parse Campaign expires at from|String|
|ParamFieldNames->ParamCurrentCampaign|CurrentCampaign|External event parameter name to parse Current Campaign from|String|
|ParamFieldNames->ParamCallToAction|CallToAction|External event parameter name to parse Call To Action from|String|
|Session->sessionLifecycleExpiration|30 minutes|time local application session is valid for before triggering session ended event|EngageExpirationParser String|
|Networking->maxNumRetries|3|Number of times that an event is retried before it is finally marked as failed in the local event store and no more attempts are made|Number|
|UBFFieldNames->UBFSessionDurationFieldName|Session Duration|JSON Universal Event Session Duration field name|String|
|UBFFieldNames->UBFTagsFieldName|Tags|JSON Universal Event Tags field name|String|
|UBFFieldNames->UBFDisplayedMessageFieldName|Displayed Message|JSON Universal Event Displayed Message field name|String|
|UBFFieldNames->UBFCallToActionFieldName|Call To Action|JSON Universal Event Call To Action field name|String|
|UBFFieldNames->UBFEventNameFieldName|Event Name|JSON Universal Event name field name|String|
|UBFFieldNames->UBFGoalNameFieldName|Goal Name|JSON Universal Event goal field name|String|
|UBFFieldNames->UBFCurrentCampaignFieldName|Campaign Name|JSON Universal Event current campaign field name|String|
|UBFFieldNames->UBFLastCampaignFieldName|Last Campaign|JSON Universal Event last campaign field name|String|
|UBFFieldNames->UBFLocationAddressFieldName|Location Address|JSON Universal Event location address field name|String|
|UBFFieldNames->UBFLocationNameFieldName|Location Name|JSON Universal Event location name field name|String|
|UBFFieldNames->UBFLatitudeFieldName|Latitude|JSON Universal Event Latitude field name|String|
|UBFFieldNames->UBFLongitudeFieldName|Longitude|JSON Universal Event Longitude field name|String|
|LocationServices->lastKnownLocationDateFormat|yyyy'-'MM'-'dd|User last known location date format|String|
|LocationServices->lastKnownLocationTimestampColumn|Last Location Address Time|Engage DB column name for the last known location time|String|
|LocationServices->lastKnownLocationColumn|Last Location Address|Engage DB column name for the last known location|String|
|LocationServices->locationDistanceFilter|10|meters in location change before updated location information delegate is invoked|Number|
|LocationServices->locationPrecisionLevel|kCLLocationAccuracyBest|desired level of location accuracy|String|
|LocationServices->locationCacheLifespan|1 hr|lifespan of location coordinates before they are considered expired|EngageExpirationParser String|
|LocationServices->coordinatesPlacemarkTimeout|15 sec|timeout on acquiring CLPlacemark before event is posted without that information|EngageExpirationParser String|
|LocationServices->coordinatesAcquisitionTimeout|15 sec|timeout on acquiring CLLocation before event is posted without that information|EngageExpirationParser String|
|LocationServices->enabled|YES|Are Location services enabled for UBF events|Boolean|
|Augmentation->augmentationTimeout|15 sec|timeout for augmenting UBF events|EngageExpirationParser|String|
|Recipient->enableAutoAnonymousTracking|true|If set to true it allows mobile user ids to be auto generated for recipients.  If set to false you are responsible for manually setting the mobile user id.|Boolean|
|Recipient->mobileUserIdGeneratorClassName|EngageDefaultUUIDGenerator|The class to use for auto generating mobile user ids if the ```enableAutoAnonymousTracking``` property is set to true.|Class|
|Recipient->mobileUserIdColumn|Mobile User Id|Column name to store the mobile user id in.|String|
|Recipient->mergedRecipientIdColumn|Merged Recipient Id|Column name to store the merged recipient id in.  The merged recipient id column is populated if needed during the check identity process.|String|
|Recipient->mergedDateColumn|Merged Date|Column name to store the merged date in. The merged recipient id column is populated if needed during the check identity process.|String|
|Recipient->mergeHistoryInMarketingDatabase|YES|If the audit history for merged recipients should be stored in the marketing database.|Boolean|
|AuditRecord->auditRecordPrimaryKeyColumnName|Audit Record Id|Only required if ```mergeHistoryInAuditRecordTable``` is set to ```YES```.  The column name for the generated primary key in the audit record table.|String|
|AuditRecord->auditRecordPrimaryKeyGeneratorClassName|EngageDefaultUUIDGenerator|Only required if ```mergeHistoryInAuditRecordTable``` is set to ```YES```.  The class to use to generate primary keys for the audit record table.|Class|
|AuditRecord->oldRecipientIdColumnName|Old Recipient Id|Only required if ```mergeHistoryInAuditRecordTable``` is set to ```YES```. When a recipient is merged during the check identity process, this is the column name for old recipient id.|String|
|AuditRecord>newRecipientIdColumnName|New Recipient Id|Only required if ```mergeHistoryInAuditRecordTable``` is set to ```YES```. When a recipient is merged during the check identity process, this is the column name for assumed recipient id.|String|
|AuditRecord->createDateColumnName|Create Date|Only required if ```mergeHistoryInAuditRecordTable``` is set to ```YES```. When a recipient is merged during the check identity process, this is the column name for the timestamp for when the merge occurred.|String|
|AuditRecord->mergeHistoryInAuditRecordTable|NO|If the audit history for merged recipients should be stored in a separate audit record table.|Boolean|


## EngageExpirationParser

EnagageSDK interacts with a wide array of dates and expiration times. Those values are pulled from both external parameters and internal configurations. To ensure that those values are most accurately interpretted a flexible format was created for the EngageSDK and a special format which will be referred to as the "EngageExpirationParser String". This "EngageExpirationParser String" value can accept any number of time based values and then provides several convenience methods for accessing specific units of time measurement from those parsed values. Units of time are measured from either a reference date that you provide when you create the object or otherwise the the time string is interpreted as a "valid for" value instead of a "expires at" value.

### EngageExpirationExamples

####Assume current date of 6/10/2014 00:00:00

|EngageExpirationParser String|Expiration Date|
|-----------------------------|---------------|
|1 day 15m|6/11/2014 00:15:00|
|15m1d0seconds|6/11/2014 00:15:00|
|65minutes|6/10/2014 01:05:00|
|3seconds|6/10/2014 00:00:03|

### Sessions

EngageSDK implements predefined Session events for Universal Behaviors. Sessions are configured to timeout if a user leaves your app for at least 5 minutes. At the end of the Session, duration is computed excluding any portion of inactivity.

#### Notifications
Both local and push notifications require that the user of the SDK enable their application for subscribing and listening for the notifications. These hooks for the notifications are defined inside your application's UIApplicationDelegage (AppDelegate) implementation class. Full reference for those hooks can be found [here] (https://developer.apple.com/library/ios/documentation/uikit/reference/uiapplicationdelegate_protocol/Reference/Reference.html#//apple_ref/occ/intfm/UIApplicationDelegate). Examples of using the local and push notification hooks are found below.

#### Local Notification Received
```objective-c
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification {
    [[UBFManager sharedInstance] handleLocalNotificationReceivedEvents:notification withParams:nil];
}
```

#### Push Notification Received
```objective-c
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)pushNotification  {
    [[UBFManager sharedInstance] handlePushNotificationReceivedEvents:pushNotification];
}
```

#### Application Opened by clicking Notification - Application AppDelegate class
```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    if (launchOptions != nil) {
        // Launched from push notification or local notification
        NSDictionary *notification = nil;
        if ([launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey]) {
            notification = [launchOptions objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        } else if ([launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey]) {
            notification = [launchOptions objectForKey:UIApplicationLaunchOptionsLocalNotificationKey];
        } else {
            //Other application logic
        }
        
        [[UBFManager sharedInstance] handleNotificationOpenedEvents:notification];
    }
}
```

#### Application Opened by clicking external DeepLink - Application AppDelegate class snippet
```objective-c
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    NSURL *ubfEventUid = [[UBFManager sharedInstance] handleExternalURLOpenedEvents:url];
}
```

#### DeepLink Configuration
Deep linking is handled in the EngageSDK by leveraging the [MobileDeepLinking](http://mobiledeeplinking.org) library. **You must create a MobileDeepLinkingConfig.json file** in your application. MobileDeepLinkingConfig.json is the definition of how EngageSDK will parse the parameters from the DeepLinks presented to your app and ultimately are sent as part of UBF events. Complete configuration can be found on the [MobileDeepLinking website](http://mobiledeeplinking.org). At a minimum you must define a "handler" to handle the parsing of the URLs. The EngageSDK handler is named "postSilverpop" and a sample configuration is found below. At a minimum you should include the "defaultRoute" section from the sample below to your MobileDeepLinkingConfig.json file. You can also register your own custom handlers with MobileDeepLinking and add them to the list of handlers in the configuration file.

```json
{
    "logging": "true",
    "defaultRoute": {
        "handlers": [
            "postSilverpop"
        ]
    },
    "routes": {
        "test/:testId": {
            "handlers": [
                         "postSilverpop"
                         ],
            "routeParameters": {
                "testId": {
                    "required": "true",
                    "regex": "[0-9]"
                },
                "CurrentCampaign": {
                    "required": "false"
                },
                "utmSource": {
                    "required": "false"
                }
            }
        },
        "campaign/:CurrentCampaign": {
            "handlers": [
                "postSilverpop"
            ],
            "routeParameters": {
                "CurrentCampaign": {
                    "required": "true"
                },
                "CampaignEndTimeStamp": {
                    "required": "false"
                }
            }
        }
    }
}
```

#### Current Campaigns
If you noticed the configuration value above has a parameter with a value of "CurrentCampaign". The #define macro of ```#define CURRENT_CAMPAIGN_PARAM_NAME @"CurrentCampaign"``` also has a default value of "CurrentCampaign". When a URL is opened and the UBFManager is invoked the CURRENT_CAMPAIGN_PARAM_NAME value is used to search the parameters for a match. If a match is found then the value of that parameter is set as the "Campaign Name" for all subsequent UBF events that are posted to Engage. Campaigns have a default expiration time of 86400 seconds (1 day) after they are set via opened url of push notification. If that value is not desirable you may also supply a ```objective-c #define CAMPAIGN_EXTERNAL_EXPIRATION_DATETIME_PARAM @"CampaignEndTimeStamp"``` value which is a standard linux timestamp for when you want the campaign specified to expire. [Here](http://www.timestampgenerator.com) is a handy timestamp tool for calculating those values. **Timestamps should be GMT**


#### CurrentCampaign and CampaignEndTimeStamp Deeplink Examples
Below are some deep link examples assuming that your application is configured to open for a URL containing a host value of "Silverpop".

```objective-c
Silverpop://campaign/TestCurrentCampaign?CampaignEndTimeStamp=1419465600    //Campaign Name set to "TestCurrentCampaign" and Expires on December 25th 2014 at 12AM
Silverpop://campaign/TestCurrentCampaign   //Campaign Name set to "TestCurrentCampaign" and Expires 1 Day after the URL is opened in the application
Silverpop://campaign/TestCurrentCampaign?CampaignEndTimeStamp=30931200    //Campaign Name set to "TestCurrentCampaign" and Expires on December 25th 1970 at 12AM. So campaign is never activated
```


### Posting events to Universal Behaviors service

Events are cached and sent in larger batches for efficiency. The timing of the automated dispatches varies but usually occur when the app is sent to the background. If you would like to control when events are posted, you can tell the UBFClient to post any cached events.

#### Manually post all events in cache
```objective-c
[[UBFManager sharedInstance] postEventCache];
```

### Further Questions, Issues, or Comments?
We have setup a [forum on our Silverpop Community](http://community.silverpop.com/t5/Silverpop-Mobile-Connector/bd-p/Mobile) for fostering collaboration in both sharing success stories and tackling problems together.  We invite you to share your thoughts, questions, and stories there.
