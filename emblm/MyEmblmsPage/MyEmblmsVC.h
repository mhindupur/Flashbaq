//
//  MyEmblmsVC.h
//  emblm
//
//  Created by Kavya Valavala on 1/6/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FlashbaqVideoPlayer.h"

@interface MyEmblmsVC : UIViewController

@property (nonatomic, strong) IBOutlet UITableView        *_tableView;
@property (nonatomic, strong) IBOutlet UIImageView        *nodataImageview;
@property (nonatomic, strong) IBOutlet UIButton           *btn_myScans , *btn_myflashbaq;
@end
