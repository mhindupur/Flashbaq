//
//  TrendingViewController.m
//  emblm
//
//  Created by Kavya Valavala on 12/31/14.
//  Copyright (c) 2014 Vaayoo. All rights reserved.
//

#import "TrendingViewController.h"
#import "TrendingCustomCell.h"
#import "WebService.h"
#import "VSCore.h"

@interface TrendingViewController ()<WebServiceDelegate>

{
    NSArray *dataArray;
}
@end

@implementation TrendingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self._navbar.barTintColor=[VSCore getColor:@"ff4b4a" withDefault:[UIColor blackColor]];
    [self._navbar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];

    // Do any additional setup after loading the view.
}

-(void)viewWillAppear:(BOOL)animated
{
    /*send Data to the server */
    WebService *_webservice=[[WebService alloc]init];
    [_webservice setWebDelegate:self];
    [_webservice sendGETrequestToservertoURI:TrendingEmblem];
    
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark WebViewDelegate Methods
-(void)responseReceivedwithData:(NSDictionary *)data
{
    dataArray=[data objectForKey:@"result"];
    
//    NSString *path = [VSCore createandGetPlistwithFileName:@"UserStories"];
//    
//    [result writeToFile:path atomically:YES];
    
    [__tableview reloadData];
    
}


#pragma mark UITableViewDatasource

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
//    NSInteger numOfRows = [self.story[kCommentsKey] count];
//    return numOfRows;
    
    return [dataArray count];
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
//    CGFloat cellHeight = 0.0;
//    NSDictionary *commentDetails = self.story[kCommentsKey][indexPath.row];
//    NSString *comment = commentDetails[kCommentKey];
//    
//    cellHeight += [StoryCommentCell cellHeightForComment:comment];
//    return cellHeight;
    return 337;
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentity = @"TrendingCellId";
    
    TrendingCustomCell *cell = (TrendingCustomCell *)[tableView dequeueReusableCellWithIdentifier:cellIdentity];
    
    NSDictionary *dict=[dataArray objectAtIndex:indexPath.row];
    
    NSDictionary *userDict=[[dict objectForKey:@"emblm"] objectForKey:@"user"];
    
    cell.lbl_username.text=[NSString stringWithFormat:@"By:%@",[userDict objectForKey:@"name"]];
    cell.lbl_username.textColor=[VSCore getColor:@"ff4b4a" withDefault:[UIColor blackColor]];
    cell.lbl_username.font=[UIFont fontWithName:OTHER_FONT size:16];
    
    cell.lbl_comment.text=[[dict objectForKey:@"emblm"]objectForKey:@"message"];
    cell.lbl_comment.textColor=[UIColor darkGrayColor];
    cell.lbl_comment.font=[UIFont fontWithName:OTHER_FONT size:15];

    NSString *cmntslikesCount=[NSString stringWithFormat:@"%@ Comments . %@ Likes",[[dict objectForKey:@"emblm"]objectForKey:@"comment_count"],[[dict objectForKey:@"emblm"]objectForKey:@"like_count"]];
    cell.lbl_commentscount.text=cmntslikesCount;
    cell.lbl_commentscount.textColor=[UIColor grayColor];
    cell.lbl_commentscount.font=[UIFont fontWithName:OTHER_FONT size:14];

    
    NSURL *url = [NSURL URLWithString:[userDict objectForKey:@"user_image"]]; //0 Index will be the Default Profile Picture
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSData *imageData = [NSData dataWithContentsOfURL:url];
        UIImage *image = [UIImage imageWithData:imageData];
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           CALayer * l = [cell.userImageView layer];
                           [l setMasksToBounds:YES];
                           //    [l setCornerRadius:50.0];
                           [l setCornerRadius:cell.userImageView.frame.size.width/2];
                           
                           cell.userImageView.image= image;
                       });
    });
    
        cell.lbl_scanncount.text=@"9";
        cell.lbl_scanncount.textColor=[VSCore getColor:@"ff4b4a" withDefault:[UIColor blackColor]];
        cell.lbl_scanncount.font=[UIFont fontWithName:OTHER_FONT size:16];
    
    int milliseconds=[[[dict objectForKey:@"emblm"] objectForKey:@"created"] intValue];

//    NSInteger days=[VSCore daysBetweenDate:[NSDate dateWithTimeIntervalSince1970:milliseconds] andDate:[NSDate date]];
//    cell.lbl_timestamp.text=[NSString stringWithFormat:@"%ld days",days];
//    cell.lbl_timestamp.textColor=[UIColor grayColor];
//    cell.lbl_timestamp.font=[UIFont fontWithName:OTHER_FONT size:16];
//

    return cell;
}

#pragma UITableViewDelegate MEthods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
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
