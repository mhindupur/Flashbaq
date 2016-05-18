//
//  FollowingVC.h
//  emblm
//
//  Created by Kavya Valavala on 2/15/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FollowingviewDelegate <NSObject>

-(void)setFollowingFormDidDismisswithData:(NSDictionary *)userdata;

@end

@interface FollowingVC : UIViewController

@property (nonatomic, strong) IBOutlet UITextField *txt_search;
@property (nonatomic, strong) IBOutlet UIButton    *btn_searchClick;
@property (nonatomic, strong) IBOutlet UITableView *table_follwinglist;
@property (nonatomic, strong) IBOutlet UIImageView *emptyResultView;
@property (nonatomic) id  <FollowingviewDelegate>       _followingDelegate;
@property (nonatomic, strong) NSString *userID;
@end
