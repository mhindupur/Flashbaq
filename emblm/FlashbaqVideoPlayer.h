//
//  FlashbaqVideoPlayer.h
//  Flashbaq
//
//  Created by Kavya Valavala on 4/1/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GUIPlayerView.h"


@interface FlashbaqVideoPlayer : UIView<GUIPlayerViewDelegate>

@property (nonatomic, strong)  UIView      *playerView;

@property (nonatomic, strong)  UIImageView *previewImageview;
@property (nonatomic, strong)  UIImageView *playButtonView;
@property (nonatomic, strong)  UIImageView *animationImageView;
@property (nonatomic, strong)  GUIPlayerView        *_guiplayerView;
@property (nonatomic, strong) NSMutableArray     *listviewarray;
@property (nonatomic, strong) NSDictionary       *postresultDict;
@property (nonatomic, strong) NSString           *videoFilepath;
@property (nonatomic)         BOOL               isFirsttimeTapped;
@property (nonatomic)         BOOL               isstillBuffering;

-(void)flashbaqvideoplayerTapped:(UITapGestureRecognizer *)sender;
-(void)postDetailsFormVideoTapped:(UITapGestureRecognizer *)sender;
-(void)flashbaqVCFormVideoTapped:(UITapGestureRecognizer *)sender;
-(void)startBufferingVideo;

@end
