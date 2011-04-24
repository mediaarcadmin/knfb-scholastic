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
#import "SCHThemeManager.h"
#import "SCHCustomNavigationBar.h"

static int STANDARD_SCRUB_INFO_HEIGHT = 47;

static const CGFloat kReadingViewBackButtonPadding = 7.0f;

@interface SCHReadingViewController ()

- (void) toggleToolbarVisibility;
- (void) setToolbarVisibility: (BOOL) visibility animated: (BOOL) animated;
- (void) cancelInitialTimer;
- (void) adjustScrubberInfoViewHeightForImageSize: (CGSize) imageSize;

- (IBAction) storyInteractionAction: (id) sender;
- (IBAction) notesAction: (id) sender;
- (IBAction) settingsAction: (id) sender;

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)releaseViewObjects;

@property (readwrite) BOOL toolbarsVisible;
@property (readwrite) BOOL zoomActive;
@property (nonatomic, retain) NSTimer *initialFadeTimer;
@property (readwrite) NSInteger currentPageIndex;
@property (nonatomic, assign) SCHXPSProvider *xpsProvider;
@property (readwrite) BOOL currentlyRotating;

@property (readwrite) int currentFontSizeIndex;
@property (readwrite) SCHReadingViewPaperType paperType;

@end

@implementation SCHReadingViewController

// FIXME: can we have one synthesize per line so that automatic merges are easy
@synthesize isbn, flowView, eucPageView, youngerMode;
@synthesize toolbarsVisible, zoomActive, initialFadeTimer, currentPageIndex, xpsProvider, currentlyRotating, currentFontSizeIndex, paperType;

@synthesize titleLabel;
@synthesize leftBarButtonItemContainer;
@synthesize youngerRightBarButtonItemContainer;
@synthesize backButton;
@synthesize audioButton;
@synthesize zoomButton;

#pragma mark - Memory Management

- (void)dealloc {
    
    [olderBottomToolbar release];
    [youngerBookTitleLabel release];
    [youngerBookTitleView release];
    [olderBookTitleLabel release];
    [olderBookTitleView release];
    [optionsView release];
    [fontSegmentedControl release];
    [flowFixedSegmentedControl release];
    [paperTypeSegmentedControl release];
    [scrubberThumbImage release];
    
    [self releaseViewObjects];
    [super dealloc];
}

// FIXME: release all nib or viewDidUnload retained objects here
// Have only added the ones I have added or amended myself
- (void)releaseViewObjects
{
    [titleLabel release], titleLabel = nil;
    [leftBarButtonItemContainer release], leftBarButtonItemContainer = nil;
    [youngerRightBarButtonItemContainer release], youngerRightBarButtonItemContainer = nil;
    [backButton release], backButton = nil;
    [audioButton release], audioButton = nil;
    [zoomButton release], zoomButton = nil;
}

- (void)viewDidUnload {
    // FIXME: this method does not get called on dealloc
    [olderBottomToolbar release];
    olderBottomToolbar = nil;
    [youngerBookTitleLabel release];
    youngerBookTitleLabel = nil;
    [youngerBookTitleView release];
    youngerBookTitleView = nil;
    [olderBookTitleLabel release];
    olderBookTitleLabel = nil;
    [olderBookTitleView release];
    olderBookTitleView = nil;
    [optionsView release];
    optionsView = nil;
    [fontSegmentedControl release];
    fontSegmentedControl = nil;
    [flowFixedSegmentedControl release];
    flowFixedSegmentedControl = nil;
    [paperTypeSegmentedControl release];
    paperTypeSegmentedControl = nil;
    [scrubberThumbImage release];
    scrubberThumbImage = nil;
    [super viewDidUnload];
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
    self.xpsProvider = nil;
    self.eucPageView = nil;
    
    [self releaseViewObjects];
}

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self.backButton setImage:[UIImage imageNamed:@"icon-books.png"] forState:UIControlStateNormal];
        
        [self.audioButton setImage:[UIImage imageNamed:@"icon-play.png"] forState:UIControlStateNormal];
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reading-view-portrait-top-bar.png"]];
        [scrubberToolbar setBackgroundWith:[UIImage imageNamed:@"reading-view-portrait-scrubber-bar.png"]];
        [olderBottomToolbar setBackgroundWith:[UIImage imageNamed:@"reading-view-portrait-bottom-bar.png"]];
        
        if (self.zoomActive) {
            [self.zoomButton setImage:[UIImage imageNamed:@"icon-magnify-active.png"] forState:UIControlStateNormal];
        } else {
            [self.zoomButton setImage:[UIImage imageNamed:@"icon-magnify.png"] forState:UIControlStateNormal];
        }
    } else {
        [self.backButton setImage:[UIImage imageNamed:@"icon-books-landscape.png"] forState:UIControlStateNormal];
        
        [self.audioButton setImage:[UIImage imageNamed:@"icon-play-landscape.png"] forState:UIControlStateNormal];
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reading-view-landscape-top-bar.png"]];
        [scrubberToolbar setBackgroundWith:[UIImage imageNamed:@"reading-view-landscape-scrubber-bar.png"]];
        [olderBottomToolbar setBackgroundWith:[UIImage imageNamed:@"reading-view-landscape-bottom-bar.png"]];
        
        if (self.zoomActive) {
            [self.zoomButton setImage:[UIImage imageNamed:@"icon-magnify-active-landscape.png"] forState:UIControlStateNormal];
        } else {
            [self.zoomButton setImage:[UIImage imageNamed:@"icon-magnify-landscape.png"] forState:UIControlStateNormal];
        }
    }
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
        self.zoomActive = NO;
        self.currentlyRotating = NO;
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.currentPageIndex = 0;
	toolbarsVisible = YES;
    self.xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
	
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
    
    NSLog(@"XPSCategory: %@", book.XPSCategory);
    
	pageScrubber.delegate = self;
	pageScrubber.minimumValue = 1;
	pageScrubber.maximumValue = [self.xpsProvider pageCount];
	pageScrubber.continuous = YES;
	pageScrubber.value = self.currentPageIndex + 1;
	
    // FIXME: localise this text and make sure we get it from the bookview so its pagination aware
    pageLabel.text = [NSString stringWithFormat:@"Page %d of %d", self.currentPageIndex, [self.xpsProvider pageCount] - 1];
    
    // FIXME: the variable eucPageView is confusingly named
    if (self.flowView) {
        self.eucPageView = [[SCHFlowView alloc] initWithFrame:self.view.bounds isbn:self.isbn];
    } else {
        self.eucPageView = [[SCHLayoutView alloc] initWithFrame:self.view.bounds isbn:self.isbn]; 
    }
    
    self.eucPageView.delegate = self;
    
    // FIXME: this should be a stored preference
    self.currentFontSizeIndex = 2;
    [self.eucPageView setFontPointIndex:self.currentFontSizeIndex];
    
    // FIXME: can we standardise access to sythesized ivars via properties except in init and dealloc
    if (self.flowView) {
        [fontSegmentedControl setEnabled:YES forSegmentAtIndex:0];
        [fontSegmentedControl setEnabled:YES forSegmentAtIndex:1];
        [flowFixedSegmentedControl setSelectedSegmentIndex:0];
    } else {
        [fontSegmentedControl setEnabled:NO forSegmentAtIndex:0];
        [fontSegmentedControl setEnabled:NO forSegmentAtIndex:1];
        [flowFixedSegmentedControl setSelectedSegmentIndex:1];
    }
    
    
    // FIXME: this should be a stored preference
    self.paperType = SCHReadingViewPaperTypeWhite;
    
    switch (self.paperType) {
        case SCHReadingViewPaperTypeWhite:
            [paperTypeSegmentedControl setSelectedSegmentIndex:0];
            break;
        case SCHReadingViewPaperTypeBlack:
            [paperTypeSegmentedControl setSelectedSegmentIndex:1];
            break;
        case SCHReadingViewPaperTypeSepia:
            [paperTypeSegmentedControl setSelectedSegmentIndex:2];
            break;
    }
    [self.eucPageView setPaperType:self.paperType];
    
    self.wantsFullScreenLayout = YES;
    self.navigationController.navigationBar.translucent = YES;
    
    [self.view addSubview:self.eucPageView];
    [self.view sendSubviewToBack:self.eucPageView];
    

	scrubberInfoView.layer.cornerRadius = 5.0f;
	scrubberInfoView.layer.masksToBounds = YES;
    
	[self setToolbarVisibility:YES animated:NO];
	
	self.initialFadeTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                             target:self
                                                           selector:@selector(hideToolbarsFromTimer)
                                                           userInfo:nil
                                                            repeats:NO];
	

    
    
    CGFloat containerHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    
    CGRect leftBarButtonItemFrame = self.leftBarButtonItemContainer.frame;
    leftBarButtonItemFrame.size.height = containerHeight;
    self.leftBarButtonItemContainer.frame = leftBarButtonItemFrame;
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.leftBarButtonItemContainer] autorelease];
    
    if (self.youngerMode) {
        CGRect rightBarButtonItemFrame = self.youngerRightBarButtonItemContainer.frame;
        rightBarButtonItemFrame.size.height = containerHeight;
        self.youngerRightBarButtonItemContainer.frame = rightBarButtonItemFrame;
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.youngerRightBarButtonItemContainer] autorelease];
    } else {
        self.navigationItem.rightBarButtonItem = nil;
    }
    
    self.titleLabel.text = book.Title;
    self.navigationItem.titleView = self.titleLabel;
}

- (void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    // FIXME: why here rather than in the viewDidLoad?
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

- (void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.currentlyRotating = NO;
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.currentlyRotating = YES;
    if ([scrubberInfoView superview]) {
        
        CGRect scrubFrame = scrubberInfoView.frame;
        
        CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
        float statusBarHeight = MIN(statusFrame.size.height, statusFrame.size.width);
        
        float newNavBarHeight = 44.0f;
        
        NSLog(@"Status bar height is currently %f", statusBarHeight);
        NSLog(@"Nav bar height is currently %f", self.navigationController.navigationBar.frame.size.height);
        
        if (newNavBarHeight == self.navigationController.navigationBar.frame.size.height) {
            newNavBarHeight = 32.0f;
        }
        
        scrubFrame.origin.x = self.view.bounds.size.width / 2 - (scrubFrame.size.width / 2);
        scrubFrame.origin.y = statusBarHeight + newNavBarHeight + 10;
        
        
        if (!self.flowView && scrubberThumbImage) {
            
            int maxHeight = (self.view.frame.size.width - scrubberToolbar.frame.size.height - newNavBarHeight - STANDARD_SCRUB_INFO_HEIGHT - 40);
            
            NSLog(@"Max height: %d", maxHeight);
            
            if (scrubberThumbImage.image.size.height > maxHeight) {
                scrubberThumbImage.contentMode = UIViewContentModeScaleAspectFit;
                scrubFrame.size.height = STANDARD_SCRUB_INFO_HEIGHT + maxHeight;
            } else {
                scrubberThumbImage.contentMode = UIViewContentModeTop;
                scrubFrame.size.height = STANDARD_SCRUB_INFO_HEIGHT + scrubberThumbImage.image.size.height + 20;
            }
            
            
            NSLog(@"Scrub frame height: %f", scrubFrame.size.height);
            
        } else {
            scrubFrame.size.height = STANDARD_SCRUB_INFO_HEIGHT;
        }

        
        scrubberInfoView.frame = scrubFrame;
        
    }
    
    [self setupAssetsForOrientation:toInterfaceOrientation];
    
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
    
    UIButton *button = (UIButton *) sender;
    
    if (self.zoomActive) {
        self.zoomActive = NO;
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]  )) {
            [button setImage:[UIImage imageNamed:@"icon-magnify"] forState:UIControlStateNormal];
        } else {
            [button setImage:[UIImage imageNamed:@"icon-magnify-landscape"] forState:UIControlStateNormal];
        }

        [self.eucPageView didExitSmartZoomMode];
    } else {
        self.zoomActive = YES;
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]  )) {
            [button setImage:[UIImage imageNamed:@"icon-magnify-active"] forState:UIControlStateNormal];
        } else {
            [button setImage:[UIImage imageNamed:@"icon-magnify-active-landscape"] forState:UIControlStateNormal];
        }
        [self.eucPageView didEnterSmartZoomMode];
    }
    
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
    [self cancelInitialTimer];
    
    if (optionsView.superview) {
        [optionsView removeFromSuperview];
    } else {
        
        CGRect optionsFrame = optionsView.frame;
        optionsFrame.origin.x = 0;
        optionsFrame.origin.y = olderBottomToolbar.frame.origin.y - optionsFrame.size.height;
        
        optionsFrame.size.width = self.view.frame.size.width;
        optionsView.frame = optionsFrame;
        
        [self.view addSubview:optionsView];
    }
}

#pragma mark - SCHReadingViewDelegate methods

- (void)readingView:(SCHReadingView *)readingView hasMovedToPageAtIndex:(NSUInteger)pageIndex
{
    self.currentPageIndex = pageIndex;
    [pageScrubber setValue:self.currentPageIndex + 1];
    pageLabel.text = [NSString stringWithFormat:@"Page %d of %d", self.currentPageIndex + 1, [self.xpsProvider pageCount]];
}

- (void) unhandledTouchOnPageForReadingView: (SCHReadingView *) readingView
{
    [self toggleToolbarVisibility];
}


- (void) adjustScrubberInfoViewHeightForImageSize: (CGSize) imageSize
{
    CGRect scrubFrame = scrubberInfoView.frame;
    scrubFrame.origin.x = self.view.bounds.size.width / 2 - (scrubFrame.size.width / 2);
    
    CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
    float statusBarHeight = MIN(statusFrame.size.height, statusFrame.size.width);
    
    scrubFrame.origin.y = statusBarHeight + self.navigationController.navigationBar.frame.size.height + 10;
    
    // if we're in fixed view, and there's an image size set, then check if we're showing an image
    if (!self.flowView && imageSize.width > 0 && imageSize.height > 0) {
        
        // the maximum space available for an image
        int maxImageHeight = (self.view.frame.size.height - scrubberToolbar.frame.size.height - self.navigationController.navigationBar.frame.size.height - STANDARD_SCRUB_INFO_HEIGHT - 60);
        
        // if the double toolbar is visible, reduce available space
        if ([olderBottomToolbar superview]) {
            maxImageHeight -= olderBottomToolbar.frame.size.height;
        }
        
        // if the options view is also visible, reduce available space
        if ([optionsView superview]) {
            maxImageHeight -= optionsView.frame.size.height;
        }
        
        // shrink the thumb image to 75% - thumb quality is not great
        int desiredHeight = (int) (imageSize.height * 0.75);
        
        // if we need more height than is available, scale to fit.
        if (desiredHeight > maxImageHeight) {
            desiredHeight = maxImageHeight;
        }
        
        NSLog(@"Max height: %d", maxImageHeight);
        NSLog(@"Desired height: %d", desiredHeight);

        // if there's not enough space to sensibly render the image, don't try - just go with the text
        if (maxImageHeight < 40) {
            scrubFrame.size.height = STANDARD_SCRUB_INFO_HEIGHT;
        } else {
            // otherwise, set up the imageview and info frame to the correct height
            scrubFrame.size.height = STANDARD_SCRUB_INFO_HEIGHT + desiredHeight;
            
            CGRect imageRect = scrubberThumbImage.frame;
            imageRect.size.height = desiredHeight - 10;
            scrubberThumbImage.frame = imageRect;
            
            scrubFrame.size.height = STANDARD_SCRUB_INFO_HEIGHT + desiredHeight;
            
            if (scrubFrame.size.height < STANDARD_SCRUB_INFO_HEIGHT) {
                scrubFrame.size.height = STANDARD_SCRUB_INFO_HEIGHT;
            }
            
            NSLog(@"Scrub frame height: %f", scrubFrame.size.height);
        }
    } else {
        scrubFrame.size.height = STANDARD_SCRUB_INFO_HEIGHT;
    }
    
    scrubberInfoView.frame = scrubFrame;
}


#pragma mark -
#pragma mark Scrubber Actions

- (void) scrubberView:(BITScrubberView *)scrubberView scrubberValueUpdated:(float)currentValue
{
	if (scrubberView == pageScrubber) {
        NSLog(@"Current value is %d", (int) currentValue);
		self.currentPageIndex = (int) currentValue;
		
		[pageLabel setText:[NSString stringWithFormat:@"Page %d of %d", self.currentPageIndex, [self.xpsProvider pageCount]]];
        
        if (!self.flowView) {
            
            UIImage *scrubImage = [self.xpsProvider thumbnailForPage:self.currentPageIndex];
            
            if (scrubberInfoView.frame.size.height == STANDARD_SCRUB_INFO_HEIGHT) {
                scrubberThumbImage.image = nil;
            } else {
                scrubberThumbImage.image = scrubImage;
            }
        } 
        
        [self adjustScrubberInfoViewHeightForImageSize:scrubberThumbImage.image.size];
        
	}
}

- (void) scrubberView:(BITScrubberView *)scrubberView beginScrubbingWithValue:(float)currentValue
{
    self.currentPageIndex = (int) currentValue;
    NSLog(@"Current value is %d", (int) currentValue);
    
    // add the scrub view here
    if (!self.flowView) {
        UIImage *scrubImage = [self.xpsProvider thumbnailForPage:self.currentPageIndex];
        scrubberThumbImage.image = scrubImage;
        [self adjustScrubberInfoViewHeightForImageSize:scrubImage.size];
    } else {
        [self adjustScrubberInfoViewHeightForImageSize:CGSizeZero];
        scrubberThumbImage.image = nil;
    }
    
    [pageLabel setText:[NSString stringWithFormat:@"Page %d of %d", self.currentPageIndex, [self.xpsProvider pageCount]]];
    

    [scrubberInfoView setAlpha:1.0f];

    [self.view addSubview:scrubberInfoView];
    
	[self cancelInitialTimer];
	
}

- (void) scrubberView:(BITScrubberView *)scrubberView endScrubbingWithValue:(float)currentValue
{
    self.currentPageIndex = (int) currentValue;

	[UIView animateWithDuration:0.3f 
                          delay:0.2f 
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{ 
                         [scrubberInfoView setAlpha:0.0f];
                     }
                     completion:^(BOOL finished){
                         [scrubberInfoView removeFromSuperview];
                     }
     ];
    
    NSLog(@"Turning to page %d", (int) currentValue);
    
    [self.eucPageView jumpToPageAtIndex:self.currentPageIndex - 1 animated:YES];
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

    if (!self.currentlyRotating) {
        CGRect navRect = self.navigationController.navigationBar.frame;
        if (navRect.origin.y == 0) {
            navRect.origin.y = 20;
            self.navigationController.navigationBar.frame = navRect;
        }
    }
    
    if (self.toolbarsVisible) {
		[[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
	}

	if (animated) {
		[UIView beginAnimations:@"toolbarFade" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationBeginsFromCurrentState:YES];
	}
	
	if (self.toolbarsVisible) {
        [self.navigationController.navigationBar setAlpha:1.0f];
        [scrubberToolbar setAlpha:1.0f];
        if (!youngerMode) {
            [olderBottomToolbar setAlpha:1.0f];
        }
        [optionsView setAlpha:1.0f];
	} else {
        [self.navigationController.navigationBar setAlpha:0.0f];
        [scrubberToolbar setAlpha:0.0f];
        if (!youngerMode) {
            [olderBottomToolbar setAlpha:0.0f];
        }
        
        [optionsView setAlpha:0.0f];
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
    [self.eucPageView jumpToNextZoomBlock];
}

- (IBAction)prevSmartZoom:(id)sender
{
    NSLog(@"Previous");
    [self.eucPageView jumpToPreviousZoomBlock];
}

#pragma mark - Flowed/Fixed Toggle

- (IBAction) flowedFixedSegmentChanged: (UISegmentedControl *) segControl
{
    int selected = segControl.selectedSegmentIndex;
    
    if (selected == 0) {
        // flowed
        NSLog(@"Picking flowed view!");
        self.flowView = YES;
        [fontSegmentedControl setEnabled:YES forSegmentAtIndex:0];
        [fontSegmentedControl setEnabled:YES forSegmentAtIndex:1];
    } else {
        // fixed
        NSLog(@"Picking fixed view!");
        self.flowView = NO;
        [fontSegmentedControl setEnabled:NO forSegmentAtIndex:0];
        [fontSegmentedControl setEnabled:NO forSegmentAtIndex:1];
    }
    
    [self.eucPageView removeFromSuperview];
    self.eucPageView = nil;
    
    if (self.flowView) {
        self.eucPageView = [[SCHFlowView alloc] initWithFrame:self.view.bounds isbn:self.isbn];
    } else {
        self.eucPageView = [[SCHLayoutView alloc] initWithFrame:self.view.bounds isbn:self.isbn]; 
    }
    
    self.eucPageView.delegate = self;
    self.eucPageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.eucPageView jumpToPageAtIndex:self.currentPageIndex - 1 animated:NO];
    
    [self.view addSubview:self.eucPageView];
    [self.view sendSubviewToBack:self.eucPageView];
    [self.eucPageView setPaperType:self.paperType];
}

#pragma mark - Paper Type Toggle

- (IBAction) paperTypeSegmentChanged: (UISegmentedControl *) segControl
{
    int selected = segControl.selectedSegmentIndex;
    
    if (selected == 0) {
        // white
        [self.eucPageView setPaperType:SCHReadingViewPaperTypeWhite];
        self.paperType = SCHReadingViewPaperTypeWhite;
    } else if (selected == 1) {
        // black
        [self.eucPageView setPaperType:SCHReadingViewPaperTypeBlack];
        self.paperType = SCHReadingViewPaperTypeBlack;
    } else {
        // sepia
        [self.eucPageView setPaperType:SCHReadingViewPaperTypeSepia];
        self.paperType = SCHReadingViewPaperTypeSepia;
    }
    
}

#pragma mark - Font Size Toggle

- (IBAction) fontSizeSegmentPressed: (UISegmentedControl *) segControl
{
    int selected = segControl.selectedSegmentIndex;
    
    int index = self.currentFontSizeIndex;
    
    if (selected == 0) {
        // decrease font size
        index--;
    } else {
        // increase font size
        index++;
    }
    
    if (index > [self.eucPageView maximumFontIndex]) {
        index = [self.eucPageView maximumFontIndex];
    }
    
    if (index < 0) {
        index = 0;
    }
    
    [self.eucPageView setFontPointIndex:index];
    self.currentFontSizeIndex = index;
    
}


@end
