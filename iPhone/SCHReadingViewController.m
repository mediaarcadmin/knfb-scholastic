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
#import "SCHFlowView.h"
#import "SCHLayoutView.h"
#import "SCHXPSProvider.h"
#import "SCHCustomNavigationBar.h"
#import "SCHCustomToolbar.h"


// constants
static const CGFloat kReadingViewStandardScrubHeight = 47.0f;
static const CGFloat kReadingViewBackButtonPadding = 7.0f;

#pragma mark - Class Extension

@interface SCHReadingViewController ()

// the page view, either fixed or flow
@property (nonatomic, retain) SCHReadingView *readingView;

// toolbars/nav bar visible/not visible
@property (readwrite) BOOL toolbarsVisible;

// timer used to fade toolbars out after a certain period of time
@property (nonatomic, retain) NSTimer *initialFadeTimer;

// smart zoom active/inactive
@property (readwrite) BOOL zoomActive;

// the first page that the view is currently showing
@property (readwrite) NSInteger currentPageIndex;

// XPS book data provider
@property (nonatomic, assign) SCHXPSProvider *xpsProvider;

// temporary flag to prevent nav bar from being positioned behind the status bar on rotation
@property (readwrite) BOOL currentlyRotating;

// the current font size index (of an array of font sizes provided by libEucalyptus)
@property (readwrite) int currentFontSizeIndex;

// the current paper type for the reading view
@property (readwrite) SCHReadingViewPaperType paperType;

-(void)releaseViewObjects;

-(void)toggleToolbarVisibility;
-(void)setToolbarVisibility: (BOOL) visibility animated: (BOOL) animated;
-(void)cancelInitialTimer;
-(void)adjustScrubberInfoViewHeightForImageSize: (CGSize) imageSize;

-(void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;


@end

#pragma mark - SCHReadingViewController

@implementation SCHReadingViewController

#pragma mark Object Synthesis

@synthesize isbn;
@synthesize flowView;
@synthesize readingView;
@synthesize youngerMode;
@synthesize toolbarsVisible;
@synthesize zoomActive;
@synthesize initialFadeTimer;
@synthesize currentPageIndex;
@synthesize xpsProvider;
@synthesize currentlyRotating;
@synthesize currentFontSizeIndex;
@synthesize paperType;

@synthesize optionsView;
@synthesize fontSegmentedControl;
@synthesize flowFixedSegmentedControl;
@synthesize paperTypeSegmentedControl;
@synthesize scrubberThumbImage;

@synthesize pageScrubber;
@synthesize scrubberInfoView;
@synthesize pageLabel;
@synthesize panSpeedLabel;

@synthesize titleLabel;
@synthesize leftBarButtonItemContainer;
@synthesize youngerRightBarButtonItemContainer;
@synthesize backButton;
@synthesize audioButton;
@synthesize zoomButton;
@synthesize scrubberToolbar;
@synthesize olderBottomToolbar;
@synthesize topShadow;
@synthesize bottomShadow;

#pragma mark - Dealloc and View Teardown

-(void)dealloc {
    [self releaseViewObjects];

    [xpsProvider release], xpsProvider = nil;
    [readingView release], readingView = nil;
    
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
    
    [super dealloc];
}

-(void)releaseViewObjects
{
    [titleLabel release], titleLabel = nil;
    [leftBarButtonItemContainer release], leftBarButtonItemContainer = nil;
    [youngerRightBarButtonItemContainer release], youngerRightBarButtonItemContainer = nil;
    [backButton release], backButton = nil;
    [audioButton release], audioButton = nil;
    [zoomButton release], zoomButton = nil;
    [scrubberToolbar release], scrubberToolbar = nil;
    [olderBottomToolbar release], olderBottomToolbar = nil;
    [topShadow release], topShadow = nil;
    [bottomShadow release], bottomShadow = nil;
    [pageScrubber release], pageScrubber = nil;
    [scrubberThumbImage release], scrubberThumbImage = nil;
    [scrubberInfoView release], scrubberInfoView = nil;
    [pageLabel release], pageLabel = nil;
    [panSpeedLabel release], panSpeedLabel = nil;
    [optionsView release], optionsView = nil;
    [fontSegmentedControl release], fontSegmentedControl = nil;
    [flowFixedSegmentedControl release], flowFixedSegmentedControl = nil;
    [paperTypeSegmentedControl release], paperTypeSegmentedControl = nil;
}

-(void)viewDidUnload {
    [super viewDidUnload];
    [self releaseViewObjects];
}

#pragma mark - Memory Warnings

-(void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // FIXME: pass along memory warning to reading views?
}




#pragma mark - Object Initialiser

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isbn:(NSString *)aIsbn
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.isbn = aIsbn;
        self.zoomActive = NO;
        self.currentlyRotating = NO;
    }
    return self;
}

#pragma mark - View Lifecycle

-(void)viewDidLoad {
    [super viewDidLoad];
	
	self.currentPageIndex = 1;
	self.toolbarsVisible = YES;
    self.xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
	
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
    
    NSLog(@"XPSCategory: %@", book.XPSCategory);
    
    if (self.flowView) {
        self.readingView = [[SCHFlowView alloc] initWithFrame:self.view.bounds isbn:self.isbn];
    } else {
        self.readingView = [[SCHLayoutView alloc] initWithFrame:self.view.bounds isbn:self.isbn]; 
    }
    
    self.readingView.delegate = self;

    // FIXME: this should be a stored preference
    self.currentFontSizeIndex = 2;
    [self.readingView setFontPointIndex:self.currentFontSizeIndex];
    
    if (self.flowView) {
        [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:0];
        [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:1];
        [self.flowFixedSegmentedControl setSelectedSegmentIndex:0];
    } else {
        [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:0];
        [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:1];
        [self.flowFixedSegmentedControl setSelectedSegmentIndex:1];
    }
    
    
    // FIXME: this should be a stored preference
    self.paperType = SCHReadingViewPaperTypeWhite;
    
    switch (self.paperType) {
        case SCHReadingViewPaperTypeWhite:
            [self.paperTypeSegmentedControl setSelectedSegmentIndex:0];
            break;
        case SCHReadingViewPaperTypeBlack:
            [self.paperTypeSegmentedControl setSelectedSegmentIndex:1];
            break;
        case SCHReadingViewPaperTypeSepia:
            [self.paperTypeSegmentedControl setSelectedSegmentIndex:2];
            break;
    }

    [self.readingView setPaperType:self.paperType];
    self.readingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    
    self.wantsFullScreenLayout = YES;
    self.navigationController.navigationBar.translucent = YES;
    
    [self.view addSubview:self.readingView];
    [self.view sendSubviewToBack:self.readingView];
    

	self.scrubberInfoView.layer.cornerRadius = 5.0f;
	self.scrubberInfoView.layer.masksToBounds = YES;
    
	[self setToolbarVisibility:YES animated:NO];
	
	self.initialFadeTimer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                             target:self
                                                           selector:@selector(hideToolbarsFromTimer)
                                                           userInfo:nil
                                                            repeats:NO];
	

    
    
    CGFloat containerHeight = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    
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
    
    if (self.youngerMode) {
        [self.olderBottomToolbar setAlpha:0];
    }
    
    [self.topShadow setImage:[[UIImage imageNamed:@"reading-view-iphone-top-shadow.png"] stretchableImageWithLeftCapWidth:15.0f topCapHeight:0]];
    
    [self.bottomShadow setImage:[[UIImage imageNamed:@"reading-view-iphone-bottom-shadow.png"] stretchableImageWithLeftCapWidth:15.0f topCapHeight:0]];
    
    CGRect bottomShadowFrame = self.bottomShadow.frame;

    if (self.youngerMode) {
        bottomShadowFrame.origin.y = CGRectGetMinY(self.scrubberToolbar.frame) - 
        CGRectGetHeight(bottomShadowFrame);
    } else {
        bottomShadowFrame.origin.y = CGRectGetMinY(self.olderBottomToolbar.frame) - 
        CGRectGetHeight(bottomShadowFrame);
    }
    self.bottomShadow.frame = bottomShadowFrame;
    
    NSString *localisedPageLabelText = NSLocalizedString(@"pageCountString", @"Page %d of %d");
    [self.pageLabel setText:[NSString stringWithFormat:localisedPageLabelText, self.currentPageIndex, [self.readingView pageCount]]];
    
    self.pageScrubber.delegate = self;
	self.pageScrubber.minimumValue = 1;
	self.pageScrubber.maximumValue = [self.readingView pageCount];
	self.pageScrubber.continuous = YES;
	self.pageScrubber.value = self.currentPageIndex;
	
}

-(void) viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
}


-(void) viewWillDisappear:(BOOL)animated
{
    [self cancelInitialTimer];
    [super viewWillDisappear:animated];
}

#pragma mark - Rotation

-(void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self.backButton setImage:[UIImage imageNamed:@"icon-books.png"] forState:UIControlStateNormal];
        
        [self.audioButton setImage:[UIImage imageNamed:@"icon-play.png"] forState:UIControlStateNormal];
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reading-view-portrait-top-bar.png"]];
        self.scrubberToolbar.backgroundImage = [UIImage imageNamed:@"reading-view-portrait-scrubber-bar.png"];
        self.olderBottomToolbar.backgroundImage = [UIImage imageNamed:@"reading-view-portrait-bottom-bar.png"];
        
        if (self.zoomActive) {
            [self.zoomButton setImage:[UIImage imageNamed:@"icon-magnify-active.png"] forState:UIControlStateNormal];
        } else {
            [self.zoomButton setImage:[UIImage imageNamed:@"icon-magnify.png"] forState:UIControlStateNormal];
        }
    } else {
        [self.backButton setImage:[UIImage imageNamed:@"icon-books-landscape.png"] forState:UIControlStateNormal];
        
        [self.audioButton setImage:[UIImage imageNamed:@"icon-play-landscape.png"] forState:UIControlStateNormal];
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reading-view-landscape-top-bar.png"]];
        self.scrubberToolbar.backgroundImage = [UIImage imageNamed:@"reading-view-landscape-scrubber-bar.png"];
        self.olderBottomToolbar.backgroundImage = [UIImage imageNamed:@"reading-view-landscape-bottom-bar.png"];
        
        if (self.zoomActive) {
            [self.zoomButton setImage:[UIImage imageNamed:@"icon-magnify-active-landscape.png"] forState:UIControlStateNormal];
        } else {
            [self.zoomButton setImage:[UIImage imageNamed:@"icon-magnify-landscape.png"] forState:UIControlStateNormal];
        }
    }    
    
    CGRect topShadowFrame = self.topShadow.frame;
    topShadowFrame.origin.y = CGRectGetMinY(self.navigationController.navigationBar.frame) + 
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar backgroundImage].size.height;
    self.topShadow.frame = topShadowFrame;
    
}

// Override to allow orientations other than the default portrait orientation.
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return YES;
}

-(void) didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.currentlyRotating = NO;
}

-(void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    self.currentlyRotating = YES;
    if ([self.scrubberInfoView superview]) {
        
        CGRect scrubFrame = self.scrubberInfoView.frame;
        
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
        
        
        if (!self.flowView && self.scrubberThumbImage) {
            
            int maxHeight = (self.view.frame.size.width - scrubberToolbar.frame.size.height - newNavBarHeight - kReadingViewStandardScrubHeight - 40);
            
            NSLog(@"Max height: %d", maxHeight);
            
            if (self.scrubberThumbImage.image.size.height > maxHeight) {
                self.scrubberThumbImage.contentMode = UIViewContentModeScaleAspectFit;
                scrubFrame.size.height = kReadingViewStandardScrubHeight + maxHeight;
            } else {
                self.scrubberThumbImage.contentMode = UIViewContentModeTop;
                scrubFrame.size.height = kReadingViewStandardScrubHeight + self.scrubberThumbImage.image.size.height + 20;
            }
            
            
            NSLog(@"Scrub frame height: %f", scrubFrame.size.height);
            
        } else {
            scrubFrame.size.height = kReadingViewStandardScrubHeight;
        }

        
        self.scrubberInfoView.frame = scrubFrame;
        
    }
    
    [self setupAssetsForOrientation:toInterfaceOrientation];
    
}

#pragma mark -
#pragma mark Button Actions

-(IBAction) popViewController: (id) sender
{
    self.navigationController.navigationBar.translucent = NO;
	[self.navigationController popViewControllerAnimated:YES];
}

-(IBAction) magnifyAction: (id) sender
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

        [self.readingView didExitSmartZoomMode];
    } else {
        self.zoomActive = YES;
        if (UIInterfaceOrientationIsPortrait([[UIApplication sharedApplication] statusBarOrientation]  )) {
            [button setImage:[UIImage imageNamed:@"icon-magnify-active"] forState:UIControlStateNormal];
        } else {
            [button setImage:[UIImage imageNamed:@"icon-magnify-active-landscape"] forState:UIControlStateNormal];
        }
        [self.readingView didEnterSmartZoomMode];
    }
    
}

-(IBAction) audioPlayAction: (id) sender
{
    NSLog(@"Audio Play action");
}

-(IBAction) storyInteractionAction: (id) sender
{
    NSLog(@"Story Interactions action");
}

-(IBAction) notesAction: (id) sender
{
    NSLog(@"Notes action");
}

-(IBAction) settingsAction: (id) sender
{
    NSLog(@"Settings action");
    [self cancelInitialTimer];
    
    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    } else {
        
        CGRect optionsFrame = self.optionsView.frame;
        optionsFrame.origin.x = 0;
        optionsFrame.origin.y = olderBottomToolbar.frame.origin.y - optionsFrame.size.height;
        
        optionsFrame.size.width = self.view.frame.size.width;
        self.optionsView.frame = optionsFrame;
        
        [self.view addSubview:self.optionsView];
    }
}

#pragma mark - Smart Zoom

-(IBAction)nextSmartZoom:(id)sender
{
    NSLog(@"Next");
    [self.readingView jumpToNextZoomBlock];
}

-(IBAction)prevSmartZoom:(id)sender
{
    NSLog(@"Previous");
    [self.readingView jumpToPreviousZoomBlock];
}

#pragma mark - Flowed/Fixed Toggle

-(IBAction) flowedFixedSegmentChanged: (UISegmentedControl *) segControl
{
    int selected = segControl.selectedSegmentIndex;
    
    if (selected == 0) {
        // flowed
        NSLog(@"Picking flowed view!");
        self.flowView = YES;
        [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:0];
        [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:1];
    } else {
        // fixed
        NSLog(@"Picking fixed view!");
        self.flowView = NO;
        [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:0];
        [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:1];
    }
    
    [self.readingView removeFromSuperview];
    self.readingView = nil;
    
    if (self.flowView) {
        self.readingView = [[SCHFlowView alloc] initWithFrame:self.view.bounds isbn:self.isbn];
    } else {
        self.readingView = [[SCHLayoutView alloc] initWithFrame:self.view.bounds isbn:self.isbn]; 
    }
    
    self.readingView.delegate = self;
    self.readingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.readingView jumpToPageAtIndex:self.currentPageIndex - 1 animated:NO];
    
    [self.view addSubview:self.readingView];
    [self.view sendSubviewToBack:self.readingView];
    [self.readingView setPaperType:self.paperType];
}

#pragma mark - Paper Type Toggle

-(IBAction) paperTypeSegmentChanged: (UISegmentedControl *) segControl
{
    int selected = segControl.selectedSegmentIndex;
    
    if (selected == 0) {
        // white
        [self.readingView setPaperType:SCHReadingViewPaperTypeWhite];
        self.paperType = SCHReadingViewPaperTypeWhite;
    } else if (selected == 1) {
        // black
        [self.readingView setPaperType:SCHReadingViewPaperTypeBlack];
        self.paperType = SCHReadingViewPaperTypeBlack;
    } else {
        // sepia
        [self.readingView setPaperType:SCHReadingViewPaperTypeSepia];
        self.paperType = SCHReadingViewPaperTypeSepia;
    }
    
}

#pragma mark - Font Size Toggle

-(IBAction) fontSizeSegmentPressed: (UISegmentedControl *) segControl
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
    
    if (index > [self.readingView maximumFontIndex]) {
        index = [self.readingView maximumFontIndex];
    }
    
    if (index < 0) {
        index = 0;
    }
    
    [self.readingView setFontPointIndex:index];
    self.currentFontSizeIndex = index;
    
    self.pageScrubber.minimumValue = 1;
	self.pageScrubber.maximumValue = [self.readingView pageCount];
	self.pageScrubber.continuous = YES;
	self.pageScrubber.value = self.currentPageIndex;

    
}


#pragma mark - SCHReadingViewDelegate methods

-(void)readingView:(SCHReadingView *)readingView hasMovedToPageAtIndex:(NSUInteger)pageIndex
{
    self.currentPageIndex = pageIndex + 1;
    [self.pageScrubber setValue:self.currentPageIndex];
    NSString *localisedPageLabelText = NSLocalizedString(@"pageCountString", @"Page %d of %d");
    [self.pageLabel setText:[NSString stringWithFormat:localisedPageLabelText, self.currentPageIndex, [self.readingView pageCount]]];

}

-(void) unhandledTouchOnPageForReadingView: (SCHReadingView *) readingView
{
    [self toggleToolbarVisibility];
}


-(void) adjustScrubberInfoViewHeightForImageSize: (CGSize) imageSize
{
    CGRect scrubFrame = self.scrubberInfoView.frame;
    scrubFrame.origin.x = self.view.bounds.size.width / 2 - (scrubFrame.size.width / 2);
    
    CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
    float statusBarHeight = MIN(statusFrame.size.height, statusFrame.size.width);
    
    scrubFrame.origin.y = statusBarHeight + self.navigationController.navigationBar.frame.size.height + 10;
    
    // if we're in fixed view, and there's an image size set, then check if we're showing an image
    if (!self.flowView && imageSize.width > 0 && imageSize.height > 0) {
        
        // the maximum space available for an image
        int maxImageHeight = (self.view.frame.size.height - scrubberToolbar.frame.size.height - self.navigationController.navigationBar.frame.size.height - kReadingViewStandardScrubHeight - 60);
        
        // if the double toolbar is visible, reduce available space
        if ([olderBottomToolbar superview]) {
            maxImageHeight -= olderBottomToolbar.frame.size.height;
        }
        
        // if the options view is also visible, reduce available space
        if ([self.optionsView superview]) {
            maxImageHeight -= self.optionsView.frame.size.height;
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
            scrubFrame.size.height = kReadingViewStandardScrubHeight;
        } else {
            // otherwise, set up the imageview and info frame to the correct height
            scrubFrame.size.height = kReadingViewStandardScrubHeight + desiredHeight;
            
            CGRect imageRect = self.scrubberThumbImage.frame;
            imageRect.size.height = desiredHeight - 10;
            self.scrubberThumbImage.frame = imageRect;
            
            scrubFrame.size.height = kReadingViewStandardScrubHeight + desiredHeight;
            
            if (scrubFrame.size.height < kReadingViewStandardScrubHeight) {
                scrubFrame.size.height = kReadingViewStandardScrubHeight;
            }
            
            NSLog(@"Scrub frame height: %f", scrubFrame.size.height);
        }
    } else {
        scrubFrame.size.height = kReadingViewStandardScrubHeight;
    }
    
    self.scrubberInfoView.frame = scrubFrame;
}


#pragma mark -
#pragma mark BITScrubberViewDelegate Methods

-(void) scrubberView:(BITScrubberView *)scrubberView scrubberValueUpdated:(float)currentValue
{
	if (scrubberView == self.pageScrubber) {
        NSLog(@"Current value is %d", (int) currentValue);
		self.currentPageIndex = (int) currentValue;
		
        NSString *localisedPageLabelText = NSLocalizedString(@"pageCountString", @"Page %d of %d");
        [self.pageLabel setText:[NSString stringWithFormat:localisedPageLabelText, self.currentPageIndex, [self.readingView pageCount]]];
        
        if (!self.flowView) {
            
            UIImage *scrubImage = [self.xpsProvider thumbnailForPage:self.currentPageIndex];
            
            if (self.scrubberInfoView.frame.size.height == kReadingViewStandardScrubHeight) {
                self.scrubberThumbImage.image = nil;
            } else {
                self.scrubberThumbImage.image = scrubImage;
            }
        } 
        
        [self adjustScrubberInfoViewHeightForImageSize:self.scrubberThumbImage.image.size];
        
	}
}

-(void) scrubberView:(BITScrubberView *)scrubberView beginScrubbingWithValue:(float)currentValue
{
    self.currentPageIndex = (int) currentValue;
    NSLog(@"Current value is %d", (int) currentValue);
    
    // add the scrub view here
    if (!self.flowView) {
        UIImage *scrubImage = [self.xpsProvider thumbnailForPage:self.currentPageIndex];
        self.scrubberThumbImage.image = scrubImage;
        [self adjustScrubberInfoViewHeightForImageSize:scrubImage.size];
    } else {
        [self adjustScrubberInfoViewHeightForImageSize:CGSizeZero];
        self.scrubberThumbImage.image = nil;
    }
    
    NSString *localisedPageLabelText = NSLocalizedString(@"pageCountString", @"Page %d of %d");
    [self.pageLabel setText:[NSString stringWithFormat:localisedPageLabelText, self.currentPageIndex, [self.readingView pageCount]]];
 

    [self.scrubberInfoView setAlpha:1.0f];

    [self.view addSubview:self.scrubberInfoView];
    
	[self cancelInitialTimer];
	
}

-(void) scrubberView:(BITScrubberView *)scrubberView endScrubbingWithValue:(float)currentValue
{
    self.currentPageIndex = (int) currentValue;

	[UIView animateWithDuration:0.3f 
                          delay:0.2f 
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState
                     animations:^{ 
                         [self.scrubberInfoView setAlpha:0.0f];
                     }
                     completion:^(BOOL finished){
                         [self.scrubberInfoView removeFromSuperview];
                     }
     ];
    
    NSLog(@"Turning to page %d", (int) currentValue);
    
    [self.readingView jumpToPageAtIndex:self.currentPageIndex - 1 animated:YES];
}

#pragma mark - Toolbar Methods - including timer

-(void) hideToolbarsFromTimer
{
	[self setToolbarVisibility:NO animated:YES];
	[self.initialFadeTimer invalidate];
	self.initialFadeTimer = nil;
}

-(void) setToolbarVisibility: (BOOL) visibility animated: (BOOL) animated
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
        [self.scrubberToolbar setAlpha:1.0f];
        if (!youngerMode) {
            [olderBottomToolbar setAlpha:1.0f];
        }
        [self.optionsView setAlpha:1.0f];
        [self.topShadow setAlpha:1.0f];   
        [self.bottomShadow setAlpha:1.0f];  
	} else {
        [self.navigationController.navigationBar setAlpha:0.0f];
        [self.scrubberToolbar setAlpha:0.0f];
        if (!youngerMode) {
            [olderBottomToolbar setAlpha:0.0f];
        }
        
        [self.optionsView setAlpha:0.0f];
        [self.topShadow setAlpha:0.0f];
        [self.bottomShadow setAlpha:0.0f];
	}
	
	if (animated) {
		[UIView commitAnimations];
	}
}

-(void) toggleToolbarVisibility
{
	NSLog(@"Toggling visibility.");
	[self setToolbarVisibility:!self.toolbarsVisible animated:YES];
}

-(void) cancelInitialTimer
{
	if (self.initialFadeTimer && [self.initialFadeTimer isValid]) {
		[self.initialFadeTimer invalidate];
		self.initialFadeTimer = nil;
	}
}	

@end
