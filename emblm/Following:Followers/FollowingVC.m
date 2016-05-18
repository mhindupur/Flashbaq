//
//  FollowingVC.m
//  emblm
//
//  Created by Kavya Valavala on 2/15/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "FollowingVC.h"
#import "VSCore.h"
#import "WebService.h"
#import "FollowersCustomCell.h"

@interface FollowingVC ()<UITextFieldDelegate, WebServiceDelegate>
{
    NSMutableArray *tableviewDataArray;
    UIActivityIndicatorView *_activityIndicator;
    BOOL isSearchMode;
    BOOL isfollowRequest;
    BOOL isunFollowRequest;
    UIButton *btn_clickedView;
    NSMutableArray *UnfollowerIndexes;
    UIActivityIndicatorView *spinner;
    int pageNumber;
    BOOL isendOfPage;

}
-(IBAction)btn_searchClicked:(id)sender;
-(IBAction)backbtn_clicked:(id)sender;

@end

@implementation FollowingVC
@synthesize userID;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [_emptyResultView setHidden:YES];
    tableviewDataArray=[[NSMutableArray alloc]init];
    
    UnfollowerIndexes=[[NSMutableArray alloc]init];

    _btn_searchClick.titleLabel.text=@"Search";
    [_btn_searchClick.titleLabel setHidden:YES];
    
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;

    self.navigationController.topViewController.title=@"Following";
    UIButton *bckbtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    bckbtn.frame = CGRectMake(0,0,44,44);
    [bckbtn setBackgroundImage:[UIImage imageNamed:@"navback.png"] forState:UIControlStateNormal];
    [bckbtn addTarget:self action:@selector(backbtn_clicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationController.topViewController.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]
                                                                                  initWithCustomView:bckbtn];
    
    self.view.backgroundColor=[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]];
    
    _txt_search.backgroundColor=[UIColor whiteColor];
    CGFloat leftInset = 10.0f;
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, leftInset, self.view.bounds.size.height)];
    _txt_search.leftView = leftView;
    _txt_search .leftViewMode= UITextFieldViewModeAlways;

    _table_follwinglist.allowsSelection = NO;

    [UnfollowerIndexes removeAllObjects];

    pageNumber=1;
    isendOfPage=NO;
    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    [self fetchFollowingList];
}

-(void)fetchFollowingList
{
    isSearchMode=NO;
    isfollowRequest=NO;
    
    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;
    
    NSString *url=[NSString stringWithFormat:Following,userID,pageNumber];
    [_webservice sendGETrequestToservertoURI:url];
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [spinner startAnimating];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(IBAction)btn_searchClicked:(id)sender
{
    isSearchMode=YES;

    if ([_btn_searchClick.titleLabel.text isEqualToString:@"Search"])
    {
        _btn_searchClick.titleLabel.text=@"Close";
        [_btn_searchClick setImage:[UIImage imageNamed:@"imgCross.png"] forState:UIControlStateNormal];
        
        NSArray *keys = [NSArray arrayWithObjects:@"search", nil];
        
        NSArray *objects=[NSArray arrayWithObjects:_txt_search.text, nil];
        
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        WebService *_webservice=[[WebService alloc]init];
        _webservice.webDelegate=self;
        
        [_webservice SendJSONDataToServer:dataDict toURI:search forRequestType:POST];
        
        [spinner startAnimating];
        
    }
    else
    {
        [_emptyResultView setHidden:YES];
        [_txt_search resignFirstResponder];
        _btn_searchClick.titleLabel.text=@"Search";
        [_btn_searchClick setImage:[UIImage imageNamed:@"search arrow.png"] forState:UIControlStateNormal];
        
        [self viewWillAppear:YES];
//        [_btn_searchClick setBackgroundImage:[UIImage imageNamed:@"search arrow.png"] forState:UIControlStateNormal];

    }
    
}

-(void)backbtn_clicked
{
    [_txt_search resignFirstResponder];
    [self.navigationController popToRootViewControllerAnimated:YES];
}

-(void)imageviewTapoccurred
{
    [self.navigationController popToRootViewControllerAnimated:YES];
    //    [self.navigationController pushViewController:vc animated:YES];
}

-(void)imageviewTapoccurred:(UITapGestureRecognizer *)sender
{
    UIImageView *selectedimgView = (UIImageView*)sender.view;
    
    [self.navigationController popToRootViewControllerAnimated:YES];
    
    if ([__followingDelegate respondsToSelector:@selector(setFollowingFormDidDismisswithData:)])
    {
        NSDictionary *userdict=[tableviewDataArray objectAtIndex:selectedimgView.tag];
        [__followingDelegate setFollowingFormDidDismisswithData:userdict];
    }
}

-(void)sendUnfollowRequest:(UIButton *)sender
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
        //send Unfollwer request
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

-(void)sendfollowRequest:(UIButton *)sender
{
    NSLog(@"send Follow Request");

    btn_clickedView=sender;
    isunFollowRequest=YES;
    
    NSIndexPath* unfollowIndexpath = [NSIndexPath indexPathForRow:sender.tag inSection:0];
    [UnfollowerIndexes removeObject:unfollowIndexpath];
    
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.alpha = 1.0;
    _activityIndicator.center = CGPointMake(sender.frame.size.width-13,13);
    _activityIndicator.hidesWhenStopped = YES;
    [sender addSubview:_activityIndicator];
    
    [_activityIndicator startAnimating];
    
  
    
}


-(void)sendSearchFollowRequest:(UIButton *)sender
{
    isfollowRequest=YES;
    
    btn_clickedView=sender;
    _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    _activityIndicator.alpha = 1.0;
    _activityIndicator.center = CGPointMake(sender.frame.size.width-13,13);
    _activityIndicator.hidesWhenStopped = YES;
    [sender addSubview:_activityIndicator];
    
    [_activityIndicator startAnimating];
    
    NSDictionary *dict=[tableviewDataArray objectAtIndex:sender.tag];
    
    /*send Data to the server */
    NSArray *keys = [NSArray arrayWithObjects:@"user", @"follower", nil];
    NSArray *objects=[NSArray arrayWithObjects:[VSCore getUserID], [dict objectForKey:@"id"], nil];
    
    NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
    
    WebService *_webservice=[[WebService alloc]init];
    [_webservice setWebDelegate:self];
    [_webservice SendJSONDataToServer:dataDict toURI:NewFollower forRequestType:POST];
    
}

#pragma mark UITextFieldDelegate Methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
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
    
//    if (isSearchMode)
//    {
//        [cell.btn_follow setTitle:@"Follow" forState:UIControlStateNormal];
//        [cell.btn_follow setBackgroundColor:[VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]]];
//        [cell.btn_follow addTarget:self action:@selector(sendSearchFollowRequest:) forControlEvents:UIControlEventTouchUpInside];
//    }
//    else
//    {
//        
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
        

        [cell.btn_follow addTarget:self action:@selector(sendUnfollowRequest:) forControlEvents:UIControlEventTouchUpInside];

//    }
   
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
    _table_follwinglist.tableFooterView = spinner;
    //    [spinner startAnimating];
    return _table_follwinglist.tableFooterView;
}


- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSIndexPath *selectedIndexPath = [_table_follwinglist indexPathForRowAtPoint:scrollView.contentOffset];
    //    NSLog(@"%ld",(long)selectedIndexPath.row);
    
    if(_table_follwinglist.contentOffset.y >= (_table_follwinglist.contentSize.height - _table_follwinglist.frame.size.height))
    {
        //user has scrolled to the bottom
        
        NSLog(@"Equal");
        //Send request for Next Page
        
        if (!isendOfPage)
        {
            isendOfPage=YES;
            
            pageNumber++;
            
            [self fetchFollowingList];
            
        }

    }
//    if (selectedIndexPath.row == ([tableviewDataArray count]-1))
//    {
////        isfollowRequest=NO;
//        
//        
//    }
    
}

#pragma mark WebServiceDelegate methods
-(void)responseReceivedwithData:(NSDictionary *)data
{

    if ([data objectForKey:@"result"] != nil)
    {
        if (!([[data objectForKey:@"result"] count ]> 0 ) && (pageNumber == 1))
        {
            [_emptyResultView setHidden:NO];
            [self.view bringSubviewToFront:_emptyResultView];
            [_txt_search resignFirstResponder];
        }

        else
        {
            [_emptyResultView setHidden:YES];
            
        }
    }
    
   
    
    [_activityIndicator stopAnimating];
    [spinner stopAnimating];

    if(isfollowRequest)
    {
        [_emptyResultView setHidden:YES];

        isfollowRequest=NO;
        [btn_clickedView setTitle:@"Following" forState:UIControlStateNormal];
        [btn_clickedView setBackgroundColor:[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]]];
    }
    
    else if (isunFollowRequest)
    {
        [_emptyResultView setHidden:YES];

        isunFollowRequest=NO;
        [btn_clickedView setTitle:@"Follow" forState:UIControlStateNormal];
        [btn_clickedView setBackgroundColor:[VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]]];

    }
    else
    {
        
//        [tableviewDataArray removeAllObjects];
        [tableviewDataArray addObjectsFromArray:[data objectForKey:@"result"]];
        [_table_follwinglist reloadData];

    }
    
    if (isendOfPage)
    {
        isendOfPage=NO;
    }
    
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
