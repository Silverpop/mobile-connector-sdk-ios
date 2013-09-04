engage-sdk-ios
==============

Silverpop Engage SDK for iOS (a.k.a. the "Silverpop Mobile Connector")

## Simple Engage Database wrapper for iOS 

EngageSDK is a Engage API wrapper library for iOS development.
The goal is to provide a library that is simple to setup and use for communicating remotely with our Silverpop Engage Database system.


## Features

EngageSDK is a wrapper for the Engage Database XMLAPI and JSON Univeral Events. Before you can post any data, you must create a client configured with your OAuth 2 credentials provided by the Engage Portal.

```objective-c
XMLAPIClient *client = [XMLAPIClient createClient:ENGAGE_CLIENT_ID
                                           secret:ENGAGE_SECRET
                                            token:ENGAGE_REFRESH_TOKEN
                                             host:ENGAGE_BASE_URL];
```

Once you have configured your client, you should connect to the Engage OAuth 2 provider.

```objective-c
[client connectSuccess:^(AFOAuthCredential *credential) {
    NSLog(@"SUCCESS");
} failure:^(NSError *error) {
    NSLog(@"FAIL");
}];
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
#define ENGAGE_BASE_URL (@"YOUR ENGAGE POD OR PILOT URL")
#define ENGAGE_CLIENT_ID (@"YOUR CLIENT ID GOES HERE")
#define ENGAGE_SECRET (@"YOUR SECRET GOES HERE")
#define ENGAGE_REFRESH_TOKEN (@"YOUR REFRESH TOKEN HERE")
#define ENGAGE_LIST_ID (@"YOUR LIST ID")

// if your database uses a unique key different from Recipient/Contact ID
#define ENGAGE_SYNC_COLUMN (@"YOUR SYNC COLUMN NAME GOES HERE")

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

### Posting events to Universal Behaviors service

Events are cached and sent in larger batches for efficiency. The timing of the automated dispatches varies but usually occur when the app is sent to the background. If you would like to control when events are posted, you can tell the UBFClient to post any cached events.

#### Manually post all events in cache
```objective-c
[[UBFClient client] postEventCache];
```

### Further Questions, Issues, or Comments?
We have setup a [forum on our Silverpop Community](http://community.silverpop.com/t5/Silverpop-Mobile-Connector/bd-p/Mobile) for fostering collaboration in both sharing success stories and tackling problems together.  We invite you to share your thoughts, questions, and stories there.
