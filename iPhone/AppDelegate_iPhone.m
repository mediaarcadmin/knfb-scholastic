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
#import "SCHAppStateManager.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

static NSTimeInterval const kAppDelegate_iPhoneSyncManagerWakeDelay = 5.0;

@implementation AppDelegate_iPhone

@synthesize navigationController;
@synthesize customNavigationBar;

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
	[super application:application didFinishLaunchingWithOptions:launchOptions];

    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    [customNavigationBar setTheme:kSCHThemeManagerNavigationBarImage];
    
    return(YES);
}

- (void)applicationDidBecomeActive:(UIApplication *)application 
{
#if NON_DRM_AUTHENTICATION
	SCHAuthenticationManager *authenticationManager = [SCHAuthenticationManager sharedAuthenticationManager];
	if ([authenticationManager isAuthenticated] == YES) {
#else
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];
    if (deviceKey != nil &&
        [[deviceKey stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {   
#endif
        double delayInSeconds = kAppDelegate_iPhoneSyncManagerWakeDelay;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[SCHSyncManager sharedSyncManager] firstSync:NO requireDeviceAuthentication:NO];
        });
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

