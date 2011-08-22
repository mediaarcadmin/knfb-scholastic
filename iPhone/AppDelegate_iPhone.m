//
//  AppDelegate_iPhone.m
//  Scholastic
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "AppDelegate_Private.h"

#import "SCHProfileViewController_iPhone.h"
#import "SCHSyncManager.h"
#import "SCHAuthenticationManager.h"
#import "SCHThemeManager.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

static NSTimeInterval const kAppDelegate_iPhoneSyncManagerWakeDelay = 5.0;

@implementation AppDelegate_iPhone

@synthesize navigationController;
@synthesize customNavigationBar;

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
	[super application:application didFinishLaunchingWithOptions:launchOptions];

    if ([[SCHAuthenticationManager sharedAuthenticationManager] hasUsernameAndPassword]) {
        // skip the starter screen if already authenticated
        SCHProfileViewController_iPhone *profileViewController = [[SCHProfileViewController_iPhone alloc] initWithNibName:@"SCHProfileViewController_iPhone" bundle:nil];
        profileViewController.managedObjectContext = self.coreDataHelper.managedObjectContext;
        [self.navigationController pushViewController:profileViewController animated:NO];
        [profileViewController release];
    }

    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    [customNavigationBar setTheme:kSCHThemeManagerNavigationBarImage];
    
    return(YES);
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
    SCHSyncManager *syncManager = [SCHSyncManager sharedSyncManager];
#if NONDRMAUTHENTICATION
	SCHAuthenticationManager *authenticationManager = [SCHAuthenticationManager sharedAuthenticationManager];
	if ([authenticationManager isAuthenticated] == YES) {
#else
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];
    if (deviceKey != nil &&
        [[deviceKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {   
#endif
        [syncManager performSelector:@selector(firstSync:) withObject:[NSNumber numberWithBool:NO] afterDelay:kAppDelegate_iPhoneSyncManagerWakeDelay];
    }
}

#pragma mark - Memory management

- (void)dealloc
{
	[navigationController release], navigationController = nil;
    [customNavigationBar release], customNavigationBar = nil;

	[super dealloc];
}
    
@end

