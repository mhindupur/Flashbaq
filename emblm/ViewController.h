//
//  ViewController.h
//  emblm
//
//  Created by Kavya Valavala on 11/26/14.
//  Copyright (c) 2014 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>

@interface ViewController : UIViewController<UITextFieldDelegate>

@property (nonatomic,strong) IBOutlet UITextField      *txt_username, *txt_password, *txt_email;
@property (nonatomic,strong) IBOutlet UILabel          *lbl_or;
@property (nonatomic,strong) IBOutlet UINavigationBar  *_navbar;
@property (nonatomic,strong) IBOutlet UIButton         *btn_FBLogin;
@property (nonatomic,strong) IBOutlet UIView           *errorMsgview;
@property (nonatomic,strong) IBOutlet UILabel          *lbl_errormsg;
@end

