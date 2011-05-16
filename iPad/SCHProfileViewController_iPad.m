//
//  SCHProfileViewController_iPad.m
//  Scholastic
//
//  Created by Gordon Christie on 13/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewController_iPad.h"

#pragma mark - Class Extension

@interface SCHProfileViewController_iPad () 

@end

@implementation SCHProfileViewController_iPad
@synthesize tableView;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [tableView release], tableView = nil;
}

- (void)dealloc 
{    
    [self releaseViewObjects];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = logoImageView;
    [logoImageView release];
}  


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)viewDidUnload {
    [super viewDidUnload];
}

@end
