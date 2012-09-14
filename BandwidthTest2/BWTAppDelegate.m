//
//  BWTAppDelegate.m
//  BandwidthTest2
//
//  Created by Richard Steinberger on 9/4/12.
//  Copyright (c) 2012 Richard Steinberger. All rights reserved.
//

#import "BWTAppDelegate.h"

#import "BWTFirstViewController.h"
#import "BWTSecondViewController.h"
#import "BWTThirdViewController.h"
#import "URLDefaults.h"

@implementation BWTAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    
    // Some default defaults for multi-bandwidth test
    [[NSUserDefaults standardUserDefaults] registerDefaults:[NSDictionary dictionaryWithObjectsAndKeys:INITIAL_WEBSITE, @"INITIAL_WEBSITE", URL1, @"URL1", URL2, @"URL2", URL3, @"URL3", nil]];

    UIViewController *viewController1 = [[BWTFirstViewController alloc] initWithNibName:@"BWTFirstViewController" bundle:nil];
    UIViewController *viewController2 = [[BWTSecondViewController alloc] initWithNibName:@"BWTSecondViewController" bundle:nil];
    UIViewController *viewController3 = [[BWTThirdViewController alloc] initWithNibName:@"BWTThirdViewController" bundle:nil];
    
    self.tabBarController = [[UITabBarController alloc] init];
    // Loading order = 1, 3, 2
    self.tabBarController.viewControllers = @[viewController1, viewController3, viewController2];
    self.window.rootViewController = self.tabBarController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
