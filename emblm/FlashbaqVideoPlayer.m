//
//  FlashbaqVideoPlayer.m
//  Flashbaq
//
//  Created by Kavya Valavala on 4/1/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "FlashbaqVideoPlayer.h"
#import "EmblmCell.h"
#import "ApplicationSettings.h"

@implementation FlashbaqVideoPlayer

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    if ((self = [super initWithFrame:frame])) {
        [self initialize];
    }
    return self;
}


- (void)initialize
{
    self.backgroundColor = [UIColor clearColor];
    _previewImageview=[[UIImageView alloc]init];
    _previewImageview.contentMode=UIViewContentModeScaleToFill;
    _previewImageview.userInteractionEnabled=YES;
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    _previewImageview.frame=CGRectMake(0, 0, width , self.frame.size.height);
    [self addSubview:_previewImageview];
    
    _playButtonView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play.png"]];
    _playButtonView.frame=CGRectMake(0, 0 , 60, 60);
    _playButtonView.center=_previewImageview.center;
    [self addSubview:_playButtonView];
    
}

-(void)startBufferingVideo
{
    _isstillBuffering=YES;
   
        [self displayanimationView];
        [__guiplayerView setHidden:YES];
        //    [_playButtonView setHidden:YES];
        [_playButtonView removeFromSuperview];

}


-(void)playerviewTapped:(UITapGestureRecognizer *)sender
{
    
    if (!_isstillBuffering)
    {
        if ([__guiplayerView isPlaying])
        {
            [__guiplayerView pause];
            //display play image
            _playButtonView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play.png"]];
            _playButtonView.frame=CGRectMake(0, 0 , 60, 60);
            _playButtonView.center=_previewImageview.center;
            [self addSubview:_playButtonView];
            
        }
        
        else
        {
//            [_playButtonView setHidden:YES];
            [_playButtonView removeFromSuperview];
                    [__guiplayerView play];
//            __guiplayerView.hidden=YES;
            //[self displayanimationView];
        }

    }
    
}
-(void)flashbaqvideoplayerTapped:(UITapGestureRecognizer *)sender
{
   
    NSURL *mediaurl;
    
    if ([[_listviewarray objectAtIndex:sender.view.tag] objectForKey:@"emblm"] != nil)
    {
        mediaurl=[NSURL URLWithString:[[[_listviewarray objectAtIndex:sender.view.tag] objectForKey:@"emblm"] objectForKey:@"media"]];
    }
    else
    {
        mediaurl=[NSURL URLWithString:[[_listviewarray objectAtIndex:sender.view.tag] objectForKey:@"media"]];
        
    }

    __guiplayerView = [[GUIPlayerView alloc] initWithFrame:_previewImageview.frame];
    [__guiplayerView clean];
    UITapGestureRecognizer *_thmbnailtap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playerviewTapped:)];
    _thmbnailtap.numberOfTapsRequired=1;
    [__guiplayerView addGestureRecognizer:_thmbnailtap];

    
    [__guiplayerView setDelegate:self];
    
    [self addSubview:__guiplayerView];
    
    [__guiplayerView setVideoURL:mediaurl];
    __guiplayerView.contentMode=UIViewContentModeScaleToFill;
    __guiplayerView.clipsToBounds=YES;
    
    [__guiplayerView prepareAndPlayAutomatically:YES];

}

-(void)postDetailsFormVideoTapped:(UITapGestureRecognizer *)sender
{
    NSURL *mediaurl=[NSURL URLWithString:[_postresultDict objectForKey:@"media"]];
    
    
    __guiplayerView = [[GUIPlayerView alloc] initWithFrame:_previewImageview.frame];
    
    /* */
    UITapGestureRecognizer *_thmbnailtap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playerviewTapped:)];
    _thmbnailtap.numberOfTapsRequired=1;
    [__guiplayerView addGestureRecognizer:_thmbnailtap];

    
    [__guiplayerView setDelegate:self];
    [self addSubview:__guiplayerView];
    
    [__guiplayerView setVideoURL:mediaurl];
    //    playerView.contentMode=UIViewContentModeScaleAspectFill;
    __guiplayerView.clipsToBounds=YES;
    
    [self startBufferingVideo];
    [__guiplayerView prepareAndPlayAutomatically:YES];
    
}


-(void)flashbaqVCFormVideoTapped:(UITapGestureRecognizer *)sender
{
    NSURL *mediaurl=[NSURL fileURLWithPath:_videoFilepath];
    
    __guiplayerView = [[GUIPlayerView alloc] initWithFrame:_previewImageview.bounds];
    
    /*add tap gesture to GUIPlayer */
    
    UITapGestureRecognizer *_thmbnailtap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(playerviewTapped:)];
    _thmbnailtap.numberOfTapsRequired=1;
    [__guiplayerView addGestureRecognizer:_thmbnailtap];

    
    /* ---*/
    [__guiplayerView setDelegate:self];
    __guiplayerView.contentMode=UIViewContentModeScaleToFill;
    __guiplayerView.clipsToBounds=YES;

    [self addSubview:__guiplayerView];
    
    [__guiplayerView setVideoURL:mediaurl];
    
    [__guiplayerView prepareAndPlayAutomatically:YES];
    
}

-(void)displayanimationView
{
    /* */
    /*Add animation images on top of _previewImageview */
    
    // Load images
    NSArray *imageNames = @[@"whitecir", @"whitecir_tra", @"whitecir_white"];
    
    NSMutableArray *images = [[NSMutableArray alloc] init];
    for (int i = 0; i < imageNames.count; i++) {
        [images addObject:[UIImage imageNamed:[imageNames objectAtIndex:i]]];
    }
    
    _animationImageView = [[UIImageView alloc] initWithFrame:CGRectMake(_previewImageview.frame.size.width - 55, _previewImageview.frame.origin.y + 20, 27, 27)];
    _animationImageView.animationImages = images;
    _animationImageView.animationDuration = 1;
    
    [self addSubview:_animationImageView];
    [_animationImageView startAnimating];

}

#pragma mark FlashbaqVideoPlayer Delegates
- (void)playerDidEndPlaying
{
    [__guiplayerView removeFromSuperview];
    _playButtonView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play.png"]];
    _playButtonView.frame=CGRectMake(0, 0 , 60, 60);
    _playButtonView.center=_previewImageview.center;
    
    [self addSubview:_playButtonView];
}

- (void)playerFailedToPlayToEnd
{
    NSLog(@"playerFailedToPlayToEnd");
}

- (void)playerStalled
{
    NSLog(@"playerStalled");
    _playButtonView=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"play.png"]];
    _playButtonView.frame=CGRectMake(0, 0 , 60, 60);
    _playButtonView.center=_previewImageview.center;
    //[self addSubview:_playButtonView];

    [self displayanimationView];
}

- (void)playerDidPause
{
    NSLog(@"playerDidPause");
}

- (void)playerDidResume
{
    NSLog(@"playerDidResume");
}

-(void)bufferingCompletedandReadytoPlay
{
    _isstillBuffering=NO;
    [__guiplayerView setHidden:NO];
    [__guiplayerView play];
    
    /*remove animationview and set _previewimageview hidden */
    
    [_animationImageView removeFromSuperview];
//    [_previewImageview setHidden:YES];
}

@end
