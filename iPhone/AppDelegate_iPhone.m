//
//  AppDelegate_iPhone.m
//  Scholastic
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import "AppDelegate_iPhone.h"
#import "AppDelegate_Private.h"

#import "SCHSyncManager.h"
#import "SCHAuthenticationManager.h"
#import "SCHThemeManager.h"
#import "SCHAppStateManager.h"
#import "SCHAppModel.h"
#import "SCHNavigationAppController.h"

@interface AppDelegate_iPhone()

@property (nonatomic, retain) SCHNavigationAppController *appController;

@end

extern NSString * const kSCHAuthenticationManagerDeviceKey;

static NSTimeInterval const kAppDelegate_iPhoneSyncManagerWakeDelay = 5.0;

@implementation AppDelegate_iPhone

@synthesize navigationController;
@synthesize customNavigationBar;
@synthesize appModel;
@synthesize appController;

#pragma mark - Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
	BOOL success = [super application:application didFinishLaunchingWithOptions:launchOptions];

    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
    [customNavigationBar setTheme:kSCHThemeManagerNavigationBarImage];
    
    if (success) {
        self.appController = (SCHNavigationAppController *)self.navigationController;
        self.appModel = [[[SCHAppModel alloc] initWithAppController:self.appController] autorelease];
        [self.appModel restoreAppState];
    }

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
            [[SCHSyncManager sharedSyncManager] accountSyncForced:YES requireDeviceAuthentication:NO];
        });
    }

    return(YES);
}

#pragma mark - Memory management

- (void)dealloc
{
	[navigationController release], navigationController = nil;
    [customNavigationBar release], customNavigationBar = nil;
    [appModel release], appModel = nil;
    [appController release], appController = nil;

	[super dealloc];
}
    
@end

