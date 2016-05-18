//
//  FollowersCustomCell.h
//  emblm
//
//  Created by Kavya Valavala on 2/15/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FollowersCustomCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIButton *btn_follow;
@property (nonatomic, strong) IBOutlet UIImageView *imgview;
@property (nonatomic, strong) IBOutlet UILabel     *lbl_name;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;

@end
