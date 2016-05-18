//
//  ProfilePageVC.m
//  emblm
//
//  Created by Kavya Valavala on 1/6/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "ProfilePageVC.h"
#import "VSCore.h"
#import "WebService.h"
#import "profileHeaderview.h"
#import "PostDetailsVC.h"
#import "EmblmCell.h"
#import "LikesView.h"
#import "ProgressHUD.h"
#import "ApplicationSettings.h"
#import "GIBadgeView.h"
#import "NotificationTableVC.h"

@interface ProfilePageVC ()<WebServiceDelegate, UITableViewDataSource , UITableViewDelegate , PostDetailsViewDelegate , LikesViewDelegate>
{
    profileHeaderview* _profileheaderview ;
    BOOL iscurrentuserprofile;
    NSString *currentuserID;
    NSMutableDictionary *userprofileDict;
    BOOL isformOpen;
    UIActivityIndicatorView *spinner;
    int currentPage;
    BOOL isendOfPage;
    BOOL isDeleteRequest;
    BOOL isLikeRequest;
    NSInteger deleteIndex;
    NSInteger likeBtnIndex;
    NSMutableArray *likedIndexes;
    NSMutableArray *_dataArray;
    int selectedButtonIndex;
    BOOL followbtn_clicked;
    BOOL isfollowRequest;
    BOOL videoViewgotTapped;
    EmblmCell *previousCell;
    NSInteger followbtnIndex;
    NSInteger isunfollowRequest;
    NSString *followerName;
    NSInteger selectedPostIndex;
    BOOL      donotReload;
    GIBadgeView *badgeView;

}
-(IBAction)followingbtn_clicked:(id)sender;
-(IBAction)followersbtn_Clicked:(id)sender;
-(IBAction)plusBtn_presses:(id)sender;

@end

@implementation ProfilePageVC

- (void)viewDidLoad
{
    [super viewDidLoad];
    
//    [[ApplicationSettings getInstance] setUserId:[VSCore getUserID]];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    [self createbadgeview];
    currentPage=1;
    
    _dataArray=[[NSMutableArray alloc]init];

    PostDetailsVC *pdvc=[[PostDetailsVC alloc]init];
    [pdvc setPostDelegate:self];
    
    iscurrentuserprofile=YES;
    
    self.navigationController.navigationBar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];

    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    _profileheaderview  = [[[NSBundle mainBundle] loadNibNamed:@"profileHeaderview" owner:self options:nil] objectAtIndex:0];
    
    _mainTableView.allowsSelection=NO;
    
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
    vc.isProfilePage=YES;
    
    [self.navigationController pushViewController:vc animated:YES];
    
}

-(void)viewWillAppear:(BOOL)animated
{
    if (!donotReload)
    {
        _profileheaderview.userimageview.image=nil;
        selectedButtonIndex=1;
        followbtn_clicked=NO;
        
        [_mainTableView setContentOffset:CGPointMake(0, 0) animated:YES];
        
        [ProgressHUD show:@"Fetching Details.."];
        
        isformOpen=YES;
        
        currentPage=1;
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
        
        WebService *_webservice=[[WebService alloc]init];
        _webservice.webDelegate=self;
        
        NSString *url=[NSString stringWithFormat:ProfileSetup,[[ApplicationSettings getInstance] userId]];
        
        [_webservice sendGETrequestToservertoURI:url];
    }
   
}

-(void)viewDidDisappear:(BOOL)animated
{
    donotReload=NO;
    
    if (previousCell)
    {
        [previousCell.flashbaqPlayer._guiplayerView clean];
        
        [previousCell.flashbaqPlayer._guiplayerView stop];
        
    }
}

-(IBAction)followingbtn_clicked:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FollowingVC *vc = (FollowingVC *)[storyboard instantiateViewControllerWithIdentifier:@"Following"];
    vc.userID=[[ApplicationSettings getInstance] userId];
    [vc set_followingDelegate:self];
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)followersbtn_Clicked:(id)sender
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    FollowerVC *vc = (FollowerVC *)[storyboard instantiateViewControllerWithIdentifier:@"Followers"];
    vc.userID=[[ApplicationSettings getInstance] userId];
    [vc set_followDelegate:self];
    [self.navigationController pushViewController:vc animated:YES];
}

-(IBAction)plusBtn_presses:(id)sender
{
    /*follow user */
    followbtn_clicked=YES;
    
    NSArray *keys = [NSArray arrayWithObjects:@"user", @"follower", nil];
    NSArray *objects=[NSArray arrayWithObjects:[VSCore getUserID], [userprofileDict objectForKey:@"id"], nil];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    if (![[userprofileDict objectForKey:@"is_following"] boolValue])/*if not following, follow */
    {
        WebService *_webservice=[[WebService alloc]init];
        [_webservice setWebDelegate:self];
        
        [_webservice SendJSONDataToServer:dataDict toURI:NewFollower forRequestType:POST];
        
    }
    
    else
    {
        NSString *message=[NSString stringWithFormat:@"Following %@",[userprofileDict objectForKey:@"username"]];
        
        [ProgressHUD showSuccess:message];
    }
}

-(IBAction)MyScans_cliked:(UIButton*)sender
{
    if (previousCell)
    {
        [previousCell.flashbaqPlayer._guiplayerView clean];
        
        [previousCell.flashbaqPlayer._guiplayerView stop];
        
    }
    
    sender.titleLabel.font = [UIFont fontWithName:TITLE_FONT size:16.0];
    selectedButtonIndex=1;
    currentPage=1;
    
    [_dataArray removeAllObjects];
    [_mainTableView reloadData];

    [self sendMyscanRequestToAPI];
}

-(IBAction)MyEmblms_Clicked:(UIButton *)sender
{
    if (previousCell)
    {
        [previousCell.flashbaqPlayer._guiplayerView clean];
        
        [previousCell.flashbaqPlayer._guiplayerView stop];
        
    }
    
    sender.titleLabel.font = [UIFont fontWithName:TITLE_FONT size:16.0];

    currentPage=1;

    selectedButtonIndex=2;

    [_dataArray removeAllObjects];
    [_mainTableView reloadData];

    [self sendMyEmblmRequestToAPI];
}

-(void)sendMyscanRequestToAPI
{
    [spinner startAnimating];

    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;
    NSString *url=[NSString stringWithFormat:MyScans,[[ApplicationSettings getInstance] userId],currentPage];
    [_webservice sendGETrequestToservertoURI:url];

}

-(void)sendMyEmblmRequestToAPI
{
//    currentPage=1;
    
    [spinner startAnimating];

    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;//
    NSString *url=[NSString stringWithFormat:MyEmblms,[[ApplicationSettings getInstance] userId],currentPage];
    [_webservice sendGETrequestToservertoURI:url];
}

-(void)checkforUserID
{
    ApplicationSettings *aps=[ApplicationSettings getInstance];

    if ([currentuserID isEqualToString:[VSCore getUserID]])
    {
        [aps setUserId:currentuserID];
        [aps setIscurrentuserprofile:YES];
    }
    
    else
    {
        [aps setUserId:currentuserID];
        [aps setIscurrentuserprofile:NO];
    }
}
-(void)LikesCountTapoccurred:(UITapGestureRecognizer *)recognizer
{
    UILabel *selectedcmntsView = (UILabel*)recognizer.view;
        
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
    
//      NSLog(@"%@", NSStringFromCGPoint(point));
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
    vc.isProfileView=YES;
    if ([[_dataArray objectAtIndex:selectedcmntsView.tag] objectForKey:@"emblm"] != nil)
    {
        vc.resultDict=[NSMutableDictionary dictionaryWithDictionary:[[_dataArray objectAtIndex:selectedcmntsView.tag] objectForKey:@"emblm"]];

//        vc.resultDict=[[_dataArray objectAtIndex:selectedcmntsView.tag] objectForKey:@"emblm"];
        
    }
    
    else
    {
        vc.resultDict=[NSMutableDictionary dictionaryWithDictionary:[_dataArray objectAtIndex:selectedcmntsView.tag]];

//        vc.resultDict=[_dataArray objectAtIndex:selectedcmntsView.tag];
        
    }
    
    
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
        [selectedView setImage:[UIImage imageNamed:@"heart_red"]];
    }
    
    
}

-(NSString *) returnMonthAndYear:(NSTimeInterval ) miliseconds
{
    NSDate *dateGot = [NSDate dateWithTimeIntervalSince1970:miliseconds];
    NSDateComponents *components = [[NSCalendar currentCalendar] components:NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit fromDate:dateGot];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    NSString *monthName = [[df monthSymbols] objectAtIndex:([components month]-1)];
    return [NSString stringWithFormat:@"%@ %ld",monthName, (long)[components year]];;
    
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


    [self viewWillAppear:YES];
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
        
        }
    [self viewWillAppear:YES];

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)bindatatoHeaderview:(NSDictionary *)data
{
    [_profileheaderview._indicatorView startAnimating];
    
    if ([[data objectForKey:@"user_image"] length ]> 0)
    {
        NSURL *url = [NSURL URLWithString:[data objectForKey:@"user_image"]]; //0 Index will be the Default Profile Picture
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               _profileheaderview.userimageview.image= image;
                               [_profileheaderview._indicatorView stopAnimating];
                           });
        });

    }
    
    else
    {
        _profileheaderview.userimageview.image=[UIImage imageNamed:@"profile pics.png"];
        [_profileheaderview._indicatorView stopAnimating];

    }
    
    _profileheaderview.lbl_username.text=[data objectForKey:@"username"];
    _profileheaderview.lbl_username.textColor=[UIColor whiteColor];
    _profileheaderview.lbl_username.textAlignment=NSTextAlignmentCenter;
    
   int  milliseconds=[[data objectForKey:@"created"] intValue];

    NSString *time=[self returnMonthAndYear:milliseconds];
    _profileheaderview.lbl_createdDate.text=[NSString stringWithFormat:@"Member Since %@",time];
    
    NSString *followerTitle=[NSString stringWithFormat:@"%@ Followers",[data objectForKey:@"follower_count"]];
    [_profileheaderview.btn_follower setTitle:followerTitle forState:UIControlStateNormal];
    
    NSString *followingTitle=[NSString stringWithFormat:@"%@ Following",[data objectForKey:@"following_count"]];
    [_profileheaderview.btn_following setTitle:followingTitle forState:UIControlStateNormal];


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
    
}


-(void)followViewTapOccured:(UITapGestureRecognizer *)sender
{
    UIImageView *selectedfollowView = (UIImageView*)sender.view;
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
        /*follow him */
        
        isfollowRequest=YES;
        
        [_webservice SendJSONDataToServer:dataDict toURI:NewFollower forRequestType:POST];
    }
    else if(is_following && !([[VSCore getUserID] isEqualToString:followerid]))
    {
        /*unfollow him */
        
        isunfollowRequest=YES;
        
        NSString *url=[NSString stringWithFormat:Unfollow,followerid];
        
        [_webservice SendJSONDataToServer:0 toURI:url forRequestType:POST];
        
    }
    
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
    [_mainTableView reloadRowsAtIndexPaths:updateIndexArray withRowAnimation:UITableViewRowAnimationNone];
    
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

#pragma mark UITableViewDataSource Delegate Methods


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

    [cell.btn_delete setHidden:YES];
    
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
//    followbtn_clicked=NO;
    
    NSIndexPath *selectedIndexPath = [_mainTableView indexPathForRowAtPoint:scrollView.contentOffset];
    //    NSLog(@"%ld",(long)selectedIndexPath.row);
    
    if (selectedIndexPath != nil)
    {
        if (selectedIndexPath.row == ([_dataArray count]-1))
        {
            followbtn_clicked=NO;
            NSLog(@"Equal");
            //Send request for Next Page
            
            if (!isendOfPage)
            {
                isendOfPage=YES;
                
                
                if (selectedButtonIndex == 1)
                {
                    currentPage++;
                    
                    /* Retrieve all of the scans that have occured for a specific Emblm. Valid emblm-token required in headers to authenticate the logged in user per this request. */
                    [self sendMyscanRequestToAPI];
                    
                }
                
                else
                {
                    currentPage++;
                    
                    /* Get all of the Emblms created by a specific user. Valid emblm-token required in headers to authenticate the logged in user per this request.*/
                    
                    [self sendMyEmblmRequestToAPI];
                }
                
            }
            
        }

    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    _mainTableView.tableFooterView = spinner;
    //    [spinner startAnimating];
    return _mainTableView.tableFooterView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    _profileheaderview.frame=CGRectMake(0, 0, _mainTableView.frame.size.width, 0);

    _profileheaderview.userInteractionEnabled=YES;
    
    _mainTableView.tableHeaderView=_profileheaderview;
    
    if ([[[ApplicationSettings getInstance] userId] isEqualToString:[VSCore getUserID]])
    {
        [_profileheaderview.followImagebtn setHidden:YES];
    }
    else
        [_profileheaderview.followImagebtn setHidden:NO];

    return _mainTableView.tableHeaderView;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 336;
}

#pragma mark WebServiceDelegate methods
-(void)responseReceivedwithData:(NSDictionary *)data
{
    
    if (followbtn_clicked)
    {
        followbtn_clicked=NO;

        NSString *message=[NSString stringWithFormat:@"Started following %@",[userprofileDict objectForKey:@"username"]];
        
        [ProgressHUD showSuccess:message];
        
        [userprofileDict setObject:@"1" forKey:@"is_following"];
    }
    
    if (selectedButtonIndex == 1)
    {
       
        if (!([[data objectForKey:@"result"] count] > 0))
        {
            /*if no found data for the currentPage, decrement the pageCount */
            
            if (currentPage != 1)
            {
                currentPage--;
                
            }
        }
        
        if (isformOpen)
        {
            [_dataArray removeAllObjects];

            isformOpen=NO;
            
            [_dataArray addObjectsFromArray:[[[data objectForKey:@"result"] objectForKey:@"scans"] objectForKey:@"result"]];
//            userprofileDict=[[data objectForKey:@"result"] objectForKey:@"user"];
            userprofileDict=[[NSMutableDictionary alloc]initWithDictionary:[[data objectForKey:@"result"] objectForKey:@"user"]];
//            self.navigationController.title=[userprofileDict objectForKey:@"username"];
            
            self.navigationItem.title = [userprofileDict objectForKey:@"username"];

//            self.navigationController.tabBarController.tabBarItem.title=@"Profile";
        }
        
        else
        {
            [_dataArray addObjectsFromArray:[data objectForKey:@"result"]];

        }
        //    [_mainTableView.tableFooterView setHidden:YES];
        
        [_mainTableView reloadData];
        [self bindatatoHeaderview:userprofileDict];

    }
    
    else
    {

        if (!([[data objectForKey:@"result"] count] > 0))
        {
            /*if no found data for the currentPage, decrement the pageCount */
            
            if (currentPage != 1)
            {
                currentPage--;

            }
        }
        
        [_dataArray addObjectsFromArray:[data objectForKey:@"result"]];
        //    [_mainTableView.tableFooterView setHidden:YES];
        
        [_mainTableView reloadData];
        [self bindatatoHeaderview:userprofileDict];
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
                [_mainTableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
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
                [_mainTableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
                [likedIndexes addObject:indexPath1];
                
            }
            
        }
        
    }
    
    if (isfollowRequest)
    {
        NSString *alrtmessage=[NSString stringWithFormat:@"Following %@",followerName];
        isfollowRequest=NO;
        isunfollowRequest=NO;
        [ProgressHUD showSuccess:alrtmessage];
        [self updateis_followingInDataArray:YES];
        
    }
    
    else if (isunfollowRequest)
    {
        NSString *alrtmessage=[NSString stringWithFormat:@"Unfollowed %@",followerName];
        isunfollowRequest=NO;
        isfollowRequest=NO;
        [ProgressHUD showSuccess:alrtmessage];
        [self updateis_followingInDataArray:NO];
        
    }


    [spinner stopAnimating];
    
    if (isendOfPage)
    {
        isendOfPage=NO;
    }

    [ProgressHUD dismiss];

}

-(void)connectionFailed
{
    [VSCore showConnectionFailedAlert];
    [ProgressHUD dismiss];
}

#pragma mark FollowerDelegate Methods
-(void)setFollowerDidDismisswithData:(NSDictionary *)userdata
{
    NSLog(@"setFollowerDidDismisswithData");
    iscurrentuserprofile=NO;
    [[ApplicationSettings getInstance] setUserId:[userdata objectForKey:@"id"]];
    userprofileDict=userdata;
}

#pragma mark FollowingView Delegate Methods
-(void)setFollowingFormDidDismisswithData:(NSDictionary *)userdata
{
    NSLog(@"setFollowingFormDidDismisswithData");
    iscurrentuserprofile=NO;
    [[ApplicationSettings getInstance] setUserId:[userdata objectForKey:@"id"]];
    userprofileDict=userdata;
}

#pragma mark PostDetailViewDelegate Methods
#pragma PostDelegate methods
-(void)donotReloadTableviewDatawith:(NSMutableDictionary *)resultData
{
    donotReload=YES;
    
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
    [_mainTableView reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
    
}

#pragma mark LikesViewDelegate methods

-(void)donotReloadTableviewfromLikesView
{
    donotReload=YES;
}

-(void)setProfileViewwithData:(NSDictionary *)userdata
{
    NSLog(@"setProfileViewwithData");
    iscurrentuserprofile=NO;
    [[ApplicationSettings getInstance] setUserId:[[userdata objectForKey:@"user"]objectForKey:@"id"]];
    
    userprofileDict=[userdata objectForKey:@"user"];
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
