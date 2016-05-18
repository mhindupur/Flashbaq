//
//  AppDelegate.m
//  emblm
//
//  Created by Kavya Valavala on 11/26/14.
//  Copyright (c) 2014 Vaayoo. All rights reserved.
//

#import "AppDelegate.h"
#import "OnboardingViewController.h"
#import "OnboardingContentViewController.h"
#import "VSCore.h"
#import <Parse/Parse.h>

@interface AppDelegate ()

@end

static NSString * const kUserHasOnboardedKey = @"user_has_onboarded";

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    NSLog(@"%@",[NSDate date]);
    [Parse setApplicationId:@"LrEn5VNOwrMlWlRw5Z5uVrY1FtKaQCbbuf3kFcfa"
                  clientKey:@"F9L136cvq1P3wcJNUetiORq7fmNFrf7oMiNYihqr"];
    
    
    
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSArray *fileArray = [fileMgr contentsOfDirectoryAtPath:[VSCore getVideosFolder] error:nil];
    for (NSString *filename in fileArray)  {
        
        [fileMgr removeItemAtPath:[[VSCore getVideosFolder] stringByAppendingPathComponent:filename] error:NULL];
    }
    
    [VSCore clearImagesFolder];
    [VSCore clearTmpDirectory];
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
//     [application setStatusBarHidden:NO];
//     [application setStatusBarStyle:UIStatusBarStyleDefault];
    // determine if the user has onboarded yet or not
    BOOL userHasLoggedIn = [[[NSUserDefaults standardUserDefaults] objectForKey:@"isLoginDone"] isEqualToString:@"yes"];
    
    // if the user has already onboarded, just set up the normal root view controller
    // for the application, but don't animate it because there's no transition in this case
    if (userHasLoggedIn)
    {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UIViewController *vc = [storyboard instantiateViewControllerWithIdentifier:@"HomePage"];
        [VSCore setTabBaritemsforvc:vc];
        
//        UIViewController *profilevc = [storyboard instantiateViewControllerWithIdentifier:@"CreateProfile"];

        self.window.rootViewController=vc;
        
    }
    
    // otherwise set the root view controller to the onboarding view controller
    else
    {
        self.window.rootViewController = [self generateFirstDemoVC];
        
    }
    
    application.statusBarStyle = UIStatusBarStyleLightContent;
    
    [self.window makeKeyAndVisible];
    
    
    /*Register for notifications */
    
    // Register for Push Notitications
    UIUserNotificationType userNotificationTypes = (UIUserNotificationTypeAlert |
                                                    UIUserNotificationTypeBadge |
                                                    UIUserNotificationTypeSound);
    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:userNotificationTypes
                                                                             categories:nil];
    [application registerUserNotificationSettings:settings];
    [application registerForRemoteNotifications];
    
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    [FBAppEvents activateApp];
    [FBAppCall handleDidBecomeActive];
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    // Store the deviceToken in the current installation and save it to Parse.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
    
    /*save the deviceToken which is sent to Parse */
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    [[NSUserDefaults standardUserDefaults] setObject:currentInstallation.deviceToken forKey:@"DeviceToken"];
    [defaults synchronize];

}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    [PFPush handlePush:userInfo];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

- (void)setupNormalRootViewControllerAnimated:(BOOL)animated {
    // create whatever your root view controller is going to be, in this case just a simple view controller
    // wrapped in a navigation controller
    UIViewController *mainVC = [UIViewController new];
    mainVC.title = @"Main Application";
    
    // if we want to animate the transition, do it
    if (animated) {
        [UIView transitionWithView:self.window duration:0.5 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
            self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:mainVC];
        } completion:nil];
    }
    
    // otherwise just set the root view controller normally without animation
    else {
        self.window.rootViewController = [[UINavigationController alloc] initWithRootViewController:mainVC];
    }
}

- (void)handleOnboardingCompletion {
    // set that we have completed onboarding so we only do it once... for demo
    // purposes we don't want to have to set this every time so I'll just leave
    // this here...
    //    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kUserHasOnboardedKey];
    
    // animate the transition to the main application
    [self setupNormalRootViewControllerAnimated:YES];
}

- (OnboardingViewController *)generateFirstDemoVC {
    OnboardingContentViewController *firstPage = [OnboardingContentViewController contentWithTitle:@"" body:@"" image:[UIImage imageNamed:@"welcome_750x1334"] buttonText:@"SignUp" action:^{
       
    }];

    
    OnboardingContentViewController *secondPage = [OnboardingContentViewController contentWithTitle:@"" body:@"" image:[UIImage imageNamed:@"screen1_750x1334"] buttonText:@"Connect With Facebook" action:^{
    }];
    
    OnboardingContentViewController *thirdPage = [OnboardingContentViewController contentWithTitle:@"" body:@"" image:[UIImage imageNamed:@"screen2_750x1334"] buttonText:@"Get Started" action:^{
        [self handleOnboardingCompletion];
    }];
    
    OnboardingContentViewController *fourthPage = [OnboardingContentViewController contentWithTitle:@"" body:@"" image:[UIImage imageNamed:@"screen3_750x1334"] buttonText:@"Get Started" action:^{
        [self handleOnboardingCompletion];
    }];
    
    OnboardingViewController *onboardingVC = [OnboardingViewController onboardWithBackgroundImage:[UIImage imageNamed:@""] contents:@[firstPage, secondPage, thirdPage , fourthPage]];
    onboardingVC.shouldFadeTransitions = NO;
    onboardingVC.fadePageControlOnLastPage = NO;
    
    // If you want to allow skipping the onboarding process, enable skipping and set a block to be executed
    // when the user hits the skip button.
    onboardingVC.allowSkipping = NO;
    onboardingVC.skipHandler = ^{
        [self handleOnboardingCompletion];
    };
    
    return onboardingVC;
}

- (void)application:(UIApplication *)application didChangeStatusBarFrame:(CGRect)oldStatusBarFrame
{
    [application setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [FBAppCall handleOpenURL:url
                  sourceApplication:sourceApplication];
}



@end
