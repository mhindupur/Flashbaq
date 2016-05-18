//
//  PostEmblmVC.h
//  emblm
//
//  Created by Kavya Valavala on 1/30/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol postEmblmVCDelegate <NSObject>

-(void)dismissAttachMediaandPoptoScannerVC;
-(void)displayPostDetailsformwithData:(NSDictionary *)data;
-(void)dismissPostEmblmVC;

@end

@interface PostEmblmVC : UIViewController

@property (nonatomic, strong) IBOutlet UITextView *txt_notes;
@property (nonatomic, strong) IBOutlet UIImageView *imgview;
@property (nonatomic, strong) IBOutlet UISwitch    *privateSwitch;
@property (nonatomic, strong) IBOutlet UIButton    *btn_finalize;
@property (nonatomic, strong) IBOutlet UINavigationBar      *_navbar;
@property (nonatomic, strong) IBOutlet UISwitch    *emblmSwitch;
@property (nonatomic, strong) IBOutlet UILabel     *lbl_sticking, *lbl_makeprivate , *lbl_description;
@property (nonatomic, strong) IBOutlet UIActivityIndicatorView *_indicatorView;
@property (nonatomic, strong) id <postEmblmVCDelegate> postemblmDelegate;
@property (nonatomic, strong) NSString *videoFilePath;
@property (nonatomic, strong) NSMutableDictionary *postDataDict;
@property (nonatomic, strong) IBOutlet UILabel     *lbl_status;
@property (nonatomic, strong) IBOutlet UITextField           *txt_stickfield;
-(IBAction)changeSwitch:(id)sender;

@end
