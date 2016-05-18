//
//  AppDelegate.h
//  emblm
//
//  Created by Kavya Valavala on 11/26/14.
//  Copyright (c) 2014 Vaayoo. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FacebookSDK/FacebookSDK.h>
#import "OnboardingContentViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

- (OnboardingViewController *)generateFirstDemoVC;

@end

