//
//  LikesView.h
//  emblm
//
//  Created by Kavya Valavala on 2/26/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol LikesViewDelegate <NSObject>

-(void)donotReloadTableviewfromLikesView;

@end
@interface LikesView : UIViewController

@property (nonatomic, strong) IBOutlet UITableView *_tableview;
@property (nonatomic, strong) NSString *postID;
@property (nonatomic)         id <LikesViewDelegate> likesDelegate;
@end
