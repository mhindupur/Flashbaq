//
//  MyEmblmsVC.m
//  emblm
//
//  Created by Kavya Valavala on 1/6/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "MyEmblmsVC.h"
#import "VSCore.h"
#import "WebService.h"
#import "EmblmCell.h"
#import "LikesView.h"
#import "ApplicationSettings.h"
#import "PostDetailsVC.h"
#import "ProgressHUD.h"
#import "GIBadgeView.h"
#import "NotificationTableVC.h"

@interface MyEmblmsVC ()<WebServiceDelegate , UIScrollViewDelegate , PostDetailsViewDelegate>
{
    NSMutableArray *_dataArray;
    UIActivityIndicatorView *spinner;
    int currentPage;
    BOOL isendOfPage;
    BOOL isDeleteRequest;
    BOOL isLikeRequest;
    BOOL isfollowRequest;
    NSInteger deleteIndex;
    NSInteger likeBtnIndex;
    NSMutableArray *likedIndexes;
    BOOL isformOpen;
    NSInteger selectedBtnIndex;
    UIButton *delteButton;
    NSString *followerName;
    UIImageView *selectedfollowView;
    BOOL videoViewgotTapped;
    EmblmCell *previousCell;
    NSInteger followbtnIndex;
    BOOL isunfollowRequest;
    BOOL isfolloweRequest;
    NSInteger selectedPostIndex;
    GIBadgeView *badgeView;
}
@end

@implementation MyEmblmsVC;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    NSLog(@"viewDidLoad");
    
    [self createbadgeview];
    
    _btn_myflashbaq.titleLabel.font = [UIFont fontWithName:TITLE_FONT size:16.0];
    [_btn_myflashbaq setTitle: @"My flashbaqs" forState:UIControlStateNormal];

    _btn_myScans.titleLabel.font = [UIFont fontWithName:TITLE_FONT size:16.0];
    [_btn_myScans setTitle: @"My Scans" forState:UIControlStateNormal];

    currentPage=1;
    isendOfPage=NO;
    isDeleteRequest=NO;
    isLikeRequest=NO;
    isformOpen=YES;
    
    _dataArray=[[NSMutableArray alloc]init];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
    self.navigationController.navigationBar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];

    UIImageView *imgview=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = imgview;

    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    self.view.backgroundColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];
    
    [_btn_myScans setSelected:YES];
    selectedBtnIndex=0;

    __tableView.allowsSelection = NO;
    
    likedIndexes=[[NSMutableArray alloc]init];

    // Do any additional setup after loading the view.
}

-(void)createbadgeview
{
    UIImageView *notifImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"notification1"]];
    notifImage.clipsToBounds = NO;
    notifImage.contentMode=UIViewContentModeScaleAspectFit;
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.frame = CGRectMake(0, 0, 44, 53);
    notifImage.center=button.center;
    [button addSubview:notifImage];
    
    badgeView = [GIBadgeView new];
    badgeView.font = [UIFont fontWithName:OTHER_FONT size:10];
    badgeView.backgroundColor = [UIColor whiteColor];
    badgeView.textColor=[VSCore getColor:@"9c76cc" withDefault:[UIColor blackColor]];
    [notifImage addSubview:badgeView];
    
    [badgeView setBadgeValue:[[[NSUserDefaults standardUserDefaults] objectForKey:@"NotificationCount"] integerValue]];
    
    [button addTarget:self action:@selector(animatetoNotificationView) forControlEvents:UIControlEventTouchUpInside];
    notifImage.center = button.center;
    UIBarButtonItem *barItem = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.leftBarButtonItem=barItem;
    
}

-(void)animatetoNotificationView
{
    //NotificationTable
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    NotificationTableVC *vc = (NotificationTableVC *)[storyboard instantiateViewControllerWithIdentifier:@"NotificationTable"];
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    videoViewgotTapped=NO;

    isfollowRequest=NO;
    __tableView.backgroundView=nil;
    
    CALayer * l = [_btn_myScans layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:2.0];
    
    
    CALayer * flashbqL = [_btn_myflashbaq layer];
    [flashbqL setMasksToBounds:YES];
    [flashbqL setCornerRadius:1.0];

    [_nodataImageview setHidden:YES];
    NSLog(@"viewWillAppear");
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);

    [likedIndexes removeAllObjects];
    
    if (isformOpen)
    {
       [_btn_myScans setSelected:YES];
       [_btn_myflashbaq setSelected:NO];

        isformOpen=NO;
        currentPage=1;
        isendOfPage=NO;
        [_dataArray removeAllObjects];
        [__tableView reloadData];
        
        [self sendMyscanRequestToAPI];
    }
   
    
}

-(void)viewDidDisappear:(BOOL)animated
{
    isformOpen=YES;
    selectedBtnIndex=0;

    if (previousCell)
    {
        [previousCell.flashbaqPlayer._guiplayerView clean];
        
        [previousCell.flashbaqPlayer._guiplayerView stop];
        
    }
}

-(IBAction)myScans_cliked:(id)sender
{
    if (previousCell)
    {
        [previousCell.flashbaqPlayer._guiplayerView clean];
        
        [previousCell.flashbaqPlayer._guiplayerView stop];
        
    }
    
    selectedBtnIndex=0;
    
    [_btn_myScans setSelected:YES];
    [_btn_myflashbaq setSelected:NO];

    [likedIndexes removeAllObjects];
    
    currentPage=1;
    isendOfPage=NO;
    [_dataArray removeAllObjects];
    [__tableView reloadData];
    
    /* Retrieve all of the scans that have occured for a specific Emblm. Valid emblm-token required in headers to authenticate the logged in user per this request. */
    [self sendMyscanRequestToAPI];

}

-(IBAction)myEmblmsClicked:(id)sender
{
    
    if (previousCell)
    {
        [previousCell.flashbaqPlayer._guiplayerView clean];
        
        [previousCell.flashbaqPlayer._guiplayerView stop];
        
    }
    selectedBtnIndex=1;
    
    [_btn_myScans setSelected:NO];
    [_btn_myflashbaq setSelected:YES];
    
    [likedIndexes removeAllObjects];
    
    currentPage=1;
    isendOfPage=NO;
    [_dataArray removeAllObjects];
    [__tableView reloadData];
    
    /* Get all of the Emblms created by a specific user. Valid emblm-token required in headers to authenticate the logged in user per this request.*/
    
    [self sendMyEmblmRequestToAPI];

}

-(void)flashbaqvideoplayerTapped:(UITapGestureRecognizer *)sender
{
    
    if (!videoViewgotTapped)
    {
        videoViewgotTapped=YES;
        
        if (previousCell)/*if previously clicked Flashbaqvideoplayer is playing or not */
        {
            [previousCell.flashbaqPlayer._guiplayerView clean];
            [previousCell.flashbaqPlayer._guiplayerView stop];

        }
        
        /*add recent clicked cell */
        UIView *selectedview = (UIView*)sender.view;
        previousCell = (EmblmCell *)[selectedview superview];
        
        //        NSLog(@"FlashbaqVideoPlayer Stopped");
        
    }
    
    if (previousCell.flashbaqPlayer._guiplayerView != nil)
    {
        NSLog(@"FlashbaqVideoPlayer Stopped");
        
        [previousCell.flashbaqPlayer._guiplayerView clean];
        [previousCell.flashbaqPlayer._guiplayerView stop];

        videoViewgotTapped=NO;
        
        UIView *selectedview = (UIView*)sender.view;
        previousCell = (EmblmCell *)[selectedview superview];
    }
    
    FlashbaqVideoPlayer *playerview = (FlashbaqVideoPlayer*)sender.view;
    
    NSURL *mediaurl;
    
    if ([[_dataArray objectAtIndex:sender.view.tag] objectForKey:@"emblm"] != nil)
    {
        mediaurl=[NSURL URLWithString:[[[_dataArray objectAtIndex:sender.view.tag] objectForKey:@"emblm"] objectForKey:@"media"]];
    }
    else
    {
        mediaurl=[NSURL URLWithString:[[_dataArray objectAtIndex:sender.view.tag] objectForKey:@"media"]];
        
    }
    
    playerview._guiplayerView = [[GUIPlayerView alloc] initWithFrame:playerview.previewImageview.frame];
    //    [__guiplayerView clean];
    UITapGestureRecognizer *_thmbnailtap=[[UITapGestureRecognizer alloc]initWithTarget:playerview action:@selector(playerviewTapped:)];
    _thmbnailtap.numberOfTapsRequired=1;
    [playerview._guiplayerView addGestureRecognizer:_thmbnailtap];
    
    
    [playerview._guiplayerView setDelegate:playerview];
    
    [playerview addSubview:playerview._guiplayerView];
    
    [playerview._guiplayerView setVideoURL:mediaurl];
    playerview._guiplayerView.contentMode=UIViewContentModeScaleToFill;
    playerview._guiplayerView.clipsToBounds=YES;
    
    [playerview startBufferingVideo];

    [playerview._guiplayerView prepareAndPlayAutomatically:YES];
    
    /*check for previously clicked and current cell */
    
    
}

//-(IBAction)segmentedCtrl_click:(id)sender
//{
//    if (selectedBtnIndex == 0)
//    {
//        [likedIndexes removeAllObjects];
//        
//        currentPage=1;
//        isendOfPage=NO;
//        [_dataArray removeAllObjects];
//        [__tableView reloadData];
//        
//        /* Retrieve all of the scans that have occured for a specific Emblm. Valid emblm-token required in headers to authenticate the logged in user per this request. */
//        [self sendMyscanRequestToAPI];
//        
//    }
//    
//    else
//    {
//        [likedIndexes removeAllObjects];
//
//        currentPage=1;
//        isendOfPage=NO;
//        [_dataArray removeAllObjects];
//        [__tableView reloadData];
//
//        /* Get all of the Emblms created by a specific user. Valid emblm-token required in headers to authenticate the logged in user per this request.*/
//    
//        [self sendMyEmblmRequestToAPI];
//    }
//}

-(void)sendMyEmblmRequestToAPI
{
    [spinner startAnimating];
    
    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;//
    NSString *url=[NSString stringWithFormat:MyEmblms,[VSCore getUserID],currentPage];
    [_webservice sendGETrequestToservertoURI:url];
}

-(void)sendMyscanRequestToAPI
{
    [spinner startAnimating];
    
    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;
    NSString *url=[NSString stringWithFormat:MyScans,[VSCore getUserID],currentPage];
    [_webservice sendGETrequestToservertoURI:url];
    

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)followViewTapOccured:(UITapGestureRecognizer *)sender
{
    selectedfollowView = (UIImageView*)sender.view;
    followbtnIndex=selectedfollowView.tag;
    NSString *followerid=nil;
    BOOL     is_following;
    
    if ([[_dataArray objectAtIndex:selectedfollowView.tag] objectForKey:@"emblm"] != nil)
    {
        followerid=[[[[_dataArray objectAtIndex:selectedfollowView.tag] objectForKey:@"emblm"] objectForKey:@"user"] objectForKey:@"id"];//PostID
        is_following=[[[[_dataArray objectAtIndex:selectedfollowView.tag] objectForKey:@"emblm"] objectForKey:@"is_following"] boolValue];
        followerName=[[[[_dataArray objectAtIndex:selectedfollowView.tag] objectForKey:@"emblm"] objectForKey:@"user"] objectForKey:@"username"];
    }
    
    else
    {
        followerid=[[[_dataArray objectAtIndex:selectedfollowView.tag] objectForKey:@"user"] objectForKey:@"id"];//PostID
        is_following=[[[_dataArray objectAtIndex:selectedfollowView.tag] objectForKey:@"is_following"] boolValue];
        followerName=[[[_dataArray objectAtIndex:selectedfollowView.tag] objectForKey:@"user"] objectForKey:@"username"];

    }

    NSArray *keys = [NSArray arrayWithObjects:@"user", @"follower", nil];
    NSArray *objects=[NSArray arrayWithObjects:[VSCore getUserID], followerid, nil];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    WebService *_webservice=[[WebService alloc]init];
    [_webservice setWebDelegate:self];
    
    if (!is_following && !([[VSCore getUserID] isEqualToString:followerid]))
    {
        isfollowRequest=YES;
        [_webservice SendJSONDataToServer:dataDict toURI:NewFollower forRequestType:POST];
    }
    else if(is_following && !([[VSCore getUserID] isEqualToString:followerid]))
    {
        
//        NSString *_msg=[NSString stringWithFormat:@"Following %@" , followerName];
//        [ProgressHUD showSuccess:_msg];
        /*unfollow him */
        
        isunfollowRequest=YES;

        NSString *url=[NSString stringWithFormat:Unfollow, followerid];
        
        [_webservice SendJSONDataToServer:0 toURI:url forRequestType:POST];

    }
    
}

-(void)LikesCountTapoccurred:(UITapGestureRecognizer *)recognizer
{
    UILabel *selectedcmntsView = (UILabel*)recognizer.view;

    CGPoint point = [recognizer locationInView:selectedcmntsView];
    
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        LikesView *vc = (LikesView *)[storyboard instantiateViewControllerWithIdentifier:@"Like"];
        
        if ([[_dataArray objectAtIndex:selectedcmntsView.tag] objectForKey:@"emblm"] != nil)
        {
            vc.postID=[[[_dataArray objectAtIndex:selectedcmntsView.tag] objectForKey:@"emblm"] objectForKey:@"id"];

        }
        
        else
        {
            vc.postID=[[_dataArray objectAtIndex:selectedcmntsView.tag] objectForKey:@"id"];

        }
//        [vc set_followingDelegate:self];
        [self.navigationController pushViewController:vc animated:YES];
    
       NSLog(@"%@", NSStringFromCGPoint(point));
}

-(void)LikeviewTapoccurred:(UITapGestureRecognizer *)recognizer
{
    isLikeRequest=YES;
    
    UIImageView *selectedView = (UIImageView*)recognizer.view;

    likeBtnIndex=selectedView.tag;
    
    NSString *postid=nil;
    
    if ([[_dataArray objectAtIndex:selectedView.tag] objectForKey:@"emblm"] != nil)
    {
        postid=[[[_dataArray objectAtIndex:selectedView.tag] objectForKey:@"emblm"] objectForKey:@"id"];//PostID
    }
    
    else
    {
        postid=[[_dataArray objectAtIndex:selectedView.tag] objectForKey:@"id"];//PostID
    }
    

    /*send Like/Unlike Request based on the likedIndexes array */
    NSIndexPath* likedIndexPath = [NSIndexPath indexPathForRow:likeBtnIndex inSection:0];

    if ([likedIndexes containsObject:likedIndexPath])
    {
        /*send Unlike Request */
        [self sendUnlikeRequestwithPostID:postid];
        [selectedView setImage:[UIImage imageNamed:@"love.png"]];
    }
    
    else
    {
        [self sendLikeRequestwithPostID:postid];
        [selectedView setImage:[UIImage imageNamed:@"redlove.png"]];
    }
    

}

-(void)CommentsviewTapoccurred:(UITapGestureRecognizer *)recognizer
{
    UILabel *selectedcmntsView = (UILabel*)recognizer.view;
    
    selectedPostIndex=selectedcmntsView.tag;

    CGPoint point = [recognizer locationInView:selectedcmntsView];
    
        NSLog(@"Open Comments Page");
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PostDetailsVC *vc = (PostDetailsVC *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetails"];
        vc.postDelegate=self;
        vc.isProfileView=NO;
        if ([[_dataArray objectAtIndex:selectedcmntsView.tag] objectForKey:@"emblm"] != nil)
        {
            vc.resultDict=[NSMutableDictionary dictionaryWithDictionary:[[_dataArray objectAtIndex:selectedcmntsView.tag] objectForKey:@"emblm"]];

//            vc.resultDict=[[_dataArray objectAtIndex:selectedcmntsView.tag] objectForKey:@"emblm"];
            
        }
        
        else
        {
            vc.resultDict=[NSMutableDictionary dictionaryWithDictionary:[_dataArray objectAtIndex:selectedcmntsView.tag]];

//            vc.resultDict=[_dataArray objectAtIndex:selectedcmntsView.tag];
            
        }
        
        
        [self.navigationController pushViewController:vc animated:YES];
    
    NSLog(@"%@", NSStringFromCGPoint(point));

}
-(void)sendLikeRequestwithPostID:(NSString *)postid
{
    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;

    NSString *url=[NSString stringWithFormat:LikePost,postid];//PostID

    [_webservice SendJSONDataToServer:0 toURI:url forRequestType:POST];

}

-(void)sendUnlikeRequestwithPostID:(NSString *)postid
{
    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;
    
    NSString *url=[NSString stringWithFormat:UnlikePost,postid];//PostID
    
    [_webservice SendJSONDataToServer:0 toURI:url forRequestType:POST];
}

-(void)deletePost:(UIButton*)sender
{
    
    /*pop up sn alert view */
    
    UIAlertView *_alrt=[[UIAlertView alloc]initWithTitle:@"" message:@"Are you sure you want to delete?" delegate:self cancelButtonTitle:@"Yes" otherButtonTitles:@"No", nil];
    [_alrt show];
    
    delteButton=sender;
    
}

-(void)scannedByuserTapped:(UITapGestureRecognizer *)recognizer
{
    
    NSDictionary *dict=[_dataArray objectAtIndex:recognizer.view.tag];
    
    if ([dict objectForKey:@"emblm"] != nil)
    {
        [[ApplicationSettings getInstance] setUserId:[[[dict objectForKey:@"emblm"] objectForKey:@"user"] objectForKey:@"id"]];

    }
    
    else
    {
        [[ApplicationSettings getInstance] setUserId:[[dict objectForKey:@"user"] objectForKey:@"id"]];

    }
    [self.navigationController.tabBarController setSelectedIndex:3];
    
}

-(void)createdByuserTapped:(UITapGestureRecognizer *)recognizer
{
    
    NSDictionary *dict=[_dataArray objectAtIndex:recognizer.view.tag];
    
    if ([dict objectForKey:@"emblm"] != nil)
    {
        [[ApplicationSettings getInstance] setUserId:[[[dict objectForKey:@"emblm"] objectForKey:@"user"] objectForKey:@"id"]];
        
    }
    
    else
    {
        [[ApplicationSettings getInstance] setUserId:[[dict objectForKey:@"user"] objectForKey:@"id"]];
        
    }    [self.navigationController.tabBarController setSelectedIndex:3];
    
}

-(void)updateis_followingInDataArray:(BOOL)followRequest
{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithDictionary:[_dataArray objectAtIndex:followbtnIndex]];
    
    NSString *followUserId=nil;
    
    if ([dict objectForKey:@"emblm"] != nil)
    {
       followUserId=[[[dict objectForKey:@"emblm"] objectForKey:@"user"] objectForKey:@"id"];
    }
    
    else
    {
        followUserId=[[dict objectForKey:@"user"]objectForKey:@"id"];
    }
    
    
    /*check for the other indexPaths of same user ID */
    NSMutableArray *updateIndexArray=[[NSMutableArray alloc]init];
    
    for (NSMutableDictionary *postdict in _dataArray)
    {
        if ([postdict objectForKey:@"emblm"] != nil)
        {
            NSString *userID=[[[postdict objectForKey:@"emblm"] objectForKey:@"user"] objectForKey:@"id"];
            if ([userID isEqualToString:followUserId])
            {
                NSUInteger fooIndex = [_dataArray indexOfObject:postdict];
                NSIndexPath *path=[NSIndexPath indexPathForRow:fooIndex inSection:0];
                [updateIndexArray addObject:path];
            }
            
        }
        
    }
    
    
    for (int i=0; i < [updateIndexArray count]; i++)
    {
        NSIndexPath *arrayrow=[updateIndexArray objectAtIndex:i];
        NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithDictionary:[_dataArray objectAtIndex:arrayrow.row]];
        
        if ([dict objectForKey:@"emblm"] != nil)
        {
            NSMutableDictionary *emblmDict=[[NSMutableDictionary alloc]initWithDictionary:[dict objectForKey:@"emblm"]];
            if (followRequest)
                
            {
                [emblmDict setObject:@"1" forKey:@"is_following"];
            }
            
            else
            {
                [emblmDict setObject:@"0" forKey:@"is_following"];
                
            }

            [dict setObject:emblmDict forKey:@"emblm"];

        }
        
        else
        {
            if (followRequest)
            {
                [dict setObject:@"1" forKey:@"is_following"];
                
            }
            
            else
            {
                [dict setObject:@"0" forKeyedSubscript:@"is_following"];
                
            }

        }

        
        [_dataArray removeObjectAtIndex:arrayrow.row];/*Update the array*/
        
        [_dataArray insertObject:dict atIndex:arrayrow.row];
        
    }
    
    // Add them in an index path array
    // Launch reload for the two index path
    [__tableView reloadRowsAtIndexPaths:updateIndexArray withRowAnimation:UITableViewRowAnimationNone];
    
    /*Display Message */
    
    NSString *alrtmessage=nil;
    if (followRequest)
    {
        alrtmessage=[NSString stringWithFormat:@"Following %@",followerName];
    }
    
    else
    {
        alrtmessage=[NSString stringWithFormat:@"Unfollowed %@",followerName];
    }
    
    [ProgressHUD showSuccess:alrtmessage];

}

#pragma mark UITableViewDatasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_dataArray count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    /*adjust the height dynamically */
    
    NSString *comment=nil;
    
    NSDictionary *dict=[_dataArray objectAtIndex:indexPath.row];
    if ([dict objectForKey:@"emblm"] != nil)
    {
        comment=[[dict objectForKey:@"emblm"] objectForKey:@"message"];
        
    }
    
    else
    {
        comment=[dict objectForKey:@"message"];
    }
    
    CGFloat cellHeight = 0.0;
    
    cellHeight += [EmblmCell cellHeightForCommentText:comment];
    return cellHeight;
    
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"EmblmCell";
    
    EmblmCell *cell = (EmblmCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentity];
    
    if(cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"EmblmCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    BOOL visiblePathFound = NO;
    
    if (previousCell)
    {
        
        NSIndexPath *prevCellindexPath = [tableView indexPathForCell:previousCell];
        
        /*if previous cell is not contained in visible cell */
        for(NSIndexPath *_visPath in tableView.indexPathsForVisibleRows)
        {
            
            if ([_visPath isEqual:prevCellindexPath])
            {
                NSLog(@"Video Playing is playing visible path");
                visiblePathFound=YES;
                
            }
            
        }
    }
    
    if (previousCell && !visiblePathFound)
    {
        NSLog(@"Video Playing is stopped");
        
        [previousCell.flashbaqPlayer._guiplayerView clean];
        
        [previousCell.flashbaqPlayer._guiplayerView stop];
    }
    

    cell.tag=indexPath.row;
    
    NSDictionary *dict=[_dataArray objectAtIndex:indexPath.row];
    
    [cell configureEmblmCellForData:dict];
    
    UITapGestureRecognizer *_tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(LikesCountTapoccurred:)];
    _tap.numberOfTapsRequired=1;
    [cell.lbl_likesCount addGestureRecognizer:_tap];
    cell.lbl_likesCount.tag=indexPath.row;
    
    UITapGestureRecognizer *_commnetstap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(CommentsviewTapoccurred:)];
    _commnetstap.numberOfTapsRequired=1;
    [cell.lbl_commentscount addGestureRecognizer:_commnetstap];
    cell.lbl_commentscount.tag=indexPath.row;

    UITapGestureRecognizer *_followViewtap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(followViewTapOccured:)];
    _followViewtap.numberOfTapsRequired=1;
    [cell.followView addGestureRecognizer:_followViewtap];
    cell.followView.tag=indexPath.row;

    UITapGestureRecognizer *_commnetsimagetap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(CommentsviewTapoccurred:)];
    _commnetsimagetap.numberOfTapsRequired=1;
    [cell.img_comment addGestureRecognizer:_commnetsimagetap];
    cell.img_comment.tag=indexPath.row;
    
    UITapGestureRecognizer *_likepost=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(LikeviewTapoccurred:)];
    _likepost.numberOfTapsRequired=1;
    [cell.img_like addGestureRecognizer:_likepost];
    cell.img_like.tag=indexPath.row;
    
    
    UITapGestureRecognizer *_thmbnailtap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(flashbaqvideoplayerTapped:)];
    _thmbnailtap.numberOfTapsRequired=1;
    cell.flashbaqPlayer.tag=indexPath.row;
    cell.flashbaqPlayer.listviewarray=_dataArray;
    [cell.flashbaqPlayer addGestureRecognizer:_thmbnailtap];

    
    /*Add tap gesture for ProfileImageView */
    
    UITapGestureRecognizer *imagetap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scannedByuserTapped:)];
    imagetap.numberOfTapsRequired=1;
    [cell._profileImage addGestureRecognizer:imagetap];
    cell._profileImage.tag=indexPath.row;
    
    
    UITapGestureRecognizer *labeltap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(scannedByuserTapped:)];
    labeltap.numberOfTapsRequired=1;
    [cell.lbl_userName addGestureRecognizer:labeltap];
    cell.lbl_userName.tag=indexPath.row;
    
    UITapGestureRecognizer *createdusertap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(createdByuserTapped:)];
    createdusertap.numberOfTapsRequired=1;
    [cell.lbl_createdBy addGestureRecognizer:createdusertap];
    cell.lbl_createdBy.tag=indexPath.row;

    cell.btn_delete.tag=indexPath.row;
    [cell.btn_delete addTarget:self action:@selector(deletePost:) forControlEvents:UIControlEventTouchUpInside];
    
    
    if ([cell userLikedPost])
    {
        [likedIndexes addObject:indexPath];
    }
    
    return cell;
}

#pragma UITableViewDelegate MEthods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSIndexPath *selectedIndexPath = [__tableView indexPathForRowAtPoint:scrollView.contentOffset];
//    NSLog(@"%ld",(long)selectedIndexPath.row);
    
    if (selectedIndexPath.row == ([_dataArray count]-1))
    {
        isfollowRequest=NO;
        
        NSLog(@"Equal");
        //Send request for Next Page
        
        if (!isendOfPage)
        {
            isendOfPage=YES;

            currentPage++;
            
            if (selectedBtnIndex == 0)
            {
                /* Retrieve all of the scans that have occured for a specific Emblm. Valid emblm-token required in headers to authenticate the logged in user per this request. */
                [self sendMyscanRequestToAPI];
                
            }
            
            else
            {
                /* Get all of the Emblms created by a specific user. Valid emblm-token required in headers to authenticate the logged in user per this request.*/
                
                [self sendMyEmblmRequestToAPI];
            }

        }
        
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    __tableView.tableFooterView = spinner;
//    [spinner startAnimating];
    return __tableView.tableFooterView;
}
#pragma mark WebServiceDelegate methods
-(void)responseReceivedwithData:(NSDictionary *)data
{

    if (selectedBtnIndex == 0)
    {
        /*My Scans */
        BOOL noData=!([[data objectForKey:@"result"] count ]> 0 );
        
        if ( noData  && (currentPage==1))
        {
            UIImageView *messageImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            messageImage.image=[UIImage imageNamed:@"noscans"];
            messageImage.contentMode=UIViewContentModeScaleAspectFit;
            
            __tableView.backgroundView = messageImage;
            __tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            
        }
        
        else
        {
            __tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;

            [_nodataImageview setHidden:YES];

            [_dataArray addObjectsFromArray:[data objectForKey:@"result"]];
            [__tableView.tableFooterView setHidden:YES];
            
            [__tableView reloadData];
            
        }
    }
    
    else
    {
        BOOL noData=!([[data objectForKey:@"result"] count ]> 0 );

        /*My emblms */
        if ( noData && (currentPage==1))
        {
            UIImageView *messageImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
            messageImage.image=[UIImage imageNamed:@"noflashbaq"];
            messageImage.contentMode=UIViewContentModeScaleAspectFit;
            
            __tableView.backgroundView = messageImage;
            __tableView.separatorStyle = UITableViewCellSeparatorStyleNone;

        }
        
        else
        {

            [_dataArray addObjectsFromArray:[data objectForKey:@"result"]];
            [__tableView.tableFooterView setHidden:YES];
            
            [__tableView reloadData];

        }
    }
    
    if (isDeleteRequest)
    {
        __tableView.backgroundView=nil;
        
        if ([[data objectForKey:@"message"] isEqualToString:@"Success!"])
        {
            isDeleteRequest=NO;
            [_dataArray removeObjectAtIndex:deleteIndex];
            [__tableView reloadData];

        }
    }
    
    if (isLikeRequest)
    {

        if ([[data objectForKey:@"message"] isEqualToString:@"Success!"])
        {
            isLikeRequest=NO;
            
            NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:likeBtnIndex inSection:0];

            if ([likedIndexes containsObject:indexPath1])
            {
                /*if Already Liked, remove the index */
                NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithDictionary:[_dataArray objectAtIndex:likeBtnIndex]];
                
                NSInteger likecount=0;
                
                if ([dict objectForKey:@"emblm"] != nil)
                {
                    likecount=[[[dict objectForKey:@"emblm"]objectForKey:@"like_count"] integerValue];
                    likecount--;
                    
                    NSMutableDictionary *emblmDict=[[NSMutableDictionary alloc]initWithDictionary:[dict objectForKey:@"emblm"]];
                    [emblmDict setObject:[NSNumber numberWithInt:likecount] forKey:@"like_count"];
                    [emblmDict setObject:@"0" forKey:@"user_liked"];

                    [dict setObject:emblmDict forKey:@"emblm"];

                }
                
                else
                {
                    likecount=[[dict objectForKey:@"like_count"] integerValue];
                    likecount--;
                    [dict setObject:@"0" forKey:@"user_liked"];
                    [dict setObject:[NSNumber numberWithInteger:likecount] forKey:@"like_count"];

                }
                
                [_dataArray removeObjectAtIndex:likeBtnIndex];/*Update the array */
                [_dataArray insertObject:dict atIndex:likeBtnIndex];
                
                // Add them in an index path array
                NSArray* indexArray = [NSArray arrayWithObjects:indexPath1, nil];
                // Launch reload for the two index path
                [__tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
                [likedIndexes removeObject:indexPath1];

                
            }
            else
            {
                NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithDictionary:[_dataArray objectAtIndex:likeBtnIndex]];
                

                NSInteger likecount=0;
                
                
                if ([dict objectForKey:@"emblm"] != nil)
                {
                    likecount=[[[dict objectForKey:@"emblm"]objectForKey:@"like_count"] integerValue];
                    likecount++;
                    
                    NSMutableDictionary *emblmDict=[[NSMutableDictionary alloc]initWithDictionary:[dict objectForKey:@"emblm"]];
                    [emblmDict setObject:[NSNumber numberWithInt:likecount] forKey:@"like_count"];
                    [emblmDict setObject:@"1" forKey:@"user_liked"];
                    
                    [dict setObject:emblmDict forKey:@"emblm"];
                }
                
                else
                {
                    likecount=[[dict objectForKey:@"like_count"] integerValue];
                    likecount++;
                    
                    [dict setObject:[NSNumber numberWithInteger:likecount] forKey:@"like_count"];
                    [dict setObject:@"1" forKey:@"user_liked"];

                    
                }
                
                
                [_dataArray removeObjectAtIndex:likeBtnIndex];/*Update the array */
                [_dataArray insertObject:dict atIndex:likeBtnIndex];
                
                // Add them in an index path array
                NSArray* indexArray = [NSArray arrayWithObjects:indexPath1, nil];
                // Launch reload for the two index path
                [__tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
                [likedIndexes addObject:indexPath1];

            }
           
        }

    }
    
    if (isfollowRequest)
    {
//        NSString *alrtmessage=[NSString stringWithFormat:@"Following %@",followerName];
        isfollowRequest=NO;
        isunfollowRequest=NO;
        [self updateis_followingInDataArray:YES];
        
    }
    
    else if (isunfollowRequest)
    {
        isunfollowRequest=NO;
        isfollowRequest=NO;
        [self updateis_followingInDataArray:NO];
        
    }

    
//    _dataArray=[data objectForKey:@"result"];
       [spinner stopAnimating];
    
    if (isendOfPage)
    {
        isendOfPage=NO;
    }
    
}

-(void)connectionFailed
{
    [VSCore showConnectionFailedAlert];
    [spinner stopAnimating];
}

#pragma mark UIAlertViewDelegate Methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex;
{
    if (buttonIndex== 0)
    {
        isDeleteRequest=YES;
        
        WebService *_webservice=[[WebService alloc]init];
        _webservice.webDelegate=self;
        
        deleteIndex=delteButton.tag;
        NSString *postID=nil;
        
        if ([[_dataArray objectAtIndex:delteButton.tag] objectForKey:@"emblm"] != nil)
        {
            postID=[[[_dataArray objectAtIndex:delteButton.tag]objectForKey:@"emblm"] objectForKey:@"id"];
//            postID=[[_dataArray objectAtIndex:delteButton.tag] objectForKey:@"scan"];
        }
        
        else
        {
            postID=[[_dataArray objectAtIndex:delteButton.tag]objectForKey:@"id"];
        }
        
        NSString *url=[NSString stringWithFormat:DeletePost , postID];//PostID
        [_webservice sendDELETErequestToservertoURI:url];
    }
    
    else
    {
        [alertView dismissWithClickedButtonIndex:1 animated:YES];
        
    }
    
}

#pragma PostDelegate methods
-(void)donotReloadTableviewDatawith:(NSMutableDictionary *)resultData
{
    
    NSIndexPath* indexPath1 = [NSIndexPath indexPathForRow:selectedPostIndex inSection:0];
    
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithDictionary:[_dataArray objectAtIndex:selectedPostIndex]];
    
    if ([dict objectForKey:@"emblm"] != nil)
    {
        [dict setObject:resultData forKey:@"emblm"];
    }
    
    else
    {
        
        dict=[NSMutableDictionary dictionaryWithDictionary:resultData];
    }
    
    [_dataArray removeObjectAtIndex:selectedPostIndex];/*Update the array */
    [_dataArray insertObject:dict atIndex:selectedPostIndex];
    
    
    // Add them in an index path array
    NSArray* indexArray = [NSArray arrayWithObjects:indexPath1, nil];
    // Launch reload for the two index path
    [__tableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
    
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
