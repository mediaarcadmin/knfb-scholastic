//
//  BWKTestPageViewController.m
//  XPSRenderer
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import "BWKTestPageViewController.h"
#import <QuartzCore/QuartzCore.h>

@implementation BWKTestPageViewController

@synthesize bookInfo;

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
	testRenderer = [[BWKXPSProvider alloc] initWithBookInfo:self.bookInfo];
	
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
	
	UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
																					   action:@selector(scrollViewDoubleTap:)];
	doubleTapGesture.numberOfTapsRequired = 2;
	doubleTapGesture.cancelsTouchesInView = YES;
	[scrollView addGestureRecognizer:doubleTapGesture];
	
	UITapGestureRecognizer *singleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self
																				 action:@selector(scrollViewSingleTap:)];
	singleTapGesture.numberOfTapsRequired = 1;
	singleTapGesture.cancelsTouchesInView = YES;
	[singleTapGesture requireGestureRecognizerToFail:doubleTapGesture];
	
	[scrollView addGestureRecognizer:singleTapGesture];

	[doubleTapGesture release];
	[singleTapGesture release];
	
	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];	
	[self setWantsFullScreenLayout:YES];
	CGRect frame = topToolbar.frame;
	frame.origin.y = 20;
	topToolbar.frame = frame;
	
	
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
		
		if (sender) {
			[self cancelInitialTimer];
		}
		
		[self loadImageForCurrentPage];
	}
}

- (IBAction) nextPage: (id) sender
{
	if (currentPage < [testRenderer pageCount]) {
		currentPage++;
		[pageScrubber setValue:currentPage];

		if (sender) {
			[self cancelInitialTimer];
		}
		
		[self loadImageForCurrentPage];
	}
}

- (void) goToFirstPage;
{
	currentPage = 1;
	[pageScrubber setValue:currentPage];
	[self loadImageForCurrentPage];
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

		[pageLabel setText:[NSString stringWithFormat:@"Page %d of %d", currentPage, [testRenderer pageCount]]];
	}
}

- (void) scrubberView:(BWKScrubberView *)scrubberView beginScrubbingWithValue:(float)currentValue
{
	NSLog(@"Starting changes...");
	[scrubberInfoView setAlpha:1.0f];
	[self cancelInitialTimer];
	
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
	
	[self loadImageForCurrentPage];
	
}


- (void) loadImageForCurrentPage
{
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
	
	//[scrollView scrollRectToVisible:CGRectMake(0, 0, 1, 1) animated:NO];
	
	//[pageSlider setValue:currentPage];
	//[pageScrubber setValue:currentPage];
	
	[self checkButtonStatus];
}	


- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
	return pageView;
}

- (void) scrollViewSingleTap: (UIGestureRecognizer *)gestureRecognizer
{
	if ([gestureRecognizer numberOfTouches] == 1) {
		
		if ([gestureRecognizer locationInView:self.view].x < TESTPAGEVIEW_PAGETAPWIDTH) {
			[self previousPage:nil];
		} else if ([gestureRecognizer locationInView:self.view].x > (self.view.frame.size.width - TESTPAGEVIEW_PAGETAPWIDTH)) {
			[self nextPage:nil];
		} else {
			[self toggleToolbarVisibility];
			[self cancelInitialTimer];
		}
	}
}

- (void) scrollViewDoubleTap: (UIGestureRecognizer *)gestureRecognizer
{
//	[self cancelInitialTimer];
	
	if ([gestureRecognizer numberOfTouches] == 1) {
		
		NSLog(@"Scrollview zoom: %f", scrollView.zoomScale);
		
		if (scrollView.zoomScale > scrollView.minimumZoomScale) {
			[scrollView setZoomScale:scrollView.minimumZoomScale animated:YES];
		} else {
			[scrollView setZoomScale:scrollView.maximumZoomScale animated:YES];
		}
		
	}
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
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationBeginsFromCurrentState:YES];
	}
	
	if (toolbarsVisible) {
		[topToolbar setAlpha:1.0f];
		[bottomToolbar setAlpha:1.0f];
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	} else {
		[topToolbar setAlpha:0.0f];
		[bottomToolbar setAlpha:0.0f];
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
//		CGRect frame = topToolbar.frame;
//		frame.origin.y = 0;
//		topToolbar.frame = frame;
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
