# iOS Managing Mobile Identity Script

## Setup Before Video

The following steps are covered in the Up and Running Demo so we can go ahead and set them up before starting the new video.
1. Created a new project with a single view
2. Created a podfile with Engage SDK dependencies (and also a progress bar library MBProgressHUD)
3. pod install
4. Added ```initializeSDKClient``` code to ```AppDelegate.m```
6. Added ```sample_config.h``` header file
7. Added custom ```EngageConfig.plist```

## Video Starts Here

### Intro Script
Today we are going to demonstrate configuring mobile idenities using the Android Engage SDK.  We are making the assumption that you've already watched the Android Up And Running video so we're going to jump right in.

I've already configured my new XCode project with the needed configuration settings (show them).

1. Created a new project with a single view
2. Created a podfile with Engage SDK dependencies (and also a progress bar library MBProgressHUD)
3. pod install
4. Added ```initializeSDKClient``` code to ```AppDelegate.m```
6. Added ```sample_config.h``` header file
7. Added custom ```EngageConfig.plist```

But before we can add the new functionality there are a few things you need to Setup on the silverpop side.  The first is that you'll need to configure your recipient lists with columns for 
- Mobile User Id
- Merged Recipient Id
- Merged Date

You also have the option for creating a separate AuditRecord table if you'd prefer to track recipient merge history there.  You'll need to set that up with columns for 
- Audit Record Id
- Old Recipient Id
- New Recipient Id
- Create Date
if you wish to use that.  If you any help with this configuration please contact Silverpop support.

You'll also need to have your recipient table pre-configured with any custom id columns you wish - facebook_id, etc.

My recipient table is currently setup with a custom id column called "Custom Integration Test Id" so that's what I'm going to use for the demo.

### Setup UI
1. Open ```Main.storyboard```
2. Add label for config - and set for leading and trailing spaces
3. Add button for Setup Recipient - place in center don't bother with other alignment
4. Add button for Check Identity - place in center don't bother with other alignment
5. Open Assistant Editor (circle icon in top right corner)
6. Ctrl + drag all three components to interface


### Add Functionality
1.  Close assistant editor and navigate to ```ViewController.m```
2. Add the following to the ```ViewController.h```
```objective-c
-(IBAction) setupRecipient:(id)sender;
-(IBAction)checkIdentity:(id)sender;
```

3. Add the following to ```ViewController.m```
```objective-c
-(void)updateConfigLabel {
    
    NSString *currentConfig = [NSString stringWithFormat:@"Recipient Id:\n%@\nMobile User Id:\n%@", [EngageConfig recipientId], [EngageConfig mobileUserId]];
    
    [_configLabel setText:currentConfig];
    
}

-(IBAction) setupRecipient:(id)sender {
    
    [[MobileIdentityManager sharedInstance] setupRecipientWithSuccess:^(SetupRecipientResult *result) {
        
        [self updateConfigLabel];
        
    } failure:^(SetupRecipientFailure *failure) {
        NSLog(@"Setup Recipient Error");
    }];
}

-(IBAction)checkIdentity:(id)sender {
    
    [[MobileIdentityManager sharedInstance] checkIdentityForIds:@{ @"Custom Integration Test Id" : @"98798798798" } success:^(CheckIdentityResult *result) {
        
        NSLog(@"Check Identity Success");
        [self updateConfigLabel];
        
    } failure:^(CheckIdentityFailure *failure) {
        NSLog(@"Check Identity Failure");
    }];
    
}
```
1. Open ```Main.storyboard```, open the assistant editor, and connect the methods to the buttons


### Run App
1. Click the run button and wait for the emulator to start
2. Click Setup recipient and wait for the config to change
3. Click Check Identity
