//
//  mainheaderview.m
//  Flashbaq
//
//  Created by Kavya Valavala on 3/17/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "mainheaderview.h"
#import "VSCore.h"

@implementation mainheaderview

- (void)awakeFromNib
{
    // Initialization code
    
    _headerView.backgroundColor=[VSCore getColor:@"313131" withDefault:[UIColor blackColor]];

    [_btn_buyemblms setBackgroundColor:[VSCore getColor:@"f27390" withDefault:[UIColor blackColor]]];
    _btn_buyemblms.titleLabel.font = [UIFont fontWithName:OTHER_FONT size:18.0];
    [_btn_buyemblms setTitle: @"Buy flashbaq Stickers" forState:UIControlStateNormal];
    [_btn_buyemblms setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    
    _lbl_headername.font=[UIFont fontWithName:OTHER_FONT size:22.0];
    _lbl_headername.adjustsFontSizeToFitWidth=YES;
    _lbl_headername.textColor=[UIColor whiteColor];

    _lbl_purchase.font=[UIFont fontWithName:TITLE_FONT size:12.0];
    _lbl_purchase.textColor=[UIColor whiteColor];

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
