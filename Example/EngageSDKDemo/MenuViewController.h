//
//  MenuViewController.h
//  EngageSDKDemo
//
//  Created by Musa Siddeeq on 8/11/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <EngageSDK/EngageSDK.h>

@interface MenuViewController : UITableViewController

@property ResultDictionary *ERXML;
@property (weak, nonatomic) IBOutlet UITextField *firstNameField;
@property (weak, nonatomic) IBOutlet UITextField *lastNameField;
@property (weak, nonatomic) IBOutlet UISwitch *activeMemberSwitch;

@end
