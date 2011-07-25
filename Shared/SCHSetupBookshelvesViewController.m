//
//  SCHSetupBookshelvesViewController.m
//  Scholastic
//
//  Created by Neil Gall on 19/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSetupBookshelvesViewController.h"


@implementation SCHSetupBookshelvesViewController

@synthesize setupBookshelvesButton;
@synthesize spinner;

- (void)releaseViewObjects
{
    [setupBookshelvesButton release], setupBookshelvesButton = nil;
    [spinner release], spinner = nil;
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)setupBookshelves:(id)sender
{
    // TODO: URL
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.scholastic.com"]];
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
