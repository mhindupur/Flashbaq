//
//  OnboardingContentViewController.m
//  Onboard
//
//  Created by Mike on 8/17/14.
//  Copyright (c) 2014 Mike Amaral. All rights reserved.
//

#import "OnboardingContentViewController.h"
#import "OnboardingViewController.h"
#import "VSCore.h"

static NSString * const kDefaultOnboardingFont = @"Helvetica-Light";

#define DEFAULT_TEXT_COLOR [UIColor whiteColor];

static CGFloat const kContentWidthMultiplier = 0.8;
static CGFloat const kDefaultImageViewSize = 100;
static CGFloat const kDefaultTopPadding = 60;
static CGFloat const kDefaultUnderIconPadding = 30;
static CGFloat const kDefaultUnderTitlePadding = 30;
static CGFloat const kDefaultBottomPadding = 0;
static CGFloat const kDefaultTitleFontSize = 58;
static CGFloat const kDefaultBodyFontSize = 18;
static CGFloat const kDefaultButtonFontSize = 24;

static CGFloat const kActionButtonHeight = 80;
static CGFloat const kMainPageControlHeight = 35;

@interface OnboardingContentViewController ()

@end

@implementation OnboardingContentViewController

+ (instancetype)contentWithTitle:(NSString *)title body:(NSString *)body image:(UIImage *)image buttonText:(NSString *)buttonText action:(dispatch_block_t)action {
    OnboardingContentViewController *contentVC = [[self alloc] initWithTitle:title body:body image:image buttonText:buttonText action:action];
    return contentVC;
}

- (instancetype)initWithTitle:(NSString *)title body:(NSString *)body image:(UIImage *)image buttonText:(NSString *)buttonText action:(dispatch_block_t)action {
    self = [super init];

    // hold onto the passed in parameters, and set the action block to an empty block
    // in case we were passed nil, so we don't have to nil-check the block later before
    // calling
    _titleText = title;
    _body = body;
    _image = image;
    _buttonText = buttonText;
    _actionHandler = action ?: ^{};
    
    // default auto-navigation
    self.movesToNextViewController = NO;
    
    // default icon properties
    self.iconHeight = kDefaultImageViewSize;
    self.iconWidth = kDefaultImageViewSize;
    
    // default title properties
    self.titleFontName = kDefaultOnboardingFont;
    self.titleFontSize = kDefaultTitleFontSize;
    
    // default body properties
    self.bodyFontName = kDefaultOnboardingFont;
    self.bodyFontSize = kDefaultBodyFontSize;
    
    // default button properties
    self.buttonFontName = kDefaultOnboardingFont;
    self.buttonFontSize = kDefaultButtonFontSize;
    
    // default padding values
    self.topPadding = kDefaultTopPadding;
    self.underIconPadding = kDefaultUnderIconPadding;
    self.underTitlePadding = kDefaultUnderTitlePadding;
    self.bottomPadding = kDefaultBottomPadding;
    
    // default colors
    self.titleTextColor = DEFAULT_TEXT_COLOR;
    self.bodyTextColor = DEFAULT_TEXT_COLOR;
    self.buttonTextColor = DEFAULT_TEXT_COLOR;
    
    // default blocks
    self.viewWillAppearBlock = ^{};
    self.viewDidAppearBlock = ^{};
    
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // now that the view has loaded we can generate the content
    [self generateView];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    // if we have a delegate set, mark ourselves as the next page now that we're
    // about to appear
    if (self.delegate) {
        [self.delegate setNextPage:self];
    }
    
    // call our view will appear block
    self.viewWillAppearBlock();
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    // if we have a delegate set, mark ourselves as the current page now that
    // we've appeared
    if (self.delegate) {
        [self.delegate setCurrentPage:self];
    }
    
    // call our view did appear block
    self.viewDidAppearBlock();
}

- (void)generateView {
    // we want our background to be clear so we can see through it to the image provided
    self.view.backgroundColor = [UIColor clearColor];
    
    // do some calculation for some common values we'll need, namely the width of the view,
    // the center of the width, and the content width we want to fill up, which is some
    // fraction of the view width we set in the multipler constant
    CGFloat viewWidth = CGRectGetWidth(self.view.frame);
    CGFloat horizontalCenter = viewWidth / 2;
    CGFloat contentWidth = viewWidth * kContentWidthMultiplier;
    
    // create the image view with the appropriate image, size, and center in on screen
    _imageView = [[UIImageView alloc] initWithImage:_image];
//    [_imageView setFrame:CGRectMake(horizontalCenter - (self.iconWidth / 2), self.topPadding, self.iconWidth, self.iconHeight)];
    [_imageView setFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
//    _imageView.contentMode=UIViewContentModeScaleAspectFit;

    [self.view addSubview:_imageView];
    
    // create and configure the main text label sitting underneath the icon with the provided padding
//    _mainTextLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(_imageView.frame) + self.underIconPadding, contentWidth, 0)];
    _mainTextLabel = [[UILabel alloc] init];//WithFrame:CGRectMake(0, 400, contentWidth, 0)];
    _mainTextLabel.text = _titleText;
    _mainTextLabel.textColor = self.titleTextColor;
    _mainTextLabel.font = [UIFont fontWithName:OTHER_FONT size:self.titleFontSize];
    _mainTextLabel.numberOfLines = 0;
    _mainTextLabel.textAlignment = NSTextAlignmentCenter;
    [_mainTextLabel sizeToFit];
    _mainTextLabel.translatesAutoresizingMaskIntoConstraints=NO;
    [_mainTextLabel setPreferredMaxLayoutWidth:contentWidth];
//    _mainTextLabel.center = CGPointMake(horizontalCenter, _mainTextLabel.center.y);
//    NSLog(@"%@",NSStringFromCGPoint(_mainTextLabel.center));
    [self.view addSubview:_mainTextLabel];
    
    
    NSLayoutConstraint *_bottomconstraint = [NSLayoutConstraint constraintWithItem:_mainTextLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-195.f];
    [self.view addConstraint:_bottomconstraint];
    
    NSLayoutConstraint *_xconstraint = [NSLayoutConstraint constraintWithItem:_mainTextLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:horizontalCenter-85];
    
    [self.view addConstraint:_xconstraint];
    
//    NSLayoutConstraint *_yconstraint = [NSLayoutConstraint constraintWithItem:_mainTextLabel attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f constant:40.f];
//    
//    [self.view addConstraint:_yconstraint];
    
    // create and configure the sub text label
    _subTextLabel = [[UILabel alloc] init ];//WithFrame:CGRectMake(0, 470, contentWidth, 0)];
    _subTextLabel.text = _body;
    _subTextLabel.textColor = self.bodyTextColor;
    _subTextLabel.font = [UIFont fontWithName:TITLE_FONT size:self.bodyFontSize];
    _subTextLabel.numberOfLines = 0;
    _subTextLabel.textAlignment = NSTextAlignmentCenter;
    [_subTextLabel sizeToFit];
    _subTextLabel.translatesAutoresizingMaskIntoConstraints=NO;
    [_subTextLabel setPreferredMaxLayoutWidth:contentWidth];
    _subTextLabel.lineBreakMode=NSLineBreakByWordWrapping;
//    _subTextLabel.center = CGPointMake(horizontalCenter, _subTextLabel.center.y);
    [self.view addSubview:_subTextLabel];
    
    
    NSLayoutConstraint *bottomconstraint = [NSLayoutConstraint constraintWithItem:_subTextLabel attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f constant:-155.f];
    [self.view addConstraint:bottomconstraint];
    
    NSLayoutConstraint *xconstraint = [NSLayoutConstraint constraintWithItem:_subTextLabel attribute:NSLayoutAttributeLeading relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeading multiplier:1.0f constant:horizontalCenter-120];
    
    [self.view addConstraint:xconstraint];
    

    // create the action button if we were given button text
//    if (_buttonText) {
//        _actionButton = [[UIButton alloc] init];
//        _actionButton.frame=CGRectMake(0, 500, 160, 75);
//        _actionButton.titleLabel.font = [UIFont fontWithName:self.buttonFontName size:self.buttonFontSize];
////        [_actionButton setTitle:_buttonText forState:UIControlStateNormal];
//        [_actionButton setBackgroundImage:[UIImage imageNamed:@"Login.png"] forState:UIControlStateNormal];
//        [_actionButton setTitleColor:self.buttonTextColor forState:UIControlStateNormal];
//        [_actionButton addTarget:self action:@selector(handleButtonPressed) forControlEvents:UIControlEventTouchUpInside];
//       // [self.view addSubview:_actionButton];
//    }
}


#pragma mark - Transition alpha

- (void)updateAlphas:(CGFloat)newAlpha {
    _imageView.alpha = newAlpha;
    _mainTextLabel.alpha = newAlpha;
    _subTextLabel.alpha = newAlpha;
    _actionButton.alpha = newAlpha;
}


#pragma mark - action button callback

- (void)handleButtonPressed {
    // if we want to navigate to the next view controller, tell our delegate
    // to handle it
    if (self.movesToNextViewController) {
        [self.delegate moveNextPage];
    }
    
    // call the provided action handler
    _actionHandler();
}

@end
