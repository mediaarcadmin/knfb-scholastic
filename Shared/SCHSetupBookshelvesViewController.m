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
    [moveToWebParentToolsTimer invalidate];
    [moveToWebParentToolsTimer release], moveToWebParentToolsTimer = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonBackground:self.setupBookshelvesButton];
    
    self.title = NSLocalizedString(@"Set Up Your Bookshelves", @"");
    
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

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.moveToWebParentToolsTimer invalidate];
    self.moveToWebParentToolsTimer = nil;
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

- (void)moveToWebParentTools:(NSTimer *)theTimer
{
    [self setupBookshelves:nil];
}

@end
