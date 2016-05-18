//
//  Settings.m
//  Flashbaq
//
//  Created by Kavya Valavala on 3/17/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "Settings.h"
#import "SetiingsFieldCell.h"
#import "ProfileImageCell.h"
#import "NotificationCell.h"
#import "LogoutCell.h"
#import "mainheaderview.h"
#import "VSCore.h"
#import "WebService.h"
#import "VMediaDevice.h"
#import <AWSiOSSDKv2/AWSCore.h>
#import <AWSiOSSDKv2/AWSS3TransferManager.h>
#import "AppDelegate.h"
#import "FlashbaqWebview.h"

#define kOFFSET_FOR_KEYBOARD 80.0
NSString * const FIELD_NAME        =@"fieldname";
NSString * const Data              =@"Data";
NSString * const FIRST_NAME        =@"First Name";
NSString * const LAST_NAME         =@"Last Name";
NSString * const EMAIL             =@"Email";
NSString * const NEW_password      =@"New Password";
NSString * const CONFIRM           =@"Confirm";


@interface Settings ()<UITextFieldDelegate, WebServiceDelegate , MediaDeviceDelegate>
{
    NSArray *tableDataArray;
    NSMutableDictionary *sectionsData;
    BOOL saveBtnPressed;
    AWSS3TransferManagerUploadRequest *uploadRequest;

}
@property (nonatomic) uint64_t file1AlreadyUpload;

@end

@implementation Settings

- (void)viewDidLoad {
    [super viewDidLoad];
    
    saveBtnPressed=NO;

    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    

    __navigationbar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];
    
    [__navigationbar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    __tableView.allowsSelection=NO;
    __tableView.tableFooterView=nil;
    sectionsData=[[NSMutableDictionary alloc]init];
    
    NSMutableDictionary *_dict=(NSMutableDictionary *)@{@"MainHeaderView" : @[@"view"],
                                                        @"Profile Image" : @{@"image":@""},
                                          @"Account Information" : @[@{FIELD_NAME:@"Username",Data:@""},@{FIELD_NAME:FIRST_NAME,Data:@""},@{FIELD_NAME:LAST_NAME,Data:@""},@{FIELD_NAME:EMAIL,Data:@""}],
                                          @"Reset My Password"   :@[@{FIELD_NAME:NEW_password,Data:@""},@{FIELD_NAME:CONFIRM,Data:@""}],
                                          @"Notifications"       : @[@{FIELD_NAME:@"Receive Email Notifications",Data:@""},@{FIELD_NAME:@"Receive Push Notifications",Data:@""},@{FIELD_NAME:@"Logoutcell"}]};
    
    

    sectionsData=[NSMutableDictionary dictionaryWithDictionary:_dict];
    
    tableDataArray=[[NSArray alloc] initWithObjects:@"MainHeaderView",@"Profile Image",@"Account Information",@"Reset My Password", @"Notifications", @"Logout",  nil];
    
    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;//
    [_webservice sendGETrequestToservertoURI:userSettings];
    
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

-(IBAction)btn_buyStcikers_pressed:(id)sender
{
    NSURL *requesturl=[NSURL URLWithString:@"https://www.flashbaq.com/buy"];
    if (![[UIApplication sharedApplication] openURL:requesturl])
    {
        NSLog(@"%@%@",@"Failed to open url:",[requesturl description]);
    }
}

-(IBAction)btn_termsPressed:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FlashbaqWebview *vc = (FlashbaqWebview *)[storyboard instantiateViewControllerWithIdentifier:@"FWebView"];
    vc.urlString=@"https://www.flashbaq.com/terms";
    self.navigationController.navigationBar.hidden=NO;
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)btn_privacyPressed:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FlashbaqWebview *vc = (FlashbaqWebview *)[storyboard instantiateViewControllerWithIdentifier:@"FWebView"];
    vc.urlString=@"https://www.flashbaq.com/privacy";
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)btn_helpPressed:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FlashbaqWebview *vc = (FlashbaqWebview *)[storyboard instantiateViewControllerWithIdentifier:@"FWebView"];
    vc.urlString=@"http://support.flashbaq.com";
    [self.navigationController pushViewController:vc animated:YES];
}

-(void)viewWillAppear:(BOOL)animated
{
    
    AWSStaticCredentialsProvider *credentialsProvider = [AWSStaticCredentialsProvider credentialsWithAccessKey:MY_ACCESS_KEY_ID secretKey:MY_SECRET_KEY];
    AWSServiceConfiguration *configuration = [AWSServiceConfiguration configurationWithRegion:AWSRegionUSEast1
                                                                          credentialsProvider:credentialsProvider];
    
    [AWSServiceManager defaultServiceManager].defaultServiceConfiguration = configuration;

    
    // register for keyboard notifications
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    // unregister for keyboard notifications while not visible.
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillShowNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
}

-(IBAction)back_btnClicked:(id)sender
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)logout_clicked:(id)sender
{
    /* set the value of  */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setObject:@"no" forKey:@"isLoginDone"];
    [defaults synchronize];

    /*clear facebook session Data also */
    AppDelegate *_appdelegate=(AppDelegate *)[[UIApplication sharedApplication] delegate];
    [self dismissViewControllerAnimated:YES completion:nil];
    
    [_appdelegate.window.rootViewController removeFromParentViewController];
    _appdelegate.window=nil;
    _appdelegate.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    _appdelegate.window.backgroundColor = [UIColor whiteColor];

    _appdelegate.window.rootViewController=[_appdelegate generateFirstDemoVC];
    
    [_appdelegate.window makeKeyAndVisible];
    
}


-(IBAction)savebtn_clicked:(id)sender
{
    saveBtnPressed=YES;
    
    NSString *username=[[[sectionsData objectForKey:@"Account Information"]objectAtIndex:0]objectForKey:Data];
    NSString *firstName=[[[sectionsData objectForKey:@"Account Information"]objectAtIndex:1]objectForKey:Data];
    NSString *lastName=[[[sectionsData objectForKey:@"Account Information"]objectAtIndex:2]objectForKey:Data];
    NSString *email=[[[sectionsData objectForKey:@"Account Information"]objectAtIndex:3]objectForKey:Data];
    
    /*check for the updated profile Image */
    NSString *userImage=[[sectionsData objectForKey:@"Profile Image"]objectForKey:@"image"];
    
    if ([[userImage lowercaseString] containsString:@"/var/"])
    {
        /* upload to AWS */
        [self uploadimagetoAWS:userImage];
        
    }
    
    NSString *password=[[[sectionsData objectForKey:@"Reset My Password"]objectAtIndex:0]objectForKey:Data];
    
    NSString *allowPushNotif=[[[sectionsData objectForKey:@"Notifications"]objectAtIndex:1]objectForKey:Data];
    NSString *allowEmailNotif=[[[sectionsData objectForKey:@"Notifications"]objectAtIndex:0]objectForKey:Data];
    NSString *facebook_id=@" ";
    NSString *facebook_token=@" ";

    /*send Data to the server */
    
    
        NSArray *_keys = [NSArray arrayWithObjects:@"username", @"first_name", @"last_name",@"email",@"password",@"user_image",@"facebook_id",@"facebook_token",@"allow_notifications",@"allow_emails", nil];
    
    
    NSArray *_objects=[NSArray arrayWithObjects:username, firstName , lastName , email , password , [userImage lastPathComponent] , facebook_id , facebook_token , allowPushNotif , allowEmailNotif ,nil];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:_objects forKeys:_keys];
//
    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;
    NSString *url=[NSString stringWithFormat:@"https://api.flashbaq.com/v1/users/%@",[VSCore getUserID]];
    [_webservice SendJSONDataToServer:dataDict toURI:url forRequestType:PUT];
}

-(IBAction)takePhoto_clicked:(id)sender
{
    VMediaDevice *_vmediaDevice=[[VMediaDevice alloc]init];
    [_vmediaDevice setDeviceDelegate:self];
    [_vmediaDevice setIsCameraMode:YES];
    _vmediaDevice.mediaDeviceMode=TypeCamera;
    
    [self presentViewController:_vmediaDevice animated:YES completion:nil];

}

-(IBAction)choosephoto_clicked:(id)sender
{
    VMediaDevice *_vmediaDevice=[[VMediaDevice alloc]init];
    [_vmediaDevice setDeviceDelegate:self];
    [_vmediaDevice setIsCameraMode:YES];
    _vmediaDevice.mediaDeviceMode=TypeLibrary;
    
    [self presentViewController:_vmediaDevice animated:YES completion:nil];

}

-(IBAction)toggle_moved:(UISwitch *)sender
{
    UITableViewCell *textFieldRowCell=nil;
    
    NSIndexPath *indexPath = [__tableView indexPathForCell:(UITableViewCell *)[(UIView *)[sender superview] superview]];

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
    }
    
    else
    {
        textFieldRowCell = (NotificationCell *)[[[sender superview] superview] superview];
        
    }

    NSMutableArray *arrayData=[NSMutableArray arrayWithArray:[sectionsData objectForKey:@"Notifications"]];
    
    NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[arrayData objectAtIndex:indexPath.row]];
    
    NSString *switchValue=nil;
    if (sender.isOn)
    {
        switchValue=@"1";
    }
    
    else
    {
        switchValue=@"0";
        

    }
    [dict setObject:switchValue forKey:Data];

    [arrayData replaceObjectAtIndex:indexPath.row withObject:dict];
//    [arrayData addObject:dict];
    
    [sectionsData setObject:arrayData forKey:@"Notifications"];
    NSLog(@"%@",sectionsData);

}

-(void)keyboardWillShow
{
    // Animate the current view out of the way
    if (__tableView.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (__tableView.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}

-(void)keyboardWillHide
{
    if (__tableView.frame.origin.y >= 0)
    {
        [self setViewMovedUp:YES];
    }
    else if (__tableView.frame.origin.y < 0)
    {
        [self setViewMovedUp:NO];
    }
}


//method to move the view up/down whenever the keyboard is shown/dismissed
-(void)setViewMovedUp:(BOOL)movedUp
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3]; // if you want to slide up the view
    
    CGRect rect = __tableView.frame;
    if (movedUp)
    {
        // 1. move the view's origin up so that the text field that will be hidden come above the keyboard
        // 2. increase the size of the view so that the area behind the keyboard is covered up.
        rect.origin.y -= kOFFSET_FOR_KEYBOARD;
        rect.size.height += kOFFSET_FOR_KEYBOARD;
    }
    else
    {
        // revert back to the normal state.
        rect.origin.y += kOFFSET_FOR_KEYBOARD;
        rect.size.height -= kOFFSET_FOR_KEYBOARD;
    }
    __tableView.frame = rect;
    
    [UIView commitAnimations];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)uploadimagetoAWS:(NSString *)_filename
{
    
    __weak typeof(self) weakSelf = self;
    
    uploadRequest = [AWSS3TransferManagerUploadRequest new];
    uploadRequest.bucket = MY_PICTURE_BUCKET;
    uploadRequest.key = [_filename lastPathComponent];
    uploadRequest.body = [NSURL fileURLWithPath:_filename];
    uploadRequest.uploadProgress =  ^(int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend){
        dispatch_sync(dispatch_get_main_queue(), ^{
            weakSelf.file1AlreadyUpload = totalBytesSent;
            //            [weakSelf updateProgress];
        });
    };
    
    [self uploadFiles];
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

#pragma mark UITableViewDataSource Methods

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 || section == 1 )
    {
        return 1;
    }
    else
    {
        NSString *sectionTitle = [tableDataArray objectAtIndex:section];

        NSArray *sectionarray = [sectionsData objectForKey:sectionTitle];
        return [sectionarray count];

    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 5;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {
        return 124;
    }
    
    else if (indexPath.section == 1)
    {
        return 160;
    }
    else if (indexPath.section == 4)
    {
        if (indexPath.row == 0 || indexPath.row == 1)
        {
            return 44;

        }
        
        else
            return 175;
    }
    else
    {
        return 44;

    }
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"EmblmCell";
   
    UITableViewCell *cell = (UITableViewCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentity];

    
    if (indexPath.section == 1)
    {
        static NSString *cellIdentity = @"ProfileImage";

        ProfileImageCell *cell = (ProfileImageCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentity];
        
        if(cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"ProfileImageCell" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell = [topLevelObjects objectAtIndex:0];
        }

        NSString *sectionTitle = [tableDataArray objectAtIndex:indexPath.section];

        NSString *user_imageurl=[[sectionsData objectForKey:sectionTitle]objectForKey:@"image"];
        if ([user_imageurl length] > 0)
        {
            /*chck for the local path */
            if ([[user_imageurl lowercaseString] containsString:@"/var/"])
            {
                cell.userimageView.image=[UIImage imageWithContentsOfFile:user_imageurl];
                
            }
            
            else
            {
                NSURL *url = [NSURL URLWithString:user_imageurl]; //0 Index will be the Default Profile Picture
                
                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                    NSData *imageData = [NSData dataWithContentsOfURL:url];
                    UIImage *image = [UIImage imageWithData:imageData];
                    dispatch_async(dispatch_get_main_queue(),
                                   ^{
                                       cell.userimageView.image= image;
                                   });
                });
                

            }
        }
        
        return cell;
    }
    
    else if (indexPath.section == 2 || indexPath.section == 3)
    {
        static NSString *cellIdentity = @"SettingsField";

        SetiingsFieldCell *cell = (SetiingsFieldCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentity];
        
        if(cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SetiingsFieldCell" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        NSString *sectionTitle = [tableDataArray objectAtIndex:indexPath.section];
        
        NSDictionary *dict=[[sectionsData objectForKey:sectionTitle]objectAtIndex:indexPath.row];
        cell.lbl_name.text=[dict objectForKey:FIELD_NAME];
        
        if ([[dict objectForKey:FIELD_NAME] isEqualToString:@"Username"])
        {
            cell.txt_fieldName.enabled=NO;
        }
        else
        {
            cell.txt_fieldName.enabled=YES;

        }
        
        if (indexPath.section == 3)
        {
            [cell.txt_fieldName setSecureTextEntry:YES];
        }
        cell.txt_fieldName.delegate=self;
        cell.txt_fieldName.text=[dict objectForKey:Data];
        cell.txt_fieldName.tag=indexPath.section;
        return cell;

    }
    
    else if(indexPath.section == 4)
    {
        static NSString *cellIdentity = @"Notification";

        if (indexPath.row == 0 || indexPath.row ==1)
        {
            NotificationCell *cell = (NotificationCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentity];
            
            if(cell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"NotificationCell" owner:self options:nil];
                // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
                cell = [topLevelObjects objectAtIndex:0];
            }
            
            
            NSString *sectionTitle = [tableDataArray objectAtIndex:indexPath.section];
            
            NSDictionary *dict=[[sectionsData objectForKey:sectionTitle]objectAtIndex:indexPath.row];
            cell.lbl_name.text=[dict objectForKey:FIELD_NAME];
            
            if ([[dict objectForKey:Data] isEqualToString:@"1"])
            {
                [cell.toggleView setOn:YES animated:YES];
            }
            else
            {
                [cell.toggleView setOn:NO animated:YES];
            }
            return cell;
        }
        
        else
        {
            static NSString *cellIdentity = @"logout";
            
            LogoutCell *cell = (LogoutCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentity];
            
            if(cell == nil)
            {
                NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"LogoutCell" owner:self options:nil];
                // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
                cell = [topLevelObjects objectAtIndex:0];
            }
            
            cell.backgroundColor=[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]];
            
            return cell;

        }

    }
    
    else
    {
        static NSString *cellIdentity = @"mainheaderview";
        
        mainheaderview *cell = (mainheaderview *)[tableView dequeueReusableCellWithIdentifier:cellIdentity];
        
        if(cell == nil)
        {
            NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"mainheaderview" owner:self options:nil];
            // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
            cell = [topLevelObjects objectAtIndex:0];
        }
        
        cell.backgroundColor=[VSCore getColor:@"1a1a1a" withDefault:[UIColor blackColor]];

        return cell;
 
    }
    
    return 0;
}


- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return nil;
    }
    else
    {
        return [tableDataArray objectAtIndex:section] ;
    
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 0;
    }
    
    else
      return 44;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
 
    if (section == 0)
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        return headerView;
    }
    
    else
    {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.bounds.size.width, 44)];
        
        UILabel *lbl_title=[[UILabel alloc]initWithFrame:CGRectMake(20, 6, 250, 30)];
        lbl_title.text=[tableDataArray objectAtIndex:section];
        lbl_title.textColor=[VSCore getColor:@"888888" withDefault:[UIColor grayColor]];
        lbl_title.font=[UIFont fontWithName:OTHER_FONT size:17.0];
        
        [headerView addSubview:lbl_title];
        
        [headerView setBackgroundColor:[VSCore getColor:@"dedede" withDefault:[UIColor grayColor]]];
        return headerView;
    }
   
}


#pragma mark UITextFieldDelegate methods

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;

}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
   
//    NSString *name=[txt_names GetTextFieldTag];
//    NSString *fieldName=[NSString stringWithFormat:@"%ld",(long)textField.tag];
    /*change the data over here */
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    UITableViewCell *textFieldRowCell;
    
    NSIndexPath *indexPath = [__tableView indexPathForCell:(UITableViewCell *)[(UIView *)[textField superview] superview]];
    
    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_6_1)
    {
    }
    
    else
    {
        textFieldRowCell = (UITableViewCell *)[[[textField superview] superview] superview];
        
    }
    
    NSLog(@"%ld",(long)indexPath.row);
    
    if (textField.tag == 2)
    {
        NSMutableArray *arrayData=[NSMutableArray arrayWithArray:[sectionsData objectForKey:@"Account Information"]];

        NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[arrayData objectAtIndex:indexPath.row]];
        
        if ([textField.text length] > 0)
        {
            [dict setObject:textField.text forKey:Data];
            
            [arrayData replaceObjectAtIndex:indexPath.row withObject:dict];
            
            [sectionsData setObject:arrayData forKey:@"Account Information"];
            NSLog(@"%@",sectionsData);

        }
    }
    
    else
    {
        
        NSMutableArray *arrayData=[NSMutableArray arrayWithArray:[sectionsData objectForKey:@"Reset My Password"]];

        NSMutableDictionary *dict=[NSMutableDictionary dictionaryWithDictionary:[arrayData objectAtIndex:indexPath.row]];
        
        if ([textField.text length] > 0)
        {
            [dict setObject:textField.text forKey:Data];
            
            [arrayData replaceObjectAtIndex:indexPath.row withObject:dict];
            
            [sectionsData setObject:arrayData forKey:@"Reset My Password"];
            
            NSLog(@"%@",sectionsData);

        }

    }

}

#pragma mark UIWebserviceDelegate methods

-(void)responseReceivedwithData:(NSDictionary *)data
{
    if (saveBtnPressed)
    {
        saveBtnPressed=NO;
        [self dismissViewControllerAnimated:YES completion:nil];
    }
    
    else
    {
        NSDictionary *result=[data objectForKey:@"result"];
        
        for (int i=0 ; i < [[sectionsData allKeys] count]; i++)
        {
            
            if ([[tableDataArray objectAtIndex:i] isEqualToString:@"Account Information"])
            {
                NSMutableArray *arrayData=[NSMutableArray arrayWithArray:[sectionsData objectForKey:@"Account Information"]];
                
                for (int j=0; j < [arrayData count]; j++)
                {
                    NSMutableDictionary *data=[NSMutableDictionary dictionaryWithDictionary:[arrayData objectAtIndex:j]];
                    
                    if ([[data objectForKey:FIELD_NAME] isEqualToString:@"Username"])
                    {
                        [data setObject:[result objectForKey:@"username"] forKey:Data];
                        [arrayData setObject:data atIndexedSubscript:j];
                    }
                    
                    else if ([[data objectForKey:FIELD_NAME] isEqualToString:@"First Name"])
                    {
                        [data setObject:[result objectForKey:@"first_name"] forKey:Data];
                        [arrayData setObject:data atIndexedSubscript:j];
                        
                    }
                    
                    else if ([[data objectForKey:FIELD_NAME] isEqualToString:@"Last Name"])
                    {
                        [data setObject:[result objectForKey:@"last_name"] forKey:Data];
                        [arrayData setObject:data atIndexedSubscript:j];
                        
                    }
                    else
                    {
                        [data setObject:[result objectForKey:@"email"] forKey:Data];
                        [arrayData setObject:data atIndexedSubscript:j];
                        
                    }
                }
                
                [sectionsData setObject:arrayData forKey:@"Account Information"];
            }
            
            else if ([[tableDataArray objectAtIndex:i] isEqualToString:@"Notifications"])
            {
                NSMutableArray *arrayData=[NSMutableArray arrayWithArray:[sectionsData objectForKey:@"Notifications"]];
                
                for (int j=0; j < [arrayData count]; j++)
                {
                    NSMutableDictionary *data=[NSMutableDictionary dictionaryWithDictionary:[arrayData objectAtIndex:j]];
                    if ([[data objectForKey:FIELD_NAME] isEqualToString:@"Receive Email Notifications"])
                    {
                        [data setObject:[result objectForKey:@"allow_emails"] forKey:Data];
                        [arrayData setObject:data atIndexedSubscript:j];
                        
                    }
                    
                    else if ([[data objectForKey:FIELD_NAME] isEqualToString:@"Receive Push Notifications"])
                    {
                        [data setObject:[result objectForKey:@"allow_notifications"] forKey:Data];
                        [arrayData setObject:data atIndexedSubscript:j];
                        
                    }
                    
                }
                
                [sectionsData setObject:arrayData forKey:@"Notifications"];
                
            }
            
            else if ([[tableDataArray objectAtIndex:i] isEqualToString:@"Profile Image"])
            {
                NSMutableDictionary *data=[NSMutableDictionary dictionaryWithDictionary:[sectionsData objectForKey:@"Profile Image"]];
                
                [data setObject:[result objectForKey:@"user_image"] forKey:@"image"];
                
                [sectionsData setObject:data forKey:@"Profile Image"];
                
            }
        }
        
        [__tableView reloadData];

    }
//    sectionsData setObject:[result objectForKey:@"email"] forKey:(id<NSCopying>)
}

#pragma mark MediaDeviceDelegate Methods
-(void)imagePickerdidfinishLoadedWithData:(NSDictionary *)mediaData
{
    if ([[[mediaData objectForKey:@"filename"] pathExtension] isEqualToString:@"jpg"])
    {

        NSMutableDictionary *profileImageData=[NSMutableDictionary dictionaryWithDictionary:[sectionsData objectForKey:@"Profile Image"]];
        [profileImageData setObject:[mediaData objectForKey:@"filepath"] forKey:@"image"];
         
         [sectionsData setObject:profileImageData forKey:@"Profile Image"];

        NSIndexPath *path=[NSIndexPath indexPathForItem:0 inSection:1];
        [__tableView reloadRowsAtIndexPaths:[NSArray arrayWithObjects:path, nil] withRowAnimation:UITableViewRowAnimationNone];
        
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
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
