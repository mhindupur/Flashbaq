//
//  PasswordResetPage.m
//  emblm
//
//  Created by Kavya Valavala on 2/6/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "PasswordResetPage.h"
#import "VSCore.h"
#import "Canvas.h"
#import "WebService.h"

@interface PasswordResetPage ()<UITextFieldDelegate>
{
    UIView *inputAccessoryView;
    UIButton *contButton;
    UIActivityIndicatorView *activityIndicator;
    BOOL isanimationDone;
}
@end

@implementation PasswordResetPage

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }

//    [self._navbar setBackgroundImage:[UIImage imageNamed:@"headerbg.png"]
//                       forBarMetrics:UIBarMetricsDefault];
    
    self._navbar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];

    //    self._navbar.barTintColor=[VSCore getColor:@"ff4b4a" withDefault:[UIColor blackColor]];
    [self._navbar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    self.view.backgroundColor=[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]];
    
    [self.txt_email setFont:[UIFont fontWithName:TITLE_FONT size:18]];
    [self.txt_email setBackgroundColor:[UIColor whiteColor]];
    [self.txt_email setLeftViewMode:UITextFieldViewModeAlways];
    self.txt_email.leftView= [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"E.png"]];
    
    CGFloat width = [UIScreen mainScreen].bounds.size.width;

    if (width > 320)
    {
        if (width > 375)//iphone6plus
        {
            __imgview.image=[UIImage imageNamed:@"forgotpwdimage_6.png"];

        }
        
        else
        {
            __imgview.image=[UIImage imageNamed:@"forgotpwdimage6.png"];

        }
    }
    
    else
    {
        __imgview.image=[UIImage imageNamed:@"forgotpwdimage.png"];

    }
    
    [self.errormsgview setHidden:YES];
    
    [_lbl_errormsg setFont:[UIFont fontWithName:OTHER_FONT size:16]];
//    [_lbl_errormsg setTextColor:[VSCore getColor:@"ff4b4a" withDefault:[UIColor blackColor]]];
    [_lbl_errormsg setTextColor:[VSCore getColor:@"008000" withDefault:[UIColor blackColor]]];
    [_lbl_errormsg setText:@"EmailId already exists"];
    [_lbl_errormsg sizeToFit];
      // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


-(IBAction)backbtn_clicked:(id)sender
{
    [_txt_email resignFirstResponder];
    
    [self dismissViewControllerAnimated:YES completion:nil];
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
        [contButton setTitle: @"Reset Password" forState:UIControlStateNormal];
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
    //NSLog(@"commitAnimationforInputAccessory Called");
    
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

-(void)buttonClicked
{
    [activityIndicator startAnimating];
    
    /*send Data to the server */
    NSArray *keys = [NSArray arrayWithObjects:@"email", nil];
    NSArray *objects=[NSArray arrayWithObjects:_txt_email.text, nil];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    WebService *_webservice=[[WebService alloc]init];
    [_webservice setWebDelegate:self];
    [_webservice SendJSONDataToServer:dataDict toURI:resetPassword forRequestType:POST];
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
    if ([_txt_email.text length]>0)
    {
        
        if (!isanimationDone)
        {
            isanimationDone=YES;
            [self commitAnimationforInputAccessory];
        }
    }
    
    else
    {
        
        /* */
        
        if (isanimationDone)
        {
            isanimationDone=NO;
            [self hidetheInputAccessoryView];
            
        }
        
    }
    
    /* if no data entered in all the three fields, make FBLogin button visible */
    return YES;
}

#pragma mark WebServiceDelegate methods
-(void)responseReceivedwithData:(NSDictionary *)data
{
    if (data != nil)
    {
        [activityIndicator stopAnimating];
        
        if ([[data objectForKey:@"message"] length] >0)
        {
            //Display the error message
            [_lbl_errormsg setText:[data objectForKey:@"message"]];
            [_errormsgview setHidden:NO];
            
            inputAccessoryView.backgroundColor = [UIColor clearColor];
            [contButton setHidden:YES];
            [_txt_email resignFirstResponder];
        }
        
        else
        {
            
        }
        
    }
    
}

-(void)connectionFailed
{
    [activityIndicator stopAnimating];

    [_lbl_errormsg setText:@"Connection Failed"];
    [_errormsgview setHidden:NO];
    
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
