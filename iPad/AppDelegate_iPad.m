//
//  AppDelegate_iPad.m
//  Scholastic
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//  

#import "AppDelegate_iPad.h"
#import "SCHReadingViewController.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"
#import "SCHCustomNavigationBar.h"
#import "SCHThemeManager.h"

@implementation AppDelegate_iPad

@synthesize navigationController;
@synthesize customNavigationBar;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
	[super application:application didFinishLaunchingWithOptions:launchOptions];
	
    SCHProfileViewController *rootViewController = (SCHProfileViewController *)[navigationController topViewController];
    rootViewController.managedObjectContext = self.managedObjectContext;
    
    
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    [customNavigationBar setTheme:kSCHThemeManagerNavigationBarImage];

    
    return(YES);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive.
     */
}


/**
 Superclass implementation saves changes in the application's managed object context before the application terminates.
 */
- (void)applicationWillTerminate:(UIApplication *)application {
	[super applicationWillTerminate:application];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
    [super applicationDidReceiveMemoryWarning:application];
}


- (void)dealloc {
	
    [navigationController release];
    [customNavigationBar release];
	[super dealloc];
}


@end

