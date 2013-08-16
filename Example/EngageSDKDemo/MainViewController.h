//
//  MainViewController.h
//  EngageSDKDemo
//
//  Created by Musa Siddeeq on 8/11/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController

@property (strong, nonatomic) UIButton *menuBtn;
- (IBAction)upgradeAnonymousUser:(id)sender;
@property (weak, nonatomic) IBOutlet UITextView *userInfo;
@property (weak, nonatomic) IBOutlet UITextField *emailAddressField;
@property (weak, nonatomic) IBOutlet UIButton *upgradeAnonymousButton;


@end
