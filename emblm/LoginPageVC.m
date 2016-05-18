//
//  LoginPageVC.m
//  emblm
//
//  Created by Kavya Valavala on 12/16/14.
//  Copyright (c) 2014 Vaayoo. All rights reserved.
//

#import "LoginPageVC.h"
#import "VSCore.h"
#import "WebService.h"
#import "Canvas.h"
#import "ApplicationSettings.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface LoginPageVC ()<UITextFieldDelegate>

{
    UIView *inputAccessoryView;
    UIButton *contButton;
    UIActivityIndicatorView *activityIndicator;
    BOOL isanimationDone;
}

@end

@implementation LoginPageVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }

    isanimationDone=NO;
//    [self._navbar setBackgroundImage:[UIImage imageNamed:@"headerbg.png"]
//                                                  forBarMetrics:UIBarMetricsDefault];
    self._navbar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];

//    self._navbar.barTintColor=[VSCore getColor:@"ff4b4a" withDefault:[UIColor blackColor]];
    [self._navbar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    self.view.backgroundColor=[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]];
    
    [self.errormsgview setHidden:YES];
    
    [_lbl_errormsg setFont:[UIFont fontWithName:OTHER_FONT size:16]];
    [_lbl_errormsg setTextColor:[VSCore getColor:@"ff4b4a" withDefault:[UIColor blackColor]]];

    [_txt_userName setFont:[UIFont fontWithName:TITLE_FONT size:18]];
    [_txt_userName setBackgroundColor:[UIColor whiteColor]];
    [_txt_userName setLeftViewMode:UITextFieldViewModeAlways];
    _txt_userName.leftView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"U.png"]];
    
    [_txt_password setFont:[UIFont fontWithName:TITLE_FONT size:18]];
    [_txt_password setBackgroundColor:[UIColor whiteColor]];
    [_txt_password setLeftViewMode:UITextFieldViewModeAlways];
     _txt_password.leftView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"P.png"]];

    UITapGestureRecognizer *_tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(tappedonce)];
    _tap.numberOfTapsRequired=1;
    [_lbl_frgtPwd addGestureRecognizer:_tap];

    // Do any additional setup after loading the view.
}

-(void)tappedonce
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"Password Reset"];
    [self presentViewController:vc animated:YES completion:nil];
    //    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)goback:(id)sender
{
    [_txt_userName resignFirstResponder];
    [_txt_password resignFirstResponder];

    [self dismissViewControllerAnimated:YES completion:nil];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIView *)inputAccessoryView
{
    if (!inputAccessoryView) {
        CGRect accessFrame = CGRectMake(0.0, 0.0, 414.0, 50.0);
        inputAccessoryView = [[UIView alloc] initWithFrame:accessFrame];
        //        inputAccessoryView.backgroundColor = [VSCore getColor:@"0ab7a4" withDefault:[UIColor blackColor]];
        inputAccessoryView.backgroundColor = [UIColor clearColor];
        contButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        contButton.frame = CGRectMake(0.0, 0.0, self.view.frame.size.width, inputAccessoryView.frame.size.height);
        contButton.backgroundColor=[VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]];
        contButton.titleLabel.font = [UIFont fontWithName:TITLE_FONT size:22.0];
        [contButton setTitle: @"Login" forState:UIControlStateNormal];
        [contButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [contButton addTarget:self action:@selector(buttonClicked)
             forControlEvents:UIControlEventTouchUpInside];
        [contButton setHidden:YES];
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

-(void)buttonClicked
{
    [activityIndicator startAnimating];

    PFInstallation *currentInstallation = [PFInstallation currentInstallation];

    NSString *deviceObject=nil;
    
    if ([currentInstallation.objectId length] > 0)
    {
        deviceObject=currentInstallation.objectId;
    }
    
    else
    {
        deviceObject=@"";
    }
    
    NSString *deviceToken=nil;
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"] length] > 0)
    {
        deviceToken=[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"] ;
    }
    
    else
    {
        deviceToken=@"";
    }
    
    /*send Data to the server */
    NSArray *keys = [NSArray arrayWithObjects:@"username", @"password",@"device_type",@"device_token",@"device_object" , nil];
    NSArray *objects=[NSArray arrayWithObjects:_txt_userName.text,_txt_password.text,DeviceType, deviceToken , deviceObject, nil];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    WebService *_webservice=[[WebService alloc]init];
    [_webservice setWebDelegate:self];
    [_webservice SendJSONDataToServer:dataDict toURI:@"https://api.flashbaq.com/v1/users/login" forRequestType:POST];
}

-(void)setUpUserchannel
{
    NSString  *userID=[NSString stringWithFormat:@"user%@",[VSCore getUserID]];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:userID forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    /*send Device & user Details to Flashbaq API */
    
    /*send Data to the server */
   /* NSArray *keys = [NSArray arrayWithObjects:@"device_type", @"device_token", @"device_object" , nil];
    NSArray *objects=[NSArray arrayWithObjects:DeviceType,[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"], currentInstallation.objectId ,nil];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    WebService *_webservice=[[WebService alloc]init];
    [_webservice setWebDelegate:self];
    [_webservice SendJSONDataToServer:dataDict toURI:AddDevice forRequestType:POST];*/

}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)commitAnimationforInputAccessory
{
    NSLog(@"commitAnimationforInputAccessory Called");

    CSAnimationView *animationView = [[CSAnimationView alloc] initWithFrame:contButton.frame];
    
    animationView.backgroundColor = [UIColor clearColor];
    
    animationView.duration = 0.5;
    animationView.delay    = 0;
    animationView.type     = CSAnimationTypeSlideUp;
    
    [inputAccessoryView addSubview:animationView];
    
    // Add your subviews into animationView
    [animationView addSubview:contButton];
    
    // Kick start the animation immediately
    
    [animationView startCanvasAnimation];
    
    [inputAccessoryView setHidden:NO];
    [contButton setHidden:NO];
//    inputAccessoryView.backgroundColor = [VSCore getColor:@"0ab7a4" withDefault:[UIColor blackColor]];

}


-(void)hidetheInputAccessoryView
{
    NSLog(@"hidetheInputAccessoryView Called");
    CSAnimationView *animationView = [[CSAnimationView alloc] initWithFrame:contButton.frame];
    
    animationView.backgroundColor = [UIColor clearColor];
    
    animationView.duration = 0.5;
    animationView.delay    = 0;
    animationView.type     = CSAnimationTypeSlideDown;
    
    [inputAccessoryView addSubview:animationView];
    
    // Add your subviews into animationView
    [animationView addSubview:contButton];
    
    // Kick start the animation immediately
            [animationView startCanvasAnimation];
    //---
//            [UIView beginAnimations:@"ShowHideView" context:nil];
//    //        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
//            [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:contButton cache:YES];
//            [UIView setAnimationDuration:1.0];
    [inputAccessoryView setHidden:YES];
    [contButton setHidden:YES];

}


#pragma mark UITextFieldDelegate Methods

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
//    [_btn_FBLogin setHidden:YES];
    [_errormsgview setHidden:YES];
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
//    if (([_txt_email.text isEqualToString:@""] ) && ([_txt_username.text isEqualToString:@"" ]) && ([_txt_password.text isEqualToString:@""]))
//    {
//        [self.btn_FBLogin setHidden:NO];
//    }
    
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    /* if text is entered in all the three fields, display Login button */
    if (([_txt_userName.text length]>0) && ([_txt_password.text length] > 0))
    {
        
        if (!isanimationDone)
        {
            isanimationDone=YES;
            [self commitAnimationforInputAccessory];
        }
       
        // Commit the changes and perform the animation.
//        [UIView commitAnimations];
    }
    
    else
    {
        
        /* */
       
        if (isanimationDone)
        {
            isanimationDone=NO;
            [self hidetheInputAccessoryView];
          
        }
        
        // Commit the changes and perform the animation.
//        [UIView commitAnimations];
        
    }
    
    
    
    if ([_txt_userName isFirstResponder])
    {
        if ([string isEqualToString:@" "])
        {
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"UserName cannot contain any spaces" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [error show];
            return NO;
        }
        
        else
            return YES;
        
    }
    
    else
    {
    
        return YES;
        
    }
//        return YES;

    
    
    /* if no data entered in all the three fields, make FBLogin button visible */
}

#pragma mark WebServiceDelegate methods
-(void)responseReceivedwithData:(NSDictionary *)data
{
    [inputAccessoryView setHidden:YES];
    [activityIndicator stopAnimating];
    
        if (data != nil)
        {

            [[ApplicationSettings getInstance] setAppLaunchedFirstTime:YES];
            
            if ([[data objectForKey:@"message"] length] >0)
            {
                //Display the error message
                [_lbl_errormsg setText:[data objectForKey:@"message"]];
                [_errormsgview setHidden:NO];
                
                inputAccessoryView.backgroundColor = [UIColor clearColor];
                [contButton setHidden:YES];
                [_txt_userName resignFirstResponder];
                [_txt_password resignFirstResponder];
            }
            
            else
            {
                /* save user_token, user_image , username , name for sending further requests of logged in users into a
                 plist  */
                
                [_txt_userName resignFirstResponder];
                [_txt_password resignFirstResponder];

                [VSCore copyPlistFileFromMainBundle:@"userTokenData" ToDocumentPath:@"userTokenData_m"];
                
                NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithContentsOfFile:[VSCore getPlistPath:@"userTokenData_m"]];
                
                NSDictionary *resultDict=[data objectForKey:@"result"];
                
                [dict setObject:[resultDict objectForKey:@"username"] forKey:@"username"];
                [dict setObject:[resultDict objectForKey:@"name"] forKey:@"name"];
                [dict setObject:[resultDict objectForKey:@"user_image"] forKey:@"user_image"];
                [dict setObject:[resultDict objectForKey:@"user_token"] forKey:@"user_token"];
                [dict setObject:[resultDict objectForKey:@"id"] forKey:@"id"];
                
                [dict writeToFile:[VSCore getPlistPath:@"userTokenData_m"] atomically:YES];
                
                
                /* set the value of  */
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"isLoginDone"];
                [defaults synchronize];
                
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
                [VSCore setTabBaritemsforvc:vc];
               // [self presentViewController:vc animated:YES completion:nil];
                
                AppDelegate *_appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
                [self dismissViewControllerAnimated:YES completion:nil];
                
                //    [_appdelegate.window.rootViewController.view removeFromSuperview];
                //    [_appdelegate.window.rootViewController.view removeFromSuperview];
                
                [_appdelegate.window.rootViewController removeFromParentViewController];
                _appdelegate.window=nil;
                _appdelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
                _appdelegate.window.backgroundColor = [UIColor whiteColor];
                
                _appdelegate.window.rootViewController=vc;
                
                [_appdelegate.window makeKeyAndVisible];

                
                [self setUpUserchannel];

            }
            

        }
    
}

-(void)connectionFailed
{
    [activityIndicator stopAnimating];

    inputAccessoryView.backgroundColor = [UIColor clearColor];
    [contButton setHidden:YES];
    [_txt_userName resignFirstResponder];
    [_txt_password resignFirstResponder];

    [_lbl_errormsg setText:@"Connection Failed"];
    [_errormsgview setHidden:NO];
    
}

@end
