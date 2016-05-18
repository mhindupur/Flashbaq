//
//  LikesView.m
//  emblm
//
//  Created by Kavya Valavala on 2/26/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "LikesView.h"
#import "VSCore.h"
#import "FollowersCustomCell.h"
#import "WebService.h"
#import "ApplicationSettings.h"

@interface LikesView ()<WebServiceDelegate>
{
    NSMutableArray *tableviewDataArray;
    UIActivityIndicatorView *_activityIndicator;
    UIButton *btn_like;
    BOOL isLikeBtnClicked;
    UIButton *btn_clickedView;
    NSMutableArray *UnfollowerIndexes;
    UIActivityIndicatorView *spinner;
    BOOL isfollowRequest;
    BOOL isunFollowRequest;

}
@end

@implementation LikesView
@synthesize postID;

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    
    UnfollowerIndexes=[[NSMutableArray alloc]init];
    [UnfollowerIndexes removeAllObjects];

    tableviewDataArray=[[NSMutableArray alloc]init];
    isfollowRequest=NO;
    isunFollowRequest=NO;

//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"headerbg.png"]
//                                                  forBarMetrics:UIBarMetricsDefault];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    self.navigationController.navigationBar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];

    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    self.view.backgroundColor=[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]];
    
    self.navigationController.topViewController.title=@"Likes";
    
    UIButton *bckbtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    bckbtn.frame = CGRectMake(0,0,44,44);
    [bckbtn setBackgroundImage:[UIImage imageNamed:@"navback.png"] forState:UIControlStateNormal];
    [bckbtn addTarget:self action:@selector(backbtn_clicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationController.topViewController.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]
                                                                                  
                                                                                  initWithCustomView:bckbtn];
    
    __tableview.allowsSelection = NO;
    
    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;
    
    NSString *url=[NSString stringWithFormat:Likes,postID];//PostID
    [_webservice sendGETrequestToservertoURI:url];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [spinner startAnimating];

}

-(void)backbtn_clicked
{
    if ([_likesDelegate respondsToSelector:@selector(donotReloadTableviewfromLikesView)])
    {
        [self.navigationController popViewControllerAnimated:YES];
        [_likesDelegate donotReloadTableviewfromLikesView];
    }
    
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
 
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)sendFollowRequest:(UIButton *)sender
{
    NSIndexPath* unfollowIndexpath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    
    btn_clickedView=sender;
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.alpha = 1.0;
    _activityIndicator.center = CGPointMake(sender.frame.size.width-13,13);
    _activityIndicator.hidesWhenStopped = YES;
    [sender addSubview:_activityIndicator];
    
    [_activityIndicator startAnimating];
    //    [UnfollowerIndexes addObject:unfollowIndexpath];
    
    if ([UnfollowerIndexes containsObject:unfollowIndexpath])
    {
        isfollowRequest=YES;
        //should follow
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithDictionary:[tableviewDataArray objectAtIndex:unfollowIndexpath.row]];
        
        NSMutableDictionary *userdict=[[NSMutableDictionary alloc]initWithDictionary:[dict objectForKey:@"user"]];
        [userdict setObject:@"1" forKey:@"is_following"];
        
        [tableviewDataArray removeObjectAtIndex:unfollowIndexpath.row];/*Update the array */
        [tableviewDataArray insertObject:dict atIndex:unfollowIndexpath.row];
        
        /*send Data to the server */
        NSArray *keys = [NSArray arrayWithObjects:@"user", @"follower", nil];
        NSArray *objects=[NSArray arrayWithObjects:[VSCore getUserID], [userdict objectForKey:@"id"], nil];
        
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        
        WebService *_webservice=[[WebService alloc]init];
        [_webservice setWebDelegate:self];
        [_webservice SendJSONDataToServer:dataDict toURI:NewFollower forRequestType:POST];
        
        [UnfollowerIndexes removeObject:unfollowIndexpath];
        
    }
    
    else
    {
        isunFollowRequest=YES;
        //send Unfollwer request
        [UnfollowerIndexes addObject:unfollowIndexpath];
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithDictionary:[tableviewDataArray objectAtIndex:unfollowIndexpath.row]];
        
        NSMutableDictionary *userdict=[[NSMutableDictionary alloc]initWithDictionary:[dict objectForKey:@"user"]];
        [userdict setObject:@"0" forKey:@"is_following"];
        
        
        [tableviewDataArray removeObjectAtIndex:unfollowIndexpath.row];/*Update the array */
        [tableviewDataArray insertObject:dict atIndex:unfollowIndexpath.row];
        
        WebService *_webservice=[[WebService alloc]init];
        [_webservice setWebDelegate:self];
        
        NSString *url=[NSString stringWithFormat:Unfollow,[userdict objectForKey:@"id"]];
        
        [_webservice SendJSONDataToServer:0 toURI:url forRequestType:POST];
        
        
    }
    
    
}

-(void)imageviewTapoccurred:(UITapGestureRecognizer *)sender
{
    NSDictionary *dict=[tableviewDataArray objectAtIndex:sender.view.tag];

    [[ApplicationSettings getInstance] setUserId:[[dict objectForKey:@"user"] objectForKey:@"id"]];
    
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    UIViewController *vc = (UIViewController *)[storyboard instantiateViewControllerWithIdentifier:@"ProfilePage"];

    [self.navigationController.tabBarController setSelectedIndex:3];
    
    
}

#pragma mark UITableViewDataSource Delegate Methods


- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableviewDataArray count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 55;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"FollowerCell";
    
    FollowersCustomCell *cell = (FollowersCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentity];
    
    if(cell == nil)
    {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"FollowersCustomCell" owner:self options:nil];
        // Grab a pointer to the first object (presumably the custom cell, as that's all the XIB should contain).
        cell = [topLevelObjects objectAtIndex:0];
    }
    
    UITapGestureRecognizer *_tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageviewTapoccurred:)];
    _tap.numberOfTapsRequired=1;
    [cell.imgview addGestureRecognizer:_tap];
    cell.imgview.tag=indexPath.row;
    
    UITapGestureRecognizer *_usernametap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(imageviewTapoccurred:)];
    _usernametap.numberOfTapsRequired=1;
    [cell.lbl_name addGestureRecognizer:_usernametap];
    cell.lbl_name.tag=indexPath.row;
    
    NSDictionary *dict=[tableviewDataArray objectAtIndex:indexPath.row];
    
    if ([[[dict objectForKey:@"user"] objectForKey:@"is_following"] isEqualToString:@"0"])
    {
        /*send UnFollow Request */
        
        [cell.btn_follow setTitle:@"Follow" forState:UIControlStateNormal];
        [cell.btn_follow setBackgroundColor:[VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]]];
        [UnfollowerIndexes addObject:indexPath];
        
    }
    
    else
    {
        /*send UnFollow Request */
        
        [cell.btn_follow setTitle:@"Following" forState:UIControlStateNormal];
        [cell.btn_follow setBackgroundColor:[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]]];
        
    }

    
    [cell.btn_follow addTarget:self action:@selector(sendFollowRequest:) forControlEvents:UIControlEventTouchUpInside];
    [cell.btn_follow setTag:indexPath.row];
    
    cell.lbl_name.textColor=[VSCore getColor:@"666666" withDefault:[UIColor blackColor]];
    cell.lbl_name.font=[UIFont fontWithName:OTHER_FONT size:16];
    cell.lbl_name.text=[[dict objectForKey:@"user"] objectForKey:@"username"];
    
    
    if ([[[dict objectForKey:@"user"] objectForKey:@"user_image"] length] >0)
    {
        NSURL *url = [NSURL URLWithString:[[dict objectForKey:@"user"] objectForKey:@"user_image"]]; //0 Index will be the Default Profile Picture
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               cell.imgview.image= image;
                           });
        });
        
    }
    
    else
    {
        cell.imgview.image=[UIImage imageNamed:@"profilePic_small.jpg"];
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
    __tableview.tableFooterView = spinner;
    //    [spinner startAnimating];
    return __tableview.tableFooterView;
}

#pragma mark WebServiceDelegate methods
-(void)responseReceivedwithData:(NSDictionary *)data
{
    [_activityIndicator stopAnimating];
    [spinner stopAnimating];
    
    
    if (!([[data objectForKey:@"result"] count ]> 0 ))
    {
        UIImageView *messageImage = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height)];
        messageImage.image=[UIImage imageNamed:@"nolikes_6+"];
        messageImage.contentMode=UIViewContentModeScaleAspectFit;
        
        __tableview.backgroundView = messageImage;
        __tableview.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    
    else
    {
        [tableviewDataArray addObjectsFromArray:[data objectForKey:@"result"]];
        [__tableview reloadData];

    }
    
    if(isfollowRequest)
    {
        isfollowRequest=NO;
        [btn_clickedView setTitle:@"Following" forState:UIControlStateNormal];
        [btn_clickedView setBackgroundColor:[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]]];
    }
    
    else //(isunFollowRequest)
    {
        isunFollowRequest=NO;
        [btn_clickedView setTitle:@"Follow" forState:UIControlStateNormal];
        [btn_clickedView setBackgroundColor:[VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]]];
        
    }
//    else
//    {
//        [tableviewDataArray addObjectsFromArray:[data objectForKey:@"result"]];
//        [__tableview reloadData];
//    }
    
}

-(void)connectionFailed
{
    [spinner stopAnimating];
    [VSCore showConnectionFailedAlert];
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
