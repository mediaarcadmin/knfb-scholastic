//
//  BITReadingOptionsView.m
//  XPSRenderer
//
//  Created by Gordon Christie on 13/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "BITReadingOptionsView.h"
#import <QuartzCore/QuartzCore.h>
#import "LibreAccessServiceSvc.h"
//#import "SCHReadingViewController.h"
#import "SCHThemeManager.h"
#import "SCHThemeButton.h"
#import "SCHContentProfileItem.h"
#import "SCHCustomNavigationBar.h"

@interface BITReadingOptionsView ()

- (void)updateFavoriteDisplay;

@end

@implementation BITReadingOptionsView
@synthesize pageViewController;
@synthesize isbn;
@synthesize thumbnailImage;
@synthesize profileItem;
@synthesize favouriteButton;

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	optionsView.layer.cornerRadius = 5.0f;
	optionsView.layer.masksToBounds = YES;
    
    self.favouriteButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [self updateFavoriteDisplay];
    
    SCHThemeButton *button = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [button setThemeIcon:kSCHThemeManagerBooksIcon];
    [button setContentEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
    [button sizeToFit];    
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
}


- (void) viewDidAppear:(BOOL)animated
{
	initialFadeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
														target:self
													  selector:@selector(tapBookCover:)
													  userInfo:nil
													   repeats:NO];
}	

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (YES);
}


- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];	
//    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
	NSLog(@"Item: %@", self.isbn);
	
	if (self.thumbnailImage) {
		[coverImageView setImage:self.thumbnailImage];
	}
	
//	titleLabel.text = [NSString stringWithFormat:@"%@", metadataItem.Title];
//	authorLabel.text = [NSString stringWithFormat:@"Author: %@", metadataItem.Author];
        
    if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]  )) {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reading-view-portrait-top-bar.png"]];
    } else {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reading-view-landscape-top-bar.png"]];
    }

}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reading-view-portrait-top-bar.png"]];
    } else {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reading-view-landscape-top-bar.png"]];
    }
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma -
#pragma Accessor methods

- (void)setProfileItem:(SCHProfileItem *)newProfileItem
{
    [profileItem release];
    profileItem = [newProfileItem retain];
    
    if (self.isbn != nil) {
        [self updateFavoriteDisplay];
    }
}

- (void)setIsbn:(NSString *)newIsbn
{
    [isbn release];
    isbn = [newIsbn retain];
    
    if (self.profileItem != nil) {
        [self updateFavoriteDisplay];
    }
}

#pragma -
#pragma Action methods

- (IBAction) showFlowView: (id) sender
{
    
    SCHReadingViewController *readingController = [[SCHReadingViewController alloc] initWithNibName:nil bundle:nil isbn:self.isbn];
    readingController.flowView = YES;
    
    switch ([self.profileItem.BookshelfStyle intValue]) {
        case LibreAccessServiceSvc_BookshelfStyle_YOUNG_CHILD:
            readingController.youngerMode = YES;
            break;
            
        case LibreAccessServiceSvc_BookshelfStyle_OLDER_CHILD:
            readingController.youngerMode = NO;
            break;
            
        case LibreAccessServiceSvc_BookshelfStyle_ADULT:
            readingController.youngerMode = NO;
            break;
    }

    [self.navigationController pushViewController:readingController animated:YES];
    [readingController release];
}

- (IBAction) showFixedView: (id) sender
{
    SCHReadingViewController *readingController = [[SCHReadingViewController alloc] initWithNibName:nil bundle:nil isbn:self.isbn];
    readingController.flowView = NO;
    
    switch ([self.profileItem.BookshelfStyle intValue]) {
        case LibreAccessServiceSvc_BookshelfStyle_YOUNG_CHILD:
            readingController.youngerMode = YES;
            break;
            
        case LibreAccessServiceSvc_BookshelfStyle_OLDER_CHILD:
            readingController.youngerMode = NO;
            break;
            
        case LibreAccessServiceSvc_BookshelfStyle_ADULT:
            readingController.youngerMode = NO;
            break;
    }

    [self.navigationController pushViewController:readingController animated:YES];
    [readingController release];
}

- (IBAction) tapBookCover: (id) sender
{
	[UIView beginAnimations:@"coverHide" context:nil];
	[UIView setAnimationDuration:0.15f];
	
	[bookCoverView setAlpha:0.0f];
	
	[UIView commitAnimations];
	[self cancelInitialTimer];
}

- (IBAction)toggleFavorite:(id)sender
{
    BOOL favorite = favouriteButton.tag;
    [self.profileItem setContentIdentifier:self.isbn favorite:(favorite != YES)];
    [self.profileItem.managedObjectContext save:nil];
    [self updateFavoriteDisplay];    
}

- (void) cancelInitialTimer
{
	if (initialFadeTimer && [initialFadeTimer isValid]) {
		[initialFadeTimer invalidate];
		initialFadeTimer = nil;
	}
}	

#pragma -
#pragma Private methods

- (void)updateFavoriteDisplay
{
    if (self.profileItem == nil) {
        [favouriteButton setTitle:@"" forState:UIControlStateNormal]; 
        favouriteButton.hidden = YES;
    } else {
        BOOL favorite = [self.profileItem contentIdentifierFavorite:self.isbn];
        favouriteButton.tag = favorite;        
        favouriteButton.hidden = NO;
        if (favorite == NO) {
            [favouriteButton setTitle:NSLocalizedString(@"Add to Favorites", @"") 
                             forState:UIControlStateNormal];
        } else {
            [favouriteButton setTitle:NSLocalizedString(@"Remove from Favorites", @"") 
                             forState:UIControlStateNormal];            
        }
    }
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.favouriteButton = nil;
}


- (void)dealloc {
    self.pageViewController = nil;
    self.isbn = nil;
    self.thumbnailImage = nil;
    self.profileItem = nil;
    self.favouriteButton = nil;
    
    [super dealloc];
}


@end
