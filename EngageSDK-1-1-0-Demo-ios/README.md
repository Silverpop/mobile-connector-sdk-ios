Sample app that uses the new features to manage the mobile identity in version 1.1.0 of the EngageSDK.

## Demo Environment
In addition to the normal app security token configuration, the following setup must be configured prior to 
using the ```MobileIdentityManager``` methods.
- Recipient list should already be created and the ```listId``` should be setup in the configuration.
- EngageConfig.json should be configured with the columns names representing the _Mobile User Id_, _Merged Recipient Id_, and _Merged Date_.  The EngageConfigDefault.json defines default values if you prefer to use those.
- The _Mobile User Id_, _Merged Recipient Id_, and _Merged Date_ columns must be created in the recipient list with names that match your EngageConfig.json settings
- Optional: If you prefer to save the merge history in a separate AuditRecord relational table you can 
set ```mergeHistoryInAuditRecordTable``` to ```YES```.  If enabled you are responsible for creating the AuditRecord
 table with the columns for _Audit Record Id_, _Old Recipient Id_, _New Recipient Id_, and _Create Date_ and you must manually set the audit record table id in the app.

Most people will want to use the default settings and save the merge history in the recipient list instead of a seprate Audit Record list, but for demo purposes this app has been configured to save the merge history in both places.

The environment used by the demo app has already been configured with needed lists and columns.  If you switch to use your own credentials you are responsible for setting up your own environment.

Before running the app the following 

## Using the demo app
When the app is run the current recipient configuration is automatically cleared.

You can use the 'Setup Recipient' button to configure the identity of the mobile device.

Then you can choose one of the following Scenarios to test out:
* Scenario 1 - There is no existing recipient on the server
* Scenario 2 - There is an existing recipient on the server, but it doesn't have a mobile user id.
* Scenario 3 - There is an existing recipient on the server and it does have a mobile user id.

After selecting your scenario, you can click the 'Check Identity' button and the identity of the mobile device will be updated based on the scenario.


