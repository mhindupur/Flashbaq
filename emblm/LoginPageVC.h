//
//  LoginPageVC.h
//  emblm
//
//  Created by Kavya Valavala on 12/16/14.
//  Copyright (c) 2014 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LoginPageVC : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *txt_userName, *txt_password;
@property (nonatomic,strong) IBOutlet UINavigationBar  *_navbar;
@property (nonatomic,strong) IBOutlet UIView           *errormsgview;
@property (nonatomic,strong) IBOutlet UILabel          *lbl_errormsg;
@property (nonatomic,strong) IBOutlet UILabel         *lbl_frgtPwd;

@end
