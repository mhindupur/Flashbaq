//
//  FlashbaqWebview.h
//  Flashbaq
//
//  Created by Kavya Valavala on 4/14/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FlashbaqWebview : UIViewController

@property (nonatomic, strong) IBOutlet UIWebView *_webview;
@property (nonatomic, strong) UIActivityIndicatorView *_indicatorView;
@property (nonatomic, strong) NSString           *urlString;
@property (nonatomic, strong) IBOutlet UINavigationBar    *navbar;
@property (nonatomic, strong) IBOutlet UIBarButtonItem    *rightItem;
@end
