//
//  ViewController.m
//  emblm
//
//  Created by Kavya Valavala on 11/26/14.
//  Copyright (c) 2014 Vaayoo. All rights reserved.
//

#import "ViewController.h"
#import "VSCore.h"
#import <FacebookSDK/FacebookSDK.h>
#import "NSObject+SBJSON.h"
#import "WebService.h"
#import "Canvas.h"
#import "ApplicationSettings.h"
#import <Parse/Parse.h>
#import "AppDelegate.h"

@interface ViewController ()<WebServiceDelegate,UITextFieldDelegate>
{
    UIView *inputAccessoryView;
    UIButton *contButton;
    UIActivityIndicatorView *activityIndicator;
    BOOL isanimationDone;

}
@end

@implementation ViewController
@synthesize errorMsgview,lbl_errormsg;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }

    isanimationDone=NO;
    
    errorMsgview.hidden=YES;
    
    lbl_errormsg.adjustsFontSizeToFitWidth=YES;
    
    self._navbar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];
    [self._navbar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    self.view.backgroundColor=[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]];
    
    [self.lbl_or setFont:[UIFont fontWithName:TITLE_FONT size:18]];
    
    [self.lbl_errormsg setFont:[UIFont fontWithName:OTHER_FONT size:18]];
    [self.lbl_errormsg setTextColor:[VSCore getColor:@"ff4b4a" withDefault:[UIColor blackColor]]];
    
    [self.txt_email setFont:[UIFont fontWithName:TITLE_FONT size:18]];
    [self.txt_email setBackgroundColor:[UIColor whiteColor]];
    [self.txt_email setLeftViewMode:UITextFieldViewModeAlways];
    self.txt_email.leftView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"E.png"]];
    
    [self.txt_username setFont:[UIFont fontWithName:TITLE_FONT size:18]];
    [self.txt_username setBackgroundColor:[UIColor whiteColor]];
    [self.txt_username setLeftViewMode:UITextFieldViewModeAlways];
    self.txt_username.leftView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"U.png"]];
    
    [self.txt_password setFont:[UIFont fontWithName:TITLE_FONT size:18]];
    [self.txt_password setBackgroundColor:[UIColor whiteColor]];
    [self.txt_password setLeftViewMode:UITextFieldViewModeAlways];
    self.txt_password.leftView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"P.png"]];


    // Do any additional setup after loading the view, typically from a nib.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(IBAction)goback:(id)sender
{
    [_txt_email resignFirstResponder];
    [_txt_password resignFirstResponder];
    [_txt_username resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)lbl_orTapped:(UITapGestureRecognizer*)sender
{
    if ([[_lbl_or text] isEqualToString:@"Forgot Password?"])
    {
        NSLog(@"Tap received for Forgot Password");

    }
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
        contButton.titleLabel.font = [UIFont fontWithName:TITLE_FONT size:23.0];
        [contButton setTitle: @"Continue" forState:UIControlStateNormal];
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

-(void)commitAnimationforInputAccessory
{
    NSLog(@"commitAnimationforInputAccessory Called");
    
    CSAnimationView *animationView = [[CSAnimationView alloc] initWithFrame:contButton.frame];
    
    animationView.backgroundColor = [UIColor clearColor];
    
    animationView.duration = 0.5;
    animationView.delay    = 0;
    animationView.type     = CSAnimationTypeSlideUp;
    
    [animationView addSubview:contButton];

    [inputAccessoryView addSubview:animationView];
    
    // Add your subviews into animationView
    
    // Kick start the animation immediately
    
    [animationView startCanvasAnimation];
    
    [contButton setHidden:NO];
    [inputAccessoryView setHidden:NO];
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
    
    [animationView addSubview:contButton];

    [inputAccessoryView addSubview:animationView];
    
    // Add your subviews into animationView
    
    // Kick start the animation immediately
    [animationView startCanvasAnimation];
    //---
    //            [UIView beginAnimations:@"ShowHideView" context:nil];
    //    //        [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    //            [UIView setAnimationTransition:UIViewAnimationTransitionCurlUp forView:contButton cache:YES];
    //            [UIView setAnimationDuration:1.0];
    [contButton setHidden:YES];
    [inputAccessoryView setHidden:YES];

}


-(void)buttonClicked
{
   /*Validate email and Passowrd before sending request to server */
    [errorMsgview setHidden:YES];

    BOOL isvalidMail= [self isValidEmail:_txt_email.text];
    BOOL isvalidPassword;
    
    if ([_txt_password.text length] >= 6)
    {
        isvalidPassword=YES;
    }
    
    else
    {
        isvalidPassword=NO;
    }
    
    
    if (isvalidPassword && isvalidMail)
    {
        /*send request to server */
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
        NSArray *keys = [NSArray arrayWithObjects:@"username", @"email", @"password",@"device_type", @"device_token", @"device_object", nil];
        NSArray *objects=[NSArray arrayWithObjects:_txt_username.text,_txt_email.text,_txt_password.text,DeviceType, deviceToken, deviceObject, nil];
        
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        WebService *_webservice=[[WebService alloc]init];
        _webservice.webDelegate=self;
        [_webservice SendJSONDataToServer:dataDict toURI:@"https://api.flashbaq.com/v1/users" forRequestType:POST];
        
    }
    
    else
    {
        if (!isvalidMail)
        {
            [lbl_errormsg setText:@"Email format is not correct! Please Correct"];
            [errorMsgview setHidden:NO];

        }
        
        else
        {
            [lbl_errormsg setText:@"Password needs to be 6 digits or more!"];
            [errorMsgview setHidden:NO];

        }
    }
  
}

-(void)setUpUserchannel
{
    NSString  *userID=[NSString stringWithFormat:@"user%@",[VSCore getUserID]];
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject:userID forKey:@"channels"];
    [currentInstallation saveInBackground];
    
    /*send Device & user Details to Flashbaq API */
    
    /*send Data to the server */
    NSArray *keys = [NSArray arrayWithObjects:@"device_type", @"device_token", @"device_object" , nil];
    NSArray *objects=[NSArray arrayWithObjects:DeviceType,[[NSUserDefaults standardUserDefaults] objectForKey:@"DeviceToken"], currentInstallation.objectId ,nil];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    WebService *_webservice=[[WebService alloc]init];
    [_webservice setWebDelegate:self];
    [_webservice SendJSONDataToServer:dataDict toURI:AddDevice forRequestType:POST];
    
}

- (BOOL)isValidEmail:(NSString *)email
{
//    NSString *regex1 = @"\\A[a-z0-9]+([-._][a-z0-9]+)*@([a-z0-9]+(-[a-z0-9]+)*\\.)+[a-z]{2,4}\\z";
    NSString *regex1 = @"\\A[A-Za-z0-9]+([-._][A-Za-z0-9]+)*@([A-Za-z0-9]+(-[A-Za-z0-9]+)*\\.)+[A-Za-z]{2,4}\\z";
    NSString *regex2 = @"^(?=.{1,64}@.{4,64}$)(?=.{6,100}$).*";
    NSPredicate *test1 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex1];
    NSPredicate *test2 = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", regex2];
    return [test1 evaluateWithObject:email] && [test2 evaluateWithObject:email];
}

//Method not used
/*-(IBAction)FB_loginClicked:(id)sender
{
    if (FBSession.activeSession.isOpen) {
        // login is integrated with the send button -- so if open, we send
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Message"
                                                        message:@"Session is Open--User Logged In"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        
        
    } else
    {
        NSArray *_array= (NSArray *)@[@"public_profile", @"email"];
        
        [FBSession openActiveSessionWithReadPermissions:_array
                                           allowLoginUI:YES
                                      completionHandler:^(FBSession *session,
                                                          FBSessionState status,
                                                          NSError *error) {
                                          // if login fails for any reason, we alert
                                          if (error)
                                          {
                                              UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                                              message:error.localizedDescription
                                                                                             delegate:nil
                                                                                    cancelButtonTitle:@"OK"
                                                                                    otherButtonTitles:nil];
                                              [alert show];
                                              
                                              // if otherwise we check to see if the session is open, an alternative to
                                              // to the FB_ISSESSIONOPENWITHSTATE helper-macro would be to check the isOpen
                                              // property of the session object; the macros are useful, however, for more
                                              // detailed state checking for FBSession objects
                                          }
                                          else if (FB_ISSESSIONOPENWITHSTATE(status))
                                          {
                                            
                                              [[FBRequest requestForMe] startWithCompletionHandler:^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
                                                  if (error) {
                                                      NSLog(@"error:%@",error);
                                                  } else {
                                                      // retrive user's details at here as shown below
                                                      NSLog(@"FB user first name:%@",user.first_name);
                                                      NSLog(@"FB user last name:%@",user.last_name);
                                                      NSLog(@"FB user UserID:%@",user.objectID);
                                                      NSLog(@"FB user gender:%@",[user objectForKey:@"gender"]);
                                                      NSLog(@"email id:%@",[user objectForKey:@"email"]);
                                                      NSString *userImageURL = [NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large", user.objectID];
     
                                                      [_txt_email setText:[user objectForKey:@"email"]];
                                                      
                                                  }
                                              }];
                                          }
                                      }];
    }

}
 
*/
 
#pragma mark UITextFieldDelegate Methods

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [_btn_FBLogin setHidden:YES];
    [_lbl_or setHidden:YES];
//    [_lbl_or setText:@"Forgot Password?"];
    
    if ([_txt_password isFirstResponder] && ([textField.text length] <= 5))
    {
        [lbl_errormsg setText:@"Password should contain minimum 6 characters"];
        
        [errorMsgview setHidden:NO];
    }
    
    else
    {
        [errorMsgview setHidden:YES];
    }
}

//- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
//{
//    /*Email validation */
//    if ([_txt_email isFirstResponder])
//    {
//        BOOL isvalidMail= [self isValidEmail:_txt_email.text];
//        
//        if (!isvalidMail)
//        {
//            [lbl_errormsg setText:@"Email format is not correct! Please Correct"];
//            [errorMsgview setHidden:NO];
//            [_txt_email resignFirstResponder];
//        }
//        
//        else
//        {
//            [errorMsgview setHidden:YES];
//        }
//    }
//
//    /*Password minimum characters should be 6 */
//    if ([_txt_password isFirstResponder])
//    {
//        if ([_txt_password.text length] < 6)
//        {
//            [lbl_errormsg setText:@"Password needs to be 6 digits or more!"];
//            [errorMsgview setHidden:NO];
//            [textField resignFirstResponder];
//            
//        }
//        
//        else
//        {
//            [errorMsgview setHidden:YES];
//        }
//    }
//    
//    return YES;
//}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    
    if (([_txt_email.text isEqualToString:@""] ) && ([_txt_username.text isEqualToString:@"" ]) && ([_txt_password.text isEqualToString:@""]))
    {
        [self.btn_FBLogin setHidden:NO];
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
    if (([self.txt_username.text length]>0) && ([self.txt_email.text length]>0) && ([self.txt_password.text length] >= 5))
    {
        if (!isanimationDone)
        {
            isanimationDone=YES;
            [self commitAnimationforInputAccessory];
        }
    }
    
    else
    {
        if (isanimationDone)
        {
            isanimationDone=NO;
            [self hidetheInputAccessoryView];
            
        }
        

    }
    
    
    if ([_txt_password isFirstResponder] && ([textField.text length] <= 4))
    {
        [lbl_errormsg setText:@"Password should contain minimum 6 characters"];
        
        [errorMsgview setHidden:NO];
    }
   
    else
    {
        [errorMsgview setHidden:YES];
    }
    
    if ([_txt_username isFirstResponder])
    {
        if ([string isEqualToString:@" "])
        {
            UIAlertView *error = [[UIAlertView alloc] initWithTitle:@"Error" message:@"UserName cannot contain any spaces" delegate:self cancelButtonTitle:nil otherButtonTitles:@"OK", nil];
            [error show];
            return NO;
        }
        
        else
        {
            return YES;
        }

    }
    
    else
        return YES;
    /* if no data entered in all the three fields, make FBLogin button visible */
//    return YES;
}

#pragma mark WebServiceDelegate methods
-(void)responseReceivedwithData:(NSDictionary *)data
{
    [activityIndicator stopAnimating];

       if ([data isKindOfClass:[NSArray class]])
        {
            NSArray *textarray=[data valueForKey:@"message"];
            [lbl_errormsg setText:[textarray objectAtIndex:0]];
            [errorMsgview setHidden:NO];
            
            //        [inputAccessoryView setHidden:YES];
            //        [contButton setHidden:YES];
            [_txt_username resignFirstResponder];
            [_txt_password resignFirstResponder];
            [_txt_email    resignFirstResponder];
            
        }
        
        else
        {
            /* save user_token, user_image , username , name for sending further requests of logged in users into a
             plist  */
            
            [_txt_username resignFirstResponder];
            [_txt_password resignFirstResponder];
            [_txt_email    resignFirstResponder];

            [VSCore copyPlistFileFromMainBundle:@"userTokenData" ToDocumentPath:@"userTokenData_m"];
            
            NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithContentsOfFile:[VSCore getPlistPath:@"userTokenData_m"]];
            [dict setObject:[data objectForKey:@"username"] forKey:@"username"];
            [dict setObject:[data objectForKey:@"name"] forKey:@"name"];
            [dict setObject:[data objectForKey:@"user_image"] forKey:@"user_image"];
            [dict setObject:[data objectForKey:@"user_token"] forKey:@"user_token"];
            [dict setObject:[data objectForKey:@"id"] forKey:@"id"];
            
            [dict writeToFile:[VSCore getPlistPath:@"userTokenData_m"] atomically:YES];
            
            /* set the value of  */
            NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
            [[NSUserDefaults standardUserDefaults] setObject:@"yes" forKey:@"isLoginDone"];
            [defaults synchronize];
            
            [self setUpUserchannel];

            [inputAccessoryView setHidden:YES];
            
            [[ApplicationSettings getInstance] setAppLaunchedFirstTime:YES];
            
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
            UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"CreateProfile"];
//            [self presentViewController:vc animated:YES completion:nil];
            [self dismissViewControllerAnimated:YES completion:nil];
            
            AppDelegate *_appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
            [_appdelegate.window.rootViewController removeFromParentViewController];
            _appdelegate.window=nil;
            _appdelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
            _appdelegate.window.backgroundColor = [UIColor whiteColor];
            
            _appdelegate.window.rootViewController=vc;
            
            [_appdelegate.window makeKeyAndVisible];


        }
  
}

-(void)connectionFailed
{
    [activityIndicator stopAnimating];

    [_txt_username resignFirstResponder];
    [_txt_password resignFirstResponder];
    [_txt_email    resignFirstResponder];

    [lbl_errormsg setText:@"Connection Failed"];
    [errorMsgview setHidden:NO];

}
@end
