//
//  PostEmblmVC.m
//  emblm
//
//  Created by Kavya Valavala on 1/30/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "PostEmblmVC.h"
#import "VSCore.h"
#import <AVFoundation/AVFoundation.h>
#import "WebService.h"
#import "ProgressHUD.h"
#import "PostDetailsVC.h"
#import "ApplicationSettings.h"
#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/AWSS3TransferManager.h>
#import "MBProgressHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "ScannerViewController.h"
#import "JGProgressHUDRingIndicatorView.h"

NSString * const MY_VIDEO_BUCKET        =@"emblmpost";


@interface PostEmblmVC ()<UITextFieldDelegate, WebServiceDelegate, MBProgressHUDDelegate>
{
    NSInteger switchValue;
    NSDictionary *resultDict;
    MBProgressHUD *HUD;
    BOOL       videoUploadDone;
    BOOL       isfinalizebtn_pressed;
    JGProgressHUD *_pro;
}
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest1;
@property (nonatomic, strong) AWSS3TransferManagerUploadRequest *uploadRequest2;

@property (nonatomic) uint64_t file1AlreadyUpload;
@property (nonatomic) uint64_t file2AlreadyUpload;

@property (nonatomic) uint64_t file2Size;



@end


@implementation PostEmblmVC
@synthesize videoFilePath,postemblmDelegate,postDataDict;

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    videoUploadDone=NO;
    isfinalizebtn_pressed=NO;
    
    [self prepareforUploadToAWS];

    _pro=[[JGProgressHUD alloc]initWithStyle:JGProgressHUDStyleDark];
    _pro.indicatorView=[[JGProgressHUDRingIndicatorView alloc]initWithHUDStyle:JGProgressHUDStyleDark];
    _pro.textLabel.text=@"Uploading..";
       // _pro.progress=0.20;
//    [_pro setHidden:YES];

    [self updateProgress];

    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    self.navigationController.navigationBar.hidden=YES;
    
    [_txt_stickfield setFont:[UIFont fontWithName:TITLE_FONT size:18]];
    [_txt_stickfield setTextColor:[UIColor lightGrayColor]];

    [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;

    
    [super viewDidLoad];
    
    /*when user arrives this form start uploading Thumbnail Image and video to AWS */
    
    [self.view bringSubviewToFront:_btn_finalize];
    
    self._navbar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];

    [self._navbar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];

    
    _lbl_description.adjustsFontSizeToFitWidth = YES;
    
    switchValue=0;

    self._navbar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];

    [self._navbar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    
    [self.btn_finalize setBackgroundColor:[VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]]];
    self.btn_finalize.titleLabel.textColor=[UIColor whiteColor];
    self.btn_finalize.titleLabel.font = [UIFont fontWithName:TITLE_FONT size:22];

    self.view.backgroundColor=[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]];
 
    _lbl_sticking.font=[UIFont fontWithName:TITLE_FONT size:17];
    
    _lbl_makeprivate.font=[UIFont fontWithName:TITLE_FONT size:22];
//    _lbl_makeprivate.textColor=[VSCore getColor:@"1a1a1a" withDefault:[UIColor blackColor]];
    
    _lbl_description.font=[UIFont fontWithName:TITLE_FONT size:14];

    [self.imgview setImage:[PostEmblmVC previewFromFileAtPath:videoFilePath ratio:0.1]];
        
    [_txt_notes setFont:[UIFont fontWithName:OTHER_FONT size:17]];

//    [_btn_finalize setEnabled:NO];

    // Do any additional setup after loading the view.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


-(void)viewWillAppear:(BOOL)animated{

    [_lbl_status setHidden:YES];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)changeSwitch:(id)sender
{
    //1 = A private emblm. 0 = A public emblm.
    if([sender isOn])
    {
        NSLog(@"Switch is ON");
        switchValue=1;
        
    } else{
        NSLog(@"Switch is OFF");
        switchValue=0;
    }
}

-(void)prepareforUploadToAWS
{
    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:MY_ACCESS_KEY_ID secretKey:MY_SECRET_KEY];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
                                                                          credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

    
    NSString *videofileName=[postDataDict objectForKey:@"videoFilePath"];
    NSString *imageName=[postDataDict objectForKey:@"imagefilePath"];

    __weak typeof(self) weakSelf = self;
    
    self.uploadRequest1 = [AWSS3TransferManagerUploadRequest new];
    self.uploadRequest1.bucket = MY_VIDEO_BUCKET;
    self.uploadRequest1.key = [imageName lastPathComponent];
    self.uploadRequest1.contentType = @"image/jpg";
    self.uploadRequest1.ACL = AWSS3ObjectCannedACLPublicRead;

    NSData *imagefileData = [NSData dataWithContentsOfFile:imageName];

    self.uploadRequest1.body = [NSURL fileURLWithPath:imageName];
    self.uploadRequest1.contentLength = [NSNumber numberWithUnsignedLongLong:(unsigned long long int) [imagefileData length]];

    self.uploadRequest1.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.file1AlreadyUpload = totalBytesSent;
//            [weakSelf updateProgress];
        });
    };
    
    self.uploadRequest2 = [AWSS3TransferManagerUploadRequest new];
    self.uploadRequest2.bucket = MY_VIDEO_BUCKET;
    self.uploadRequest2.key = [videofileName lastPathComponent];
    self.uploadRequest2.contentType = @"video/mp4";

    self.uploadRequest2.ACL = AWSS3ObjectCannedACLPublicRead;

    NSData *fileData = [NSData dataWithContentsOfFile:[postDataDict objectForKey:@"videoFilePath"]];
    
    self.file2Size = [fileData length];
    self.uploadRequest2.contentLength = [NSNumber numberWithUnsignedLongLong:(unsigned long long int) _file2Size];

    self.uploadRequest2.body = [NSURL fileURLWithPath:videofileName];
    self.uploadRequest2.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.file2AlreadyUpload = totalBytesSent;
            [weakSelf updateProgress];
        });
    };

    [self uploadFiles];
}

- (void) uploadFiles {
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    __block int uploadCount = 0;
    [[transferManager upload:self.uploadRequest1] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error != nil) {
            if( task.error.code != AWSS3TransferManagerErrorCancelled
               &&
               task.error.code != AWSS3TransferManagerErrorPaused
               )
            {
                NSLog(@"Failed");
            }
        } else {
            self.uploadRequest1 = nil;
            uploadCount ++;
            if(2 == uploadCount)
            {
                NSLog(@"Completed");
            }
        }
        return nil;
    }];
    
    [[transferManager upload:self.uploadRequest2] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error != nil) {
            if( task.error.code != AWSS3TransferManagerErrorCancelled
               &&
               task.error.code != AWSS3TransferManagerErrorPaused
               )
            {
//                self.uploadStatusLabel.text = StatusLabelFailed;
                NSLog(@"Failed");
            }
        } else {
            self.uploadRequest2 = nil;
            uploadCount ++;
            if(2 == uploadCount){
//                self.uploadStatusLabel.text = StatusLabelCompleted;
                NSLog(@"Completed");
                
                videoUploadDone=YES;
                
                if (videoUploadDone && isfinalizebtn_pressed)
                {
                    /*Upload happened */
                    
                    [self sendpostdetailsToFlashbaqAPI];
                    /*UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                    PostDetailsVC *vc = (PostDetailsVC *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetails"];
                    vc.resultDict=resultDict;
                    vc.hidesBottomBarWhenPushed=NO;
                    
                    [self.navigationController pushViewController:vc animated:YES];*/
                }

//                [ProgressHUD dismiss];
                [_pro dismiss];
                
            }
        }
        return nil;
    }];
}

-(IBAction)bckbtn_clicked:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
//    if ([postemblmDelegate respondsToSelector:@selector(dismissPostEmblmVC)])
//    {
//        [postemblmDelegate dismissPostEmblmVC];
//    }
//    [self dismissViewControllerAnimated:YES completion:nil];
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

#pragma UItextViewDelegate Methods

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    
    return YES;
}

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if([_txt_notes.text isEqualToString:@"Write a message..."])
    {
        [_txt_notes setText:@""];
        [_txt_notes setTextColor:[UIColor blackColor]];
    }
}


-(IBAction)finalizebtn_clicked:(id)sender
{
    isfinalizebtn_pressed=YES;

//    _pro.progress=0.20;
    [_pro showInView:self.view];

    

    [_btn_finalize setEnabled:NO];

    if (videoUploadDone)
    {
        /*First upload video to AWS and after success, send postdetails to AWS */
       
        [self sendpostdetailsToFlashbaqAPI];
    }
    
  
    //send the delegate to pop to rootviewcontroller
    
}

-(void)sendpostdetailsToFlashbaqAPI
{
    //
    //    // Set determinate bar mode
    //        /*send Data to the server */
    NSArray *keys = [NSArray arrayWithObjects:@"emblm", @"owner",@"media", @"media_preview", @"message" , @"location" , @"private", nil];
    NSArray *objects=[NSArray arrayWithObjects:[[postDataDict objectForKey:@"emblmID"]objectForKey:@"id"],[VSCore getUserID],[[postDataDict objectForKey:@"videoFilePath"] lastPathComponent],[[postDataDict objectForKey:@"imagefilePath"] lastPathComponent],_txt_notes.text,_txt_stickfield.text,[NSNumber numberWithInteger:switchValue], nil];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    WebService *_webservice=[[WebService alloc]init];
    [_webservice setWebDelegate:self];
    [_webservice SendJSONDataToServer:dataDict toURI:createPost forRequestType:POST];
}

- (void)updateProgress {
    
    if (self.file2AlreadyUpload <= self.file2Size)
    {
        _pro.progress = (float)self.file2AlreadyUpload / (float)self.file2Size;
    }
    
}


#pragma mark WebSerService Delegate methods
-(void)responseReceivedwithData:(NSDictionary *)data
{
    resultDict=data;
    
//        [ProgressHUD dismiss];
        [_pro dismiss];

        /*Upload happened */
        videoUploadDone=NO;
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PostDetailsVC *vc = (PostDetailsVC *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetails"];
        vc.flashbaqCode=[[postDataDict objectForKey:@"emblmID"] objectForKey:@"code"];
        vc.resultDict=resultDict;
        
        vc.hidesBottomBarWhenPushed=NO;
        
        [self.navigationController pushViewController:vc animated:YES];
    
}

#pragma UITextFieldDelegate methods
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];

    return YES;
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
