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

@implementation BITReadingOptionsView
@synthesize pageViewController;
@synthesize isbn;
@synthesize thumbnailImage;
@synthesize profileItem;

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
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[[SCHThemeManager sharedThemeManager] imageForBooksIcon] forState:UIControlStateNormal];
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
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	self.navigationController.navigationBarHidden = NO;
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];	
    [self.navigationController.navigationBar setBarStyle:UIBarStyleDefault];
	NSLog(@"Item: %@", self.isbn);
	
	if (self.thumbnailImage) {
		[coverImageView setImage:self.thumbnailImage];
	}
	
//	titleLabel.text = [NSString stringWithFormat:@"%@", metadataItem.Title];
//	authorLabel.text = [NSString stringWithFormat:@"Author: %@", metadataItem.Author];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

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

- (void) cancelInitialTimer
{
	if (initialFadeTimer && [initialFadeTimer isValid]) {
		[initialFadeTimer invalidate];
		initialFadeTimer = nil;
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
}


- (void)dealloc {
    [super dealloc];
}


@end
