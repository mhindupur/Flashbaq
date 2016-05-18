//
//  LogoutCell.m
//  Flashbaq
//
//  Created by Kavya Valavala on 3/17/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "LogoutCell.h"
#import "VSCore.h"

@implementation LogoutCell

- (void)awakeFromNib
{
    // Initialization code
    
    [_btn_logout setBackgroundColor:[UIColor lightGrayColor]];
    _btn_logout.titleLabel.font = [UIFont fontWithName:OTHER_FONT size:18.0];
    [_btn_logout setTitle: @"Logout" forState:UIControlStateNormal];
    [_btn_logout setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    _btn_terms.titleLabel.font = [UIFont fontWithName:OTHER_FONT size:16.0];
    [_btn_terms setTitleColor:[VSCore getColor:@"888888" withDefault:[UIColor blackColor]] forState:UIControlStateNormal];

    _btn_privacy.titleLabel.font = [UIFont fontWithName:OTHER_FONT size:16.0];
    [_btn_privacy setTitleColor:[VSCore getColor:@"888888" withDefault:[UIColor blackColor]] forState:UIControlStateNormal];

    _btn_help.titleLabel.font = [UIFont fontWithName:OTHER_FONT size:16.0];
    [_btn_help setTitleColor:[VSCore getColor:@"888888" withDefault:[UIColor blackColor]] forState:UIControlStateNormal];

    _lbl_terms.font=[UIFont fontWithName:OTHER_FONT size:16.0];
    _lbl_terms.textColor=[VSCore getColor:@"888888" withDefault:[UIColor blackColor]];

    _lbl_privacy.font=[UIFont fontWithName:OTHER_FONT size:16.0];
    _lbl_privacy.textColor=[VSCore getColor:@"888888" withDefault:[UIColor blackColor]];
    
    _lbl_help.font=[UIFont fontWithName:OTHER_FONT size:16.0];
    _lbl_help.textColor=[VSCore getColor:@"888888" withDefault:[UIColor blackColor]];


}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
