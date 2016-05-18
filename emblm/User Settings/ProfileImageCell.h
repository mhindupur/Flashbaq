//
//  ProfileImageCell.h
//  Flashbaq
//
//  Created by Kavya Valavala on 3/17/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ProfileImageCell : UITableViewCell

@property (nonatomic, strong) IBOutlet UIImageView *userimageView;
@property (nonatomic, strong) IBOutlet UIButton    *btn_choosephoto , *btn_takephoto;
@end

