//
//  ProfileImageCell.m
//  Flashbaq
//
//  Created by Kavya Valavala on 3/17/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "ProfileImageCell.h"

@implementation ProfileImageCell

- (void)awakeFromNib {
    // Initialization code
    
    CALayer * l = [_userimageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:_userimageView.frame.size.width/2];
    [l setBorderColor:[[UIColor blackColor] CGColor]];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;

    if (width == 320)
    {
        [_btn_choosephoto setImage:[UIImage imageNamed:@"Choose A Photo_5"] forState:UIControlStateNormal];
        [_btn_takephoto setImage:[UIImage imageNamed:@"Take A Photo_5"] forState:UIControlStateNormal];
    }

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
