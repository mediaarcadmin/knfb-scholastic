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
#import "SCHThemeManager.h"
#import "SCHThemeButton.h"
#import "SCHCustomNavigationBar.h"
#import "SCHReadingViewController.h"
#import "SCHProfileItem.h"

@interface BITReadingOptionsView ()

- (void)updateFavoriteDisplay;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)releaseViewObjects;

@end

@implementation BITReadingOptionsView

@synthesize coverImageView;
@synthesize bookCoverView;
@synthesize optionsView;

@synthesize initialFadeTimer;	

@synthesize pageViewController;
@synthesize isbn;
@synthesize thumbnailImage;
@synthesize profileItem;
@synthesize favouriteButton;
@synthesize shadowView;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [coverImageView release], coverImageView = nil;
    [bookCoverView release], bookCoverView = nil;
    [optionsView release], optionsView = nil;

    [self cancelInitialTimer];
    
    [favouriteButton release], favouriteButton = nil;
    [shadowView release], shadowView = nil;
}

- (void)dealloc 
{        
    [pageViewController release], pageViewController = nil;
    [isbn release], isbn = nil;
    [thumbnailImage release], thumbnailImage = nil;
    [profileItem release], profileItem = nil;
    
    [self releaseViewObjects];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
	self.optionsView.layer.cornerRadius = 5.0f;
	self.optionsView.layer.masksToBounds = YES;
    [self.optionsView setAlpha:0];
    
    self.favouriteButton.titleLabel.textAlignment = UITextAlignmentCenter;
    [self updateFavoriteDisplay];
    
    SCHThemeButton *button = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [button setThemeIcon:kSCHThemeManagerBooksIcon];
    [button setContentEdgeInsets:UIEdgeInsetsMake(0, 7, 0, 0)];
    [button sizeToFit];    
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    
    [self.shadowView setImage:[[UIImage imageNamed:@"bookshelf-iphone-top-shadow.png"] stretchableImageWithLeftCapWidth:15.0f topCapHeight:0]];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];	
    
	if (self.thumbnailImage) {
		[coverImageView setImage:self.thumbnailImage];
	}
    
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
	self.initialFadeTimer = [NSTimer scheduledTimerWithTimeInterval:1.0f
														target:self
													  selector:@selector(tapBookCover:)
													  userInfo:nil
													   repeats:NO];
}	

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self cancelInitialTimer];
}

#pragma mark - Orientation methods

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar updateTheme:orientation];
    [self.view.layer setContents:(id)[[SCHThemeManager sharedThemeManager] imageForBackground:orientation].CGImage];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return(YES);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

#pragma mark - Accessor methods

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

#pragma mark - Action methods

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)showFlowView:(id)sender
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
    [readingController release], readingController = nil;
}

- (IBAction)showFixedView:(id)sender
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
    [readingController release], readingController = nil;
}

- (IBAction)tapBookCover:(id)sender
{
	[UIView beginAnimations:@"coverHide" context:nil];
	[UIView setAnimationDuration:0.15f];
	
	[bookCoverView setAlpha:0.0f];
    [optionsView setAlpha:1];
	
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

#pragma mark - Private methods

- (void)cancelInitialTimer
{
	if (self.initialFadeTimer && [self.initialFadeTimer isValid]) {
		[self.initialFadeTimer invalidate];
		self.initialFadeTimer = nil;
	}
}	

- (void)updateFavoriteDisplay
{
    if (self.profileItem == nil) {
        [self.favouriteButton setTitle:@"" forState:UIControlStateNormal]; 
        self.favouriteButton.hidden = YES;
    } else {
        BOOL favorite = [self.profileItem contentIdentifierFavorite:self.isbn];
        self.favouriteButton.tag = favorite;        
        self.favouriteButton.hidden = NO;
        if (favorite == NO) {
            [self.favouriteButton setTitle:NSLocalizedString(@"Add to Favorites", @"") 
                             forState:UIControlStateNormal];
        } else {
            [self.favouriteButton setTitle:NSLocalizedString(@"Remove from Favorites", @"") 
                             forState:UIControlStateNormal];            
        }
    }
}

@end
