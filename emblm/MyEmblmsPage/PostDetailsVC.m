//
//  PostDetailsVC.m
//  emblm
//
//  Created by Kavya Valavala on 2/19/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "PostDetailsVC.h"
#import "VSCore.h"
#import "PostDetailHeaderView.h"
#import <MediaPlayer/MediaPlayer.h>
#import "StoryCommentCell.h"
#import "ApplicationSettings.h"
#import "WebService.h"
#import "LikesView.h"
#import "MODropAlertView.h"

static CGFloat kDefaultHeaderViewHeight = 480.0f;
#define k_lbl_messagetextFont  [UIFont fontWithName:@"Lato-Bold" size:15]

@interface PostDetailsVC ()<HPGrowingTextViewDelegate, WebServiceDelegate>

{
    PostDetailHeaderView *_headerview;
    UIActivityIndicatorView *spinner;
    UIView *containerView;
    BOOL isendOfPage;
    int currentPage;
    BOOL isfollowRequest;

}

@property (nonatomic) NSMutableDictionary *story;

-(IBAction)followButton_clicked:(id)sender;
@end

@implementation PostDetailsVC
@synthesize resultDict, isProfileView , flashbaqCode;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    currentPage=1;
    
    self.story=[[NSMutableDictionary alloc]init];
    [self.story setObject:[resultDict objectForKey:@"comments"] forKey:kCommentsKey];
    [StoryCommentCell setTableViewWidth:__tableView.frame.size.width];

    _headerview = [[[NSBundle mainBundle] loadNibNamed:@"PostDetailHeaderView" owner:self options:nil] objectAtIndex:0];

    self.automaticallyAdjustsScrollViewInsets = NO;

    [self.navigationController.tabBarController.tabBar setHidden:NO];
    
    self.navigationController.navigationBar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];

    [self.navigationController.navigationBar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];
    
    self.navigationController.navigationBar.topItem.backBarButtonItem = [[UIBarButtonItem alloc]
                                                                         initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    self.navigationController.topViewController.title=@"Post";
    
    UIButton *bckbtn =  [UIButton buttonWithType:UIButtonTypeCustom];
    bckbtn.frame = CGRectMake(0,0,44,44);
    [bckbtn setBackgroundImage:[UIImage imageNamed:@"navback.png"] forState:UIControlStateNormal];
    [bckbtn addTarget:self action:@selector(postBckbtn_clicked) forControlEvents:UIControlEventTouchUpInside];
    
    self.navigationController.topViewController.navigationItem.leftBarButtonItem=[[UIBarButtonItem alloc]
                                                                                  initWithCustomView:bckbtn];
        // Do any additional setup after loading the view.
    _btn_follow.titleLabel.font = [UIFont fontWithName:TITLE_FONT size:18.0];
    [_btn_follow setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _btn_follow.backgroundColor=[VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]];

    BOOL is_following;
    
    if ([[[resultDict objectForKey:@"user"] objectForKey:@"id" ] isEqualToString:[VSCore getUserID]])
    {
        [_btn_follow setHidden:YES];
    }
    

    if(![[resultDict objectForKey:@"is_following"] isEqual:[NSNull null]])
    {
        is_following=[[resultDict objectForKey:@"is_following"] boolValue];
        
        if (is_following)
        {
            [_btn_follow setTitle:[NSString stringWithFormat:@"Unfollow %@?",[[resultDict objectForKey:@"user"]objectForKey:@"username"]] forState:UIControlStateNormal];
            
        }
        
        else
        {
            [_btn_follow setTitle:[NSString stringWithFormat:@"Follow %@?",[[resultDict objectForKey:@"user"]objectForKey:@"username"]] forState:UIControlStateNormal];

        }

    }
    
   
}

-(void)viewWillAppear:(BOOL)animated
{
    self.navigationController.navigationBar.hidden=NO;

    [self loadTextView];
//    __tableView.contentInset = UIEdgeInsetsZero;

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillShow:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification 
                                               object:nil];
    
    /*Display Flashbaq Code as PopUp */
    
    if ([flashbaqCode length] > 0)
    {
        NSString *displayMessage=[NSString stringWithFormat:@"You have successfully created flashbaq code \"%@\"" , flashbaqCode];
        
        MODropAlertView *codealert=[[MODropAlertView alloc] initDropAlertWithTitle:@"Success" description:displayMessage okButtonTitle:@"OK" okButtonColor:[VSCore getColor:@"7c9365" withDefault:[UIColor blackColor]]];
        [codealert show];


    }
}

-(void)viewDidDisappear:(BOOL)animated
{
    /*stop the player if-any */
    
    [_headerview.flahbaqPlayer._guiplayerView clean];
    
    [_headerview.flahbaqPlayer._guiplayerView stop];

    
}

-(IBAction)followButton_clicked:(id)sender
{
    
    isfollowRequest=YES;
    NSMutableDictionary *mutableResult=[NSMutableDictionary dictionaryWithDictionary:resultDict];
    
   BOOL is_following=[[resultDict objectForKey:@"is_following"] boolValue];

    if (is_following)
    {
        /*unfollow him */
        NSString *followerID=[[resultDict objectForKey:@"user"] objectForKey:@"id"];

        NSString *url=[NSString stringWithFormat:Unfollow, followerID];
        WebService *_webservice=[[WebService alloc]init];
        [_webservice setWebDelegate:self];

        [_webservice SendJSONDataToServer:0 toURI:url forRequestType:POST];
        
        [_btn_follow setTitle:[NSString stringWithFormat:@"Follow %@?",[[resultDict objectForKey:@"user"]objectForKey:@"username"]] forState:UIControlStateNormal];
        
        [mutableResult setObject:@"0" forKey:@"is_following"];
        
        resultDict=[mutableResult copy];

    }
    
    else
    {
        /*follow him */
        
        NSString *followerID=[[resultDict objectForKey:@"user"] objectForKey:@"id"];
        NSArray *keys = [NSArray arrayWithObjects:@"user", @"follower", nil];
        NSArray *objects=[NSArray arrayWithObjects:[VSCore getUserID], followerID, nil];
        
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        WebService *_webservice=[[WebService alloc]init];
        [_webservice setWebDelegate:self];
        
        [_webservice SendJSONDataToServer:dataDict toURI:NewFollower forRequestType:POST];
        
        [_btn_follow setTitle:[NSString stringWithFormat:@"Unfollow %@?",[[resultDict objectForKey:@"user"]objectForKey:@"username"]] forState:UIControlStateNormal];

        [mutableResult setObject:@"1" forKey:@"is_following"];

        resultDict=[mutableResult copy];

    }

}

//Code from Brett Schumann
-(void) keyboardWillShow:(NSNotification *)note{
    // get keyboard size and loctaion
    CGRect keyboardBounds;
    
    NSValue* keyboardFrameBegin = [note.userInfo valueForKey:UIKeyboardFrameBeginUserInfoKey];
    keyboardBounds = [keyboardFrameBegin CGRectValue];

//    [[note.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue: &keyboardBounds];
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // Need to translate the bounds to account for rotation.
    keyboardBounds = [self.view convertRect:keyboardBounds toView:nil];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - (keyboardBounds.size.height + containerFrame.size.height)+49;
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    containerView.frame = containerFrame;    // commit animations
    [UIView commitAnimations];
}

-(void) keyboardWillHide:(NSNotification *)note{
    NSNumber *duration = [note.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [note.userInfo objectForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    // get a rect for the textView frame
    CGRect containerFrame = containerView.frame;
    containerFrame.origin.y = self.view.bounds.size.height - containerFrame.size.height;
    
    // animations settings
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    
    // set views with new info
    containerView.frame = containerFrame;
    
    // commit animations
    [UIView commitAnimations];
}

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadTextView {
    
    containerView = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height - 40, self.view.frame.size.width, 40)];
    containerView.backgroundColor=[VSCore getColor:@"dedede" withDefault:[UIColor blackColor]];
    textView = [[HPGrowingTextView alloc] initWithFrame:CGRectMake(9, 5, self.view.frame.size.width - 58, 0)];
    textView.isScrollable = NO;
    textView.contentInset = UIEdgeInsetsMake(0, 5, 0, 3);
    
    textView.minNumberOfLines = 1;
    textView.maxNumberOfLines = 6;
    // you can also set the maximum height in points with maxHeight
    // textView.maxHeight = 200.0f;
    textView.returnKeyType = UIReturnKeyGo; //just as an example
    textView.font = [UIFont systemFontOfSize:15.0f];
    textView.delegate = self;
    textView.internalTextView.scrollIndicatorInsets = UIEdgeInsetsMake(5, 0, 5, 0);
    textView.backgroundColor = [UIColor whiteColor];
    textView.placeholder = @"Enter a comment...";
    
    // textView.text = @"test\n\ntest";
    // textView.animateHeightChange = NO; //turns off animation
    
    [self.view addSubview:containerView];
    
    UIImage *rawEntryBackground = [UIImage imageNamed:@"MessageEntryInputField.png"];
    UIImage *entryBackground = [rawEntryBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *entryImageView = [[UIImageView alloc] initWithImage:entryBackground];
    entryImageView.frame = CGRectMake(5, 0, 248, 40);
    entryImageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIImage *rawBackground = [UIImage imageNamed:@"MessageEntryBackground.png"];
    UIImage *background = [rawBackground stretchableImageWithLeftCapWidth:13 topCapHeight:22];
    UIImageView *imageView = [[UIImageView alloc] initWithImage:background];
    imageView.frame = CGRectMake(0, 0, containerView.frame.size.width, containerView.frame.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth;
    
    // view hierachy
//    [containerView addSubview:imageView];
    [containerView addSubview:textView];
//    [containerView addSubview:entryImageView];
    
    UIImage *sendBtnBackground = [[UIImage imageNamed:@"search arrow.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    UIImage *selectedSendBtnBackground = [[UIImage imageNamed:@"search arrow.png"] stretchableImageWithLeftCapWidth:13 topCapHeight:0];
    
    UIButton *doneBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    doneBtn.frame = CGRectMake(containerView.frame.size.width - 60, 5, 63, 30);
    doneBtn.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin;
//    [doneBtn setTitle:@"Done" forState:UIControlStateNormal];
    
    [doneBtn setTitleShadowColor:[UIColor colorWithWhite:0 alpha:0.4] forState:UIControlStateNormal];
    doneBtn.titleLabel.shadowOffset = CGSizeMake (0.0, -1.0);
    doneBtn.titleLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    
    [doneBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneBtn addTarget:self action:@selector(resignTextView) forControlEvents:UIControlEventTouchUpInside];
    [doneBtn setImage:sendBtnBackground forState:UIControlStateNormal];
    [doneBtn setImage:selectedSendBtnBackground forState:UIControlStateSelected];
    [containerView addSubview:doneBtn];
    containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
}

-(void)resignTextView
{
  
    [textView resignFirstResponder];
    
   NSString *trimmedString = [textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                                        
    if ([trimmedString length] > 0)
    {
        /*send comments data to server */
        NSArray *keys = [NSArray arrayWithObjects:@"owner", @"post", @"comment", nil];
        NSArray *objects=[NSArray arrayWithObjects:[VSCore getUserID],[resultDict objectForKey:@"id"], textView.text ,nil];
        
        NSDictionary *dataDict = [NSDictionary dictionaryWithObjects:objects forKeys:keys];
        
        WebService *_webservice=[[WebService alloc]init];
        [_webservice setWebDelegate:self];
        [_webservice SendJSONDataToServer:dataDict toURI:PostComment forRequestType:POST];

    }
   

}


-(void)userImgTapoccurred
{
    if (isProfileView)
    {
        [[ApplicationSettings getInstance] setUserId:[[resultDict objectForKey:@"user"] objectForKey:@"id"]];
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    else
    {
        [[ApplicationSettings getInstance] setUserId:[[resultDict objectForKey:@"user"] objectForKey:@"id"]];
        [self.navigationController.tabBarController setSelectedIndex:3];

    }
    
}

-(void)LikesViewTapoccured:(UITapGestureRecognizer *)recog
{
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    LikesView *vc = (LikesView *)[storyboard instantiateViewControllerWithIdentifier:@"Like"];
    
    vc.postID=[resultDict objectForKey:@"id"];
    [self.navigationController pushViewController:vc animated:YES];

}

-(void)bindDatatoHeaderview
{
    _headerview.lbl_comments.text=[NSString stringWithFormat:@"%@ Comments",[resultDict objectForKey:@"comment_count"]];
    _headerview.lbl_likes.text=[NSString stringWithFormat:@"%@ Likes",[resultDict objectForKey:@"like_count"]];
    
    UITapGestureRecognizer *_tap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(LikesViewTapoccured:)];
    _tap.numberOfTapsRequired=1;
    [_headerview.lbl_likes addGestureRecognizer:_tap];
    
    if ([[resultDict objectForKey:@"media_preview"] length ]> 0)
    {
        NSURL *url = [NSURL URLWithString:[resultDict objectForKey:@"media_preview"]]; //0 Index will be the Default Profile Picture
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               _headerview.flahbaqPlayer.previewImageview.image= image;
                           });
        });
        
    }
    
    else
    {
//        _headerview.flahbaqPlayer.previewImageview.image=[UIImage imageNamed:@"noPreview.png"];
    }
    
    _headerview.lblDescription.text=[resultDict objectForKey:@"message"];
    
    int milliseconds=[[resultDict objectForKey:@"created"] intValue];
    
//    NSInteger days=[VSCore daysBetweenDate:[NSDate dateWithTimeIntervalSince1970:milliseconds] andDate:[NSDate date]];
    _headerview.lbl_timeStamp.text=[VSCore daysBetweenDate:[NSDate dateWithTimeIntervalSince1970:milliseconds] andDate:[NSDate date]];
    
    if ([[[resultDict objectForKey:@"user"]objectForKey:@"user_image"] length ]> 0)
    {
        NSURL *url = [NSURL URLWithString:[[resultDict objectForKey:@"user"]objectForKey:@"user_image"]]; //0 Index will be the Default Profile Picture
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *imageData = [NSData dataWithContentsOfURL:url];
            UIImage *image = [UIImage imageWithData:imageData];
            dispatch_async(dispatch_get_main_queue(),
                           ^{
                               _headerview.userimgView.image= image;
                           });
        });
        
    }
    
    _headerview.lbl_username.text=[[resultDict objectForKey:@"user"]objectForKey:@"username"];
    
//    [_btn_follow setTitle:[NSString stringWithFormat:@"Follow %@?",[[resultDict objectForKey:@"user"]objectForKey:@"username"]] forState:UIControlStateNormal];
    
    if ([[resultDict objectForKey:@"user_liked"] isEqualToString:@"1"])
    {
        _headerview.img_likes.image=[UIImage imageNamed:@"redlove"];
    }
}


-(void)postBckbtn_clicked
{
    
    if ([_postDelegate respondsToSelector:@selector(donotReloadTableviewDatawith:)])
    {
        [self.navigationController popViewControllerAnimated:YES];
        [_postDelegate donotReloadTableviewDatawith:resultDict];

    }
    
    else
    {
        if (_isnotificationView)
        {
            [self.navigationController popViewControllerAnimated:YES];
        }
        
        else
        {
            [self.navigationController popToRootViewControllerAnimated:YES];

        }

    }
}

//-(void)sendListCommentsrequesttoAPI
//{
//    
//    NSString *url=[NSString stringWithFormat:CommentsList,[resultDict objectForKey:@"id"],currentPage];
//    WebService *_webservice=[[WebService alloc]init];
//    [_webservice setWebDelegate:self];
//
//    [_webservice sendGETrequestToservertoURI:url];
//
//}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark UITableViewDelegate Methods
- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger numOfRows = [self.story[kCommentsKey] count];
    return numOfRows;
}

- (CGFloat) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat cellHeight = 0.0;
    NSDictionary *commentDetails = self.story[kCommentsKey][indexPath.row];
    NSString *comment = commentDetails[kCommentKey];
    
    cellHeight += [StoryCommentCell cellHeightForComment:comment];
    return cellHeight;

}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [self customCellForIndex:indexPath];
    NSDictionary *comment = self.story[kCommentsKey][indexPath.row];
    [(StoryCommentCell *)cell  configureCommentCellForComment:comment];
    return cell;

}

#pragma UITableViewDelegate MEthods
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    //
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{

    _headerview.frame=CGRectMake(0, 0, __tableView.frame.size.width, 0);

    _headerview.userInteractionEnabled=YES;
    
    UITapGestureRecognizer *_tap=[[UITapGestureRecognizer alloc]initWithTarget:_headerview.flahbaqPlayer action:@selector(postDetailsFormVideoTapped:)];
    _headerview.flahbaqPlayer.postresultDict=resultDict;
    _tap.numberOfTapsRequired=1;
    [_headerview.flahbaqPlayer addGestureRecognizer:_tap];

    UITapGestureRecognizer *_userimagetap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userImgTapoccurred)];
    _userimagetap.numberOfTapsRequired=1;
    [_headerview.userimgView addGestureRecognizer:_userimagetap];
    
    UITapGestureRecognizer *_labelTap=[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(userImgTapoccurred)];
    _labelTap.numberOfTapsRequired=1;
    [_headerview.lbl_username addGestureRecognizer:_labelTap];

    __tableView.tableHeaderView=_headerview;
    [self bindDatatoHeaderview];

    return __tableView.tableHeaderView;

}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
//    return 621;
    
    /*adjust the height dynamically */
    
    NSString *comment=[resultDict objectForKey:@"message"];
    
    CGFloat cellHeight = 0.0;
    
    cellHeight += [PostDetailsVC cellHeightForCommentText:comment];
    return cellHeight;
}

+ (CGFloat)cellHeightForCommentText:(NSString *)comment
{
    return kDefaultHeaderViewHeight + [PostDetailsVC heightForComment:comment];
}

+ (CGFloat)heightForComment:(NSString *)comment
{
    CGFloat commentlabelWidth = 320.0;
    
    CGRect textRect = [comment boundingRectWithSize:(CGSize){commentlabelWidth, MAXFLOAT}
                                            options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                         attributes:@{NSFontAttributeName:k_lbl_messagetextFont}
                                            context:nil];
    
    CGFloat labelHeight = textRect.size.height;
    return labelHeight;
    
}

//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    __tableView.tableFooterView = spinner;
//    //    [spinner startAnimating];
//    return __tableView.tableFooterView;
//}
#pragma mark -
#pragma mark Private

- (UITableViewCell *)customCellForIndex:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    NSString * detailId = kCellIdentifier;
    cell = [__tableView dequeueReusableCellWithIdentifier:detailId];
    if (!cell)
    {
        cell = [StoryCommentCell storyCommentCellForTableWidth:__tableView.frame.size.width];
    }
    return cell;
}

#pragma mark HPGrwing
- (void)growingTextView:(HPGrowingTextView *)growingTextView willChangeHeight:(float)height
{
    float diff = (growingTextView.frame.size.height - height);
    
    CGRect r = containerView.frame;
    r.size.height -= diff;
    r.origin.y += diff;
    containerView.frame = r;
}

#pragma mark Webservice Delegate methods
-(void)responseReceivedwithData:(NSDictionary *)data
{
    
//    if (!([[data objectForKey:@"result"] count] > 0))
//    {
//        /*if no found data for the currentPage, decrement the pageCount */
//        
//        if (currentPage != 1)
//        {
//            currentPage--;
//            
//        }
//    }
    
    
//    [spinner stopAnimating];

    if (isfollowRequest)
    {
        isfollowRequest=NO;
    }
    
    else
    {

        textView.text=@"";
        NSArray *_array=[NSArray arrayWithObject:data];
        
        NSMutableArray *updatedarray=[NSMutableArray arrayWithArray:[resultDict objectForKey:kCommentsKey]];
        
        NSArray *newArray=[updatedarray arrayByAddingObjectsFromArray:_array];
        
        [self.story setObject:newArray forKey:kCommentsKey];
        
        [resultDict setObject:newArray forKey:kCommentsKey];
        [resultDict setObject:[NSString stringWithFormat:@"%lu" ,(unsigned long)[[resultDict objectForKey:kCommentsKey]count]] forKey:@"comment_count"];
        
        _headerview.lbl_comments.text=[NSString stringWithFormat:@"%@ Comments",[resultDict objectForKey:@"comment_count"]];

        [__tableView reloadData];
        [__tableView setContentOffset:CGPointMake(0, (__tableView.contentSize.height - __tableView.frame.size.height))];

    }
}

-(void)connectionFailed
{
    [VSCore showConnectionFailedAlert];
}

#pragma mark UIScrollViewDelegate Methods
//- (void)scrollViewDidScroll:(UIScrollView *)scrollView
//{
//    //[_headerview setHidden:YES];
//    
//    NSIndexPath *selectedIndexPath = [__tableView indexPathForRowAtPoint:scrollView.contentOffset];
//    //    NSLog(@"%ld",(long)selectedIndexPath.row);
//    
//    int storycount=[self.story[kCommentsKey] count];
//    if (selectedIndexPath.row == (storycount-1))
//    {
//
//        NSLog(@"Equal");
//        //Send request for Next Page
//        
//        if (!isendOfPage)
//        {
//            isendOfPage=YES;
//            
//            currentPage++;
//            
//            [self sendListCommentsrequesttoAPI];
//            
//        }
//        
//    }
//}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
