//
//  PasswordResetPage.h
//  emblm
//
//  Created by Kavya Valavala on 2/6/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PasswordResetPage : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *txt_email;
@property (nonatomic,strong) IBOutlet UINavigationBar  *_navbar;
@property (nonatomic, strong) IBOutlet UIImageView     *_imgview;
@property (nonatomic,strong) IBOutlet UIView           *errormsgview;
@property (nonatomic,strong) IBOutlet UILabel          *lbl_errormsg;

@end
