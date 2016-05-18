//
//  AttachMediaVC.h
//  AVCam
//
//  Created by Kavya Valavala on 1/26/15.
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "LDProgressView.h"

@interface AttachMediaVC : UIViewController

@property (nonatomic, strong) IBOutlet LDProgressView *_progressview;
@property (nonatomic, strong) IBOutlet UINavigationBar *_navigationbar;
@property (nonatomic, strong) UIBarButtonItem *_donebtn;
@property (nonatomic, strong) IBOutlet UIButton *btn_keep, *btn_startover;
@property (nonatomic, strong) IBOutlet UIView   *progressbarView;
@property (nonatomic, strong) IBOutlet UIView *videoPreviewView;
@property (nonatomic, strong) NSMutableDictionary  *postDataDict;
@property (nonatomic, strong) IBOutlet UISlider    *progressbar;

@end
