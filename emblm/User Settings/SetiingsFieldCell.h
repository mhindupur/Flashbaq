//
//  SetiingsFieldCell.h
//  Flashbaq
//
//  Created by Kavya Valavala on 3/17/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SetiingsFieldCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UILabel     *lbl_name;
@property (nonatomic, strong) IBOutlet UITextField *txt_fieldName;

@end