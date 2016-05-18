//
//  profileHeaderview.m
//  emblm
//
//  Created by Kavya Valavala on 2/15/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "profileHeaderview.h"
#import "VSCore.h"

@implementation profileHeaderview

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)awakeFromNib
{
    _profileDetailView.backgroundColor=[VSCore getColor:@"1a1a1a" withDefault:[UIColor blackColor]];
    self.backgroundColor=[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]];
    
        CALayer * l = [_userimageview layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:_userimageview.frame.size.width/2];
        [l setBorderColor:[[UIColor blackColor] CGColor]];
        [l setBorderWidth:3.0];

    _btn_follower.titleLabel.font = [UIFont fontWithName:OTHER_FONT size:16.0];
    _btn_following.titleLabel.font = [UIFont fontWithName:OTHER_FONT size:16.0];
    
    [_lbl_username setFont:[UIFont fontWithName:TITLE_FONT size:19.0]];
    [_lbl_username setAdjustsFontSizeToFitWidth:YES];
    
    [_btn_myscans setBackgroundColor:[VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]]];
    [_btn_myemblms setBackgroundColor:[VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]]];

    _btn_myscans.titleLabel.font = [UIFont fontWithName:OTHER_FONT size:16.0];
    _btn_myemblms.titleLabel.font = [UIFont fontWithName:OTHER_FONT size:16.0];

    [_lbl_createdDate setFont:[UIFont fontWithName:OTHER_FONT size:17.0]];
    

}

@end
