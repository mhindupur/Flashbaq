//
//  FollowerVC.h
//  emblm
//
//  Created by Kavya Valavala on 2/16/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol FollowerDelegate <NSObject>

-(void)setFollowerDidDismisswithData:(NSDictionary *)userdata;

@end

@interface FollowerVC : UIViewController

@property (nonatomic, strong) IBOutlet UITableView *_tableview;
@property (nonatomic, strong) IBOutlet UIImageView *nofollowersImage;
@property (nonatomic) id  <FollowerDelegate>       _followDelegate;
@property (nonatomic) BOOL isCurrentUserProfile;
@property (nonatomic, strong) NSString *userID;
@end
