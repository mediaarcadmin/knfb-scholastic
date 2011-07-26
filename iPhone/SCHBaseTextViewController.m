//
//  SCHBaseTextViewController.m
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBaseTextViewController.h"
#import "SCHCustomToolbar.h"

@implementation SCHBaseTextViewController

@synthesize titleLabel;
@synthesize textView;
@synthesize topToolbar;

- (id)init
{
    self = [super initWithNibName:@"SCHBaseTextViewController" bundle:nil];
    return self;
}

- (void)releaseViewObjects
{
    self.titleLabel = nil;
    self.textView = nil;
    self.topToolbar = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    [super dealloc];
}

- (void)viewDidLoad
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.topToolbar setBackgroundImage:[UIImage imageNamed:@"settings-ipad-top-toolbar"]];
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.titleLabel.text = self.title;
}

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
