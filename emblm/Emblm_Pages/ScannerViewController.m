//
//  igViewController.m
//  ScanBarCodes
//
//  Created by Torrey Betts on 10/10/13.
//  Copyright (c) 2013 Infragistics. All rights reserved.
//

#import <AVFoundation/AVFoundation.h>
#import "ScannerViewController.h"
#import "VSCore.h"
#import "WebService.h"
#import "MODropAlertView.h"
#import "PostDetailsVC.h"
#import "ApplicationSettings.h"
#import "FlashbaqVideoRecorder.h"
#import "PostEmblmVC.h"
#import "ProgressHUD.h"
#import "GIBadgeView.h"
#import "NotificationTableVC.h"

@interface ScannerViewController () <AVCaptureMetadataOutputObjectsDelegate,WebServiceDelegate, flashbaqRecorDelegate, postEmblmVCDelegate>
{
    AVCaptureSession *_session;
    AVCaptureDevice *_device;
    AVCaptureDeviceInput *_input;
    AVCaptureMetadataOutput *_output;
    AVCaptureVideoPreviewLayer *_prevLayer;

    UIView *_highlightView;
    UILabel *_label;
    UIButton *btn;
    
    BOOL isdetected;
    BOOL isScanned_By_owner;
    GIBadgeView *badgeView;
    UIImageView *notifImage;
    BOOL        isNotifCountReq;
}
@end

@implementation ScannerViewController
@synthesize postDatadict;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
   [self setNeedsStatusBarAppearanceUpdate];
}

-(void)viewWillAppear:(BOOL)animated
{
    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;
    
    isNotifCountReq=YES;
    [_webservice sendGETrequestToservertoURI:Notification_Count];

//    [self setNeedsStatusBarAppearanceUpdate];

      //    self.badgeView.font = [UIFont fontWithName:@"OpenSans-Semibold" size:18];
    //    self.badgeView.backgroundColor = [UIColor colorWithRed:49/255.0 green:69/255.0 blue:122/255.0 alpha:1.0];

    [self createbadgeview];
    
    self.navigationController.navigationBar.hidden=NO;
    
    UIImageView *imgview=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = imgview;

    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    [[ApplicationSettings getInstance] setScannerViewController:self];
    
    isdetected=NO;
    isScanned_By_owner=NO;
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed: @"headerbg.png"]
//                                                  forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];

    //    _navigationBar.barTintColor=[VSCore getColor:@"ff4b4a" withDefault:[UIColor blackColor]];
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    // Load the image to show in the overlay:
    UIImage *overlayGraphic = [UIImage imageNamed:@"Scanner.png"];
    _overlayGraphicView.image=overlayGraphic;
    
    _highlightView = [[UIView alloc] init];
    _highlightView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
    _highlightView.layer.borderColor = [UIColor greenColor].CGColor;
    _highlightView.layer.borderWidth = 3;
    [self.view addSubview:_highlightView];
    
    _label = [[UILabel alloc] init];
    _label.frame = CGRectMake(0, self.view.bounds.size.height -75, self.view.bounds.size.width, 80);
    _label.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    _label.backgroundColor = [UIColor colorWithWhite:0.15 alpha:0.65];
    _label.textColor = [UIColor whiteColor];
    _label.numberOfLines=2;
    _label.lineBreakMode = NSLineBreakByTruncatingTail;
    _label.textAlignment = NSTextAlignmentCenter;
    _label.text = @"Scan Your flashbaq";
    _label.font=[UIFont fontWithName:TITLE_FONT size:23];
    [self.view addSubview:_label];
    
    
    _session = [[AVCaptureSession alloc] init];
    _device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
    NSError *error = nil;
    
    _input = [AVCaptureDeviceInput deviceInputWithDevice:_device error:&error];
    if (_input) {
        [_session addInput:_input];
    } else {
        NSLog(@"Error: %@", error);
    }
    
    _output = [[AVCaptureMetadataOutput alloc] init];
    [_output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
    [_session addOutput:_output];
    
    _output.metadataObjectTypes = [_output availableMetadataObjectTypes];
    
    _prevLayer = [AVCaptureVideoPreviewLayer layerWithSession:_session];
    //    _prevLayer.frame = self.view.bounds;
    _prevLayer.frame=CGRectMake(0, 44, self.view.bounds.size.width, self.view.bounds.size.height);
    _prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    
    [self.view.layer addSublayer:_prevLayer];
    
    [_session startRunning];
    
    [self.view bringSubviewToFront:_overlayGraphicView];
    
    [self.view bringSubviewToFront:_highlightView];
    [self.view bringSubviewToFront:_label];
    [self.view bringSubviewToFront:btn];

//    NSString *displayMessage=[NSString stringWithFormat:@"You have successfully created flashbaq code \"%@\"" , @"c0a42600"];
//    
//    MODropAlertView *codealert=[[MODropAlertView alloc] initDropAlertWithTitle:@"Success" description:displayMessage okButtonTitle:@"OK" okButtonColor:[VSCore getColor:@"7c9365" withDefault:[UIColor blackColor]]];
//    [codealert show];

}

-(void)createbadgeview
{
    notifImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notification1"]];
    notifImage.clipsToBounds = NO;
    notifImage.contentMode=UIViewContentModeScaleAspectFit;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44, 53);
    notifImage.center=button.center;
    [button addSubview:notifImage];
    
    badgeView = [GIBadgeView new];
    badgeView.font = [UIFont fontWithName:OTHER_FONT size:10];
    badgeView.backgroundColor = [UIColor whiteColor];
    badgeView.textColor=[VSCore getColor:@"9c76cc" withDefault:[UIColor blackColor]];
    [notifImage addSubview:badgeView];
    
    [badgeView setBadgeValue:0];
    
    [button addTarget:self action:@selector(animatetoNotificationView) forControlEvents:UIControlEventTouchUpInside];
    notifImage.center = button.center;
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem=barItem;

}

-(void)viewDidLayoutSubviews
{
//    CGRect visibleMetadataOutputRect = [_prevLayer metadataOutputRectOfInterestForRect:_overlayGraphicView.bounds];
//    _output.rectOfInterest = visibleMetadataOutputRect;
    notifImage.frame = CGRectMake(0, 0, 44, 44);
}

-(void)viewDidDisappear:(BOOL)animated
{
//    _prevLayer.session=nil;
//    [_prevLayer removeFromSuperlayer];

    NSLog(@"Calling viewDidDisappear");
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

-(void)animatetoNotificationView
{
   //NotificationTable
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NotificationTableVC *vc = (NotificationTableVC *)[storyboard instantiateViewControllerWithIdentifier:@"NotificationTable"];
    
    [self.navigationController pushViewController:vc animated:YES];

}

-(void)back_btn
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)settingsbtn_clicked:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetails"];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}
- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection
{
    CGRect highlightViewRect = CGRectZero;
    AVMetadataMachineReadableCodeObject *barCodeObject;
    NSString *detectionString = nil;
    NSArray *barCodeTypes = @[AVMetadataObjectTypeUPCECode, AVMetadataObjectTypeCode39Code, AVMetadataObjectTypeCode39Mod43Code,
            AVMetadataObjectTypeEAN13Code, AVMetadataObjectTypeEAN8Code, AVMetadataObjectTypeCode93Code, AVMetadataObjectTypeCode128Code,
            AVMetadataObjectTypePDF417Code, AVMetadataObjectTypeQRCode, AVMetadataObjectTypeAztecCode];

    for (AVMetadataObject *metadata in metadataObjects) {
        for (NSString *type in barCodeTypes) {
            if ([metadata.type isEqualToString:type])
            {
                barCodeObject = (AVMetadataMachineReadableCodeObject *)[_prevLayer transformedMetadataObjectForMetadataObject:(AVMetadataMachineReadableCodeObject *)metadata];
                highlightViewRect = _overlayGraphicView.frame;
                detectionString = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
                break;
            }
        }

        if (detectionString != nil)
        {
           // _label.text = detectionString;
            
            if (!isdetected)
            {
                [ProgressHUD show:@"Processing.."];
                
                NSLog(@"Scan Detected");
                [_session stopRunning];
                [self sendScannedDatatoServer:detectionString];
                isdetected=YES;
            }
            /*send the detection string to server */
        
            break;
        }
       // else
            //_label.text = @"(none)";
    }

    _highlightView.frame = highlightViewRect;
}

-(void)sendScannedDatatoServer:(NSString*)string
{
    isNotifCountReq=NO;
    string = [string stringByReplacingOccurrencesOfString:@"https://www.emblmapp.com/e/"
                                         withString:@"https://www.flashbaq.com/"];

    NSArray *keys = [NSArray arrayWithObjects:@"scan_data", nil];
    NSArray *objects=[NSArray arrayWithObjects:string , nil];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    WebService *_webservice=[[WebService alloc]init];
    [_webservice setWebDelegate:self];
    
    [_webservice SendJSONDataToServer:dataDict toURI:@"https://api.flashbaq.com/v1/emblms/scan" forRequestType:POST];
    
}

#pragma mark WebServiceDelegate Methods
-(void)responseReceivedwithData:(NSDictionary *)data
{
    
    if (isNotifCountReq)
    {
        isNotifCountReq=NO;
        [badgeView setBadgeValue:[[data objectForKey:@"result"] integerValue]];
        
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [[NSUserDefaults standardUserDefaults]setObject:[data objectForKey:@"result"] forKey:@"NotificationCount"];
        [defaults synchronize];
    }
    
    else
    {
        NSLog(@"%@",data);
        
        if ([[data objectForKey:@"type"] isEqualToString:@"UNKNOWN"])
        {
            [ProgressHUD dismiss];
            
            MODropAlertView *alert = [[MODropAlertView alloc]initDropAlertWithTitle:@"Oops!"
                                                                        description:@"It looks like you have scanned a barcode that is not recognized by flashbaq.Would you like to create one anyway?"
                                                                      okButtonTitle:@"Nevermind"
                                                                  cancelButtonTitle:@"Yes Please!"
                                                                       successBlock:^{
                                                                           NSLog(@"Success Log");
                                                                           isdetected=NO;
                                                                           [_session startRunning];
                                                                           
                                                                           _highlightView.frame = CGRectZero;
                                                                           
                                                                       }
                                                                       failureBlock:^{
                                                                           //                                                                       UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                                                                           //
                                                                           //                                                                       AttachMediaVC *vc = (AttachMediaVC *)[storyboard instantiateViewControllerWithIdentifier:@"AttachVideo"];
                                                                           //
                                                                           ////                                                                       postDatadict=[[NSMutableDictionary alloc]init];
                                                                           ////                                                                       NSString *emblmID=[[data objectForKey:@"result"] objectForKey:@"id"];
                                                                           ////                                                                       [postDatadict setObject:[data objectForKey:@"result"] forKey:@"emblmID"];
                                                                           //
                                                                           ////                                                                       vc.postDataDict=postDatadict;
                                                                           //                                                                       [self.navigationController pushViewController:vc animated:YES]; /*create an emblm*/
                                                                           isdetected=NO;
                                                                           [_session startRunning];
                                                                           
                                                                           _highlightView.frame = CGRectZero;
                                                                           
                                                                       }];
            [alert show];
            
            
        }
        
        else if ([[data objectForKey:@"type"] isEqualToString:@"UNASSIGNED"])
        {
            [ProgressHUD dismiss];
            
            /*  MODropAlertView *alert = [[MODropAlertView alloc]initDropAlertWithTitle:@"Oops!"
             description:@"It looks like you have scanned a barcode which is empty.Would you like to create one anyway?"
             okButtonTitle:@"Nevermind"
             cancelButtonTitle:@"Yes Please!"
             successBlock:^{
             NSLog(@"Success Log");
             isdetected=NO;
             [_session startRunning];
             _highlightView.frame = CGRectZero;
             
             
             
             }
             failureBlock:^{
             UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
             AttachMediaVC *vc = (AttachMediaVC *)[storyboard instantiateViewControllerWithIdentifier:@"AttachVideo"];
             
             postDatadict=[[NSMutableDictionary alloc]init];
             [postDatadict setObject:[data objectForKey:@"result"] forKey:@"emblmID"];
             
             vc.postDataDict=postDatadict;
             [self.navigationController pushViewController:vc animated:YES];
             isdetected=NO;
             [_session startRunning];
             
             _highlightView.frame = CGRectZero;
             
             
             }];
             [alert show];*/
            isdetected=NO;
            //        [_session startRunning];
            
            _highlightView.frame = CGRectZero;
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            FlashbaqVideoRecorder *vc = (FlashbaqVideoRecorder *)[storyboard instantiateViewControllerWithIdentifier:@"FlashbaqVideo"];
            [vc setFlashbaqrecDelegate:self];
            postDatadict=[[NSMutableDictionary alloc]init];
            [postDatadict setObject:[data objectForKey:@"result"] forKey:@"emblmID"];
            
            vc.postDataDict=postDatadict;
            //        [self presentViewController:vc animated:YES completion:nil];
            vc.hidesBottomBarWhenPushed=YES;
            [self.navigationController pushViewController:vc animated:YES];
            
            [_session startRunning];//kavya commented today
            
        }
        
        else if ([[data objectForKey:@"type"] isEqualToString:@"SCANNED-BY-OWNER"])
        {
            [ProgressHUD dismiss];
            
            MODropAlertView *alert = [[MODropAlertView alloc]initDropAlertWithTitle:@""
                                                                        description:@"You've scanned a flashbaq that YOU created! Would you like to share this with your followers?"
                                                                      okButtonTitle:@"No thanks"
                                                                  cancelButtonTitle:@"Yes Please!"
                                                                       successBlock:^{
                                                                           NSLog(@"No thanks");
                                                                           
                                                                           isScanned_By_owner=YES;
                                                                           
                                                                           _highlightView.frame = CGRectZero;
                                                                           
                                                                           NSString *emblmid=[[data objectForKey:@"result"]objectForKey:@"emblm"];
                                                                           WebService *_webservice=[[WebService alloc]init];
                                                                           _webservice.webDelegate=self;//
                                                                           NSString *url=[NSString stringWithFormat:PostDetails,emblmid];
                                                                           [_webservice sendGETrequestToservertoURI:url];
                                                                           
                                                                           isdetected=NO;
                                                                           [_session startRunning];
                                                                           
                                                                           
                                                                       }
                                                                       failureBlock:^{
                                                                           
                                                                           isScanned_By_owner=YES;
                                                                           
                                                                           NSArray *keys = [NSArray arrayWithObjects:@"emblm", nil];
                                                                           
                                                                           NSString *emblm=[[data objectForKey:@"result"] objectForKey:@"emblm"];
                                                                           
                                                                           NSArray *objects=[NSArray arrayWithObjects:emblm , nil];
                                                                           
                                                                           NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
                                                                           
                                                                           
                                                                           WebService *_webservice=[[WebService alloc]init];
                                                                           [_webservice setWebDelegate:self];
                                                                           [_webservice SendJSONDataToServer:dataDict toURI:AddScan forRequestType:POST];
                                                                           
                                                                           isdetected=NO;
                                                                           [_session startRunning];
                                                                           
                                                                           _highlightView.frame = CGRectZero;
                                                                           
                                                                       }];
            [alert show];
            
            
        }
        
        else if ([[data objectForKey:@"type"] isEqualToString:@"PRIVATE"])
        {
            
            isScanned_By_owner=YES;
            
            _highlightView.frame = CGRectZero;
            
            NSString *emblmid=[[data objectForKey:@"result"]objectForKey:@"emblm"];
            WebService *_webservice=[[WebService alloc]init];
            _webservice.webDelegate=self;//
            NSString *url=[NSString stringWithFormat:PostDetails,emblmid];
            [_webservice sendGETrequestToservertoURI:url];
            
            isdetected=NO;
            [_session startRunning];
            
            _highlightView.frame = CGRectZero;
            
        }
        
        else if ([[data objectForKey:@"type"] isEqualToString:@"SUCCESS"])
            
        /*type = SUCCESS */
        {
            [ProgressHUD dismiss];
            
            if (isScanned_By_owner)
            {
                isScanned_By_owner=NO;
                [self.navigationController.tabBarController setSelectedIndex:0];
                
            }
            
            else
            {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                PostDetailsVC *vc = (PostDetailsVC *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetails"];
                vc.resultDict=[data objectForKey:@"result"];
                
                [self.navigationController pushViewController:vc animated:YES];
                
            }
            
        }
        
        else
        {
            [ProgressHUD dismiss];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            PostDetailsVC *vc = (PostDetailsVC *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetails"];
            vc.resultDict=[data objectForKey:@"result"];
            
            [self.navigationController pushViewController:vc animated:YES];
        }

    }
    
  }

-(void)connectionFailed
{
    [ProgressHUD dismiss];
    
    [VSCore showConnectionFailedAlert];
    
    isdetected=NO;
    [_session startRunning];
    
    _highlightView.frame = CGRectZero;

}

#pragma mark FlashBaqVideoRecorder Delegate methods
-(void)dismissFlashbaqVR
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    [_session startRunning];

}


//-(void)dismissAttachMediaandPoptoScannerVC
//{
//    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
//    PostDetailsVC *vc = (PostDetailsVC *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetails"];
////    vc.resultDict=[data objectForKey:@"result"];
//    
//    [self.navigationController pushViewController:vc animated:YES];
//
//}
@end