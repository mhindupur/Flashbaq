//
//  NotificationTableVC.m
//  Flashbaq
//
//  Created by Kavya Valavala on 7/9/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "NotificationTableVC.h"
#import "VSCore.h"
#import "WebService.h"
#import "NotifViewCell.h"
#import "ApplicationSettings.h"
#import "PostDetailsVC.h"

static NSString *ACTION_TYPE=@"action_type";
static NSString *ACTION_LIKED = @"liked";
static NSString *ACTION_COMMENT=@"comment";
static NSString *ACTION_SCAN=@"scan";
static NSString *ACTION_FOLLOW=@"follow";

//TODO :have to do this

@interface NotificationTableVC ()<WebServiceDelegate>
{
    int pageNumber;
    NSMutableArray *notifArray;
    UIActivityIndicatorView *spinner;
    BOOL isViewPostDetailsPage;
    BOOL isendOfPage;
}
@end

@implementation NotificationTableVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.refreshControl = [[UIRefreshControl alloc] init];
    self.refreshControl.backgroundColor = [UIColor purpleColor];
    self.refreshControl.tintColor = [UIColor whiteColor];
    [self.refreshControl addTarget:self
                            action:@selector(getLatestNotifications)
                  forControlEvents:UIControlEventValueChanged];
    
    notifArray=[[NSMutableArray alloc] init];
    
    pageNumber=0;
    isendOfPage=NO;

    [self sendNotifcationRequest];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)viewWillAppear:(BOOL)animated
{
    
    self.navigationController.topViewController.title=@"Notifications";
    
    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:20],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];

    UIButton *bckbtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    bckbtn.frame = CGRectMake(0,0,44,44);
    [bckbtn setBackgroundImage:[UIImage imageNamed:@"navback.png"] forState:UIControlStateNormal];
    [bckbtn addTarget:self action:@selector(backbtn_notifclicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationController.topViewController.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]
                                                                                  
                                                                                  initWithCustomView:bckbtn];
    
    
    spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    spinner.frame = CGRectMake(0, 0, self.view.frame.size.width, 44);
    [spinner startAnimating];

}

-(void)viewWillDisappear:(BOOL)animated
{
   // [self.navigationController removeFromParentViewController];
}

-(void)sendNotifcationRequest
{
    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;
    
    NSString *url=[NSString stringWithFormat:Notifications,pageNumber];
    [_webservice sendGETrequestToservertoURI:url];

}

-(void)backbtn_notifclicked
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)getLatestNotifications
{
    pageNumber=1;
    
    WebService *_webservice=[[WebService alloc]init];
    _webservice.webDelegate=self;

    NSString *url=[NSString stringWithFormat:Notifications,pageNumber];
    [_webservice sendGETrequestToservertoURI:url];

    [notifArray removeAllObjects];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return [notifArray count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NotifViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"notifCell" forIndexPath:indexPath];
    
    NSDictionary *userDict=[[notifArray objectAtIndex:indexPath.row]objectForKey:@"user"];
    if ([[userDict objectForKey:@"user_image"] length ]> 0)
    {
        NSMutableDictionary *cacheImages =   [[ApplicationSettings getInstance] getCacheImages];
        
        NSString *imgname=[userDict objectForKey:@"user_image"];
        
        if([cacheImages objectForKey:imgname] == nil)
        {
            dispatch_queue_t queue =  dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0);
            dispatch_async(queue, ^{
                @try {
                    NSData *imageData = [NSData dataWithContentsOfURL:[NSURL URLWithString:[userDict objectForKey:@"user_image"]]];
                    UIImage *image= [[UIImage alloc] initWithData:imageData];
                    if(image)
                    {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            cell.profileimage.image= image;
                            [cacheImages setObject:image forKey:imgname];
                        });
                    }
                }
                @catch (NSException *exception) {
                }
                @finally {
                }
            });
        }
        else
        {
            cell.profileimage.image = [cacheImages objectForKey:imgname];
        }
        
    }
    else
    {
        cell.profileimage.image=[UIImage imageNamed:@"profile pics.png"];
        
    }

    if ([[[notifArray objectAtIndex:indexPath.row]  objectForKey:ACTION_TYPE] isEqualToString:ACTION_FOLLOW])

    {
        NSString *name=[[[[notifArray objectAtIndex:indexPath.row]objectForKey:@"strings"]objectAtIndex:0]objectForKey:@"text"];
        NSString *string=[[[[notifArray objectAtIndex:indexPath.row]objectForKey:@"strings"]objectAtIndex:1]objectForKey:@"text"];
        NSString *descp=[NSString stringWithFormat:@"%@ %@",name, string];
        cell.lbl_descp.text=descp;

    }
    
    else  if ([[[notifArray objectAtIndex:indexPath.row]  objectForKey:ACTION_TYPE] isEqualToString:ACTION_COMMENT])
    {
        NSString *name=[[[[notifArray objectAtIndex:indexPath.row]objectForKey:@"strings"]objectAtIndex:0]objectForKey:@"text"];
        NSString *string=[[[[notifArray objectAtIndex:indexPath.row]objectForKey:@"strings"]objectAtIndex:1]objectForKey:@"text"];
        NSString *event=[[[[notifArray objectAtIndex:indexPath.row]objectForKey:@"strings"]objectAtIndex:2]objectForKey:@"text"];
        NSString *cmnttext=[[[[notifArray objectAtIndex:indexPath.row]objectForKey:@"strings"]objectAtIndex:3]objectForKey:@"text"];
        NSString *descp=[NSString stringWithFormat:@"%@ %@ %@ %@",name, string , event , cmnttext];

        NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:descp];

        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[name length])];
        [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:TITLE_FONT size:14.0] range:NSMakeRange(0, [name length])];
        
        NSRange cmntrange = [descp rangeOfString:cmnttext];
        
        [attString addAttribute:NSForegroundColorAttributeName value:[VSCore getColor:@"9c76cc" withDefault:[UIColor blackColor]] range:cmntrange];
        [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:TITLE_FONT size:14.0] range:cmntrange];
        
        cell.lbl_descp.attributedText=attString;
    }
    

    else
    {
        NSString *name=[[[[notifArray objectAtIndex:indexPath.row]objectForKey:@"strings"]objectAtIndex:0]objectForKey:@"text"];
        NSString *string=[[[[notifArray objectAtIndex:indexPath.row]objectForKey:@"strings"]objectAtIndex:1]objectForKey:@"text"];
        NSString *event=[[[[notifArray objectAtIndex:indexPath.row]objectForKey:@"strings"]objectAtIndex:2]objectForKey:@"text"];

        NSString *descp=[NSString stringWithFormat:@"%@ %@ %@",name, string , event];
//        cell.lbl_descp.text=descp;
        
        NSMutableAttributedString * attString = [[NSMutableAttributedString alloc] initWithString:descp];
        NSRange nameRange=[descp rangeOfString:name];
        
        [attString addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[name length])];
        [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:TITLE_FONT size:14.0] range:NSMakeRange(0, [name length])];

        NSRange eventrange = [descp rangeOfString:event];

        [attString addAttribute:NSForegroundColorAttributeName value:[VSCore getColor:@"9c76cc" withDefault:[UIColor blackColor]] range:eventrange];
        [attString addAttribute:NSFontAttributeName value:[UIFont fontWithName:TITLE_FONT size:14.0] range:NSMakeRange(0, [name length])];

        cell.lbl_descp.attributedText=attString;
    }
    
    int milliseconds=[[[notifArray objectAtIndex:indexPath.row]objectForKey:@"created"] intValue];
    cell.lbl_timestamp.text=[VSCore daysBetweenDate:[NSDate dateWithTimeIntervalSince1970:milliseconds] andDate:[NSDate date]];

    return cell;
}


- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    self.tableView.tableFooterView = spinner;
//        [spinner startAnimating];
    return self.tableView.tableFooterView;
}

/*- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
  
 
  if(self.tableView.contentOffset.y >= (self.tableView.contentSize.height - self.tableView.frame.size.height))
    {
        //user has scrolled to the bottom
        
        NSLog(@"Equal");
        //Send request for Next Page
        
        if (pageNumber != 1)
        {
            if (!isendOfPage)
            {
                isendOfPage=YES;
                
                pageNumber++;
                
                [self sendNotifcationRequest];
                
            }

        }
        
    }
    //    if (selectedIndexPath.row == ([tableviewDataArray count]-1))
    //    {
    ////        isfollowRequest=NO;
    //
    //
    //    }
    
}*/

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView {
    CGPoint offset = aScrollView.contentOffset;
    CGRect bounds = aScrollView.bounds;
    CGSize size = aScrollView.contentSize;
    UIEdgeInsets inset = aScrollView.contentInset;
    float y = offset.y + bounds.size.height - inset.bottom;
    float h = size.height;
    // NSLog(@"offset: %f", offset.y);
    // NSLog(@"content.height: %f", size.height);
    // NSLog(@"bounds.height: %f", bounds.size.height);
    // NSLog(@"inset.top: %f", inset.top);
    // NSLog(@"inset.bottom: %f", inset.bottom);
    // NSLog(@"pos: %f of %f", y, h);
    
    float reload_distance = 10;
    if(y > h + reload_distance)
    {
        NSLog(@"load more rows");
        
        if (!isendOfPage)
        {
            isendOfPage=YES;
            
            pageNumber++;
            
            [self sendNotifcationRequest];
            
        }

    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[[notifArray objectAtIndex:indexPath.row]  objectForKey:ACTION_TYPE] isEqualToString:ACTION_FOLLOW])
    {
        //OPEN profile Page of the following user
        //TODO:
        NSString *userID=[[[[notifArray objectAtIndex:indexPath.row] objectForKey:@"user"] objectForKey:@"id"] stringValue];
        [[ApplicationSettings getInstance] setUserId:userID];
                
        if (_isProfilePage)
        {
            _isProfilePage=NO;
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else
        {
            [self.navigationController.tabBarController setSelectedIndex:3];

        }
        
    }
    
    else if ([[[notifArray objectAtIndex:indexPath.row]  objectForKey:ACTION_TYPE] isEqualToString:ACTION_COMMENT])
    {
        //FIXME m,nlkj.bnj,bn,
        isViewPostDetailsPage=YES;
        
        NSString *emblmid=[[[[notifArray objectAtIndex:indexPath.row]objectForKey:@"strings"] objectAtIndex:2]objectForKey:@"action_id"];
        WebService *_webservice=[[WebService alloc]init];
        _webservice.webDelegate=self;//
        NSString *url=[NSString stringWithFormat:PostDetails,emblmid];
        [_webservice sendGETrequestToservertoURI:url];
        
    }
    
    else if ([[[notifArray objectAtIndex:indexPath.row]  objectForKey:ACTION_TYPE] isEqualToString:ACTION_LIKED])
    {
        isViewPostDetailsPage=YES;
        
        NSString *emblmid=[[[[notifArray objectAtIndex:indexPath.row] objectForKey:@"strings"] objectAtIndex:2]objectForKey:@"action_id"];
        WebService *_webservice=[[WebService alloc]init];
        _webservice.webDelegate=self;//
        NSString *url=[NSString stringWithFormat:PostDetails,emblmid];
        [_webservice sendGETrequestToservertoURI:url];
    }
    
    else if ([[[notifArray objectAtIndex:indexPath.row]  objectForKey:ACTION_TYPE] isEqualToString:ACTION_SCAN])
    {
        isViewPostDetailsPage=YES;
        //TODO
        NSString *emblmid=[[[[notifArray objectAtIndex:indexPath.row] objectForKey:@"strings"] objectAtIndex:2]objectForKey:@"action_id"];
        WebService *_webservice=[[WebService alloc]init];
        _webservice.webDelegate=self;//
        NSString *url=[NSString stringWithFormat:PostDetails,emblmid];
        [_webservice sendGETrequestToservertoURI:url];
    }
}


#pragma mark WebServiceDelegate Methods
-(void)responseReceivedwithData:(NSDictionary *)data
{
    [spinner stopAnimating];
    
    
    if (isViewPostDetailsPage)
    {
        isViewPostDetailsPage=NO;
        
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        PostDetailsVC *vc = (PostDetailsVC *)[storyboard instantiateViewControllerWithIdentifier:@"PostDetails"];
        vc.isnotificationView=YES;
        vc.resultDict=[NSMutableDictionary dictionaryWithDictionary:[data objectForKey:@"result"]];
        
        [self.navigationController pushViewController:vc animated:YES];
        
    }
    
    else
    {
        if ([[data objectForKey:@"result"] count] > 0)
        {
            [notifArray addObjectsFromArray:[data objectForKey:@"result"]];
            [self.tableView reloadData];
            
        }
        
        else
        {
            pageNumber--; /*if no data for the currentPage, decremnt the number */
        }

    }
    
    [self.refreshControl endRefreshing];
    isendOfPage=NO;
}

-(void)connectionFailed
{
    
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
