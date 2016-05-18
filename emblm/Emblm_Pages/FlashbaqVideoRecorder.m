//
//  FlashbaqVideoRecorder.m
//  AVCam
//
//  Created by Kavya Valavala on 3/21/15.
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import "FlashbaqVideoRecorder.h"
#import <AssetsLibrary/AssetsLibrary.h>
#import "PBJVision.h"
#import "PBJVisionUtilities.h"
#import "VSCore.h"
#import "GUIPlayerView.h"
#import "PostEmblmVC.h"
#import "VMediaDevice.h"
#import <CoreMedia/CMTime.h>

@interface FlashbaqVideoRecorder ()<PBJVisionDelegate,GUIPlayerViewDelegate,postEmblmVCDelegate>
{
    AVCaptureVideoPreviewLayer *videoPreviewLayer;

    ALAssetsLibrary *_assetLibrary;
    __block NSDictionary *_currentVideo;
    BOOL _recording;
    GUIPlayerView *playerView;
    NSString *videoFilepath;
    NSString *imgfilePath;
    BOOL startoverBtn_clicked;
    BOOL isChooseVideoMode;
    BOOL backbutton;
    CGRect previewviewRect;
    AVCaptureSession *_session;

}
// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;


-(IBAction)reviewBtn_Pressed:(id)sender;
-(IBAction)startover_pressed:(id)sender;
-(IBAction)flipBtn_presses:(id)sender;
-(IBAction)chooseVideo_pressed:(id)sender;
-(IBAction)cancelbtn_pressed:(id)sender;

@end

@implementation FlashbaqVideoRecorder
@synthesize postDataDict,cancelButton;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [_doneButton setEnabled:NO];
    startoverBtn_clicked=NO;
    isChooseVideoMode=NO;
    [cancelButton setHidden:YES];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    previewviewRect=_previewView.bounds;

    self.navigationController.navigationBar.hidden=YES;
    
    __navigationbar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];
    
    [__navigationbar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:20],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    self.view.backgroundColor=[VSCore getColor:@"1a1a1a" withDefault:[UIColor blackColor]];

    _assetLibrary = [[ALAssetsLibrary alloc] init];

    //manju added this code..
    [[PBJVision sharedInstance] startCaptureSession];//kavya commented today
    //End here..
    
    videoPreviewLayer = [[PBJVision sharedInstance] previewLayer];
    videoPreviewLayer.frame = _previewView.bounds;
    videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [_previewView.layer addSublayer:videoPreviewLayer];


    [_recordButton addTarget:self action:@selector(dragBegan:withEvent: )
            forControlEvents: UIControlEventTouchDown];
    [_recordButton addTarget:self action:@selector(dragEnded:withEvent: )
            forControlEvents: UIControlEventTouchUpInside | UIControlEventTouchUpOutside];
    
    UIImage *sliderLeftTrackImage = [UIImage imageNamed: @"Left.png"];
    sliderLeftTrackImage = [sliderLeftTrackImage resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
        UIImage *sliderRightTrackImage = [UIImage imageNamed: @"Right.png"];
    sliderRightTrackImage = [sliderRightTrackImage resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    
    [__progressbar setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
    [__progressbar setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];
    [
     __progressbar setThumbImage: [UIImage imageNamed:@"0.png"] forState:UIControlStateNormal];

    [self hideButtons];
    // Do any additional setup after loading the view.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(void)viewDidLayoutSubviews
{
    NSLog(@"calling viewDidLayoutSubviews");
//    [super viewWillLayoutSubviews];
}
-(void)viewWillAppear:(BOOL)animated
{
    
        if (isChooseVideoMode)
        {
            [_startoverButton setHidden:NO];
            [_keepButton setHidden:NO];
            
            [cancelButton setHidden:NO];
            [_recordButton setHidden:YES];
        }
        
        else
        {

            [self _resetCapture];
            [[PBJVision sharedInstance] startPreview];
            [_previewView bringSubviewToFront:_flipButton];
            
        }
//    [self.view setNeedsLayout];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    if (isChooseVideoMode)
    {
        [_flashbaqVideoPlayer._guiplayerView removeFromSuperview];


    }
    else
    {
        [_flashbaqVideoPlayer._guiplayerView pause];

    }
    
//    [[PBJVision sharedInstance] stopPreview];//KAVYA ADDED today

//    videoPreviewLayer.session=nil;
//    [videoPreviewLayer removeFromSuperlayer];
//
//    [[PBJVision sharedInstance] stopPreview];
//    
//    for (CALayer *layer in [videoPreviewLayer.sublayers copy]) {
//        [layer removeFromSuperlayer];
//    }
//    
//    [[PBJVision sharedInstance] cancelVideoCapture];
//    [videoPreviewLayer removeFromSuperlayer];

    // iOS 6 support
//    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationSlide];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)reviewBtn_Pressed:(id)sender
{
    [_flipButton setHidden:YES];
    [__progressbar setHidden:YES];

    [self _endCapture];
    [_doneButton setEnabled:YES];
//    [_flashbaqVideoPlayer setHidden:NO];
}

-(IBAction)startover_pressed:(id)sender
{
    
    if (isChooseVideoMode)
    {
        isChooseVideoMode=NO;
        [_recordButton setHidden:NO];
        [cancelButton setHidden:YES];
        [_startoverButton setHidden:YES];
        [_keepButton setHidden:YES];
        [_previewView bringSubviewToFront:_flipButton];
    }
    
    [_flipButton setHidden:NO];
    [__progressbar setHidden:NO];
    
    [_flashbaqVideoPlayer._guiplayerView stop];
    [_flashbaqVideoPlayer._guiplayerView clean];
    
    [_flashbaqVideoPlayer removeFromSuperview];
    _flashbaqVideoPlayer=nil;

    [_doneButton setEnabled:NO];
    
    _recording=NO;
    startoverBtn_clicked=YES;
    
//    [[PBJVision sharedInstance] cancelVideoCapture];
    [self _endCapture];
    [self _resetCapture];
    
    [self hideButtons];
    
//    [[PBJVision sharedInstance] startPreview];

    [_previewView bringSubviewToFront:_flipButton];

}

-(IBAction)flipBtn_presses:(id)sender
{
    PBJVision *vision = [PBJVision sharedInstance];
    vision.cameraDevice = vision.cameraDevice == PBJCameraDeviceBack ? PBJCameraDeviceFront : PBJCameraDeviceBack;
}

-(IBAction)chooseVideo_pressed:(id)sender
{
    [__progressbar setHidden:YES];

    isChooseVideoMode=YES;
    
    VMediaDevice *_vmediaDevice=[[VMediaDevice alloc]init];
    [_vmediaDevice setDeviceDelegate:self];
    [_vmediaDevice setIsCameraMode:NO];
    _vmediaDevice.mediaDeviceMode=TypeLibrary;
    
    [self presentViewController:_vmediaDevice animated:YES completion:nil];
   
}

-(IBAction)cancelbtn_pressed:(id)sender
{
    isChooseVideoMode=YES;
    
    VMediaDevice *_vmediaDevice=[[VMediaDevice alloc]init];
    [_vmediaDevice setDeviceDelegate:self];
    [_vmediaDevice setIsCameraMode:NO];
    _vmediaDevice.mediaDeviceMode=TypeLibrary;
    
    [self presentViewController:_vmediaDevice animated:YES completion:nil];

}
- (void) dragBegan: (UIButton *) c withEvent:ev
{
    
    if (!_recording)
        [self _startCapture];
    else
        [self _resumeCapture];
    
}

- (void) dragMoving: (UIButton *) c withEvent:ev
{
    NSLog(@"dragMoving..............");
}

- (void) dragEnded: (UIButton *) c withEvent:ev
{
//    /*check the time of recording and pause it if not reached the maximumtime */
//    [self stopTimer];
//    NSLog(@"Recording Stopped");
//    [[self movieFileOutput] stopRecording];
    if(_recording)
        [self _pauseCapture];
    else
        [self _endCapture];
    
}

-(IBAction)bckbtn_clicked:(id)sender
{
   
    [_flashbaqVideoPlayer removeFromSuperview];
    
  [self.navigationController popToRootViewControllerAnimated:YES];

}

-(IBAction)donebtn_clicked:(id)sender
{
//    [playerView clean];
    
    /*upload to aws and send the fileName to emblm API */
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    PostEmblmVC *vc = (PostEmblmVC *)[storyboard instantiateViewControllerWithIdentifier:@"PostEmblm"];
    
    /*send Data to the server */
    /*  NSArray *keys = [NSArray arrayWithObjects:@"image", @"type", @"foreign_data", nil];
     NSArray *objects=[NSArray arrayWithObjects:[imgfilePath lastPathComponent],@"1", @"",nil];
     
     NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
     
     WebService *_webservice=[[WebService alloc]init];
     //    [_webservice setWebDelegate:self];
     [_webservice SendJSONDataToServer:dataDict toURI:createEmblm forRequestType:POST];
     */
    vc.postemblmDelegate=self;
    [postDataDict setObject:videoFilepath forKey:@"videoFilePath"];
    [postDataDict setObject:imgfilePath forKey:@"imagefilePath"];
    vc.postDataDict=postDataDict;
    vc.videoFilePath=videoFilepath;
    vc.hidesBottomBarWhenPushed=YES;
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)hideButtons
{
    [_keepButton setHidden:YES];
    [_startoverButton setHidden:YES];
    
    [__progressbar setValue:0];
   [ __progressbar setThumbImage: [UIImage imageNamed:@"0.png"] forState:UIControlStateNormal];
    
    
}


-(void)unhideButtons
{
    [_keepButton setHidden:NO];
    [_startoverButton setHidden:NO];
    
}
#pragma mark - private start/stop helper methods

- (void)_startCapture
{
    startoverBtn_clicked=NO;
    
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    
   /* [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _instructionLabel.alpha = 0;
        _instructionLabel.transform = CGAffineTransformMakeTranslation(0, 10.0f);
    } completion:^(BOOL finished) {
    }]; */
    [[PBJVision sharedInstance] startVideoCapture];
}

- (void)_pauseCapture
{
    [self unhideButtons];

    NSLog(@"PauseCapture Called");

    /*[UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _instructionLabel.alpha = 1;
        _instructionLabel.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
    }];*/
    
    [[PBJVision sharedInstance] pauseVideoCapture];
    
    
}

- (void)_resumeCapture
{
    NSLog(@"resumeCapture Called");
   /* [UIView animateWithDuration:0.2f delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        _instructionLabel.alpha = 0;
        _instructionLabel.transform = CGAffineTransformMakeTranslation(0, 10.0f);
    } completion:^(BOOL finished) {
    }];*/
    
    [[PBJVision sharedInstance] resumeVideoCapture];
}

- (void)_endCapture
{
    [UIApplication sharedApplication].idleTimerDisabled = NO;
    [[PBJVision sharedInstance] endVideoCapture];
}


- (void)_resetCapture
{
    PBJVision *vision = [PBJVision sharedInstance];
    vision.delegate = self;
    
    if ([vision isCameraDeviceAvailable:PBJCameraDeviceBack]) {
        vision.cameraDevice = PBJCameraDeviceBack;
        _flipButton.hidden = NO;
    } else {
        vision.cameraDevice = PBJCameraDeviceFront;
        _flipButton.hidden = YES;
    }
    
    vision.cameraMode = PBJCameraModeVideo;
    //vision.cameraMode = PBJCameraModePhoto; // PHOTO: uncomment to test photo capture
    vision.cameraOrientation = PBJCameraOrientationPortrait;
    vision.focusMode = PBJFocusModeContinuousAutoFocus;
    vision.outputFormat = PBJOutputFormatSquare;
    vision.videoRenderingEnabled = YES;
    vision.thumbnailEnabled=YES;
    vision.defaultVideoThumbnails=YES;
    
    if ([vision isFlashAvailable])
    {
        [vision setFlashMode:PBJFlashModeOn];

    }
    vision.additionalCompressionProperties = @{AVVideoProfileLevelKey : AVVideoProfileLevelH264Baseline31}; // AVVideoProfileLevelKey requires sxpecific captureSessionPreset
    
    // specify a maximum duration with the following property
    // vision.maximumCaptureDuration = CMTimeMakeWithSeconds(5, 600); // ~ 5 seconds
    
    Float64 maximumVideoLength = 30; //Whatever value you wish to set as the maximum, in seconds
    int32_t prefferedTimeScale = 30 ;//Frames per second
    
    CMTime maxDuration = CMTimeMakeWithSeconds(maximumVideoLength, prefferedTimeScale);
    vision.maximumCaptureDuration=maxDuration;
}

- (void)vision:(PBJVision *)vision capturedPhoto:(NSDictionary *)photoDict error:(NSError *)error
{
    NSLog(@"capturedPhoto called");
}

// video capture

- (void)visionDidStartVideoCapture:(PBJVision *)vision
{
    _recording = YES;
    
}

- (void)visionDidPauseVideoCapture:(PBJVision *)vision
{
    
}


- (void)visionDidResumeVideoCapture:(PBJVision *)vision
{
    
}

- (void)vision:(PBJVision *)vision capturedVideo:(NSDictionary *)videoDict error:(NSError *)error
{
    if (!startoverBtn_clicked)
    {
        [_startoverButton setHidden:NO];
        [_keepButton setHidden:NO];
        
        _recording = NO;
        
        if (error && [error.domain isEqual:PBJVisionErrorDomain] && error.code == PBJVisionErrorCancelled) {
            NSLog(@"recording session cancelled");
            return;
        } else if (error) {
            NSLog(@"encounted an error in video capture (%@)", error);
            return;
        }
        
        _currentVideo = videoDict;
        
        videoFilepath = [_currentVideo  objectForKey:PBJVisionVideoPathKey];
        
        /*save thumbnail image to image folder of video*/
        NSMutableString *imagefilePath = [[NSMutableString alloc] initWithFormat:@"%@", [VSCore getImagesFolder]];
        NSMutableString *imagefilename = [NSMutableString stringWithFormat:@"%@.jpg",[VSCore getUniqueFileName]];
        imgfilePath = [imagefilePath stringByAppendingPathComponent:imagefilename];
        
        UIImage *chosenImage = [[_currentVideo objectForKey:PBJVisionVideoThumbnailArrayKey]objectAtIndex:1];
        
        NSData *imD = [NSData dataWithData:UIImageJPEGRepresentation(chosenImage, 1.0f)];
        
        if (![imD writeToFile:imgfilePath atomically:YES])
        {
            NSLog(@"There was a problem writing the image %@", imgfilePath);
        }
        
        
        /*play the video */
        _flashbaqVideoPlayer=[[FlashbaqVideoPlayer alloc]initWithFrame:_previewView.bounds];
        
        UITapGestureRecognizer *_thmbnailtap=[[UITapGestureRecognizer alloc]initWithTarget:_flashbaqVideoPlayer action:@selector(flashbaqVCFormVideoTapped:)];
        _thmbnailtap.numberOfTapsRequired=1;
        _flashbaqVideoPlayer.videoFilepath=videoFilepath;
        [_flashbaqVideoPlayer addGestureRecognizer:_thmbnailtap];

        CGRect frame = _flashbaqVideoPlayer.bounds;
        
        frame.size.height -=30;
        _flashbaqVideoPlayer.contentMode=UIViewContentModeScaleAspectFit;
        [_previewView addSubview:_flashbaqVideoPlayer];
    
        _flashbaqVideoPlayer.previewImageview.image=chosenImage;

    }
    
}

// progress

- (void)vision:(PBJVision *)vision didCaptureVideoSampleBuffer:(CMSampleBufferRef)sampleBuffer
{
    //    NSLog(@"captured audio (%f) seconds", vision.capturedAudioSeconds);
}

- (void)vision:(PBJVision *)vision didCaptureAudioSample:(CMSampleBufferRef)sampleBuffer
{
        NSLog(@"captured video (%f) seconds", vision.capturedVideoSeconds);
//    _recordingDuration.text=[NSString stringWithFormat:@"0.0%.0f",vision.capturedVideoSeconds];

    [__progressbar setValue:vision.capturedVideoSeconds];
    [__progressbar setThumbImage: [UIImage imageNamed:[NSString stringWithFormat:@"%.0f.png",vision.capturedVideoSeconds]] forState:UIControlStateNormal];

}


#pragma mark - PBJVisionDelegate

- (void)visionSessionWillStart:(PBJVision *)vision
{
}

- (void)visionSessionDidStart:(PBJVision *)vision
{
    if (![_previewView superview])
    {
        [self.view addSubview:_previewView];
    }
}

- (void)visionSessionDidStop:(PBJVision *)vision
{
    [_previewView removeFromSuperview];
}

// preview

- (void)visionSessionDidStartPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did start");
    
}

- (void)visionSessionDidStopPreview:(PBJVision *)vision
{
    NSLog(@"Camera preview did stop");
}

// device

- (void)visionCameraDeviceWillChange:(PBJVision *)vision
{
    NSLog(@"Camera device will change");
}

- (void)visionCameraDeviceDidChange:(PBJVision *)vision
{
    NSLog(@"Camera device did change");
}

// mode

- (void)visionCameraModeWillChange:(PBJVision *)vision
{
    NSLog(@"Camera mode will change");
}

- (void)visionCameraModeDidChange:(PBJVision *)vision
{
    NSLog(@"Camera mode did change");
}

// format

- (void)visionOutputFormatWillChange:(PBJVision *)vision
{
    NSLog(@"Output format will change");
}

- (void)visionOutputFormatDidChange:(PBJVision *)vision
{
    NSLog(@"Output format did change");
}

- (void)vision:(PBJVision *)vision didChangeCleanAperture:(CGRect)cleanAperture
{
}

// focus / exposure

- (void)visionWillStartFocus:(PBJVision *)vision
{
}

- (void)visionDidStopFocus:(PBJVision *)vision
{
//    if (_focusView && [_focusView superview]) {
//        [_focusView stopAnimation];
//    }
}

- (void)visionWillChangeExposure:(PBJVision *)vision
{
}

- (void)visionDidChangeExposure:(PBJVision *)vision
{
//    if (_focusView && [_focusView superview]) {
//        [_focusView stopAnimation];
//    }
}

// flash

- (void)visionDidChangeFlashMode:(PBJVision *)vision
{
    NSLog(@"Flash mode did change");
}

// photo

- (void)visionWillCapturePhoto:(PBJVision *)vision
{
    
}

- (void)visionDidCapturePhoto:(PBJVision *)vision
{
}

#pragma mark MediaDeviceDelegate Methods
-(void)imagePickerdidfinishLoadedWithData:(NSDictionary *)mediaData
{
    if ([[[mediaData objectForKey:@"filename"] pathExtension] isEqualToString:@"mp4"])
    {
        videoFilepath=[mediaData objectForKey:@"filepath"];
        
        /*save thumbnail image to image folder of video*/
        NSMutableString *imagefilePath = [[NSMutableString alloc] initWithFormat:@"%@", [VSCore getImagesFolder]];
        NSMutableString *imagefilename = [NSMutableString stringWithFormat:@"%@_%@.jpg",[VSCore getUserID],[VSCore getUniqueFileName]];
        imgfilePath = [imagefilePath stringByAppendingPathComponent:imagefilename];
        
        UIImage *chosenImage = [VSCore  previewFromFileAtPath:videoFilepath ratio:0.1];
        
        CGSize newSize = CGSizeMake(600, 600);
        
        UIGraphicsBeginImageContext( newSize );// a CGSize that has the size you want
        [chosenImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
        //image is the original UIImage
        UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        
        NSData *imD = [NSData dataWithData:UIImageJPEGRepresentation(newImage, 1.0f)];
        
        if (![imD writeToFile:imgfilePath atomically:YES])
        {
            NSLog(@"There was a problem writing the image %@", imgfilePath);
        }
        
    }
}

-(void)imagepickerloadedwithTrimmedVideo:(NSDictionary *)videoData
{
    if ([[[videoData objectForKey:@"filename"] pathExtension] isEqualToString:@"mp4"])
    {
        videoFilepath=[videoData objectForKey:@"filepath"];
        
        /*save thumbnail image to image folder of video*/
        NSMutableString *imagefilePath = [[NSMutableString alloc] initWithFormat:@"%@", [VSCore getImagesFolder]];
        NSMutableString *imagefilename = [NSMutableString stringWithFormat:@"%@_%@.jpg",[VSCore getUserID],[VSCore getUniqueFileName]];
        imgfilePath = [imagefilePath stringByAppendingPathComponent:imagefilename];
        
        UIImage *chosenImage = [VSCore  previewFromFileAtPath:videoFilepath ratio:0.1];
        
        NSData *imD = [NSData dataWithData:UIImageJPEGRepresentation(chosenImage, 1.0f)];
        
        if (![imD writeToFile:imgfilePath atomically:YES])
        {
            NSLog(@"There was a problem writing the image %@", imgfilePath);
        }
        
        
        /*play the video */
        _flashbaqVideoPlayer=[[FlashbaqVideoPlayer alloc]initWithFrame:_previewView.bounds];
      
        UITapGestureRecognizer *_thmbnailtap=[[UITapGestureRecognizer alloc]initWithTarget:_flashbaqVideoPlayer action:@selector(flashbaqVCFormVideoTapped:)];
        _thmbnailtap.numberOfTapsRequired=1;
        _flashbaqVideoPlayer.videoFilepath=videoFilepath;
        [_flashbaqVideoPlayer addGestureRecognizer:_thmbnailtap];
        
        _flashbaqVideoPlayer.contentMode=UIViewContentModeScaleToFill;
        _flashbaqVideoPlayer._guiplayerView.transform=CGAffineTransformMakeRotation(M_PI/2);
        CGRect frame = _flashbaqVideoPlayer.bounds;
        
        frame.size.height -=30;
        _flashbaqVideoPlayer.contentMode=UIViewContentModeScaleAspectFit;
        [_previewView addSubview:_flashbaqVideoPlayer];

        _flashbaqVideoPlayer.previewImageview.image=chosenImage;

    }

}

-(void)dismissMediaDeviceView
{
    isChooseVideoMode=YES;
    [self dismissViewControllerAnimated:YES completion:nil];
    
}

-(void)imagePickerdidCancelled
{
    isChooseVideoMode=NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark PostEmblmVCDelegate methods
-(void)dismissPostEmblmVC
{
    isChooseVideoMode=NO;

    [self dismissViewControllerAnimated:YES completion:nil];

    
//    [self viewWillAppear:NO];
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
