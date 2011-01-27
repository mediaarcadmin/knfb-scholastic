//
//  BWKTestPageViewController.m
//  XPSRenderer
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010 Chillypea. All rights reserved.
//

#import "BWKTestPageViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation BWKTestPageViewController

@synthesize xpsPath;

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
	
	currentPage = 1;
	toolbarsVisible = YES;
	testRenderer = [[BWKXPSProvider alloc] initWithPath:self.xpsPath];
	
	pageScrubber.delegate = self;
	pageScrubber.minimumValue = 1;
	pageScrubber.maximumValue = [testRenderer pageCount];
//	pageScrubber.maximumValue = 3;
	pageScrubber.continuous = YES;
	pageScrubber.value = currentPage;
	
	panSpeedLabel.text = @"";
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self loadImageForCurrentPage];
	
	scrubberInfoView.layer.cornerRadius = 5.0f;
	scrubberInfoView.layer.masksToBounds = YES;

	[self setToolbarVisibility:YES animated:NO];
	
	initialFadeTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
														target:self
													  selector:@selector(hideToolbarsFromTimer)
													  userInfo:nil
													   repeats:NO];
	
	self.navigationController.navigationBarHidden = YES;
	
	UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
																				 action:@selector(scrollViewSingleTap:)];
	tapGesture.numberOfTapsRequired = 1;
	tapGesture.cancelsTouchesInView = YES;
	
	[scrollView addGestureRecognizer:tapGesture];
	[tapGesture release];
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}


#pragma mark -
#pragma mark Button Actions

- (IBAction) backAction: (id) sender
{
	[self cancelInitialTimer];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) previousPage: (id) sender
{
	if (currentPage > 1) {
		currentPage--;
		[pageScrubber setValue:currentPage];
		[self loadImageForCurrentPage];
	}
}

- (IBAction) nextPage: (id) sender
{
	if (currentPage < [testRenderer pageCount]) {
		currentPage++;
		[pageScrubber setValue:currentPage];
		[self loadImageForCurrentPage];
	}
}

- (void) checkButtonStatus
{
	if (currentPage == 1) {
		[previousButton setEnabled:NO];
	} else {
		[previousButton setEnabled:YES];
	}
	
	if (currentPage >= [testRenderer pageCount]) {
		[nextButton setEnabled:NO];
	} else {
		[nextButton setEnabled:YES];
	}
}

#pragma mark -
#pragma mark Scrubber Actions

- (void) scrubberView:(BWKScrubberView *)scrubberView scrubberValueUpdated:(float)currentValue
{
	if (scrubberView == pageScrubber) {
		currentPage = (int) currentValue;
		
		switch (scrubberView.scrubSpeed) {
			case kBWKScrubberScrubSpeedNormal:
				panSpeedLabel.text = @"Hi-speed Scrubbing";
				break;
			case kBWKScrubberScrubSpeedHalf:
				panSpeedLabel.text = @"Half Speed Scrubbing";
				break;
			case kBWKScrubberScrubSpeedQuarter:
				panSpeedLabel.text = @"Slow Scrubbing";
				break;
			default:
				break;
		}
		
		[self loadImageForCurrentPage];
	}
}

- (void) scrubberView:(BWKScrubberView *)scrubberView beginScrubbingWithValue:(float)currentValue
{
	NSLog(@"Starting changes...");
	[scrubberInfoView setAlpha:1.0f];
}

- (void) scrubberView:(BWKScrubberView *)scrubberView endScrubbingWithValue:(float)currentValue
{
	NSLog(@"Ending changes...");
	[UIView beginAnimations:@"scrubHide" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelay:0.2f];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[scrubberInfoView setAlpha:0.0f];
	[UIView commitAnimations];
}


- (void) loadImageForCurrentPage
{
	[self cancelInitialTimer];

	id context;
	UIView *oldImageView = [pageView viewWithTag:9999];
	
	if (oldImageView) {
		[oldImageView removeFromSuperview];
	}
	
	CGRect pageCrop = [testRenderer cropForPage:currentPage allowEstimate:YES];
	CGContextRef bitmap = [testRenderer RGBABitmapContextForPage:currentPage fromRect:pageCrop minSize:CGSizeMake(pageCrop.size.width, pageCrop.size.height) getContext:&context];
	CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    UIImage* result = [UIImage imageWithCGImage:ref];
	CGImageRelease(ref);
	UIImageView *imageView = [[UIImageView alloc] initWithImage:result];
	imageView.tag = 9999;
	
	[pageView setFrame:CGRectMake(0, 0, imageView.frame.size.width, imageView.frame.size.height)];
	[pageView addSubview:imageView];
	[imageView release];
	
	[scrollView setContentSize: CGSizeMake(imageView.bounds.size.width, imageView.bounds.size.height)];
	
	[pageLabel setText:[NSString stringWithFormat:@"Page %d of %d", currentPage, [testRenderer pageCount]]];
	//[scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
	
	//[pageSlider setValue:currentPage];
	//[pageScrubber setValue:currentPage];
	
	[self checkButtonStatus];
}	


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return pageView;
}

- (void) scrollViewSingleTap: (id) sender
{
	[self cancelInitialTimer];
	[self toggleToolbarVisibility];
}

- (void) hideToolbarsFromTimer
{
	[self setToolbarVisibility:NO animated:YES];
	[initialFadeTimer invalidate];
	initialFadeTimer = nil;
}

- (void) setToolbarVisibility: (BOOL) visibility animated: (BOOL) animated
{
	NSLog(@"Setting visibility to %@.", visibility?@"True":@"False");
	toolbarsVisible = visibility;
	
	if (animated) {
		[UIView beginAnimations:@"toolbarFade" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
		[UIView setAnimationDuration:0.25f];
		[UIView setAnimationBeginsFromCurrentState:YES];
	}
	
	if (toolbarsVisible) {
		[topToolbar setAlpha:1.0f];
		[bottomToolbar setAlpha:1.0f];
		[scrollView setContentInset:UIEdgeInsetsMake(44, 0, 0, 0)];
		[scrollView setContentOffset:CGPointMake(scrollView.contentOffset.x, scrollView.contentOffset.y - 44)];
	} else {
		[topToolbar setAlpha:0.0f];
		[bottomToolbar setAlpha:0.0f];
		[scrollView setContentInset:UIEdgeInsetsMake(0, 0, 0, 0)];
	}
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void) toggleToolbarVisibility
{
	NSLog(@"Toggling visibility.");
	[self setToolbarVisibility:!toolbarsVisible animated:YES];
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
