//
//  AppDelegate_iPhone.m
//  Scholastic
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "SCHProfileViewController.h"

#import "SCHSyncManager.h"
#import "SCHAuthenticationManager.h"
#import "SCHCustomNavigationBar.h"

static NSTimeInterval const kAppDelegate_iPhoneSyncManagerWakeDelay = 5.0;

@implementation AppDelegate_iPhone

@synthesize navigationController;
@synthesize customNavigationBar;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
	[super application:application didFinishLaunchingWithOptions:launchOptions];
    // Override point for customization after application launch.
	
    
    SCHProfileViewController *rootViewController = (SCHProfileViewController *)[navigationController topViewController];
    rootViewController.managedObjectContext = self.managedObjectContext;
    
    // Add the navigation controller's view to the window and display.
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    customNavigationBar.backgroundImage = [UIImage imageNamed:@"ReadingCustomToolbarBG"];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.

     Superclass implementation saves changes in the application's managed object context before the application terminates.
     */
	[super applicationDidEnterBackground:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of the transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	[super applicationWillEnterForeground:application];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	
	SCHSyncManager *syncManager = [SCHSyncManager sharedSyncManager];
	SCHAuthenticationManager *authenticationManager = [SCHAuthenticationManager sharedAuthenticationManager];
	
	if ([authenticationManager hasUsernameAndPassword] == YES) {
		[syncManager performSelector:@selector(firstSync) withObject:nil afterDelay:kAppDelegate_iPhoneSyncManagerWakeDelay];
	}
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
	[super dealloc];
}


@end

