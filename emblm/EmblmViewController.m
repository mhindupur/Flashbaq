//
//  EmblmViewController.m
//  emblm
//
//  Created by Kavya Valavala on 12/29/14.
//  Copyright (c) 2014 Vaayoo. All rights reserved.
//

#import "EmblmViewController.h"
#import "EmblmCell.h"
#import "WebService.h"
#import "VSCore.h"
#import "LikesView.h"
#import "PostDetailsVC.h"
#import "ApplicationSettings.h"
#import "ProgressHUD.h"
#import "FlashbaqVideoPlayer.h"
#import "GIBadgeView.h"
#import "NotificationTableVC.h"

@interface EmblmViewController ()<WebServiceDelegate , PostDetailsViewDelegate , LikesViewDelegate>
{
    NSMutableArray *_dataArray;
    UIActivityIndicatorView *spinner;
    int currentPage;
    BOOL isendOfPage;
    BOOL isDeleteRequest;
    BOOL isLikeRequest;
    BOOL isfolloweRequest;
    BOOL isunfollowRequest;
    NSInteger deleteIndex;
    NSInteger likeBtnIndex;
    NSMutableArray *likedIndexes;
    UIView *_headerview;
    NSMutableArray *loadedImagesindexPaths;
    NSString *followerName;
    BOOL videoViewgotTapped;
    EmblmCell *previousCell;
    NSInteger followbtnIndex;
    BOOL      donotReload;
    NSInteger selectedPostIndex;
    GIBadgeView *badgeView;
}
@end

@implementation EmblmViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self createbadgeview];
    
    [[ApplicationSettings getInstance]setUserId:[VSCore getUserID]];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    isendOfPage=NO;
    isDeleteRequest=NO;
    isLikeRequest=NO;
    
    _dataArray=[[NSMutableArray alloc]init];
    loadedImagesindexPaths=[[NSMutableArray alloc]init];
    
    self.navigationController.navigationBar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];

    UIImageView *imgview=[[UIImageView alloc]initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = imgview;

    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    self.view.backgroundColor=[VSCore getColor:@"ff4b4a" withDefault:[UIColor blackColor]];
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont fontWithName:OTHER_FONT size:15], NSFontAttributeName,
                                [UIColor whiteColor], NSForegroundColorAttributeName, nil];

    _emblmTableview.allowsSelection = NO;
    
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
    /*send Data to the server */

    if (!donotReload)
    {
        _emblmTableview.backgroundView=nil;
        
        NSLog(@"viewWillAppear");
        videoViewgotTapped=NO;
        
        currentPage=1;
        
        [loadedImagesindexPaths removeAllObjects];
        [_dataArray removeAllObjects];
        [_emblmTableview reloadData];
        
        spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        spinner.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
        
        [self sendUserActivityRequestToAPI];
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
    
    if (!is_following)
    {
        /*follow him */
        
        isfolloweRequest=YES;

        [_webservice SendJSONDataToServer:dataDict toURI:NewFollower forRequestType:POST];
    }
    else
    {
        /*unfollow him */
        
        isunfollowRequest=YES;
        
        NSString *url=[NSString stringWithFormat:Unfollow,followerid];
        
        [_webservice SendJSONDataToServer:0 toURI:url forRequestType:POST];
        
    }
    
}

-(void)LikesCountTapoccurred:(UITapGestureRecognizer *)recognizer
{
    UILabel *selectedcmntsView = (UILabel*)recognizer.view;
    
    CGPoint point = [recognizer locationInView:selectedcmntsView];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LikesView *vc = (LikesView *)[storyboard instantiateViewControllerWithIdentifier:@"Like"];
    vc.likesDelegate=self;
    
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
        [selectedView setImage:[UIImage imageNamed:@"redlove.png"]];
    }
    
    
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


-(void)sendUserActivityRequestToAPI
{
    [spinner startAnimating];
    
    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;//
    NSString *url=[NSString stringWithFormat:Activity,currentPage];
    [_webservice sendGETrequestToservertoURI:url];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)scannedByuserTapped:(UITapGestureRecognizer *)recognizer
{
    
    NSDictionary *dict=[_dataArray objectAtIndex:recognizer.view.tag];

    [[ApplicationSettings getInstance] setUserId:[[dict objectForKey:@"scanned_by"] objectForKey:@"id"]];
    [self.navigationController.tabBarController setSelectedIndex:3];

}

-(void)createdByuserTapped:(UITapGestureRecognizer *)recognizer
{
    
    NSDictionary *dict=[_dataArray objectAtIndex:recognizer.view.tag];
    
    [[ApplicationSettings getInstance] setUserId:[[[dict objectForKey:@"emblm"] objectForKey:@"user"] objectForKey:@"id"]];
    [self.navigationController.tabBarController setSelectedIndex:3];
    
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
        [previousCell.flashbaqPlayer._guiplayerView clean];

        [previousCell.flashbaqPlayer._guiplayerView stop];
        
        NSLog(@"FlashbaqVideoPlayer Stopped");
        
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

-(void)displayanimationview
{
   
}
-(void)updateTableViewDataandReload
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
        [_emblmTableview reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
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
        [_emblmTableview reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];
        [likedIndexes addObject:indexPath1];
        
    }
    

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
        // Grab a pointer to the first object (q the custom cell, as that's all the XIB should contain).
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
//    cell.thmbnail_img.tag=indexPath.row;
//    [cell.thmbnail_img addGestureRecognizer:_thmbnailtap];
    
    cell.btn_delete.hidden=YES;
    
    
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

//    NSDictionary  *userDict=[[dict objectForKey:@"emblm"]objectForKey:@"user"];

//    cell.lbl_createdBy.text=[userDict objectForKey:@"name"];
    
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

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    _emblmTableview.tableFooterView = spinner;
    //    [spinner startAnimating];
    return _emblmTableview.tableFooterView;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    if ([[ApplicationSettings getInstance] appLaunchedFirstTime])
    {
        [[ApplicationSettings getInstance] setAppLaunchedFirstTime:NO];
        
        _headerview =[[UIView alloc]init];
        
        UIImageView *imgview=[[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 200)];
        imgview.image=[UIImage imageNamed:@"Home_empty.png"];
        [_headerview addSubview:imgview];
        
        _headerview.backgroundColor=[UIColor clearColor];
        
        return _headerview;

    }
    
    else
    {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    if ([[ApplicationSettings getInstance] appLaunchedFirstTime])
//    {
//        return 200;
//    }
//    
//    else
      return 0;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
//    NSLog(@"%@",_emblmTableview.visibleCells);
//    NSLog(@"%@", _emblmTableview.indexPathsForVisibleRows);

//    NSLog(@"Previous Cell: %@",previousCell);
    
    
    [_headerview setHidden:YES];
    
    NSIndexPath *selectedIndexPath = [_emblmTableview indexPathForRowAtPoint:scrollView.contentOffset];
    //    NSLog(@"%ld",(long)selectedIndexPath.row);
    
    if (selectedIndexPath.row == ([_dataArray count]-1))
    {
        isfolloweRequest=NO;
        
        NSLog(@"Equal");
        //Send request for Next Page
        
        if (!isendOfPage)
        {
            isendOfPage=YES;
            
            currentPage++;
            
            [self sendUserActivityRequestToAPI];
            
        }
        
    }
    
}

#pragma mark WebViewDelegate Methods
-(void)responseReceivedwithData:(NSDictionary *)data
{
    [spinner stopAnimating];
//    _dataArray=[data objectForKey:@"result"];
    
    BOOL noData=!([[data objectForKey:@"result"] count ]> 0 );
    
    if ( noData  && (currentPage==1))
    {
        UIImageView *messageImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageImage.image=[UIImage imageNamed:@"noActivity6+"];
        messageImage.contentMode=UIViewContentModeScaleAspectFill;
        
        _emblmTableview.backgroundView = messageImage;
        _emblmTableview.separatorStyle = UITableViewCellSeparatorStyleNone;
        
    }

    else
    {
        _emblmTableview.backgroundView=nil;
        [_dataArray addObjectsFromArray:[data objectForKey:@"result"]];
        [_emblmTableview reloadData];

    }

    
    if (isLikeRequest)
    {
        if ([[data objectForKey:@"message"] isEqualToString:@"Success!"])
        {
            [self updateTableViewDataandReload];
        }
        
    }
   // NSString *path = [VSCore createandGetPlistwithFileName:@"UserStories"];
    
    //[result writeToFile:path atomically:YES];
    
    if (isfolloweRequest)
    {
        isfolloweRequest=NO;
        isunfollowRequest=NO;
        [self updateis_followingInDataArray:YES];
        
    }

    else if (isunfollowRequest)
    {
        isunfollowRequest=NO;
        isfolloweRequest=NO;
        [self updateis_followingInDataArray:NO];

    }
}

-(void)updateis_followingInDataArray:(BOOL)followRequest
{
    
   NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithDictionary:[_dataArray objectAtIndex:followbtnIndex]];
    
    
    NSString *followUserId=[[[dict objectForKey:@"emblm"] objectForKey:@"user"] objectForKey:@"id"];
    
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
        [_dataArray removeObjectAtIndex:arrayrow.row];/*Update the array*/
        
        [_dataArray insertObject:dict atIndex:arrayrow.row];
        
    }
    
        // Launch reload for the two index path
        [_emblmTableview reloadRowsAtIndexPaths:updateIndexArray withRowAnimation:UITableViewRowAnimationNone];
    
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

#pragma mark PostDelegate Methods

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
     
    
    }
    
    [_dataArray removeObjectAtIndex:selectedPostIndex];/*Update the array */
    [_dataArray insertObject:dict atIndex:selectedPostIndex];

    
    // Add them in an index path array
    NSArray* indexArray = [NSArray arrayWithObjects:indexPath1, nil];
    // Launch reload for the two index path
    [_emblmTableview reloadRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationNone];

}

#pragma mark LikesViewDelegate methods

-(void)donotReloadTableviewfromLikesView
{
    donotReload=YES;
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
