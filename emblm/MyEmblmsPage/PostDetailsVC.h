//
//  PostDetailsVC.h
//  emblm
//
//  Created by Kavya Valavala on 2/19/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HPGrowingTextView.h"


@protocol PostDetailsViewDelegate <NSObject>

-(void)setProfileViewwithData:(NSDictionary *)userdata;
-(void)donotReloadTableviewDatawith:(NSMutableDictionary *)resultData;

@end


@interface PostDetailsVC : UIViewController
{
    HPGrowingTextView *textView;

}

@property (nonatomic, strong) IBOutlet UITableView *_tableView;
@property (nonatomic, strong) HPGrowingTextView      *textView;
@property (nonatomic, strong) NSMutableDictionary         *resultDict;
@property (nonatomic, strong) IBOutlet UIButton    *btn_follow;
@property (nonatomic) id  <PostDetailsViewDelegate>     postDelegate;
@property (nonatomic, strong) NSString              *flashbaqCode;
@property (nonatomic)         BOOL isnotificationView;
@property (nonatomic) BOOL  isProfileView;
@end
