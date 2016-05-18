//
//  EmblmCell.h
//  emblm
//
//  Created by Kavya Valavala on 1/6/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlashbaqVideoPlayer.h"

@interface EmblmCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel *lbl_userName, *lbl_timeStamp, *lbl_commentscount , *lbl_createdBy , *lbl_comnttext  , *lbl_createdText, *lbl_likesCount;
@property (nonatomic, strong) IBOutlet UIImageView  *_profileImage;
//@property (nonatomic, strong) IBOutlet UIImageView  *thmbnail_img;
@property (nonatomic, strong) IBOutlet UIButton     *btn_delete;
@property (nonatomic, strong) IBOutlet UIImageView *img_like , *img_comment;
@property (nonatomic, strong) IBOutlet UIImageView *img_follow;

@property (nonatomic, strong) IBOutlet FlashbaqVideoPlayer *flashbaqPlayer;
@property (nonatomic, strong) IBOutlet UIImageView         *followView;
@property (nonatomic)         BOOL userLikedPost;
- (void)configureEmblmCellForData:(NSDictionary *)dict;
+ (CGFloat)cellHeightForCommentText:(NSString *)comment;

@end
