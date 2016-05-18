//
//  CustomTabbarView.m
//  emblm
//
//  Created by Kavya Valavala on 1/11/15.
//  Copyright (c) 2015 Vaayoo. All rights reserved.
//

#import "CustomTabbarView.h"
#import "ApplicationSettings.h"
#import "VSCore.h"
#import "FlashbaqVideoPlayer.h"

@interface CustomTabbarView ()

@end

@implementation CustomTabbarView

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [[UITabBar appearance] setSelectedImageTintColor:[VSCore getColor:SEA_GREEN withDefault:[UIColor blackColor]]];
    
    self.tabBar.backgroundColor=[UIColor blackColor];
    self.delegate=self;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)tabBar:(UITabBar *)theTabBar didSelectItem:(UITabBarItem *)item
{

    /*check for any VideoPlayer and stop them */
    NSUInteger indexOfTab = [[theTabBar items] indexOfObject:item];
    
//    NSLog(@"Tab index = %u", indexOfTab);
    if (indexOfTab == 3)
    {
        [[ApplicationSettings getInstance] setUserId:[VSCore getUserID]];
    }


}

- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
{
    return YES;
}

- (void)tabBarController:(UITabBarController *)theTabBarController didSelectViewController:(UIViewController *)viewController
{
    
    NSUInteger indexOfTab = [theTabBarController.viewControllers indexOfObject:viewController];
    
    if (indexOfTab == 3)
    {
        [viewController viewWillAppear:NO];
    }
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
