//
//  BWKReadingOptionsView.m
//  XPSRenderer
//
//  Created by Gordon Christie on 13/01/2011.
//  Copyright 2011 Chillypea. All rights reserved.
//

#import "BWKReadingOptionsView.h"


@implementation BWKReadingOptionsView
@synthesize pageViewController;
@synthesize metadataItem;
@synthesize thumbnailImage;

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

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

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
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];	
	NSLog(@"Item: %@", metadataItem);
	
	if (self.thumbnailImage) {
		[coverImageView setImage:self.thumbnailImage];
	}
	
//	titleLabel.text = [NSString stringWithFormat:@"%@", metadataItem.Title];
//	authorLabel.text = [NSString stringWithFormat:@"Author: %@", metadataItem.Author];
}


- (IBAction) showBookView: (id) sender
{
	[self.navigationController pushViewController:pageViewController animated:YES];
}

- (IBAction) showBookViewAtStart: (id) sender
{
	[pageViewController goToFirstPage];
	[self.navigationController pushViewController:pageViewController animated:YES];
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
