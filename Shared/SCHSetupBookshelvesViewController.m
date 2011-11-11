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

@interface SCHSetupBookshelvesViewController ()

@property (nonatomic, retain) NSTimer *moveToWebParentToolsTimer;
           
@end 

@implementation SCHSetupBookshelvesViewController

@synthesize setupBookshelvesButton;
@synthesize topToolbar;
@synthesize moveToWebParentToolsTimer;

- (void)releaseViewObjects
{
    [setupBookshelvesButton release], setupBookshelvesButton = nil;
    [super releaseViewObjects];
}

- (void)dealloc
{
    [self releaseViewObjects];
    [moveToWebParentToolsTimer release], moveToWebParentToolsTimer = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonBackground:self.setupBookshelvesButton];
    
#if 0 // force a way out of this screen
    [self.setupBookshelvesButton setTitle:@"EXIT" forState:UIControlStateNormal];
    
    if ([self.profileSetupDelegate respondsToSelector:@selector(showCurrentProfileAnimated:)]) {
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

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)setupBookshelves:(id)sender
{
    [self.moveToWebParentToolsTimer invalidate];
    self.moveToWebParentToolsTimer = nil;
    
    NSString *pToken = [SCHAuthenticationManager sharedAuthenticationManager].pToken;
    if (pToken != nil) {
        SCHParentalToolsWebViewController *parentalToolsWebViewController = [[[SCHParentalToolsWebViewController alloc] init] autorelease];
        parentalToolsWebViewController.profileSetupDelegate = self.profileSetupDelegate;
        parentalToolsWebViewController.pToken = pToken;
        parentalToolsWebViewController.shouldHideCloseButton = YES;
        [self.navigationController pushViewController:parentalToolsWebViewController animated:YES];
    } else {
        SCHAccountValidationViewController *accountValidationViewController = [[[SCHAccountValidationViewController alloc] init] autorelease];
        accountValidationViewController.profileSetupDelegate = self.profileSetupDelegate;        
        accountValidationViewController.validatedControllerShouldHideCloseButton = YES;
        [self.navigationController pushViewController:accountValidationViewController animated:YES];        
    }    
}

- (void)moveToWebParentTools:(NSTimer *)theTimer
{
    [self setupBookshelves:nil];
}

@end
