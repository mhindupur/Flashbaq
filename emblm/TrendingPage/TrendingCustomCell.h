//
//  TrendingCustomCell.h
//  emblm
//
//  Created by Kavya Valavala on 12/31/14.
//  Copyright (c) 2014 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString *kCellIdentifier = @"TrendingCellId";

@interface TrendingCustomCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIView *mediaview;
@property (nonatomic, strong) IBOutlet UIImageView  *userImageView;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_username;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_timestamp;
@property (nonatomic, strong) IBOutlet UILabel      *lbl_commentscount, *lbl_likescount , *lbl_comment , *lbl_scanncount;


@end
