//
//  AppDelegate_iPad.m
//  Scholastic
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//  

#import "AppDelegate_iPad.h"
#import "AppDelegate_Private.h"
#import "SCHProfileViewController_iPad.h"
#import "SCHSyncManager.h"
#import "SCHAuthenticationManager.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

static NSTimeInterval const kAppDelegate_iPadSyncManagerWakeDelay = 5.0;

@implementation AppDelegate_iPad

@synthesize navigationController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
	[super application:application didFinishLaunchingWithOptions:launchOptions];
	
    if ([[SCHAuthenticationManager sharedAuthenticationManager] hasUsernameAndPassword]) {
        // skip the starter screen if already authenticated
        SCHProfileViewController_iPad *profileViewController = [[SCHProfileViewController_iPad alloc] initWithNibName:@"SCHProfileViewController_iPad" bundle:nil];
        profileViewController.managedObjectContext = self.coreDataHelper.managedObjectContext;
        [self.navigationController pushViewController:profileViewController animated:NO];
        [profileViewController release];
    }
    
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    return(YES);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    SCHSyncManager *syncManager = [SCHSyncManager sharedSyncManager];
#if NONDRMAUTHENTICATION
	SCHAuthenticationManager *authenticationManager = [SCHAuthenticationManager sharedAuthenticationManager];
	if ([authenticationManager isAuthenticated] == YES) {
#else
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];
    if (deviceKey != nil &&
        [[deviceKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {   
#endif
        [syncManager performSelector:@selector(firstSync:) withObject:[NSNumber numberWithBool:NO] afterDelay:kAppDelegate_iPadSyncManagerWakeDelay];
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
    //[super applicationDidReceiveMemoryWarning:application];
}


- (void)dealloc {
	
    [navigationController release];
	[super dealloc];
}


@end

