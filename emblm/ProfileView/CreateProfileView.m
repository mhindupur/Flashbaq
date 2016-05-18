//
//  CreateProfileView.m
//  emblm
//
//  Created by Kavya Valavala on 1/5/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "CreateProfileView.h"
#import "VSCore.h"
#import "VMediaDevice.h"
#import "WebService.h"
#import "AppDelegate.h"
#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/AWSS3TransferManager.h>


@interface CreateProfileView ()<MediaDeviceDelegate, UITextFieldDelegate , WebServiceDelegate>
{
    UIView *inputAccessoryView;
    UIButton *contButton;
    UIActivityIndicatorView *activityIndicator;
    NSString *profileImage;
    AWSS3TransferManagerUploadRequest *uploadRequest;
}

@property (nonatomic) uint64_t file1AlreadyUpload;

@end

@implementation CreateProfileView

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }

    [AWSLogger defaultLogger].logLevel = AWSLogLevelVerbose;

    self._navbar.barStyle = UIBarStyleBlack;

    self._navbar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];
    [self._navbar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    [btn setImage:[UIImage imageNamed:@"skip.png"] forState:UIControlStateNormal];
    self.navigationItem.rightBarButtonItem = __skipbtn;
    self.view.backgroundColor=[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]];

    CALayer * l = [__imageView layer];
    [l setMasksToBounds:YES];
    //    [l setCornerRadius:50.0];
    [l setCornerRadius:__imageView.frame.size.width/2];
    
    [_txt_firstName setFont:[UIFont fontWithName:OTHER_FONT size:17]];
    [_txt_lastName setFont:[UIFont fontWithName:OTHER_FONT size:17]];

    CGFloat leftInset = 10.0f;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, leftInset, self.view.bounds.size.height)];
    _txt_firstName.leftView = leftView;
    _txt_firstName .leftViewMode= UITextFieldViewModeAlways;
    
    UIView *insetleftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, leftInset, self.view.bounds.size.height)];
    _txt_lastName.leftView = insetleftView;
    _txt_lastName .leftViewMode= UITextFieldViewModeAlways;
    // Do any additional setup after loading the view.
    
    
    _btn_continue.titleLabel.font = [UIFont fontWithName:TITLE_FONT size:18.0];
    [_btn_continue setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btn_continue setBackgroundColor:[VSCore getColor:@"0ab7a4" withDefault:[UIColor blackColor]]];
    // Commit the changes and perform the animation.
 //   [UIView commitAnimations];
    
   // [_txt_firstName becomeFirstResponder];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];

    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:MY_ACCESS_KEY_ID secretKey:MY_SECRET_KEY];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
                                                                          credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*- (UIView *)inputAccessoryView
{
    if (!inputAccessoryView) {
        CGRect accessFrame = CGRectMake(0.0, 0.0, 414.0, 50.0);
        inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
        //        inputAccessoryView.backgroundColor = [VSCore getColor:@"0ab7a4" withDefault:[UIColor blackColor]];
        inputAccessoryView.backgroundColor = [UIColor clearColor];
        contButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        contButton.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, 45.0);
        contButton.titleLabel.font = [UIFont fontWithName:TITLE_FONT size:18.0];
        [contButton setTitle: @"Continue" forState:UIControlStateNormal];
        [contButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [contButton addTarget:self action:@selector(buttonClicked)
             forControlEvents:UIControlEventTouchUpInside];
        [contButton setHidden:NO];
        [inputAccessoryView addSubview:contButton];
        
        //Create and add the Activity Indicator to splashView
        if (!activityIndicator)
        {
            activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            activityIndicator.alpha = 1.0;
            activityIndicator.center = CGPointMake(self.view.frame.size.width-20,22);
            activityIndicator.hidesWhenStopped = YES;
            [contButton addSubview:activityIndicator];
            
        }
        
    }
    return inputAccessoryView;
}
*/
-(IBAction)skip_clicked:(id)sender
{
    /* User should go to HomeScreen */
    [inputAccessoryView setHidden:YES];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
    [VSCore setTabBaritemsforvc:vc];
    [self presentViewController:vc animated:YES completion:nil];

}

-(IBAction)back_clicked:(id)sender
{
    /* User should go to LoginPage */
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"signup"];
    [self presentViewController:vc animated:YES completion:nil];

}

-(IBAction)choosePhoto_clicked:(id)sender
{
    VMediaDevice *_vmediaDevice=[[VMediaDevice alloc]init];
    [_vmediaDevice setDeviceDelegate:self];
    [_vmediaDevice setIsCameraMode:YES];
    _vmediaDevice.mediaDeviceMode=TypeLibrary;
    
    [self presentViewController:_vmediaDevice animated:YES completion:nil];

}

-(IBAction)buttonClicked:(id)sender
{
    NSString *imagepath=nil;
    
    if ([profileImage length] > 0)
    {
        imagepath=[profileImage lastPathComponent];
        [self uploadimagetoAWS];
    }
    
    else
    {
        imagepath=@"";
    }
    
    [activityIndicator startAnimating];
    
    /*send Data to the server */
    NSArray *keys = [NSArray arrayWithObjects: @"first_name", @"last_name",@"user_image", nil];
    
//    NSArray *_keys = [NSArray arrayWithObjects:@"username", @"first_name", @"last_name",@"email",@"password",@"user_image",@"facebook_id",@"facebook_token",@"allow_notifications",@"allow_emails", nil];

    NSString *firstName=nil;
    
    if ([_txt_firstName.text length] > 0)
    {
        firstName=_txt_firstName.text;
    }
    else
    {
        firstName=@"";
    }
    
    NSString *lastName=nil;
    
    if ([_txt_lastName.text length] > 0)
    {
        lastName=_txt_lastName.text;
    }
    
    else
    {
        lastName=@"";
    }
    
    NSArray *objects=[NSArray arrayWithObjects:firstName,lastName, imagepath, nil];

    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
   
    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;
//    NSString *url=[NSString stringWithFormat:@"https://api.flashbaq.com/v1/users/%@",[VSCore getUserID]];
    NSString *url=@"https://api.flashbaq.com/v1/users/18";

    [_webservice SendJSONDataToServer:dataDict toURI:url forRequestType:PUT];
}

- (CGRect)textRectForBounds:(CGRect)bounds
{
    return CGRectInset( bounds , 20 , 20 );
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)uploadimagetoAWS
{
    
    __weak typeof(self) weakSelf = self;

    NSString *fileName=[NSString stringWithFormat:@"%@",[profileImage lastPathComponent]];
    
    uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = MY_PICTURE_BUCKET;
    uploadRequest.key = fileName;
    uploadRequest.body = [NSURL fileURLWithPath:profileImage];
    uploadRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.file1AlreadyUpload = totalBytesSent;
//            [weakSelf updateProgress];
        });
    };

    [self uploadFiles];
   /* AmazonS3Client *s3 = [[AmazonS3Client alloc] initWithAccessKey:MY_ACCESS_KEY_ID withSecretKey:MY_SECRET_KEY];
    
    //[s3 createBucket:[[[S3CreateBucketRequest alloc] initWithName:MY_PICTURE_BUCKET] autorelease]];
    
    S3PutObjectRequest *por = [[S3PutObjectRequest alloc] initWithKey:[profileImage lastPathComponent] inBucket:MY_PICTURE_BUCKET];
    por.contentType = @"image/jpeg";
    

   NSData *imgdata=[NSData dataWithContentsOfFile:profileImage];
    por.data=imgdata;
    //[s3 putObject:por];
    
    S3TransferManager *manager = [S3TransferManager new];
    manager.s3 = s3;
    
    AppDelegate *_appdelegate=(AppDelegate*)[[UIApplication sharedApplication] delegate];
    manager.delegate=_appdelegate;
    [manager upload:por];
  */

}

- (void) uploadFiles {
    AWSS3TransferManager *transferManager = [AWSS3TransferManager defaultS3TransferManager];
    
    __block int uploadCount = 0;
    [[transferManager upload:uploadRequest] continueWithExecutor:[BFExecutor mainThreadExecutor] withBlock:^id(BFTask *task) {
        if (task.error != nil) {
            if( task.error.code != AWSS3TransferManagerErrorCancelled
               &&
               task.error.code != AWSS3TransferManagerErrorPaused
               )
            {
                NSLog(@"StatusFailed");
//                self.uploadStatusLabel.text = StatusLabelFailed;
            }
        } else
        {
            uploadRequest = nil;
            uploadCount ++;
            if(1 == uploadCount)
            {
                NSLog(@"Completed");
            }
        }
        return nil;
    }];
}


#pragma mark MediaDeviceDelegate Methods
-(void)imagePickerdidfinishLoadedWithData:(NSDictionary *)mediaData
{
    if ([[[mediaData objectForKey:@"filename"] pathExtension] isEqualToString:@"jpg"])
    {
        profileImage=[mediaData objectForKey:@"filepath"];
        __imageView.image=[UIImage imageWithContentsOfFile:[mediaData objectForKey:@"filepath"]];
        
    }
}

-(void)dismissMediaDeviceView
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void)imagePickerdidCancelled
{
    [self dismissViewControllerAnimated:YES completion:nil];
}
#pragma mark UITextFieldDelegate Methods

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
//    [_btn_FBLogin setHidden:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (([_txt_firstName.text isEqualToString:@""] ) && ([_txt_lastName.text isEqualToString:@"" ]))
    {
//        [self.btn_FBLogin setHidden:NO];
    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /* if text is entered in all the three fields, display continue button */
    
    //Code commented by kavya on 12June 2015
    
 /*   if (([_txt_firstName.text length]>0) && ([_txt_lastName.text length]>0))
    {
        [UIView beginAnimations:@"ShowHideView" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:1.0];
        inputAccessoryView.backgroundColor = [VSCore getColor:@"0ab7a4" withDefault:[UIColor blackColor]];
        [contButton setHidden:NO];
        
        // Commit the changes and perform the animation.
        [UIView commitAnimations];
    }
    
    else
    {
        [UIView beginAnimations:@"ShowHideView" context:nil];
        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
        [UIView setAnimationDuration:1.0];
        inputAccessoryView.backgroundColor = [UIColor clearColor];
        [contButton setHidden:YES];
        
        // Commit the changes and perform the animation.
        [UIView commitAnimations];
        
    }
 */
    
    return YES;
}

#pragma mark WebServiceDelegate methods
-(void)responseReceivedwithData:(NSDictionary *)data
{
    [activityIndicator stopAnimating];
    [inputAccessoryView setHidden:YES];
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithContentsOfFile:[VSCore getPlistPath:@"userTokenData_m"]];
    
    [dict setObject:[data objectForKey:@"user_image"] forKey:@"user_image"];
    [dict setObject:[data objectForKey:@"username"] forKey:@"username"];
    [dict setObject:[data objectForKey:@"name"] forKey:@"name"];
    [dict setObject:[data objectForKey:@"id"] forKey:@"id"];
    
    [dict writeToFile:[VSCore getPlistPath:@"userTokenData_m"] atomically:YES];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
    [VSCore setTabBaritemsforvc:vc];
    [self presentViewController:vc animated:YES completion:nil];
}


@end
