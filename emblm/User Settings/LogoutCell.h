//
//  LogoutCell.h
//  Flashbaq
//
//  Created by Kavya Valavala on 3/17/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LogoutCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIButton *btn_logout;
@property (nonatomic, strong) IBOutlet UILabel  *lbl_terms;
@property (nonatomic, strong) IBOutlet UILabel  *lbl_privacy;
@property (nonatomic, strong) IBOutlet UILabel  *lbl_help;
@property (nonatomic, strong) IBOutlet UIButton *btn_terms;
@property (nonatomic, strong) IBOutlet UIButton *btn_privacy;
@property (nonatomic, strong) IBOutlet UIButton *btn_help;

@end
