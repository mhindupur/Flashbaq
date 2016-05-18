//
//  profileHeaderview.h
//  emblm
//
//  Created by Kavya Valavala on 2/15/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface profileHeaderview : UIView

@property (nonatomic, strong) IBOutlet UIView *profileDetailView;
@property (nonatomic, strong) IBOutlet UIImageView *userimageview;
@property (nonatomic, strong) IBOutlet UILabel     *lbl_username;
@property (nonatomic, strong) IBOutlet UIButton    *btn_follower, *btn_following;
@property (nonatomic, strong) IBOutlet UIButton    *btn_myscans;
@property (nonatomic, strong) IBOutlet UIButton    *btn_myemblms;
@property (nonatomic, strong) IBOutlet UILabel     *lbl_createdDate;
@property (nonatomic, strong) IBOutlet UIButton *followImagebtn;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *_indicatorView;
@end
