//
//  NotifViewCell.m
//  Flashbaq
//
//  Created by Kavya Valavala on 7/13/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "NotifViewCell.h"
#import "VSCore.h"

@implementation NotifViewCell
@synthesize profileimage,lbl_descp, lbl_timestamp;

- (void)awakeFromNib
{
    // Initialization code
    CALayer * l = [profileimage layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:profileimage.frame.size.width/2];
    [l setBorderColor:[[UIColor blackColor] CGColor]];
    
    [lbl_descp setFont:[UIFont fontWithName:TITLE_FONT size:16.0]];
    [lbl_timestamp setFont:[UIFont fontWithName:TITLE_FONT size:12.0]];


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
