//
//  PostDetailHeaderView.m
//  emblm
//
//  Created by Kavya Valavala on 2/19/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "PostDetailHeaderView.h"
#import "VSCore.h"

@implementation PostDetailHeaderView
@synthesize isProfilePage;

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)awakeFromNib
{
    self.lblDescription.adjustsFontSizeToFitWidth = YES;
    
    CALayer * l = [_userimgView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:_userimgView.frame.size.width/2];
//    [l setBorderColor:[[VSCore getColor:@"ff4b4a" withDefault:[UIColor blackColor]] CGColor]];
//    [l setBorderWidth:1.0];
    

    [_lbl_username setFont:[UIFont fontWithName:OTHER_FONT size:19.0]];
    _lbl_username.textColor=[VSCore getColor:@"c63492" withDefault:[UIColor blackColor]];
    _lbl_username.adjustsFontSizeToFitWidth=YES;
    _lbl_timeStamp.textColor=[UIColor grayColor];

    [_lblDescription setFont:[UIFont fontWithName:OTHER_FONT size:16.0]];
    
    [_lbl_timeStamp setFont:[UIFont fontWithName:OTHER_FONT size:16.0]];
    _lbl_timeStamp.textColor=[UIColor grayColor];
    _lbl_timeStamp.adjustsFontSizeToFitWidth = YES;
    
    [_lbl_comments setFont:[UIFont fontWithName:OTHER_FONT size:16.0]];
    _lbl_comments.textColor=[UIColor grayColor];
    _lbl_comments.adjustsFontSizeToFitWidth = YES;

    [_lbl_likes setFont:[UIFont fontWithName:OTHER_FONT size:16.0]];
    _lbl_likes.textColor=[UIColor grayColor];
    _lbl_likes.adjustsFontSizeToFitWidth = YES;


}
@end
