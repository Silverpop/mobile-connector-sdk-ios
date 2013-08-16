//
//  ColumnDataCell.m
//  EngageSDKDemo
//
//  Created by Musa Siddeeq on 8/11/13.
//  Copyright (c) 2013 Silverpop. All rights reserved.
//

#import "ColumnDataCell.h"

@implementation ColumnDataCell


- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
