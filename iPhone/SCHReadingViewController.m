//
//  SCHReadingViewController.m
//  Scholastic
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010-2011 BitWink Limited. All rights reserved.
//

#import "SCHReadingViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SCHAppBook.h"
#import "SCHBookManager.h"
#import "KNFBTextFlowPageRange.h"
#import "SCHDictionaryManager.h"
#import "SCHFlowView.h"
#import "SCHLayoutView.h"
#import "SCHXPSProvider.h"


@interface SCHReadingViewController ()

- (void) toggleToolbarVisibility;
- (void) setToolbarVisibility: (BOOL) visibility animated: (BOOL) animated;
- (void) cancelInitialTimer;

- (IBAction) popViewController: (id) sender;
- (IBAction) magnifyAction: (id) sender;
- (IBAction) audioPlayAction: (id) sender;
- (IBAction) storyInteractionAction: (id) sender;
- (IBAction) notesAction: (id) sender;
- (IBAction) settingsAction: (id) sender;

@property (readwrite) BOOL toolbarsVisible;
@property (readwrite, retain) NSArray *currentToolbars;
@property (nonatomic, retain) NSTimer *initialFadeTimer;
@property (readwrite) NSInteger currentPage;
@property (nonatomic, assign) SCHXPSProvider *xpsProvider;

@end

@implementation SCHReadingViewController

@synthesize isbn, flowView, eucPageView, youngerMode;
@synthesize toolbarsVisible, initialFadeTimer, currentPage, xpsProvider, currentToolbars;

#pragma mark - Memory Management

- (void)dealloc {
    
    [youngerBookTitle release];
    [olderBookTitle release];
    [youngerTopToolbar release];
    [olderTopToolbar release];
    [olderBottomToolbar release];
    [super dealloc];
}

- (void)viewDidUnload {
    [youngerBookTitle release];
    youngerBookTitle = nil;
    [olderBookTitle release];
    olderBookTitle = nil;
    [youngerTopToolbar release];
    youngerTopToolbar = nil;
    [olderTopToolbar release];
    olderTopToolbar = nil;
    [olderBottomToolbar release];
    olderBottomToolbar = nil;
    [super viewDidUnload];
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
    self.xpsProvider = nil;
    self.eucPageView = nil;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // FIXME: pass along memory warning to reading views?
}


#pragma mark - Object Initialiser

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isbn:(NSString *)aIsbn
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isbn = aIsbn;
        self.wantsFullScreenLayout = YES;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.currentPage = 1;
	toolbarsVisible = YES;
    self.xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
	
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
    
    NSLog(@"XPSCategory: %@", book.XPSCategory);

    // FIXME: mode settings should be done based on bookshelf
    if (!book.XPSCategory ||
        ([book.XPSCategory compare:@"YoungerReader"] == NSOrderedSame) ||
        ([book.XPSCategory compare:@"YoungReader"] == NSOrderedSame) ) {
        self.youngerMode = YES;
    } else {
        self.youngerMode = NO;
    }
    

    
    youngerBookTitle.title = book.Title;
    olderBookTitle.title = book.Title;
    
	pageScrubber.delegate = self;
	pageScrubber.minimumValue = 1;
	pageScrubber.maximumValue = [self.xpsProvider pageCount];
	pageScrubber.continuous = YES;
	pageScrubber.value = self.currentPage;
	
    panSpeedLabel.text = @"Hi-speed Scrubbing";
    pageLabel.text = [NSString stringWithFormat:@"Page %d of %d", self.currentPage, [self.xpsProvider pageCount]];
    
    if (self.flowView) {
        self.eucPageView = [[SCHFlowView alloc] initWithFrame:self.view.bounds isbn:self.isbn];
    } else {
        self.eucPageView = [[SCHLayoutView alloc] initWithFrame:self.view.bounds isbn:self.isbn]; 
    }
    
    self.eucPageView.delegate = self;
    
    
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	scrubberInfoView.layer.cornerRadius = 5.0f;
	scrubberInfoView.layer.masksToBounds = YES;

	[self setToolbarVisibility:YES animated:NO];
	
	self.initialFadeTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
														target:self
													  selector:@selector(hideToolbarsFromTimer)
													  userInfo:nil
													   repeats:NO];
	
	self.navigationController.navigationBarHidden = YES;

	[[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackTranslucent];	
	
    if (youngerMode) {
        CGRect frame = youngerTopToolbar.frame;
        frame.origin.y = 20;
        youngerTopToolbar.frame = frame;
        [self.view addSubview:youngerTopToolbar];
        
        self.currentToolbars = [NSArray arrayWithObjects:youngerTopToolbar, scrubberToolbar, nil];
    } else {
        CGRect frame = olderTopToolbar.frame;
        frame.origin.y = 20;
        olderTopToolbar.frame = frame;
        [self.view addSubview:olderTopToolbar];
        
        frame = olderBottomToolbar.frame;
        frame.origin.y = CGRectGetMinY(scrubberToolbar.frame) - CGRectGetHeight(olderBottomToolbar.frame);
        olderBottomToolbar.frame = frame;
        [self.view addSubview:olderBottomToolbar];

        self.currentToolbars = [NSArray arrayWithObjects:olderTopToolbar, olderBottomToolbar, scrubberToolbar, nil];
    }
        
    [self.view addSubview:self.eucPageView];
    [self.view sendSubviewToBack:self.eucPageView];
    
    [scrubberToolbar setBackgroundWith:[UIImage imageNamed:@"ReadingCustomToolbarBGAlpha"]];
    [youngerTopToolbar setBackgroundWith:[UIImage imageNamed:@"ReadingCustomToolbarBGAlpha"]];
    [olderTopToolbar setBackgroundWith:[UIImage imageNamed:@"ReadingCustomToolbarBGAlpha"]];
    [olderBottomToolbar setBackgroundWith:[UIImage imageNamed:@"ReadingCustomToolbarBGAlpha"]];

}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.eucPageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}

- (void) viewWillDisappear:(BOOL)animated
{
    [self cancelInitialTimer];
    [super viewWillDisappear:animated];
}

#pragma mark - Rotation

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [UIView beginAnimations:@"titleWidthAnimation" context:nil];
    [UIView setAnimationDuration:duration];
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        youngerBookTitle.width = 110.0f;
        olderBookTitle.width = 150.0f;
    } else {
        youngerBookTitle.width = 320.0f;
        olderBookTitle.width = 370.0f;
    }
    [UIView commitAnimations];
}

#pragma mark -
#pragma mark Button Actions

- (IBAction) popViewController: (id) sender
{
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction) magnifyAction: (id) sender
{
    NSLog(@"Magnify action");
}

- (IBAction) audioPlayAction: (id) sender
{
    NSLog(@"Audio Play action");
}

- (IBAction) storyInteractionAction: (id) sender
{
    NSLog(@"Story Interactions action");
}

- (IBAction) notesAction: (id) sender
{
    NSLog(@"Notes action");
}

- (IBAction) settingsAction: (id) sender
{
    NSLog(@"Settings action");
}

#pragma mark - SCHReadingViewDelegate methods

- (void) readingView: (SCHReadingView *) readingView hasMovedToPage: (NSInteger) page
{
    self.currentPage = page;
    [pageScrubber setValue:self.currentPage];
    pageLabel.text = [NSString stringWithFormat:@"Page %d of %d", self.currentPage, [self.xpsProvider pageCount]];
}

- (void) unhandledTouchOnPageForReadingView: (SCHReadingView *) readingView
{
    [self toggleToolbarVisibility];
}

#pragma mark -
#pragma mark Scrubber Actions

- (void) scrubberView:(BITScrubberView *)scrubberView scrubberValueUpdated:(float)currentValue
{
	if (scrubberView == pageScrubber) {
		self.currentPage = (int) currentValue;
		
		switch (scrubberView.scrubSpeed) {
			case kBITScrubberScrubSpeedNormal:
				panSpeedLabel.text = @"Hi-speed Scrubbing";
				break;
			case kBITScrubberScrubSpeedHalf:
				panSpeedLabel.text = @"Half Speed Scrubbing";
				break;
			case kBITScrubberScrubSpeedQuarter:
				panSpeedLabel.text = @"Slow Scrubbing";
				break;
			default:
				break;
		}

		[pageLabel setText:[NSString stringWithFormat:@"Page %d of %d", self.currentPage, [self.xpsProvider pageCount]]];
	}
}

- (void) scrubberView:(BITScrubberView *)scrubberView beginScrubbingWithValue:(float)currentValue
{
	NSLog(@"Starting changes...");
	[scrubberInfoView setAlpha:1.0f];
	[self cancelInitialTimer];
	
}

- (void) scrubberView:(BITScrubberView *)scrubberView endScrubbingWithValue:(float)currentValue
{
	NSLog(@"Ending changes...");
	[UIView beginAnimations:@"scrubHide" context:nil];
	[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
	[UIView setAnimationDelay:0.2f];
	[UIView setAnimationBeginsFromCurrentState:YES];
	[scrubberInfoView setAlpha:0.0f];
	[UIView commitAnimations];
	
    [self.eucPageView jumpToPage:self.currentPage animated:YES];
}

#pragma mark - Toolbar Methods - including timer

- (void) hideToolbarsFromTimer
{
	[self setToolbarVisibility:NO animated:YES];
	[self.initialFadeTimer invalidate];
	self.initialFadeTimer = nil;
}

- (void) setToolbarVisibility: (BOOL) visibility animated: (BOOL) animated
{
	NSLog(@"Setting visibility to %@.", visibility?@"True":@"False");
	self.toolbarsVisible = visibility;
	
	if (animated) {
		[UIView beginAnimations:@"toolbarFade" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationBeginsFromCurrentState:YES];
	}
	
	if (self.toolbarsVisible) {
        for (UIToolbar *toolbar in self.currentToolbars) {
            [toolbar setAlpha:1.0f];
        }
        
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	} else {
        for (UIToolbar *toolbar in self.currentToolbars) {
            [toolbar setAlpha:0.0f];
        }
        
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	}
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void) toggleToolbarVisibility
{
	NSLog(@"Toggling visibility.");
	[self setToolbarVisibility:!self.toolbarsVisible animated:YES];
}

- (void) cancelInitialTimer
{
	if (self.initialFadeTimer && [self.initialFadeTimer isValid]) {
		[self.initialFadeTimer invalidate];
		self.initialFadeTimer = nil;
	}
}	

#pragma mark - Smart Zoom

- (IBAction)nextSmartZoom:(id)sender
{
    NSLog(@"Next");
}

- (IBAction)prevSmartZoom:(id)sender
{
    NSLog(@"Previous");
}

@end
