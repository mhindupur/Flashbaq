//
//  ProfilePageVC.h
//  emblm
//
//  Created by Kavya Valavala on 1/6/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FollowerVC.h"
#import "FollowingVC.h"
#import "FlashbaqVideoPlayer.h"


@interface ProfilePageVC : UIViewController<FollowerDelegate, FollowingviewDelegate>

@property (nonatomic, strong) IBOutlet UITableView     *mainTableView;


@end

