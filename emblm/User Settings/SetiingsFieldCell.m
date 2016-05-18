//
//  SetiingsFieldCell.m
//  Flashbaq
//
//  Created by Kavya Valavala on 3/17/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "SetiingsFieldCell.h"
#import "VSCore.h"

@implementation SetiingsFieldCell
@synthesize lbl_name, txt_fieldName;

- (void)awakeFromNib
{
    // Initialization code
    lbl_name.font=[UIFont fontWithName:TITLE_FONT size:14.0];
    lbl_name.textColor=[VSCore getColor:@"888888" withDefault:[UIColor blackColor]];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
