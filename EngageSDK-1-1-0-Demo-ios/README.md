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

## Running the Demo
When the app is run the current recipient configuration is automatically cleared.

You can use the 'Setup Recipient' button to configure the identity of the mobile device.

Then you can choose one of the following Scenarios to test out:
* [Scenario 1](#scenario1) - There is no existing recipient on the server
* [Scenario 2](#scenario2) - There is an existing recipient on the server, but it doesn't have a mobile user id.
* [Scenario 3](#secnario3) - There is an existing recipient on the server and it does have a mobile user id.

After selecting your scenario, you can click the 'Check Identity' button and the identity of the mobile device will be updated based on the scenario.

Once you've completed a scenario, you can click the 'Clear Config' button to try a different scenario.

## Expected Behavior

Here is some sample data for the different scenarios.  Obviously the data in these examples will not match the once in the app since it is generating new data every time.  The other obvious differece is that the example app is using a column called 'Custom Integration Test Column Id' instead of 'Facebook Id.' 

### <a name="scenario1"/>Scenario 1
Description: There is no existing recipient on the server

####Example behavior
_Recipient Before_

|Recipient Id|Mobile User Id|Facebook Id|Merged Recipient Id|Merged Date|
|----------|----------|----------|----------|----------|
|100001|123132-12312-1|nil|||
||||||

_Connector Configuration Before_

|Mobile User Id|Recipient Id|
|----------|----------|
|123132-12312-1|100001|

_Recipient After_

|Recipient Id|Mobile User Id|Facebook Id|Merged Recipient Id|Merged Date|
|----------|----------|----------|----------|----------|
|100001|123132-12312-1|*100*|||

_Connector Configuration After_

|Mobile User Id|Recipient Id|
|----------|----------|
|123132-12312-1|100001|

### <a name="scenario2"/>Scenario 2
Description: There is an existing recipient on the server, but it doesn't have a mobile user id.

_Recipient Before_

|Recipient Id|Mobile User Id|Facebook Id|Merged Recipient Id|Merged Date|
|----------|----------|----------|----------|----------|
|100001|123132-12312-1|nil|||
|100000||100|||

_Connector Configuration Before_

|Mobile User Id|Recipient Id|
|----------|----------|
|123132-12312-1|100001|

_Recipient After_

|Recipient Id|Mobile User Id|Facebook Id|Merged Recipient Id|Merged Date|
|----------|----------|----------|----------|----------|
|100001|*nil*|nil|*100000*|*now*|
|100000|*123132-12312-1*|100|||

_Connector Configuration After_

|Mobile User Id|Recipient Id|
|----------|----------|
|123132-12312-1|*100000*|

_Audit Record (if using)_

|Primary Key|Old Recipient Id|New Recipient Id|Create Date|
|----------|----------|----------|----------|
|*1*|*100001*|*100000*|*now*|

### <a name="scenario3"/>Scenario 3
Description: There is an existing recipient on the server and it does have a mobile user id.

_Recipient Before_

|Recipient Id|Mobile User Id|Facebook Id|Merged Recipient Id|Merged Date|
|----------|----------|----------|----------|----------|
|100001|123132-12312-1|nil|||
|100000|22222-121121-1|100|||

_Connector Configuration Before_

|Mobile User Id|Recipient Id|
|----------|----------|
|123132-12312-1|100001|

_Recipient After_

|Recipient Id|Mobile User Id|Facebook Id|Merged Recipient Id|Merged Date|
|----------|----------|----------|----------|----------|
|100001|123132-12312-1|nil|*100000*|*now*|
|100000|22222-121121-1|100|||

_Connector Configuration After_

|Mobile User Id|Recipient Id|
|----------|----------|
|*22222-121121-1*|*100000*|

_Audit Record (if using)_

|Primary Key|Old Recipient Id|New Recipient Id|Create Date|
|----------|----------|----------|----------|
|*1*|*100001*|*100000*|*now*|
