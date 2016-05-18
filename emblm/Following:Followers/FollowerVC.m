//
//  FollowerVC.m
//  emblm
//
//  Created by Kavya Valavala on 2/16/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "FollowerVC.h"
#import "VSCore.h"
#import "WebService.h"
#import "FollowersCustomCell.h"
#import "ProfilePageVC.h"

@interface FollowerVC ()<WebServiceDelegate>
{
    NSMutableArray *tableviewDataArray;
    UIActivityIndicatorView *_activityIndicator;
    BOOL isfollowBtnClicked;
    UIButton *btn_follow;
    UIButton *btn_clickedView;
    NSMutableArray *UnfollowerIndexes;
    UIActivityIndicatorView *spinner;
    BOOL isfollowRequest;
    BOOL isunFollowRequest;
   

}
@end

@implementation FollowerVC
@synthesize isCurrentUserProfile, userID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UnfollowerIndexes=[[NSMutableArray alloc]init];
    tableviewDataArray=[[NSMutableArray alloc]init];
//    [self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"headerbg.png"]
//                   forBarMetrics:UIBarMetricsDefault];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    self.navigationController.navigationBar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];

    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    self.view.backgroundColor=[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]];
    
    self.navigationController.topViewController.title=@"Followers";

    UIButton *bckbtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    bckbtn.frame = CGRectMake(0,0,44,44);
    [bckbtn setBackgroundImage:[UIImage imageNamed:@"navback.png"] forState:UIControlStateNormal];
    [bckbtn addTarget:self action:@selector(backbtn_clicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationController.topViewController.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]
                           
                                                                                  initWithCustomView:bckbtn];
    
    __tableview.allowsSelection = NO;

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    __tableview.contentInset = UIEdgeInsetsZero;
    [_nofollowersImage setHidden:YES];
    [UnfollowerIndexes removeAllObjects];
    isfollowRequest=NO;

    isfollowBtnClicked=NO;
    
    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;
    
//    NSString *url=nil;
//    
//    if (isCurrentUserProfile)
//    {
//
//    }
//    else
//    {
//        url=[NSString stringWithFormat:Followers,userID];
//
//    }
   NSString *url=[NSString stringWithFormat:Followers,userID];

    [_webservice sendGETrequestToservertoURI:url];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [spinner startAnimating];


}

-(void)backbtn_clicked
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)imageviewTapoccurred:(UITapGestureRecognizer *)sender
{
    UIImageView *selectedimgView = (UIImageView*)sender.view;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    if ([__followDelegate respondsToSelector:@selector(setFollowerDidDismisswithData:)])
    {
        NSDictionary *userdict=[tableviewDataArray objectAtIndex:selectedimgView.tag];
        [__followDelegate setFollowerDidDismisswithData:userdict];
    }
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
        [dict setObject:@"1" forKey:@"is_following"];
        
        [tableviewDataArray removeObjectAtIndex:unfollowIndexpath.row];/*Update the array */
        [tableviewDataArray insertObject:dict atIndex:unfollowIndexpath.row];
        
        /*send Data to the server */
        NSArray *keys = [NSArray arrayWithObjects:@"user", @"follower", nil];
        NSArray *objects=[NSArray arrayWithObjects:[VSCore getUserID], [dict objectForKey:@"id"], nil];
        
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        
        WebService *_webservice=[[WebService alloc]init];
        [_webservice setWebDelegate:self];
        [_webservice SendJSONDataToServer:dataDict toURI:NewFollower forRequestType:POST];
        
        [UnfollowerIndexes removeObject:unfollowIndexpath];
        
    }
    
    else
    {
        isunFollowRequest=YES;
        //send Unfollow request
        [UnfollowerIndexes addObject:unfollowIndexpath];
        
        NSMutableDictionary *dict=[[NSMutableDictionary alloc]initWithDictionary:[tableviewDataArray objectAtIndex:unfollowIndexpath.row]];
        [dict setObject:@"0" forKey:@"is_following"];
        
        
        [tableviewDataArray removeObjectAtIndex:unfollowIndexpath.row];/*Update the array */
        [tableviewDataArray insertObject:dict atIndex:unfollowIndexpath.row];

        WebService *_webservice=[[WebService alloc]init];
        [_webservice setWebDelegate:self];
        
        NSString *url=[NSString stringWithFormat:Unfollow,[dict objectForKey:@"id"]];
        
        [_webservice SendJSONDataToServer:0 toURI:url forRequestType:POST];
        
        
    }
    

}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    
    if ([[dict objectForKey:@"is_following"] isEqualToString:@"0"])
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
    cell.lbl_name.text=[dict objectForKey:@"username"];
    
    
    if ([[dict objectForKey:@"user_image"] length] >0)
    {
        NSURL *url = [NSURL URLWithString:[dict objectForKey:@"user_image"]]; //0 Index will be the Default Profile Picture
        
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
    
    if ([data objectForKey:@"result"] != nil)
    {
        if (!([[data objectForKey:@"result"] count ]> 0 ))
        {
            [_nofollowersImage setHidden:NO];
            [self.view bringSubviewToFront:_nofollowersImage];
            
        }
        
        else
        {
            [_nofollowersImage setHidden:YES];
            [tableviewDataArray addObjectsFromArray:[data objectForKey:@"result"]];
            [__tableview reloadData];


        }

    }
    
    if(isfollowRequest)
    {
        [_nofollowersImage setHidden:YES];

        isfollowRequest=NO;
        [btn_clickedView setTitle:@"Following" forState:UIControlStateNormal];
        [btn_clickedView setBackgroundColor:[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]]];
    }
    
    else if (isunFollowRequest)
    {
        [_nofollowersImage setHidden:YES];

        isunFollowRequest=NO;
        [btn_clickedView setTitle:@"Follow" forState:UIControlStateNormal];
        [btn_clickedView setBackgroundColor:[VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]]];
        
    }
  
  /*  else
    {
        [_nofollowersImage setHidden:YES];

        [tableviewDataArray addObjectsFromArray:[data objectForKey:@"result"]];
        [__tableview reloadData];
    } */

    
//    if ([data objectForKey:@"result"] > 0)
//    {
//          }
//    
//    else
//    {
//        
//    }
}

-(void)connectionFailed
{
    [spinner stopAnimating];
    [_activityIndicator stopAnimating];
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
