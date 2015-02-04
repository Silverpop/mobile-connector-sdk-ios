//
//  ViewController.m
//  EngageSDK-1-1-0-Demo-ios
//
//  Created by Lindsay Thurmond on 1/30/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import "ViewController.h"
#import "sample_config.h"
#import <EngageSDK/EngageSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>


@interface ViewController ()

@end

@implementation ViewController

static NSString * const CUSTOM_ID_COLUMN = @"Custom Integration Test Id";

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    [self updateCurrentConfig];
    
    [self updateCheckIdentityEnabledState];
    
    [_customIdColumnNameField setText:CUSTOM_ID_COLUMN];
    
    [_customIdColumnNameField setEnabled:NO];
    [_customIdValueField setEnabled:NO];
    
    [self clearCurrentConfig];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)updateScreen {
    [self updateCurrentConfig];
    [self updateCheckIdentityEnabledState];
}

-(void)disableSetupButtons {
    [_setupScenario1Button setEnabled:NO];
    [_setupScenario2Button setEnabled:NO];
    [_setupScenario3Button setEnabled:NO];
}

- (void) updateCurrentConfig {
    NSString *recipientId = [EngageConfig recipientId];
    if ([recipientId length] == 0) {
        recipientId = @"[undefined]";
    }
    NSString *mobileUserId = [EngageConfig mobileUserId];
    if ([mobileUserId length] == 0) {
        mobileUserId = @"[undefined]";
    }
    
    NSString *currentConfig = [NSString stringWithFormat:@"Recipient Id:\n%@\nMobile User Id:\n%@", recipientId, mobileUserId];
    
    [_currentConfigLabel setText:currentConfig];
}

-(void) updateCheckIdentityEnabledState {
    BOOL checkIdentityEnabled = [[EngageConfig recipientId] length] > 0 && [[EngageConfig mobileUserId] length] > 0;
    
    [_setupScenario1Button setEnabled:checkIdentityEnabled];
    [_setupScenario2Button setEnabled:checkIdentityEnabled];
    [_setupScenario3Button setEnabled:checkIdentityEnabled];
    [_checkIdentityButton setEnabled:checkIdentityEnabled];
}

-(IBAction)clearConfig:(id)sender {
    [self clearCurrentConfig];
}

-(void) clearCurrentConfig {
    [EngageConfig storeMobileUserId:@""];
    [EngageConfig storeRecipientId:@""];
    [EngageConfig storeAnonymousId:@""];
    
    [_customIdValueField setText:@""];
    
    [self updateScreen];
}

-(IBAction)setupRecipient:(id)sender {
    
    [self beginHUD];
    
    [[MobileIdentityManager sharedInstance] setupRecipientWithSuccess:^(SetupRecipientResult *result) {
        
        NSString *messageFormat = @"Recipient Id: %@\nMobile User Id: %@";
        
        [self updateHUDWithMessage:@"Success" details:[NSString stringWithFormat:messageFormat, [result recipientId], [EngageConfig mobileUserId]]];
        
        [self updateScreen];
        
        
    } failure:^(SetupRecipientFailure *failure) {
        [self updateHUDWithMessage:@"Error" details:[failure errorMessage]];
        [self updateScreen];
    }];
    
}

-(IBAction)setupScenario1:(id)sender {
    
    // set custom id to one that won't exist
    [_customIdValueField setText:[[EngageDefaultUUIDGenerator new] generateUUID]];
    
    [self disableSetupButtons];
    
}

-(IBAction)setupScenario2:(id)sender {
    
    [self beginHUD];
    
    // setup recipient on server with recipientId and mobileUserId set
    
    NSString *customId = [[EngageDefaultUUIDGenerator new] generateUUID];
    
    // setup existing recipient on server with custom id but not a mobile user id
    
    XMLAPI *addRecipientwithCustomIdXml = [XMLAPI addRecipientWithMobileUserIdColumnName:CUSTOM_ID_COLUMN mobileUserId:customId list:ENGAGE_LIST_ID];
    [[XMLAPIManager sharedInstance] postXMLAPI:addRecipientwithCustomIdXml success:^(ResultDictionary *addRecipientWithCustomIdResult) {
        NSString *createdWithCustomId_RecipientId = [addRecipientWithCustomIdResult recipientId];
        
        // we now have 2 recipients configured as:
        // recipientId | mobileUserId | customId
        //    value    |     value    |             - previously created by setup recipient
        //    value    |              |  value      - just created
        
        NSString *messageFormat = @"Setup existing recipient.\nRecipient id: %@\nCustom id: %@";
        
        NSString *successMessage = [NSString stringWithFormat:messageFormat, createdWithCustomId_RecipientId, customId];
        
        NSLog(@"Scenario 2 Successful setup");
        NSLog(@"%@", successMessage);
        
        [_customIdValueField setText:customId];
        [self disableSetupButtons];
        
        [self updateHUDWithMessage:@"Success" details:successMessage];
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        [self updateHUDWithMessage:@"Setup Scenario 2 ERROR" details:[error description]];
    }];
}

-(IBAction)setupScenario3:(id)sender {
    
    [self beginHUD];
    
    NSString *customId = [[EngageDefaultUUIDGenerator new] generateUUID];
    NSString *existingMobileUserId = [[EngageDefaultUUIDGenerator new] generateUUID];
    
    // setup existing recipient on server with custom id(s) and a different mobileUserId
    XMLAPI *addRecipientWithCustomIdXml = [XMLAPI addRecipientWithMobileUserIdColumnName:[[EngageConfigManager sharedInstance] recipientMobileUserIdColumn] mobileUserId:existingMobileUserId list: ENGAGE_LIST_ID];
    [addRecipientWithCustomIdXml addColumn:CUSTOM_ID_COLUMN :customId];
    
    
    [[XMLAPIManager sharedInstance] postXMLAPI:addRecipientWithCustomIdXml success:^(ResultDictionary *addRecipientResult) {
        NSString *createdWithCustomId_RecipientId = [addRecipientResult recipientId];
        
        // we now have 2 recipients configured as:
        // recipientId | mobileUserId | customId
        //    value    |     value    |             - previously created by setup recipient
        //    value    |     value    |  value      - just created
        
        NSString *messageFormat = @"Setup existing recipient.\nRecipient id: %@\nMobile User id: %@\nCustom id: %@";
        
        NSString *successMessage = [NSString stringWithFormat:messageFormat, createdWithCustomId_RecipientId, existingMobileUserId, customId];
        
        NSLog(@"Scenario 3 Successful setup");
        NSLog(@"%@", successMessage);
        
        [_customIdValueField setText:customId];
        [self disableSetupButtons];
        
        [self updateHUDWithMessage:@"Success" details:successMessage];
        
    } failure:^(NSError *error) {
        NSLog(@"%@", error);
        [self updateHUDWithMessage:@"Setup Scenario 3 ERROR" details:[error description]];
    }];
}

-(IBAction)checkIdentity:(id)sender {
    
    [self beginHUD];
    
    NSString *customFieldName = [_customIdColumnNameField text];
    NSString *customFieldValue = [_customIdValueField text];
    
    [[MobileIdentityManager sharedInstance] checkIdentityForIds:@{ customFieldName : customFieldValue } success:^(CheckIdentityResult *result) {
        
        NSString *newRecipientId = [result recipientId];
        NSString *mergedRecipientId = [result mergedRecipientId];
        NSString *mobileUserId = [result mobileUserId];
        
        NSString *messageFormat = @"Current recipient id: %@\nMerged recipient id: %@\nMobile user id: %@";
        
        [self updateHUDWithMessage:@"Success" details:[NSString stringWithFormat:messageFormat, newRecipientId, mergedRecipientId, mobileUserId]];
        
        [self updateCurrentConfig];
        
    } failure:^(CheckIdentityFailure *failure) {
        
        [self updateHUDWithMessage:@"Error" details:[failure message]];
    }];
    
}

#pragma mark - MBProgressHUD


- (void)beginHUD {
    if ([MBProgressHUD HUDForView:self.view]) return;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)updateHUDWithMessage:(NSString *)message details:(NSString *)details {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.detailsLabelText = details;
    
    NSLog(@"%@ \n\t Details: %@",message,details);
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 2.5 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

@end
