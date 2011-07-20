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

- (void)dealloc
{
    [setupBookshelvesButton release], setupBookshelvesButton = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *buttonBGImage = [[UIImage imageNamed:@"button-login-red"] stretchableImageWithLeftCapWidth:10 topCapHeight:0];
    [self.setupBookshelvesButton setBackgroundImage:buttonBGImage forState:UIControlStateNormal];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)setupBookshelves:(id)sender
{
    // TODO
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

@end
