//
//  ColumnDataCell.h
//  EngageSDKDemo
//
//  Created by Musa Siddeeq on 8/11/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ColumnDataCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *colNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *colDataField;
@property (weak, nonatomic) IBOutlet UISwitch *colDataSwitch;

@end
