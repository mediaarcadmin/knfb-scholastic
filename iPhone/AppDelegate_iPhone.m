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
#import "SCHCustomNavigationBar.h"
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
	
    // Add the navigation controller's view to the window and display.
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
       [syncManager performSelector:@selector(firstSync) withObject:nil afterDelay:kAppDelegate_iPhoneSyncManagerWakeDelay];
    }
}

#pragma mark - Memory management

- (void)dealloc
{
	[navigationController release], navigationController = nil;
    [customNavigationBar release], customNavigationBar = nil;

	[super dealloc];
}

#pragma mark - Database control
    
- (void)distributeManagedObjectContext
{
    [super distributeManagedObjectContext];

    SCHProfileViewController_iPhone *rootViewController = (SCHProfileViewController_iPhone *)[navigationController topViewController];
    rootViewController.managedObjectContext = self.managedObjectContext;
}
    
@end

