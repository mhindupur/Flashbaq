//
//  FollowersCustomCell.m
//  emblm
//
//  Created by Kavya Valavala on 2/15/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "FollowersCustomCell.h"
#import "VSCore.h"

@implementation FollowersCustomCell

- (void)awakeFromNib
{
    // Initialization code
    
    [_btn_follow setBackgroundColor:[VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]]];
    _btn_follow.titleLabel.font = [UIFont fontWithName:OTHER_FONT size:14.0];
    CGFloat spacing = 1; // the amount of spacing to appear between image and title
    _btn_follow.titleEdgeInsets = UIEdgeInsetsMake(0, spacing, 0, 0);

    CALayer * l = [_btn_follow layer];
       [l setMasksToBounds:YES];
        [l setCornerRadius:5.0];
    
    CALayer * imgl = [_imgview layer];
    [imgl setMasksToBounds:YES];
    [imgl setCornerRadius:_imgview.frame.size.height/2];
    [_imgview setUserInteractionEnabled:YES];

   
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}


@end
