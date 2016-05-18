//
//  CreateProfileView.h
//  emblm
//
//  Created by Kavya Valavala on 1/5/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VMediaDevice;

@interface CreateProfileView : UIViewController

@property (nonatomic, strong) IBOutlet UINavigationBar *_navbar;
@property (nonatomic, strong) IBOutlet UITextField     *txt_firstName , *txt_lastName;
@property (nonatomic, strong) IBOutlet UIImageView     *_imageView;
@property (nonatomic, strong) IBOutlet UIBarButtonItem *_skipbtn;
@property (nonatomic, strong) IBOutlet UIButton        *btn_continue;

-(IBAction)choosePhoto_clicked:(id)sender;

@end
