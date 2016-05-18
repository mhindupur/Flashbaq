//
//  AttachMediaVC.m
//  AVCam
//
//  Created by Kavya Valavala on 1/26/15.
//  Copyright (c) 2015 Apple Inc. All rights reserved.
//

#import "AttachMediaVC.h"
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "VSCore.h"
#import "PostEmblmVC.h"
#import "WebService.h"
#import "VMediaDevice.h"
#import "AVCamPreviewView.h"
#import "AppDelegate.h"
#import "GUIPlayerView.h"


static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * RecordingContext = &RecordingContext;
static void * SessionRunningAndDeviceAuthorizedContext = &SessionRunningAndDeviceAuthorizedContext;

NSString * const MY_ACCESS_KEY_ID_1        =@"AKIAIUYGOJRUUCSMTD6Q";
NSString * const MY_SECRET_KEY_1        =@"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";
NSString * const MY_PICTURE_BUCKET_1        =@"emblmpost";

@interface AttachMediaVC () <AVCaptureFileOutputRecordingDelegate, postEmblmVCDelegate , MediaDeviceDelegate ,GUIPlayerViewDelegate>

{
    NSTimer *_timer;
    NSString *videoFilepath;
    NSString *imgfilePath;
    UIButton *donebtn;
    GUIPlayerView *playerView;
    BOOL isChooseVideoMode;
}
@property (nonatomic, weak) IBOutlet AVCamPreviewView *previewView;
@property (nonatomic, weak) IBOutlet UIButton *recordButton;
@property (nonatomic, weak) IBOutlet UIButton *cameraButton;
@property (nonatomic, weak) IBOutlet UIButton *chooseButton;
@property (nonatomic, weak) IBOutlet UIButton *cancelButton;
@property (nonatomic, weak) IBOutlet UIButton *frontCamButton;
@property (nonatomic, weak) IBOutlet UILabel *lbl_timestamp;

-(IBAction)takeVideo:(id)sender;
-(IBAction)openFrontCamera:(id)sender;
-(IBAction)choosevideo_clicked:(id)sender;

// Session management.
@property (nonatomic) dispatch_queue_t sessionQueue; // Communicate with the session and other session objects on this queue.
@property (nonatomic) AVCaptureSession *session;
@property (nonatomic) AVCaptureDeviceInput *videoDeviceInput;
@property (nonatomic) AVCaptureMovieFileOutput *movieFileOutput;
@property (nonatomic) AVCaptureStillImageOutput *stillImageOutput;

// Utilities.
@property (nonatomic) UIBackgroundTaskIdentifier backgroundRecordingID;
@property (nonatomic, getter = isDeviceAuthorized) BOOL deviceAuthorized;
@property (nonatomic, readonly, getter = isSessionRunningAndDeviceAuthorized) BOOL sessionRunningAndDeviceAuthorized;
@property (nonatomic) BOOL lockInterfaceRotation;
@property (nonatomic) id runtimeErrorHandlingObserver;

@end

@implementation AttachMediaVC
@synthesize _navigationbar, postDataDict;

//- (BOOL)isSessionRunningAndDeviceAuthorized
//{
//    return [[self session] isRunning] && [self isDeviceAuthorized];
//}
//
//+ (NSSet *)keyPathsForValuesAffectingSessionRunningAndDeviceAuthorized
//{
//    return [NSSet setWithObjects:@"session.running", @"deviceAuthorized", nil];
//}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    /*Newly added */
    
    UIBarButtonItem *negativeSpacer = [[UIBarButtonItem alloc]
                                       initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace
                                       target:nil action:nil];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }

     UIImage *sliderLeftTrackImage = [UIImage imageNamed: @"Left.png"];
    sliderLeftTrackImage = [sliderLeftTrackImage resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];
    
    // UIImage *sliderRightTrackImage = [[UIImage imageNamed: @"Right.png"] stretchableImageWithLeftCapWidth: self.sliderTime.frame.size.width topCapHeight: 0];
    UIImage *sliderRightTrackImage = [UIImage imageNamed: @"Right.png"];
    sliderRightTrackImage = [sliderRightTrackImage resizableImageWithCapInsets:UIEdgeInsetsZero resizingMode:UIImageResizingModeStretch];

    [_progressbar setMinimumTrackImage: sliderLeftTrackImage forState: UIControlStateNormal];
    [_progressbar setMaximumTrackImage: sliderRightTrackImage forState: UIControlStateNormal];
    [_progressbar setThumbImage: [UIImage imageNamed:@"0.png"] forState:UIControlStateNormal];
    _progressbar.backgroundColor=[VSCore getColor:@"acacaca" withDefault:[UIColor blackColor]];
    [_cancelButton setHidden:YES];
    [self.view bringSubviewToFront:_videoPreviewView];
    
    _navigationbar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];

    [_navigationbar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:20],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    self.view.backgroundColor=[VSCore getColor:@"1a1a1a" withDefault:[UIColor blackColor]];

    [_recordButton addTarget:self action:@selector(dragBegan:withEvent: )
    forControlEvents: UIControlEventTouchDown];
//    [_recordButton addTarget:self action:@selector(dragMoving:withEvent: )
//    forControlEvents: UIControlEventTouchDragInside];
    [_recordButton addTarget:self action:@selector(dragEnded:withEvent: )
    forControlEvents: UIControlEventTouchUpInside |
     UIControlEventTouchUpOutside];
    
    // Create the AVCaptureSession
    AVCaptureSession *session = [[AVCaptureSession alloc] init];
    [self setSession:session];
    
    
    // Setup the preview view
    [[self previewView] setSession:session];
    
    // Check for device authorization
    [self checkDeviceAuthorizationStatus];
    
    // In general it is not safe to mutate an AVCaptureSession or any of its inputs, outputs, or connections from multiple threads at the same time.
    // Why not do all of this on the main queue?
    // -[AVCaptureSession startRunning] is a blocking call which can take a long time. We dispatch session setup to the sessionQueue so that the main queue isn't blocked (which keeps the UI responsive).
    
    dispatch_queue_t sessionQueue = dispatch_queue_create("session queue", DISPATCH_QUEUE_SERIAL);
    [self setSessionQueue:sessionQueue];
    
    dispatch_async(sessionQueue, ^{
        [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
        
        NSError *error = nil;
        
        AVCaptureDevice *videoDevice = [AttachMediaVC deviceWithMediaType:AVMediaTypeVideo preferringPosition:AVCaptureDevicePositionBack];
        
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:&error];
    
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:videoDeviceInput])
        {
            [session addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                // Why are we dispatching this to the main queue?
                // Because AVCaptureVideoPreviewLayer is the backing layer for AVCamPreviewView and UIView can only be manipulated on main thread.
                // Note: As an exception to the above rule, it is not necessary to serialize video orientation changes on the AVCaptureVideoPreviewLayer’s connection with other session manipulation.
                
                [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)[self interfaceOrientation]];
            });
        }
        
        AVCaptureDevice *audioDevice = [[AVCaptureDevice devicesWithMediaType:AVMediaTypeAudio] firstObject];
        AVCaptureDeviceInput *audioDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:audioDevice error:&error];
        
        if (error)
        {
            NSLog(@"%@", error);
        }
        
        if ([session canAddInput:audioDeviceInput])
        {
            [session addInput:audioDeviceInput];
        }
        
        AVCaptureMovieFileOutput *movieFileOutput = [[AVCaptureMovieFileOutput alloc] init];
        if ([session canAddOutput:movieFileOutput])
        {
            [session addOutput:movieFileOutput];
            AVCaptureConnection *connection = [movieFileOutput connectionWithMediaType:AVMediaTypeVideo];
            if ([connection isVideoStabilizationSupported])
                [connection setEnablesVideoStabilizationWhenAvailable:YES];
            [self setMovieFileOutput:movieFileOutput];
        }
        
    });

    // Do any additional setup after loading the view.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(IBAction)choosevideo_clicked:(id)sender
{
    VMediaDevice *_vmediaDevice=[[VMediaDevice alloc]init];
    [_vmediaDevice setDeviceDelegate:self];
    [_vmediaDevice setIsCameraMode:NO];
    _vmediaDevice.mediaDeviceMode=TypeLibrary;
    
    [self presentViewController:_vmediaDevice animated:YES completion:nil];
    
}

-(IBAction)startover_clicked:(id)sender
{
    [self.navigationController.topViewController.navigationItem.rightBarButtonItem setEnabled:NO];
    
    [playerView clean];
    
    __progressview.progress = 0.0;
    [_progressbar setValue:0];
    [_progressbar setThumbImage: [UIImage imageNamed:@"0.png"] forState:UIControlStateNormal];
    [_videoPreviewView setHidden:YES];
    [_progressbarView setHidden:NO];
     _lbl_timestamp.text=@"0.00";

    [_btn_keep setHidden:YES];
    [_btn_startover setHidden:YES];
    [_cancelButton setHidden:YES];
    
    if (isChooseVideoMode)
    {
        VMediaDevice *_vmediaDevice=[[VMediaDevice alloc]init];
        [_vmediaDevice setDeviceDelegate:self];
        [_vmediaDevice setIsCameraMode:NO];
        _vmediaDevice.mediaDeviceMode=TypeLibrary;
        
        [self presentViewController:_vmediaDevice animated:YES completion:nil];
    }

}

-(IBAction)keepbtn_Clicked:(id)sender
{
    /*preview the user with the video */
//    [_btn_keep setHidden:YES];
//    [_btn_startover setHidden:YES];
   
     /* AVAsset  *avAsset = [AVAsset assetWithURL:[NSURL fileURLWithPath:videoFilepath]];
      AVPlayerItem *avPlayerItem =[[AVPlayerItem alloc]initWithAsset:avAsset];
      AVPlayer  *avPlayer = [[AVPlayer alloc]initWithPlayerItem:avPlayerItem];
      AVPlayerLayer  *avPlayerLayer =[AVPlayerLayer playerLayerWithPlayer:avPlayer];
//      [avPlayerLayer setFrame:self.previewView.frame];
    avPlayerLayer.frame=self.view.bounds;
    _videoPreviewView.clipsToBounds=YES;
      [_videoPreviewView.layer addSublayer:avPlayerLayer];
        //[avPlayerLayer setBackgroundColor:[[UIColor redColor]CGColor]];
        [avPlayer seekToTime:kCMTimeZero];
        [avPlayer play];
    */
    [self.navigationController.topViewController.navigationItem.rightBarButtonItem setEnabled:YES];

    if (!isChooseVideoMode)
    {
        [self playtheVideo];

    }
}

-(void)playtheVideo
{

    [_progressbarView setHidden:YES];
    [_videoPreviewView setHidden:NO];
    
    playerView = [[GUIPlayerView alloc] initWithFrame:_videoPreviewView.frame];
    [playerView setDelegate:self];
    
    [self.view bringSubviewToFront:_videoPreviewView];
    NSURL *URL = [NSURL fileURLWithPath:videoFilepath];
    [playerView setVideoURL:URL];
//    playerView.contentMode=UIViewContentModeScaleAspectFill;
    _videoPreviewView.clipsToBounds=YES;
//    playerView.bounds=self.view.bounds;
    [_videoPreviewView addSubview:playerView];
    [_videoPreviewView bringSubviewToFront:playerView];
    [playerView prepareAndPlayAutomatically:YES];

}

-(IBAction)cancel_btnClicked:(id)sender
{
    //unhide progress bar view;
    [_progressbarView setHidden:NO];
    
    isChooseVideoMode=NO;
    
    [playerView clean];
    [_videoPreviewView setHidden:YES];
    
    [_btn_keep setHidden:YES];
    [_btn_startover setHidden:YES];
    [_cancelButton setHidden:YES];
    
    [_chooseButton setHidden:NO];
    [_cameraButton setHidden:NO];
    [_recordButton setHidden:NO];

}

-(IBAction)bckbtn_clicked:(id)sender
{
    [playerView clean];
//    [self.navigationController popToRootViewControllerAnimated:YES];
    [self dismissViewControllerAnimated:YES completion:nil];

}
-(IBAction)donebtn_clicked:(id)sender
{
    [playerView clean];
    
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
    
    [self presentViewController:vc animated:YES completion:nil];
//    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([[segue identifier] isEqualToString:@"PostEmblm"]){
        PostEmblmVC *pvc = (PostEmblmVC *)[segue destinationViewController];
        pvc.videoFilePath = videoFilepath;
//        cvc.delegate = self;
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.navigationController.tabBarController.tabBar setHidden:NO];

    if (!isChooseVideoMode)
    {
        
        [self.navigationController.topViewController.navigationItem.rightBarButtonItem setEnabled:NO];
        
        [self.view bringSubviewToFront:_videoPreviewView];
        
        [_videoPreviewView setHidden:YES];
        [_progressbarView setHidden:NO];
        
        __progressview.color = [VSCore getColor:@"acacac" withDefault:[UIColor darkGrayColor]];
        __progressview.showText = @NO;
        __progressview.progress = 0;
        __progressview.borderRadius = @0;
        __progressview.animate = @YES;
        __progressview.type = LDProgressSolid;
        
        [_btn_keep setHidden:YES];
        [_btn_startover setHidden:YES];


    }
    
    else
    {
        [self playtheVideo];
//        isChooseVideoMode=NO;
        
        [_btn_keep setHidden:NO];
        [_btn_startover setHidden:NO];
        [_cancelButton setHidden:NO];

        [_chooseButton setHidden:YES];
        [_recordButton setHidden:YES];
        
    }
    
    dispatch_async([self sessionQueue], ^{
        [self addObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:SessionRunningAndDeviceAuthorizedContext];
        [self addObserver:self forKeyPath:@"movieFileOutput.recording" options:(NSKeyValueObservingOptionOld | NSKeyValueObservingOptionNew) context:RecordingContext];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        
        __weak AttachMediaVC *weakSelf = self;
        [self setRuntimeErrorHandlingObserver:[[NSNotificationCenter defaultCenter] addObserverForName:AVCaptureSessionRuntimeErrorNotification object:[self session] queue:nil usingBlock:^(NSNotification *note) {
            AttachMediaVC *strongSelf = weakSelf;
            dispatch_async([strongSelf sessionQueue], ^{
                // Manually restarting the session since it must have been stopped due to an error.
                [[strongSelf session] startRunning];
                //                [[strongSelf recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
            });
        }]];
        [[self session] startRunning];
    });

}


- (void)viewDidDisappear:(BOOL)animated
{
    
    dispatch_async([self sessionQueue], ^{
        [[self session] stopRunning];
        
        [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:[[self videoDeviceInput] device]];
        [[NSNotificationCenter defaultCenter] removeObserver:[self runtimeErrorHandlingObserver]];
        
        [self removeObserver:self forKeyPath:@"sessionRunningAndDeviceAuthorized" context:SessionRunningAndDeviceAuthorizedContext];
        [self removeObserver:self forKeyPath:@"movieFileOutput.recording" context:RecordingContext];
    });
    
}

- (void) dragBegan: (UIButton *) c withEvent:ev
{
    
    if ([_frontCamButton isEnabled])
    {
        [_frontCamButton setEnabled:NO];
    }
    
    if (!_timer) {
        _timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                  target:self
                                                selector:@selector(_timerFired:)
                                                userInfo:nil
                                                 repeats:YES];
    }
    
    NSLog(@"dragBegan......");
    /*start recording a video */
    
    Float64 maximumVideoLength = 31; //Whatever value you wish to set as the maximum, in seconds
    int32_t prefferedTimeScale = 31;//Frames per second
    
    CMTime maxDuration = CMTimeMakeWithSeconds(maximumVideoLength, prefferedTimeScale);
    
    self.movieFileOutput.maxRecordedDuration = maxDuration;
    
   	dispatch_async([self sessionQueue], ^{
        if (![[self movieFileOutput] isRecording])
        {
           
            
            [self setLockInterfaceRotation:YES];
            
            if ([[UIDevice currentDevice] isMultitaskingSupported])
            {
                // Setup background task. This is needed because the captureOutput:didFinishRecordingToOutputFileAtURL: callback is not received until AVCam returns to the foreground unless you request background execution time. This also ensures that there will be time to write the file to the assets library when AVCam is backgrounded. To conclude this background execution, -endBackgrrecordedoundTask is called in -recorder:recordingDidFinishToOutputFileURL:error: after the  file has been saved.
                [self setBackgroundRecordingID:[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:nil]];
            }
            
            // Update the orientation on the movie file output video connection before starting recording.
            [[[self movieFileOutput] connectionWithMediaType:AVMediaTypeVideo] setVideoOrientation:[[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] videoOrientation]];

//            // Turning OFF flash for video recording
            [AttachMediaVC setFlashMode:AVCaptureFlashModeOff forDevice:[[self videoDeviceInput] device]];
//
//            // Start recording to a temporary file.
            NSMutableString *filePath = [[NSMutableString alloc] initWithFormat:@"%@", [VSCore getVideosFolder]];
            NSMutableString *filename = [NSMutableString stringWithFormat:@"%@_%@.jpg",[VSCore getUserID],[VSCore getUniqueFileName]];
            NSString *outputFilePath = [filePath stringByAppendingPathComponent:filename];

//            NSString *outputFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[@"movie" stringByAppendingPathExtension:@"mov"]];
            [[self movieFileOutput] startRecordingToOutputFileURL:[NSURL fileURLWithPath:outputFilePath] recordingDelegate:self];
        }
        else
        {
            NSLog(@"Recording Stopped");
            [[self movieFileOutput] stopRecording];
            
            
            
        }
    });

    
}

- (void) dragMoving: (UIButton *) c withEvent:ev
{
    NSLog(@"dragMoving..............");
}

- (void) dragEnded: (UIButton *) c withEvent:ev
{
   /*check the time of recording and pause it if not reached the maximumtime */
    [self stopTimer];
    NSLog(@"Recording Stopped");
    [[self movieFileOutput] stopRecording];

    [_frontCamButton setEnabled:YES];
    /*compare the currentvideorecording time to the maxtimeframe of the video */
    
    
}

- (void)_timerFired:(NSTimer *)timer
{
//    NSLog(@"seconds = %f", CMTimeGetSeconds(self.movieFileOutput.recordedDuration));
    
    Float64 dur = self.movieFileOutput.recordedDuration.value/self.movieFileOutput.recordedDuration.timescale;
    
//    NSLog(@"Recorded Duration:%f", dur);
    
    __progressview.progress=dur;
    
    NSUInteger durationInSeconds = CMTimeGetSeconds(self.movieFileOutput.recordedDuration);
    NSUInteger durationInMinutes = durationInSeconds / 60;
    NSUInteger durationInRemainder = durationInSeconds % 60;

    
    CGFloat strFloat;
    NSString *finalDurationString=nil;
    
    if(durationInRemainder < 10)
    {
        finalDurationString = [NSString stringWithFormat:@"%i:0%i", durationInMinutes, durationInRemainder];
        strFloat = [[NSString stringWithFormat:@"%i.0%i", durationInMinutes, durationInRemainder] floatValue];


    }
    else
    {
        finalDurationString = [NSString stringWithFormat:@"%i:%i", durationInMinutes, durationInRemainder];
        strFloat = [[NSString stringWithFormat:@"%i.%i", durationInMinutes, durationInRemainder] floatValue];

    }
 
//    NSLog(@"%f",strFloat);
    
    _lbl_timestamp.text=finalDurationString;
    //__progressview.progress=strFloat*3.4;
    
    [_progressbar setValue:durationInSeconds];
    [_progressbar setThumbImage: [UIImage imageNamed:[NSString stringWithFormat:@"%i.png",durationInSeconds]] forState:UIControlStateNormal];
}

- (void)stopTimer
{
    if ([_timer isValid]) {
        [_timer invalidate];
        
    }
    _timer = nil;
}

- (BOOL)shouldAutorotate
{
    // Disable autorotation of the interface when recording is in progress.
    return ![self lockInterfaceRotation];
}

- (NSUInteger)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskAll;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [[(AVCaptureVideoPreviewLayer *)[[self previewView] layer] connection] setVideoOrientation:(AVCaptureVideoOrientation)toInterfaceOrientation];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == CapturingStillImageContext)
    {
        BOOL isCapturingStillImage = [change[NSKeyValueChangeNewKey] boolValue];
        
        if (isCapturingStillImage)
        {
            [self runStillImageCaptureAnimation];
        }
    }
    else if (context == RecordingContext)
    {
        BOOL isRecording = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRecording)
            {
                [[self cameraButton] setEnabled:NO];
//                [[self recordButton] setTitle:NSLocalizedString(@"Stop", @"Recording button stop title") forState:UIControlStateNormal];
                [[self recordButton] setImage:[UIImage imageNamed:@"capture.png"] forState:UIControlStateNormal];
                [[self recordButton] setEnabled:YES];
            }
            else
            {
                [[self cameraButton] setEnabled:YES];
//                [[self recordButton] setTitle:NSLocalizedString(@"Record", @"Recording button record title") forState:UIControlStateNormal];
                [[self recordButton] setImage:[UIImage imageNamed:@"capture.png"] forState:UIControlStateNormal];
                [[self recordButton] setEnabled:YES];
            }
        });
    }
    else if (context == SessionRunningAndDeviceAuthorizedContext)
    {
        BOOL isRunning = [change[NSKeyValueChangeNewKey] boolValue];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (isRunning)
            {
//                [[self cameraButton] setEnabled:YES];
//                [[self recordButton] setEnabled:YES];
//                [[self stillButton] setEnabled:YES];
            }
            else
            {
//                [[self cameraButton] setEnabled:NO];
//                [[self recordButton] setEnabled:NO];
//                [[self stillButton] setEnabled:NO];
            }
        });
    }
    else
    {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

+ (UIImage*)previewFromFileAtPath:(NSString*)path ratio:(CGFloat)ratio
{
    AVAsset *asset = [AVURLAsset assetWithURL:[NSURL fileURLWithPath:path]];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    CMTime duration = asset.duration;
    CGFloat durationInSeconds = duration.value / duration.timescale;
    CMTime time = CMTimeMakeWithSeconds(durationInSeconds * ratio, (int)duration.value);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);
    
    return thumbnail;
}

- (void)subjectAreaDidChange:(NSNotification *)notification
{
    CGPoint devicePoint = CGPointMake(.5, .5);
    [self focusWithMode:AVCaptureFocusModeContinuousAutoFocus exposeWithMode:AVCaptureExposureModeContinuousAutoExposure atDevicePoint:devicePoint monitorSubjectAreaChange:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(IBAction)openFrontCamera:(id)sender
{
    [[self cameraButton] setEnabled:NO];
    [[self recordButton] setEnabled:NO];
    [[self chooseButton] setEnabled:NO];
    
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *currentVideoDevice = [[self videoDeviceInput] device];
        AVCaptureDevicePosition preferredPosition = AVCaptureDevicePositionUnspecified;
        AVCaptureDevicePosition currentPosition = [currentVideoDevice position];
        
        switch (currentPosition)
        {
            case AVCaptureDevicePositionUnspecified:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
            case AVCaptureDevicePositionBack:
                preferredPosition = AVCaptureDevicePositionFront;
                break;
            case AVCaptureDevicePositionFront:
                preferredPosition = AVCaptureDevicePositionBack;
                break;
        }
        
        AVCaptureDevice *videoDevice = [AttachMediaVC deviceWithMediaType:AVMediaTypeVideo preferringPosition:preferredPosition];
        AVCaptureDeviceInput *videoDeviceInput = [AVCaptureDeviceInput deviceInputWithDevice:videoDevice error:nil];
        
        [[self session] beginConfiguration];
        
        [[self session] removeInput:[self videoDeviceInput]];
        if ([[self session] canAddInput:videoDeviceInput])
        {
            [[NSNotificationCenter defaultCenter] removeObserver:self name:AVCaptureDeviceSubjectAreaDidChangeNotification object:currentVideoDevice];
            
            [AttachMediaVC setFlashMode:AVCaptureFlashModeAuto forDevice:videoDevice];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(subjectAreaDidChange:) name:AVCaptureDeviceSubjectAreaDidChangeNotification object:videoDevice];
            
            [[self session] addInput:videoDeviceInput];
            [self setVideoDeviceInput:videoDeviceInput];
        }
        else
        {
            [[self session] addInput:[self videoDeviceInput]];
        }
        
        [[self session] commitConfiguration];
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [[self recordButton] setEnabled:YES];
            [[self chooseButton] setEnabled:YES];
            [[self cameraButton] setEnabled:YES];
        });
    });

}

#pragma mark File Output Delegate

- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection {
    
    NSLog(@"delegate method called");
    
//    CGImageRef cgImage = [self imageFromSampleBuffer:sampleBuffer];
//    
//    dispatch_sync(dispatch_get_main_queue(),
//                  ^{
//                      self.theImage.image = [UIImage imageWithCGImage: cgImage ];
//                      CGImageRelease( cgImage );
//                  });
}
- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didFinishRecordingToOutputFileAtURL:(NSURL *)outputFileURL fromConnections:(NSArray *)connections error:(NSError *)error
{
    [self stopTimer];
    [_btn_startover setHidden:NO];
    [_btn_keep setHidden:NO];
    
    if (([error code] == AVErrorMaximumDurationReached))
    {
        //        [delegate captureSessionMaxDurationReached];
        NSLog(@"AVErrorMaximumDurationReached");
        
        UIAlertView *message=[[UIAlertView alloc] initWithTitle:@"Message" message:@"Reached maximum time for taking video" delegate:nil cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [message show];
        
    }
    if (error)
        NSLog(@"%@", error);
    
    
    NSMutableString *filePath = [[NSMutableString alloc] initWithFormat:@"%@", [VSCore getVideosFolder]];
    NSMutableString *filename = [NSMutableString stringWithFormat:@"%@_%@.mp4",[VSCore getUserID],[VSCore getUniqueFileName]];
    videoFilepath = [filePath stringByAppendingPathComponent:filename];
    
     NSData *videoData = [NSData dataWithContentsOfURL:outputFileURL];
    
    if (![videoData writeToFile:videoFilepath atomically:YES])
    {
        
        NSLog(@"There was a problem writing the image %@", videoFilepath);
    }

    /*save thumbnail image to image folder of video*/
    NSMutableString *imagefilePath = [[NSMutableString alloc] initWithFormat:@"%@", [VSCore getImagesFolder]];
    NSMutableString *imagefilename = [NSMutableString stringWithFormat:@"%@_%@.jpg",[VSCore getUserID],[VSCore getUniqueFileName]];
    imgfilePath = [imagefilePath stringByAppendingPathComponent:imagefilename];
    
    UIImage *chosenImage = [AttachMediaVC  previewFromFileAtPath:videoFilepath ratio:0.1];
    
 /*   CGSize newSize = CGSizeMake(600, 600);
    
    UIGraphicsBeginImageContext( newSize );// a CGSize that has the size you want
    [chosenImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    //image is the original UIImage
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
*/
    
    NSData *imD = [NSData dataWithData:UIImageJPEGRepresentation(chosenImage, 1.0f)];

    if (![imD writeToFile:imgfilePath atomically:YES])
    {
        NSLog(@"There was a problem writing the image %@", imgfilePath);
    }

    [self setLockInterfaceRotation:NO];
    
    // Note the backgroundRecordingID for use in the ALAssetsLibrary completion handler to end the background task associated with this recording. This allows a new recording to be started, associated with a new UIBackgroundTaskIdentifier, once the movie file output's -isRecording is back to NO — which happens sometime after this method returns.
    UIBackgroundTaskIdentifier backgroundRecordingID = [self backgroundRecordingID];
    [self setBackgroundRecordingID:UIBackgroundTaskInvalid];
    
    [[[ALAssetsLibrary alloc] init] writeVideoAtPathToSavedPhotosAlbum:outputFileURL completionBlock:^(NSURL *assetURL, NSError *error) {
        if (error)
            NSLog(@"%@", error);
        
        [[NSFileManager defaultManager] removeItemAtURL:outputFileURL error:nil];
        
        if (backgroundRecordingID != UIBackgroundTaskInvalid)
            [[UIApplication sharedApplication] endBackgroundTask:backgroundRecordingID];
    }];
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didPauseRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    NSLog(@"didPauseRecordingToOutputFileAtURL Called");
}

- (void)captureOutput:(AVCaptureFileOutput *)captureOutput didResumeRecordingToOutputFileAtURL:(NSURL *)fileURL fromConnections:(NSArray *)connections
{
    NSLog(@"didResumeRecordingToOutputFileAtURL Called");
}

#pragma mark Device Configuration

- (void)focusWithMode:(AVCaptureFocusMode)focusMode exposeWithMode:(AVCaptureExposureMode)exposureMode atDevicePoint:(CGPoint)point monitorSubjectAreaChange:(BOOL)monitorSubjectAreaChange
{
    dispatch_async([self sessionQueue], ^{
        AVCaptureDevice *device = [[self videoDeviceInput] device];
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            if ([device isFocusPointOfInterestSupported] && [device isFocusModeSupported:focusMode])
            {
                [device setFocusMode:focusMode];
                [device setFocusPointOfInterest:point];
            }
            if ([device isExposurePointOfInterestSupported] && [device isExposureModeSupported:exposureMode])
            {
                [device setExposureMode:exposureMode];
                [device setExposurePointOfInterest:point];
            }
            [device setSubjectAreaChangeMonitoringEnabled:monitorSubjectAreaChange];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    });
}

+ (void)setFlashMode:(AVCaptureFlashMode)flashMode forDevice:(AVCaptureDevice *)device
{
    if ([device hasFlash] && [device isFlashModeSupported:flashMode])
    {
        NSError *error = nil;
        if ([device lockForConfiguration:&error])
        {
            [device setFlashMode:flashMode];
            [device unlockForConfiguration];
        }
        else
        {
            NSLog(@"%@", error);
        }
    }
}

+ (AVCaptureDevice *)deviceWithMediaType:(NSString *)mediaType preferringPosition:(AVCaptureDevicePosition)position
{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:mediaType];
    AVCaptureDevice *captureDevice = [devices firstObject];
    
    for (AVCaptureDevice *device in devices)
    {
        if ([device position] == position)
        {
            captureDevice = device;
            break;
        }
    }
    
    return captureDevice;
}

#pragma mark UI

- (void)runStillImageCaptureAnimation
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [[[self previewView] layer] setOpacity:0.0];
        [UIView animateWithDuration:.25 animations:^{
            [[[self previewView] layer] setOpacity:1.0];
        }];
    });
}

- (void)checkDeviceAuthorizationStatus
{
    NSString *mediaType = AVMediaTypeVideo;
    
    [AVCaptureDevice requestAccessForMediaType:mediaType completionHandler:^(BOOL granted) {
        if (granted)
        {
            //Granted access to mediaType
            [self setDeviceAuthorized:YES];
        }
        else
        {
            //Not granted access to mediaType
            dispatch_async(dispatch_get_main_queue(), ^{
                [[[UIAlertView alloc] initWithTitle:@"AVCam!"
                                            message:@"AVCam doesn't have permission to use Camera, please change privacy settings"
                                           delegate:self
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil] show];
                [self setDeviceAuthorized:NO];
            });
        }
    }];
}

#pragma mark PostEmblmVCDelegate Methods
-(void)dismissAttachMediaandPoptoScannerVC
{
    [self dismissViewControllerAnimated:YES completion:nil];
    [self.navigationController popToRootViewControllerAnimated:YES];

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
            
            UIImage *chosenImage = [AttachMediaVC  previewFromFileAtPath:videoFilepath ratio:0.1];
            
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

#pragma mark - GUI Player View Delegate Methods

- (void)playerWillEnterFullscreen {
    [[self navigationController] setNavigationBarHidden:YES];
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
}

- (void)playerWillLeaveFullscreen {
    [[self navigationController] setNavigationBarHidden:NO];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)playerDidEndPlaying {
    
    //  [playerView clean];
    
}
- (void)playerFailedToPlayToEnd {
    NSLog(@"Error: could not play video");
    [playerView clean];
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
