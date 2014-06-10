engage-sdk-ios
==============

Silverpop Engage SDK for iOS (a.k.a. the "Silverpop Mobile Connector")

## Simple Engage Database wrapper for iOS 

EngageSDK is a Engage API wrapper library for iOS development.
The goal is to provide a library that is simple to setup and use for communicating remotely with our Silverpop Engage Database system.

## Features

EngageSDK is a wrapper for the Engage Database XMLAPI and JSON Universal Events. The SDK assists developers in interacting with both the XMLAPI and JSON Universal Events (UBF) web services. All interaction with the Engage web services require that you first establish a secure connection with Engage via the OAuth 2 credentials you receive from the Engage Portal. Although XMLAPI and UBF share certain components the SDK divides the interaction with each module into separate components namely UBFManager and XMLAPIManager. 

### General Notes
- sample-config.h file to place your credentials and such in.
- Waits for authentication before events are posted.

### UBFManager

The UBFManager manages posting UBF events through the Engage JSON Universal Events web services. A UBFManager singleton instance should be created in your AppDelegate class. Failing to initialize the UBFManager in your AppDelegate and rather somewhere else in your application may lead to certain UBF events such as "installed" or "session started" from being captured since they may occur before anywhere else in your application has the opportunity to initialize an instance of the UBFManager. 

Create UBFManager instance in your AppDelegate
```objective-c
UBFManager *ubfManger = [UBFManager createClient:ENGAGE_CLIENT_ID
                                          secret:ENGAGE_SECRET
                                           token:ENGAGE_REFRESH_TOKEN
                                            host:ENGAGE_BASE_URL
                                  connectSuccess:^(AFOAuthCredential *credential) {
        NSLog(@"Successfully connected to Engage API : Credential %@", credential);
    } failure:^(NSError *error) {
        NSLog(@"Failed to connect to Silverpop API .... %@", [error description]);
    }];
```
Notes about UBFManager creation. The UBFManager transparently handles network reachability, event persistence, and client authentication. Initial creation of the UBFManager will establish the OAuth 2 connection to the Engage service using the credentials that you provide which you received from the Engage portal. UBF events may be immediately posted to the UBFManager even before a successful authentication connection has been established. UBF events that are posted to the manager are simply queued and persisted until the authentication is successful and then they are flushed to Engage. The UBFManager will also queue and persist the events locally if an event is posted while the device does not currently have network reachability. If the application is closed or the device powered down before network reachability has been regained then the events will be posted the next time the application is opened. The local events are durable under all circumstances other than the application being deleted from the device or the SDK user deleting them from the EngageLocalEventStore. 

After initial UBFManager creation you may reference your singleton anytime with
```objective-c
UBFManager *ubfManager = [UBFManager sharedInstance];
```

### UBFManager Operations

The goal of UBFManager is serve the simple purpose of posting UBF Universal Events to Engage while masking the more complicated management tasks such as (network reachability, persistence, and authentication) from the SDK user. 

* tracking UBF events - Posts your individual events to Engage. Local cache is taken into consideration and events are not posted until "ubfEventCacheSize" configuration value is reached. Once that value is reached then the events are batched and sent to Engage to reduce network traffic. You may set the value of "ubfEventCacheSize" if you do not wish for local caching to take palce. 
* handleLocalNotification - 
* handlePushNotificationReceived
* handleNotificationOpened
* handleExternalURLOpened

### XMLAPIManager


## Configuration Values
|Configuration Name|Default Value|Meaning|Format|
|------------------|-------------|-------|------|
|expireLocalEventsAfterNumDays|30 days|Number of days before engage events are purged from local storage|Number|
|databaseListId|<your list id>|Engage Database ListID from Engage Portal|String|
|ubfEventCacheSize|3|Events to cache locally before batch post|Number|
|defaultCurrentCampaignExpiration|1 day|time before current campaign expires by default|EngageExpirationParser String|




## EngageExpirationParser


## Installing SDK
























```objective-c
XMLAPIManager
XMLAPIClient *client = [XMLAPIClient createClient:ENGAGE_CLIENT_ID
                                           secret:ENGAGE_SECRET
                                            token:ENGAGE_REFRESH_TOKEN
                                             host:ENGAGE_BASE_URL];
```


Post an XMLAPI resource using a helper e.g. SelectRecipientData

```objective-c
// create a resource encapsulating your request to select by email address
XMLAPI *selectRecipientData = [XMLAPI selectRecipientData:@"somebody@somedomain.com" list:ENGAGE_LIST_ID];

[[XMLAPIClient client] postResource:selectRecipientData success:^(ResultDictionary *ERXML) {
    // SUCCESS = TRUE
    if ([[ERXML valueForShortPath:@"SUCCESS"] boolValue]) {
        NSLog(@"SUCCESS");
    }
    // SUCCESS != TRUE
    // This is a specific XMLAPI failure, status 2xx
    else {
		NSLog(@"%@",[ERXML valueForShortPath:@"Fault.FaultString"]);
    }
} failure:^(NSError *error) {
    // This is a status > 400 or a failure of connectivity
    NSLog(@"SERVICE FAIL");
}];
```

## Before You Release Your App

### Important Note: Increase Token Limits for Production Apps

There are currently limits placed on the number of Access Tokens that can be generated per hour per instance of Engage.  This number is easily increased, however, before deploying your app publicly, you must contact your Relationship Manager or Sales Rep regarding your intention to use this connector and that you will need to have your OAuth Access Token rate limit increased.

## Demo

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
The first thing you will want to do is contact your Relationship Manager at Silverpop and ask for the "Silverpop Mobile Connector".  They will assist in getting your Engage account provisioned for Universal Behaviors -- the new flexible event tracking system that is the backbone of tracked mobile app behaviors.

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

//Param macros default to the values listed below. You can change them if you wish 
#define CURRENT_CAMPAIGN_PARAM_NAME @"CurrentCampaign"
#define CALL_TO_ACTION_PARAM_NAME @"CallToAction"
#define CAMPAIGN_EXTERNAL_EXPIRATION_DATETIME_PARAM @"CampaignEndTimeStamp"

// if your database uses a unique key different from Recipient/Contact ID
#define ENGAGE_SYNC_COLUMN_NAME (@"YOUR SYNC COLUMN NAME GOES HERE")

// For supporting the merging of anonymous activity with registered users
// merge columns must be created manually with Engage Database portal 
#define ENGAGE_MERGE_COLUMN_NAME (@"YOUR MERGE COLUMN NAME GOES HERE")
```

Configure the defines with your values and save changes and close your project if it is open. 

Open the terminal and open the project folder. 

```
touch Podfile
```

Edit this file to add the EngageSDK dependency

```
pod 'EngageSDK', '~> 0.1'
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
XMLAPI *selectRecipientData = [XMLAPI resourceNamed:@"SelectRecipientData"
                                             params:@{
                               @"LIST_ID" : @"45654",
                               @"EMAIL" : @"someone@adomain.com",
                               @"COLUMNS" : @{ @"Customer Id" : @"123-45-6789" } }];
```

or alternately:

```objective-c
XMLAPI *selectRecipientData = [XMLAPI resourceNamed:@"SelectRecipientData"];
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
XMLAPI *selectRecipientData = [XMLAPI resourceNamed:@"SelectRecipientData" params:@{@"RECIPIENT_ID" : @"702003"}];
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

## Universal Behaviors API

Before connecting and sending Universal Behaviors, you should assume a valid user identity either "anonymous" or some other specified identity via XMLAPI.

### Creating an anonymous user

```objective-c
// Conveniently calls addRecipient and stores anonymousId within EngageConfig
[[XMLAPIClient client] createAnonymousUserToList:ENGAGE_LIST_ID success:^(ResultDictionary *ERXML) {
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

### Identifying a registered user

```objective-c

XMLAPI *selectRecipientData = [XMLAPI selectRecipientData:@"somebody@somedomain.com" list:ENGAGE_LIST_ID];

[[XMLAPIClient client] postResource:selectRecipientData success:^(ResultDictionary *ERXML) {
    if ([[ERXML valueForShortPath:@"SUCCESS"] boolValue]) {
        NSLog(@"SUCCESS");
        // VERY IMPORTANT!!! 
        // Universal Behaviors reads this value
        [EngageConfig storePrimaryUserId:[ERXML valueForShortPath:@"RecipientId"]];
    }
    else {
	NSLog(@"%@",[ERXML valueForShortPath:@"Fault.FaultString"]);
    }
} failure:^(NSError *error) {
    NSLog(@"SERVICE FAIL");
}];
```

### Convert anonymous user to registered user

```objective-c
// Conveniently links anonymous user record with the primary user record according to the mergeColumn
[[XMLAPIClient client] updateAnonymousToPrimaryUser:[EngageConfig primaryUserId]
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

### Sessions

EngageSDK implements predefined Session events for Universal Behaviors. Sessions are configured to timeout if a user leaves your app for at least 5 minutes. At the end of the Session, duration is computed excluding any portion of inactivity.

### Logging to events cache

#### Goal Completed
```objective-c
[[UBFClient client] trackingEvent:[UBF goalCompleted:@"LISTENED TO MVSTERMIND" params:nil]];
```

#### Goal Abandoned
```objective-c
[[UBFClient client] trackingEvent:[UBF goalAbandoned:@"LISTENED TO MVSTERMIND" params:nil]];
```

#### Named Event with params
```objective-c
[[UBFClient client] trackingEvent:[UBF namedEvent:@"PLAYER LOADED" params:@{ @"Event Source View" : @"HomeViewController", @"Event Tags" : @"MVSTERMIND,Underground" }]];
```

#### Notifications
Both local and push notifications require that the user of the SDK enable their application for subscribing and listening for the notifications. These hooks for the notifications are defined inside your application's UIApplicationDelegage (AppDelegate) implementation class. Full reference for those hooks can be found [here] (https://developer.apple.com/library/ios/documentation/uikit/reference/uiapplicationdelegate_protocol/Reference/Reference.html#//apple_ref/occ/intfm/UIApplicationDelegate). Examples of using the local and push notification hooks are found below.

#### Local Notification Received
```objective-c
- (void)application:(UIApplication *)application didReceiveLocalNotification:(UILocalNotification *)notification
{
    [[UBFManager sharedInstance] handleLocalNotificationReceivedEvents:notification withParams:nil];
}
```

#### Push Notification Received
```objective-c
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)pushNotification 
{
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
[[UBFClient client] postEventCache];
```

### Further Questions, Issues, or Comments?
We have setup a [forum on our Silverpop Community](http://community.silverpop.com/t5/Silverpop-Mobile-Connector/bd-p/Mobile) for fostering collaboration in both sharing success stories and tackling problems together.  We invite you to share your thoughts, questions, and stories there.
