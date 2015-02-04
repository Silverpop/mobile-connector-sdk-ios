//
//  ViewController.h
//  EngageSDK-1-1-0-Demo-ios
//
//  Created by Lindsay Thurmond on 1/30/15.
//  Copyright (c) 2015 Silverpop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIButton *clearConfigButton;
@property (weak, nonatomic) IBOutlet UILabel *currentConfigLabel;

@property (weak, nonatomic) IBOutlet UIButton *seupRecipientButton;

@property (weak, nonatomic) IBOutlet UIButton *setupScenario1Button;
@property (weak, nonatomic) IBOutlet UIButton *setupScenario2Button;
@property (weak, nonatomic) IBOutlet UIButton *setupScenario3Button;
@property (weak, nonatomic) IBOutlet UITextField *customIdColumnNameField;
@property (weak, nonatomic) IBOutlet UITextField *customIdValueField;
@property (weak, nonatomic) IBOutlet UIButton *checkIdentityButton;

-(IBAction)clearConfig:(id)sender;
-(IBAction)setupRecipient:(id)sender;


-(IBAction)setupScenario1:(id)sender;
-(IBAction)setupScenario2:(id)sender;
-(IBAction)setupScenario3:(id)sender;
-(IBAction)checkIdentity:(id)sender;

@end

