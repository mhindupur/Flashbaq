//
//  FlashbaqWebview.m
//  Flashbaq
//
//  Created by Kavya Valavala on 4/14/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "FlashbaqWebview.h"
#import "VSCore.h"

@interface FlashbaqWebview ()<UIWebViewDelegate>

@end

@implementation FlashbaqWebview
@synthesize urlString;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(setNeedsStatusBarAppearanceUpdate)]) {
        // iOS 7
        [self performSelector:@selector(setNeedsStatusBarAppearanceUpdate)];
    } else {
        // iOS 6
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationSlide];
    }
    
    _navbar.barTintColor=[VSCore getColor:TITLEBAR_COLOR withDefault:[UIColor blackColor]];

    [_navbar setTitleTextAttributes:
     [NSDictionary dictionaryWithObjectsAndKeys:
      [UIFont fontWithName:TITLE_FONT size:21],
      NSFontAttributeName, [UIColor whiteColor],NSForegroundColorAttributeName,nil]];

//    UINavigationItem *item1=[[UINavigationItem alloc]init];
    __indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    __indicatorView.hidesWhenStopped = YES;
    _rightItem.customView=__indicatorView;
//    [__indicatorView startAnimating];
//    item1.rightBarButtonItem.customView=__indicatorView;
//    [_navbar pushNavigationItem:item1 animated:YES];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}


-(void)viewWillAppear:(BOOL)animated
{
    
    [super viewWillAppear:animated];
    
    // URL Request Object
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    
    // Load the request in the UIWebView
    [__webview loadRequest:requestObj];
}

-(IBAction)back_btnPressed:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

#pragma mark UIWebViewDelegate Methods

- (void)webViewDidStartLoad:(UIWebView *)webView
{
    [__indicatorView startAnimating];
    
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [__indicatorView stopAnimating];
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    [__indicatorView stopAnimating];
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
