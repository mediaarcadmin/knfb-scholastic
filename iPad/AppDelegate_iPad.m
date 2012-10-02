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
#import "SCHAppStateManager.h"
#import "SCHNavigationAppController.h"
#import "SCHAppModel.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

static NSTimeInterval const kAppDelegate_iPadSyncManagerWakeDelay = 5.0;

@interface AppDelegate_iPad()

@property (nonatomic, retain) SCHNavigationAppController *appController;

@end

@implementation AppDelegate_iPad

@synthesize navigationController;
@synthesize appModel;
@synthesize appController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{    
	BOOL success = [super application:application didFinishLaunchingWithOptions:launchOptions];
	
    [self.window addSubview:navigationController.view];
    [self.window makeKeyAndVisible];
    
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
        double delayInSeconds = kAppDelegate_iPadSyncManagerWakeDelay;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [[SCHSyncManager sharedSyncManager] accountSyncForced:YES requireDeviceAuthentication:NO];
        });
    }

        return(YES);
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
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
    //[super applicationDidReceiveMemoryWarning:application];
}


- (void)dealloc {
	
    [navigationController release];
	[super dealloc];
}


@end

