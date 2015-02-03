# Android Managing Mobile Identity Script

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


1. Open ```activity_main.xml```
2. In the Design tab set the ```id``` of the Hello World ```TextView``` to ```currentConfigView```
3. Set the ```minLines``` property to 5
4. Set the ```layoutWidth``` to ```match_parent```
3. Change to Text tab and verify you changed the correct settings
4. Change the 'Hello World' text to say 'Current Config:'
5. Add 'Setup Recipient' button with ```setupRecipientBtn``` as the id
6. Add 'Check Identity' button with ```checkIdentityBtn``` as the id


### Add Functionality
3. Open ```MainActivity.java``` and update it with the following
```java
@Override
protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_main);

    Button setupRecipientBtn = (Button)findViewById(R.id.setupRecipientBtn);
    setupRecipientBtn.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            MobileIdentityManager.get().setupRecipient(new SetupRecipientHandler() {
                @Override
                public void onSuccess(SetupRecipientResult setupRecipientResult) {
                    updateConfigStatus();
                    Toast.makeText(getApplicationContext(), "Success", Toast.LENGTH_SHORT).showToast();
                }

                @Override
                public void onFailure(SetupRecipientFailure setupRecipientFailure) {
                    Toast.makeText(getApplicationContext(), "ERROR", Toast.LENGTH_SHORT).showToast();
                }
            });
        }
    });

    Button checkIdentityBtn = (Button)findViewById(R.id.checkIdentityBtn);
    checkIdentityBtn.setOnClickListener(new View.OnClickListener() {
        @Override
        public void onClick(View v) {
            Map<String, String> ids = new HashMap<String, String>();
            ids.put("Custom Integration Test Id", "09890809809");
            MobileIdentityManager.get().checkIdentity(ids, new CheckIdentityHandler() {
                @Override
                public void onSuccess(CheckIdentityResult checkIdentityResult) {
                    Toast.makeText(getApplicationContext(), "Check identity success", Toast.LENGTH_SHORT).showToast();
                }

                @Override
                public void onFailure(CheckIdentityFailure checkIdentityFailure) {
                    Toast.makeText(getApplicationContext(), "ERROR", Toast.LENGTH_SHORT).showToast();
                }
            });
        }
    });
}

private void updateConfigStatus() {
    TextView config = (TextView)findViewById(R.id.configStatusText);
    config.setText(String.format("Config\nRecipient Id:\n%s\nMobile User Id\n%s",
            EngageConfig.recipientId(getApplicationContext()),
            EngageConfig.mobileUserId(getApplicationContext())));
}
```

### Run App
1. Click the run button and wait for the emulator to start
2. Click Setup recipient and wait for the config to change
3. Click Check Identity
