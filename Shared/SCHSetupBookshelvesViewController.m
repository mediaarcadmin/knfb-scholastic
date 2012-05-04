//
//  SCHSetupBookshelvesViewController.m
//  Scholastic
//
//  Created by Neil Gall on 19/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSetupBookshelvesViewController.h"
#import "SCHSettingsDelegate.h"
#import "SCHParentalToolsWebViewController.h"
#import "SCHAuthenticationManager.h"
#import "SCHAccountValidationViewController.h"
#import "SCHVersionDownloadManager.h"
#import "SCHDeregisterDeviceViewController.h"
#import "LambdaAlert.h"
#import "Reachability.h"

@interface SCHSetupBookshelvesViewController ()

@property (nonatomic, retain) NSTimer *moveToWebParentToolsTimer;

- (BOOL)connectionIsReachable;
- (void)showAppVersionOutdatedAlert;
- (void)showNoInternetConnectionAlert;

@end 

@implementation SCHSetupBookshelvesViewController

@synthesize setupBookshelvesButton;
@synthesize deregisterButton;
@synthesize topToolbar;
@synthesize moveToWebParentToolsTimer;

- (void)releaseViewObjects
{
    [setupBookshelvesButton release], setupBookshelvesButton = nil;
    [deregisterButton release], deregisterButton = nil;
    [super releaseViewObjects];
}

- (void)dealloc
{
    [self releaseViewObjects];
    [moveToWebParentToolsTimer invalidate];
    [moveToWebParentToolsTimer release], moveToWebParentToolsTimer = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonBackground:self.setupBookshelvesButton];
    [self setButtonBackground:self.deregisterButton];
    
    self.title = NSLocalizedString(@"Set Up Your Bookshelves", @"");
    
#if 0 // force a way out of this screen
    [self.setupBookshelvesButton setTitle:@"EXIT" forState:UIControlStateNormal];
    
    if ([self.profileSetupDelegate respondsToSelector:@selector(pushCurrentProfileAnimated:)]) {
        [self.setupBookshelvesButton addTarget:self.profileSetupDelegate action:@selector(showCurrentProfileAnimated:) forControlEvents:UIControlEventTouchDown];
    }
#endif
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.moveToWebParentToolsTimer = [NSTimer scheduledTimerWithTimeInterval:300.0 
                                                                      target:self 
                                                                    selector:@selector(moveToWebParentTools:) 
                                                                    userInfo:nil 
                                                                     repeats:NO];    
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.moveToWebParentToolsTimer invalidate];
    self.moveToWebParentToolsTimer = nil;
    [super viewWillDisappear:animated];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
    [self.moveToWebParentToolsTimer invalidate];
    self.moveToWebParentToolsTimer = nil;
}

- (void)setupBookshelves:(id)sender
{
    [self.moveToWebParentToolsTimer invalidate];
    self.moveToWebParentToolsTimer = nil;
    
    NSString *pToken = [SCHAuthenticationManager sharedAuthenticationManager].pToken;
    if (pToken != nil) {
        [self.profileSetupDelegate presentWebParentToolsModallyWithToken:pToken 
                                                                   title:self.title 
                                                              modalStyle:UIModalPresentationFullScreen 
                                                   shouldHideCloseButton:YES];
    } else {
        SCHAccountValidationViewController *accountValidationViewController = [[[SCHAccountValidationViewController alloc] init] autorelease];
        accountValidationViewController.profileSetupDelegate = self.profileSetupDelegate;        
        accountValidationViewController.validatedControllerShouldHideCloseButton = YES;
        accountValidationViewController.title = self.title;
        [self.navigationController pushViewController:accountValidationViewController animated:YES];        
    }    
}

- (IBAction)deregister:(id)sender
{
    if ([[SCHVersionDownloadManager sharedVersionManager] isAppVersionOutdated] == YES) {
        [self showAppVersionOutdatedAlert];
    } else if ([self connectionIsReachable]) {
        SCHDeregisterDeviceViewController *vc = [[SCHDeregisterDeviceViewController alloc] init];
        vc.profileSetupDelegate = self.profileSetupDelegate;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else {
        [self showNoInternetConnectionAlert];
    }
}

- (BOOL)connectionIsReachable
{
    return [[Reachability reachabilityForInternetConnection] isReachable];
}

- (void)showAppVersionOutdatedAlert
{
    LambdaAlert *alert = [[LambdaAlert alloc]
                          initWithTitle:NSLocalizedString(@"Update Required", @"")
                          message:NSLocalizedString(@"This function requires that you update Storia. Please visit the App Store to update your app.", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
    [alert show];
    [alert release];         
}

- (void)showNoInternetConnectionAlert
{
    LambdaAlert *alert = [[LambdaAlert alloc]
                          initWithTitle:NSLocalizedString(@"No Internet Connection", @"")
                          message:NSLocalizedString(@"This function requires an Internet connection. Please connect to the internet and then try again.", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
    [alert show];
    [alert release];
}

- (void)moveToWebParentTools:(NSTimer *)theTimer
{
    BOOL shouldFireTimer = NO;
    
    if ([self respondsToSelector:@selector(presentingViewController)]) {
        if (self.presentingViewController != nil) {
            shouldFireTimer = YES;
        }
    } else {
        if (self.parentViewController != nil) {
            shouldFireTimer = YES;
        }
    }
    
    self.moveToWebParentToolsTimer = nil;
    
    if (shouldFireTimer) {
        [self setupBookshelves:nil];
    }
}

@end
