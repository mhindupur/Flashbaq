//
//  FlashbaqVideoRecorder.h
//  AVCam
//
//  Created by Kavya Valavala on 3/21/15.
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlashbaqVideoPlayer.h"

@protocol flashbaqRecorDelegate <NSObject>

-(void)dismissFlashbaqVR;

@end

@interface FlashbaqVideoRecorder : UIViewController

@property (nonatomic, strong) IBOutlet UIView *previewView;
@property (nonatomic, strong) IBOutlet UIButton *flipButton;
@property (nonatomic, strong) IBOutlet UIButton *recordButton;
@property (nonatomic, strong) IBOutlet UIButton *keepButton;
@property (nonatomic, strong) IBOutlet UIButton *startoverButton;
@property (nonatomic, strong) IBOutlet UISlider *_progressbar;
@property (nonatomic, strong) NSMutableDictionary  *postDataDict;
@property (nonatomic, strong) IBOutlet UINavigationBar *_navigationbar;
@property (nonatomic, strong) IBOutlet UIButton        *doneButton;
@property (nonatomic, strong) FlashbaqVideoPlayer *flashbaqVideoPlayer;
@property (nonatomic, strong) IBOutlet UIButton         *cancelButton;
@property (nonatomic, strong) IBOutlet UIButton         *chooseButton;
@property (nonatomic, strong) id <flashbaqRecorDelegate> flashbaqrecDelegate;
@end
