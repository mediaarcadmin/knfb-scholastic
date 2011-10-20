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

@implementation SCHSetupBookshelvesViewController

@synthesize setupBookshelvesButton;
@synthesize spinner;
@synthesize topToolbar;

- (void)releaseViewObjects
{
    [setupBookshelvesButton release], setupBookshelvesButton = nil;
    [spinner release], spinner = nil;
    [super releaseViewObjects];
}

- (void)dealloc
{
    [self releaseViewObjects];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonBackground:self.setupBookshelvesButton];
    
#if 0 // force a way out of this screen
    [self.setupBookshelvesButton setTitle:@"EXIT" forState:UIControlStateNormal];
    [self.setupBookshelvesButton addTarget:self.navigationController action:@selector(dismissModalViewControllerAnimated:) forControlEvents:UIControlEventTouchDown];
#endif
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self showActivity:NO];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)setupBookshelves:(id)sender
{
    // This is where the view should do the necessary steps to present the WPT wizard, authenticatingif required
    // As a placeholder the spinner just starts
    [self showActivity:YES];
    
//    if ([[SCHAuthenticationManager sharedAuthenticationManager] hasValidPToken] == YES) {
//        SCHParentalToolsWebViewController *parentalToolsWebViewController = [[[SCHParentalToolsWebViewController alloc] init] autorelease];
//        [self.navigationController pushViewController:parentalToolsWebViewController animated:YES];
//    } else {
//        SCHAccountValidationViewController *accountValidationViewController = [[[SCHAccountValidationViewController alloc] init] autorelease];
//        [self.navigationController pushViewController:accountValidationViewController animated:YES];        
//    }    
}

- (void)showActivity:(BOOL)activity
{
    [self view]; // ensure the view is loaded
    
    if (activity) {
        [self.spinner startAnimating];
    } else {
        [self.spinner stopAnimating];
    }
}

@end
