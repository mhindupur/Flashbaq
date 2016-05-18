//
//  PostDetailHeaderView.h
//  emblm
//
//  Created by Kavya Valavala on 2/19/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlashbaqVideoPlayer.h"

@interface PostDetailHeaderView : UIView

@property (nonatomic, strong) IBOutlet UIImageView *userimgView;
@property (strong, nonatomic) IBOutlet UILabel *lblDescription;
@property (strong, nonatomic) IBOutlet UILabel *lbl_username;
@property (nonatomic, strong) IBOutlet UILabel *lbl_comments;
@property (nonatomic, strong) IBOutlet UILabel *lbl_likes;
@property (nonatomic, strong) IBOutlet UILabel *lbl_timeStamp;
@property (nonatomic, strong) IBOutlet UIImageView *img_comments, *img_likes;
@property (nonatomic, strong) IBOutlet FlashbaqVideoPlayer *flahbaqPlayer;
@property (nonatomic)         BOOL isProfilePage;
@end
