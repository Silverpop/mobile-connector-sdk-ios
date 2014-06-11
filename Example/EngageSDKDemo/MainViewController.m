//
//  MainViewController.m
//  EngageSDKDemo
//
//  Created by Musa Siddeeq on 8/11/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "MainViewController.h"
#import "MenuViewController.h"
#import <MBProgressHUD/MBProgressHUD.h>
#import <ECSlidingViewController/ECSlidingViewController.h>
#import <EngageSDK/EngageSDK.h>

@interface MainViewController ()

@end

@implementation MainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    self.view.layer.shadowOpacity = 0.75f;
    self.view.layer.shadowRadius = 10.0f;
    self.view.layer.shadowColor = [UIColor blackColor].CGColor;
    
    
    if (![self.slidingViewController.underLeftViewController isKindOfClass:[MenuViewController class]]) {
        self.slidingViewController.underLeftViewController  = [self.storyboard instantiateViewControllerWithIdentifier:@"Menu"];
    }
    
    
    [self.view addGestureRecognizer:self.slidingViewController.panGesture];
    
    
    self.menuBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _menuBtn.frame = CGRectMake(8, 10, 34, 24);
    [_menuBtn setBackgroundImage:[UIImage imageNamed:@"menuButton.png"] forState:UIControlStateNormal];
    [_menuBtn addTarget:self action:@selector(revealMenu:) forControlEvents:UIControlEventTouchUpInside];
    
    
    [self.view addSubview:self.menuBtn];
    
    
    if (![XMLAPIClient client] || ![UBFClient client]) {
        [self engageConnect];
    }
    else {
        if ([EngageConfig primaryUserId] && ![[EngageConfig primaryUserId] isEqualToString:@"_UNKNOWN_"]) {
            [self selectEmailData:[EngageConfig primaryUserId]];
            _upgradeAnonymousButton.hidden = YES;
        }
        else {
            [self selectRecipientData:[EngageConfig anonymousId]];
            _upgradeAnonymousButton.hidden = NO;
        }
    
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - ECSlide stuff

- (IBAction)revealMenu:(id)sender
{
    [self.slidingViewController anchorTopViewTo:ECRight];
    
    MenuViewController *mvc = (MenuViewController *)self.slidingViewController.underLeftViewController;
    [mvc.tableView reloadData];
}

#pragma mark - Engage

- (void)engageConnect {
    [self beginHUD];
    
    [EngageConfig storePrimaryUserId:nil];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

- (void)postSelectRecipientData:(XMLAPI *)resource {
    [self beginHUD];
    [[XMLAPIClient client] postResource:resource success:^(ResultDictionary *ERXML) {
        
        // format string
        NSString *recipientFormat = @""
        "Recipient Id:\n%@\n"
        "Last Modified:\n%@\n"
        "Opted In:\n%@";
        
        if ([[ERXML valueForShortPath:@"SUCCESS"] boolValue]) {
            MenuViewController *mvc = (MenuViewController *)self.slidingViewController.underLeftViewController;
            mvc.ERXML = ERXML;
            
            NSLog(@"SelectRecipientData\n\n\n%@\n\n\n",[ERXML description]);
            
            NSString *userInfo =
            [NSString stringWithFormat:recipientFormat,
             [ERXML valueForShortPath:@"RecipientId"],
             [ERXML valueForShortPath:@"LastModified"],
             [ERXML valueForShortPath:@"OptedIn"]];
            
            _emailAddressField.text = [ERXML valueForShortPath:@"Email"];
            [_userInfo setText:userInfo];
            
            [self updateHUD:@"Success" details:[ERXML valueForShortPath:@"Email"]];

            [[UBFManager sharedInstance] trackEvent:[UBF goalCompleted:@"SELECTED REGISTERED USER" params:nil]];
        }
        else {
            [self updateHUD:@"Failed" details:[ERXML valueForShortPath:@"Fault.FaultString"]];
            [[UBFManager sharedInstance] trackEvent:[UBF goalAbandoned:@"SELECTED REGISTERED USER" params:nil]];
        }
        
    } failure:^(NSError *error) {
        [self updateHUD:@"Failed" details:@"Service is unavailable"];
    }];
}

- (void)selectRecipientData:(NSString *)recipientId {
    XMLAPI *anonymous = [XMLAPI resourceNamed:@"SelectRecipientData"];
    [anonymous addParams:@{ @"LIST_ID" : ENGAGE_LIST_ID, @"RECIPIENT_ID" : recipientId }];
    [self postSelectRecipientData:anonymous];
}

- (void)selectEmailData:(NSString *)userEmail {
    XMLAPI *registeredUser = [XMLAPI selectRecipientData:userEmail list:ENGAGE_LIST_ID];
    [self postSelectRecipientData:registeredUser];
}

- (void)registerAnonymousUser {
    
    if ([EngageConfig anonymousId] && ![[EngageConfig anonymousId] isEqualToString:@"_UNKNOWN_"])
    {
        [self selectRecipientData:[EngageConfig anonymousId]];
        return;
    }
    
    [self beginHUD];
    
    [[XMLAPIManager sharedInstance] createAnonymousUserToList:ENGAGE_LIST_ID success:^(ResultDictionary *ERXML) {
        if ([[ERXML valueForShortPath:@"SUCCESS"] boolValue]) {
            [self updateHUD:@"Success" details:[ERXML valueForShortPath:@"RecipientId"]];
            
            [self selectRecipientData:[ERXML valueForShortPath:@"RecipientId"]];
        }
        else {
            [self updateHUD:@"Failed" details:[ERXML valueForShortPath:@"Fault.FaultString"]];
        }
    } failure:^(NSError *error) {
        [self updateHUD:@"Failed" details:@"Service is unavailable"];
    }];
}


- (IBAction)upgradeAnonymousUser:(id)sender {
    
    if (!_emailAddressField.text || [_emailAddressField.text isEqualToString:@""]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Oops!"
                                                        message:@"Please specify a user first"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        [self beginHUD];
        
        [EngageConfig storePrimaryUserId:_emailAddressField.text];
        
        // updateAnonymousToPrimaryUser
        [[XMLAPIManager sharedInstance] updateAnonymousToPrimaryUser:[EngageConfig primaryUserId]
                                                       list:ENGAGE_LIST_ID
                                          primaryUserColumn:@"Email"
                                                mergeColumn:@"MERGE_CONTACT_ID"
                                                    success:^(ResultDictionary *ERXML) {
                                                        if ([[ERXML valueForShortPath:@"SUCCESS"] boolValue]) {
                                                            [self updateHUD:@"Success" details:[ERXML valueForShortPath:@"RecipientId"]];
                                                            
                                                            [self selectRecipientData:[ERXML valueForShortPath:@"RecipientId"]];
                                                            
                                                            _upgradeAnonymousButton.hidden = YES;
                                                            
                                                            [[UBFManager sharedInstance] trackEvent:[UBF goalCompleted:@"UPGRADE ANONYMOUS USER" params:nil]];
                                                        }
                                                        else {
                                                            NSLog(@"%@",[ERXML debugDescription]);
                                                            [self updateHUD:@"Failed" details:[ERXML valueForShortPath:@"Fault.FaultString"]];
                                                            [[UBFManager sharedInstance] trackEvent:[UBF goalAbandoned:@"UPGRADE ANONYMOUS USER" params:nil]];
                                                        }
                                                    } failure:^(NSError *error) {
                                                        [self updateHUD:@"Failed" details:@"Service is unavailable"];
                                                    }];
    }
}

#pragma mark - MBProgressHUD


- (void)beginHUD {
    if ([MBProgressHUD HUDForView:self.view]) return;
    [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
}

- (void)updateHUD:(NSString *)message details:(NSString *)details {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    MBProgressHUD *hud = [MBProgressHUD HUDForView:self.view];
    hud.mode = MBProgressHUDModeText;
    hud.labelText = message;
    hud.detailsLabelText = details;
    
    NSLog(@"%@ \n\t Details: %@",message,details);
    
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 0.8 * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        // Do something...
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });
}

@end
