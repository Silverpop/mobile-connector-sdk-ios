//
//  MenuViewController.m
//  EngageSDKDemo
//
//  Created by Musa Siddeeq on 8/11/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "MenuViewController.h"
#import "ColumnDataCell.h"
#import <ECSlidingViewController/ECSlidingViewController.h>
#import <EngageSDK/EngageSDK.h>
#import <MBProgressHUD/MBProgressHUD.h>

#define SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([[[UIDevice currentDevice] systemVersion] compare:v options:NSNumericSearch] != NSOrderedAscending)

@interface MenuViewController ()

@end

@implementation MenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    [self.slidingViewController setAnchorRightRevealAmount:270.0f];
    self.slidingViewController.underLeftWidthLayout = ECFullWidth;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [super tableView:tableView cellForRowAtIndexPath:indexPath];
    ColumnDataCell *colCell;
    
    if (indexPath.section == 1 && indexPath.row == 0) {
        colCell = (ColumnDataCell *)cell;
        colCell.colNameLabel.text = @"First";
        colCell.colDataField.text = [_ERXML valueForShortPath:@"columns.firstName"];
    }
    if (indexPath.section == 1 && indexPath.row == 1) {
        colCell = (ColumnDataCell *)cell;
        colCell.colNameLabel.text = @"Last";
        colCell.colDataField.text = [_ERXML valueForShortPath:@"columns.lastName"];
    }
    if (indexPath.section == 1 && indexPath.row == 2) {
        colCell = (ColumnDataCell *)cell;
        colCell.colNameLabel.text = @"Member";
        if (SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"6.0"))
        {
            [colCell.colDataSwitch setOnImage: [UIImage imageNamed:@"UISwitch-Yes"]];
            [colCell.colDataSwitch setOffImage:[UIImage imageNamed:@"UISwitch-No"]];
        }
        
        [colCell.colDataSwitch setOn:[[_ERXML valueForShortPath:@"columns.activeMember"] boolValue]];
    }
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
    
    if (indexPath.section == 0 && indexPath.row == 0) {
        [self updateRecipient];
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)reloadMain {
    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"Main"];
    
    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
        CGRect frame = self.slidingViewController.topViewController.view.frame;
        self.slidingViewController.topViewController = newTopViewController;
        self.slidingViewController.topViewController.view.frame = frame;
        [self.slidingViewController resetTopView];
    }];
}

#pragma mark - MBProgressHUD


- (void)beginHUD {
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

#pragma mark - EngageSDK

- (void)updateRecipient {
    if (!_ERXML) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No recipient data"
                                                        message:@"You must first retrieve recipient data."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    else {
        [self beginHUD];
        
        NSLog(@"UpdateRecipient\n\n\n%@\n\n\n",[_ERXML description]);
        
        // updaterecipient
        XMLAPI *updateRecipient = [XMLAPI updateRecipient:[_ERXML valueForShortPath:@"RecipientId"] list:ENGAGE_LIST_ID];
        [updateRecipient addColumns:@{ @"firstName" : _firstNameField.text } ];
        [updateRecipient addColumns:@{ @"lastName" : _lastNameField.text } ];
        [updateRecipient addColumns:@{ @"activeMember" : _activeMemberSwitch.on ? @"Yes" : @"No" } ];
        [[XMLAPIClient client] postResource:updateRecipient success:^(ResultDictionary *ERXML) {
            if ([[ERXML valueForShortPath:@"SUCCESS"] boolValue]) {
                [self updateHUD:@"Success" details:[ERXML valueForShortPath:@"RecipientId"]];
                
                [self reloadMain];
                
                [[UBFManager sharedInstance] trackEvent:[UBF goalCompleted:@"UPDATE RECIPIENT" params:nil]];
                [[UBFManager sharedInstance] postEventCache];
            }
            else {
                NSLog(@"%@",[ERXML debugDescription]);
                [self updateHUD:@"Failed" details:[ERXML valueForShortPath:@"Fault.FaultString"]];
                [[UBFManager sharedInstance] trackEvent:[UBF goalAbandoned:@"UPDATE RECIPIENT" params:nil]];
            }
        } failure:^(NSError *error) {
            [self updateHUD:@"Failed" details:@"Service is unavailable"];
        }];
    }
}

@end
