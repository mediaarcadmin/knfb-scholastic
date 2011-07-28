//
//  SCHBaseTextViewController.m
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBaseTextViewController.h"

@implementation SCHBaseTextViewController

@synthesize titleLabel;
@synthesize textView;

- (id)init
{
    self = [super initWithNibName:@"SCHBaseTextViewController" bundle:nil];
    return self;
}

- (void)releaseViewObjects
{
    self.titleLabel = nil;
    self.textView = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    [super dealloc];
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
