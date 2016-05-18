//
//  NotifViewCell.h
//  Flashbaq
//
//  Created by Kavya Valavala on 7/13/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NotifViewCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *profileimage;
@property (nonatomic, strong) IBOutlet UILabel     *lbl_descp;
@property (nonatomic, strong) IBOutlet UILabel     *lbl_timestamp;

@end
