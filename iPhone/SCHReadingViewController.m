//
//  SCHReadingViewController.m
//  Scholastic
//
//  Created by Gordon Christie on 20/12/2010.
//  Copyright 2010-2011 BitWink Limited. All rights reserved.
//

#import "SCHReadingViewController.h"

#import "SCHAppBook.h"
#import "SCHAppProfile.h"
#import "SCHBookManager.h"
#import "SCHFlowView.h"
#import "SCHLayoutView.h"
#import "SCHXPSProvider.h"
#import "SCHCustomNavigationBar.h"
#import "SCHCustomToolbar.h"
#import "SCHReadingNotesViewController.h"
#import "SCHSyncManager.h"
#import "SCHProfileItem.h"
#import "SCHBookPoint.h"

// constants
static const CGFloat kReadingViewStandardScrubHeight = 47.0f;
static const CGFloat kReadingViewBackButtonPadding = 7.0f;

#pragma mark - Class Extension

@interface SCHReadingViewController ()

@property (nonatomic, copy) NSString *isbn;

@property (nonatomic, retain) SCHProfileItem *profile;

// the page view, either fixed or flow
@property (nonatomic, retain) SCHReadingView *readingView;

// toolbars/nav bar visible/not visible
@property (nonatomic, assign) BOOL toolbarsVisible;

// timer used to fade toolbars out after a certain period of time
@property (nonatomic, retain) NSTimer *initialFadeTimer;

// the first page that the view is currently showing
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, assign) CGFloat currentBookProgress;

// XPS book data provider
@property (nonatomic, retain) SCHXPSProvider *xpsProvider;

// temporary flag to prevent nav bar from being positioned behind the status bar on rotation
@property (nonatomic, assign) BOOL currentlyRotating;

// temporary flag to prevent the UISlider sending change event before start and end events
@property (nonatomic) BOOL currentlyScrubbing;

// the current font size index (of an array of font sizes provided by libEucalyptus)
@property (nonatomic, assign) int currentFontSizeIndex;

@property (nonatomic, assign) SCHReadingViewPaperType paperType;
@property (nonatomic, assign) SCHReadingViewLayoutType layoutType;

- (void)releaseViewObjects;

- (void)toggleToolbarVisibility;
- (void)setToolbarVisibility:(BOOL)visibility animated:(BOOL)animated;
- (void)cancelInitialTimer;
- (void)adjustScrubberInfoViewHeightForImageSize:(CGSize)imageSize;
- (void)updateScrubberValue;
- (void)updateScrubberLabel;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)saveLastPageLocation;
- (void)jumpToLastPageLocation;
- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated; 
- (void)jumpToCurrentPlaceInBookAnimated:(BOOL)animated;

@end

#pragma mark - SCHReadingViewController

@implementation SCHReadingViewController

#pragma mark Object Synthesis

@synthesize isbn;
@synthesize profile;
@synthesize readingView;
@synthesize youngerMode;
@synthesize toolbarsVisible;
@synthesize initialFadeTimer;
@synthesize currentPageIndex;
@synthesize currentBookProgress;
@synthesize xpsProvider;
@synthesize currentlyRotating;
@synthesize currentlyScrubbing;
@synthesize currentFontSizeIndex;
@synthesize paperType;
@synthesize layoutType;

@synthesize optionsView;
@synthesize fontSegmentedControl;
@synthesize flowFixedSegmentedControl;
@synthesize paperTypeSegmentedControl;
@synthesize pageSlider;
@synthesize scrubberThumbImage;

@synthesize scrubberInfoView;
@synthesize pageLabel;
@synthesize panSpeedLabel;

@synthesize titleLabel;
@synthesize leftBarButtonItemContainer;
@synthesize youngerRightBarButtonItemContainer;
@synthesize olderRightBarButtonItemContainer;
@synthesize backButton;
@synthesize audioButton;
@synthesize scrubberToolbar;
@synthesize olderBottomToolbar;
@synthesize topShadow;
@synthesize bottomShadow;

#pragma mark - Dealloc and View Teardown

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseViewObjects];
    [isbn release], isbn = nil;
    [profile release], profile = nil;
    
    [super dealloc];
}

- (void)releaseViewObjects
{
    [titleLabel release], titleLabel = nil;
    [leftBarButtonItemContainer release], leftBarButtonItemContainer = nil;
    [youngerRightBarButtonItemContainer release], youngerRightBarButtonItemContainer = nil;
    [olderRightBarButtonItemContainer release], olderRightBarButtonItemContainer = nil;
    [backButton release], backButton = nil;
    [audioButton release], audioButton = nil;
    [scrubberToolbar release], scrubberToolbar = nil;
    [olderBottomToolbar release], olderBottomToolbar = nil;
    [topShadow release], topShadow = nil;
    [bottomShadow release], bottomShadow = nil;
    [pageSlider release], pageSlider = nil;
    [scrubberThumbImage release], scrubberThumbImage = nil;
    [scrubberInfoView release], scrubberInfoView = nil;
    [pageLabel release], pageLabel = nil;
    [panSpeedLabel release], panSpeedLabel = nil;
    [optionsView release], optionsView = nil;
    [fontSegmentedControl release], fontSegmentedControl = nil;
    [flowFixedSegmentedControl release], flowFixedSegmentedControl = nil;
    [paperTypeSegmentedControl release], paperTypeSegmentedControl = nil;
    
    if (xpsProvider) {
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:isbn];
    }
    
    [xpsProvider release], xpsProvider = nil;
    [readingView release], readingView = nil;
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

#pragma mark - Object Initialiser
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isbn:(NSString *)aIsbn profile:(SCHProfileItem *)aProfile layout:(SCHReadingViewLayoutType)layout
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isbn = [aIsbn copy];
        profile = [aProfile retain];
        layoutType = layout;
        currentlyRotating = NO;
        currentlyScrubbing = NO;
        
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:isbn];        
        NSArray *contentItems = [book.ContentMetadataItem valueForKey:@"UserContentItem"];
        
        if ([contentItems count]) {
            [[SCHSyncManager sharedSyncManager] openDocument:[contentItems objectAtIndex:0] 
                                              forProfile:profile.ID];
        }
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(didEnterBackgroundNotification:) 
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.toolbarsVisible = YES;
    self.xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
	
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
    
    NSLog(@"XPSCategory: %@", book.XPSCategory);
    
    if (self.layoutType == SCHReadingViewLayoutTypeFlow) {
        [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:0];
        [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:1];
    } else {
        [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:0];
        [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:1];
    }
    
    [self.flowFixedSegmentedControl setSelectedSegmentIndex:self.layoutType];
    
    // FIXME: this should be a stored preference
    self.currentFontSizeIndex = 2;
    
    // FIXME: this should be a stored preference
    SCHReadingViewPaperType storedType = SCHReadingViewPaperTypeWhite;
    [self.paperTypeSegmentedControl setSelectedSegmentIndex:storedType];
    
    self.wantsFullScreenLayout = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
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
        CGRect rightBarButtonItemFrame = self.olderRightBarButtonItemContainer.frame;
        rightBarButtonItemFrame.size.height = containerHeight;
        self.youngerRightBarButtonItemContainer.frame = rightBarButtonItemFrame;
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.olderRightBarButtonItemContainer] autorelease];
    }
    
    self.titleLabel.text = book.Title;
    self.navigationItem.titleView = self.titleLabel;
    
    if (self.youngerMode) {
        [self.olderBottomToolbar removeFromSuperview];
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
    
    [self jumpToLastPageLocation];
    
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
}


- (void)viewWillDisappear:(BOOL)animated
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
        if (!self.youngerMode) {
            self.olderBottomToolbar.backgroundImage = [UIImage imageNamed:@"reading-view-portrait-bottom-bar.png"];        
        }
    } else {
        [self.backButton setImage:[UIImage imageNamed:@"icon-books-landscape.png"] forState:UIControlStateNormal];
        
        [self.audioButton setImage:[UIImage imageNamed:@"icon-play-landscape.png"] forState:UIControlStateNormal];
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reading-view-landscape-top-bar.png"]];
        self.scrubberToolbar.backgroundImage = [UIImage imageNamed:@"reading-view-landscape-scrubber-bar.png"];
        if (!self.youngerMode) {
            self.olderBottomToolbar.backgroundImage = [UIImage imageNamed:@"reading-view-landscape-bottom-bar.png"];        
        }
    }    
    
    CGRect topShadowFrame = self.topShadow.frame;
    topShadowFrame.origin.y = CGRectGetMinY(self.navigationController.navigationBar.frame) + 
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar backgroundImage].size.height;
    self.topShadow.frame = topShadowFrame;
    
}

// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return YES;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    self.currentlyRotating = NO;
    [self.readingView didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
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
        
        
        if (!(self.layoutType == SCHReadingViewLayoutTypeFlow) && self.scrubberThumbImage) {
            
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
    
    [self.readingView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

#pragma mark -
#pragma mark Notification methods

- (void)didEnterBackgroundNotification:(NSNotification *)notification
{
    // store the last page
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
    
    [self saveLastPageLocation];
    
    [[SCHSyncManager sharedSyncManager] closeDocument:[[book.ContentMetadataItem valueForKey:@"UserContentItem"] objectAtIndex:0] 
                                           forProfile:self.profile.ID];
    
    // relaunch the book
    NSString *categoryType = book.categoryType;
    if (categoryType != nil && [categoryType isEqualToString:kSCHAppBookCategoryPictureBook] == NO) {
        self.profile.AppProfile.AutomaticallyLaunchBook = self.isbn;
    }
}

#pragma mark - Book Positions

- (void)saveLastPageLocation
{
    SCHBookPoint *currentBookPoint = [self.readingView currentBookPoint];
    [self.profile setContentIdentifier:self.isbn lastPageLocation:currentBookPoint.layoutPage];
}

- (void)jumpToLastPageLocation
{
    SCHBookPoint *lastPoint = [[[SCHBookPoint alloc] init] autorelease];
    lastPoint.layoutPage = [self.profile contentIdentifierLastPageLocation:self.isbn] ? : 1;
    [self jumpToBookPoint:lastPoint animated:NO];
}

- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated 
{
    if (bookPoint) {
        [self.readingView jumpToBookPoint:bookPoint animated:animated];
    }
}

- (void)jumpToCurrentPlaceInBookAnimated:(BOOL)animated
{
    if (self.currentPageIndex == NSUIntegerMax) {
        [self.readingView jumpToProgressPositionInBook:self.currentBookProgress animated:YES];
    } else {
        [self.readingView jumpToPageAtIndex:self.currentPageIndex animated:YES];
    }
}

#pragma mark -
#pragma mark Button Actions

- (IBAction)popViewController:(id)sender
{
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
    
    [self saveLastPageLocation];

    [[SCHSyncManager sharedSyncManager] closeDocument:[[book.ContentMetadataItem valueForKey:@"UserContentItem"] objectAtIndex:0] 
                                           forProfile:self.profile.ID];

    [self cancelInitialTimer];
    [self setToolbarVisibility:YES animated:NO];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toolbarButtonPressed:(id)sender
{
    [self cancelInitialTimer];
}

- (IBAction)audioPlayAction:(id)sender
{
    NSLog(@"Audio Play action");
}

- (IBAction)storyInteractionAction:(id)sender
{
    NSLog(@"Story Interactions action");
}

- (IBAction)highlightsAction:(id)sender
{
    NSLog(@"HighlightsAction action");
    
}

- (IBAction)notesAction:(id)sender
{
    NSLog(@"Notes action");
    
    SCHReadingNotesViewController *notesController = [[SCHReadingNotesViewController alloc] initWithNibName:nil bundle:nil];
    notesController.isbn = self.isbn;
    [self.navigationController presentModalViewController:notesController animated:YES];
    [notesController release];
    
}

- (IBAction)settingsAction:(id)sender
{
    NSLog(@"Settings action");
    
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

#pragma mark - Flowed/Fixed Toggle

- (void)setLayoutType:(SCHReadingViewLayoutType)newLayoutType
{
    layoutType = newLayoutType;
    
    [self.readingView removeFromSuperview];
    
    switch (newLayoutType) {
        case SCHReadingViewLayoutTypeFlow:
            [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:0];
            [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:1];
            
            SCHFlowView *flowView = [[SCHFlowView alloc] initWithFrame:self.view.bounds isbn:self.isbn];
            self.readingView = flowView;
            [flowView release];
            
            break;
        case SCHReadingViewLayoutTypeFixed:    
        default:
            [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:0];
            [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:1];
            
            SCHLayoutView *layoutView = [[SCHLayoutView alloc] initWithFrame:self.view.bounds isbn:self.isbn];
            self.readingView = layoutView;
            [layoutView release];
            
            break;
    }
    
    self.readingView.delegate = self;
    self.readingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.paperType = self.paperType; // Reload the paper
    
    [self.view addSubview:self.readingView];
    [self.view sendSubviewToBack:self.readingView];
}

- (SCHReadingViewLayoutType)layoutType
{
    return layoutType;
}

- (IBAction)flowedFixedSegmentChanged:(UISegmentedControl *)segControl
{
    SCHBookPoint *currentBookPoint = [self.readingView currentBookPoint];
    self.layoutType = segControl.selectedSegmentIndex;
    
    [self jumpToBookPoint:currentBookPoint animated:NO];
    [self updateScrubberValue];
}

#pragma mark - Paper Type Toggle

- (void)setPaperType:(SCHReadingViewPaperType)newPaperType
{
    paperType = newPaperType;
    
    switch (newPaperType) {
        case SCHReadingViewPaperTypeBlack:
            [self.readingView setPageTexture:[UIImage imageNamed: @"paper-black.png"] isDark:YES];
            break;
        case SCHReadingViewPaperTypeSepia:
            [self.readingView setPageTexture:[UIImage imageNamed: @"paper-neutral.png"] isDark:NO];
            break;
        case SCHReadingViewPaperTypeWhite:    
        default:
            [self.readingView setPageTexture:[UIImage imageNamed: @"paper-white.png"] isDark:NO];
            break;
    }
}

- (SCHReadingViewPaperType)paperType
{
    return paperType;
}

- (IBAction)paperTypeSegmentChanged: (UISegmentedControl *) segControl
{
    self.paperType = segControl.selectedSegmentIndex;
}

#pragma mark - Font Size Toggle

- (void)setCurrentFontSizeIndex:(int)newFontSizeIndex
{
    currentFontSizeIndex = newFontSizeIndex;
    
    [self.readingView setFontPointIndex:newFontSizeIndex];
    [self updateScrubberValue];
}

- (int)currentFontSizeIndex
{
    return currentFontSizeIndex;
}

- (IBAction)fontSizeSegmentPressed:(UISegmentedControl *)segControl
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
    
    self.currentFontSizeIndex = index;
}

#pragma mark - SCHReadingViewDelegate methods

- (void)readingView:(SCHReadingView *)readingView hasMovedToPageAtIndex:(NSUInteger)pageIndex
{
    //NSLog(@"hasMovedToPageAtIndex %d", pageIndex);
    self.currentPageIndex = pageIndex;
    self.currentBookProgress = -1;
    
    [self updateScrubberValue];
}

- (void)readingView:(SCHReadingView *)readingView hasMovedToProgressPositionInBook:(CGFloat)progress
{
    //NSLog(@"hasMovedToProgressPositionInBook %f", progress);
    self.currentPageIndex = NSUIntegerMax;
    self.currentBookProgress = progress;
    
    [self updateScrubberValue];
}

- (void)toggleToolbars
{
    [self toggleToolbarVisibility];
}

- (void)hideToolbars
{
    [self setToolbarVisibility:NO animated:YES];
}

- (void)adjustScrubberInfoViewHeightForImageSize:(CGSize)imageSize
{
    CGRect scrubFrame = self.scrubberInfoView.frame;
    scrubFrame.origin.x = self.view.bounds.size.width / 2 - (scrubFrame.size.width / 2);
    
    CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
    float statusBarHeight = MIN(statusFrame.size.height, statusFrame.size.width);
        
    // if we're in fixed view, and there's an image size set, then check if we're showing an image
    if ((self.layoutType == SCHReadingViewLayoutTypeFixed) && imageSize.width > 0 && imageSize.height > 0) {
        
        // the maximum space available for an image
        int maxImageHeight = (self.view.frame.size.height - scrubberToolbar.frame.size.height - self.navigationController.navigationBar.frame.size.height - kReadingViewStandardScrubHeight - 60);
        
        // if the double toolbar is visible, reduce available space
        if ([self.olderBottomToolbar superview]) {
            maxImageHeight -= self.olderBottomToolbar.frame.size.height;
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
        
//        NSLog(@"Max height: %d", maxImageHeight);
//        NSLog(@"Desired height: %d", desiredHeight);

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
            
//            NSLog(@"Scrub frame height: %f", scrubFrame.size.height);
        }
    } else {
        scrubFrame.size.height = kReadingViewStandardScrubHeight;
    }
    
    float topLimit = statusBarHeight + self.navigationController.navigationBar.frame.size.height;
    float bottomLimit = self.view.frame.size.height - scrubberToolbar.frame.size.height;
    
    if ([self.olderBottomToolbar superview]) {
        bottomLimit -= self.olderBottomToolbar.frame.size.height;
    }
    
    if ([self.optionsView superview]) {
        bottomLimit -= self.optionsView.frame.size.height;
    }
    
    float topPoint = ((bottomLimit - topLimit) / 2) - (scrubFrame.size.height / 2);
    
    //NSLog(@"Top limit: %f, bottom limit: %f", topLimit, bottomLimit);
    
//    scrubFrame.origin.y = statusBarHeight + self.navigationController.navigationBar.frame.size.height + 10;
    scrubFrame.origin.y = floorf(topLimit + topPoint);
    
    self.scrubberInfoView.frame = scrubFrame;
}

#pragma mark - Scrubber

- (void)updateScrubberLabel
{
    if (self.currentPageIndex != NSUIntegerMax) {
        NSString *localisedText = NSLocalizedString(@"Page %d of %d", @"Page %d of %d");
        [self.pageLabel setText:[NSString stringWithFormat:localisedText, self.currentPageIndex + 1, [self.readingView pageCount]]];
    } else {
        NSString *localisedText = NSLocalizedString(@"%d%% of book", @"%d of book");
        [self.pageLabel setText:[NSString stringWithFormat:localisedText, MAX((NSUInteger)(self.currentBookProgress * 100), 1)]];
    }  
    
    if (self.layoutType == SCHReadingViewLayoutTypeFixed) {
        if (self.scrubberInfoView.frame.size.height == kReadingViewStandardScrubHeight) {
            self.scrubberThumbImage.image = nil;
        } else {
            UIImage *scrubImage = [self.xpsProvider thumbnailForPage:self.currentPageIndex + 1];
            self.scrubberThumbImage.image = scrubImage;
        }
    } else {
        self.scrubberThumbImage.image = nil;
    }

}

- (void)updateScrubberValue
{
    if (self.currentPageIndex != NSUIntegerMax) {
        self.pageSlider.minimumValue = 0;
        self.pageSlider.maximumValue = [self.readingView pageCount] - 1;
        self.pageSlider.value = self.currentPageIndex;        
    } else {
        self.pageSlider.minimumValue = 0;
        self.pageSlider.maximumValue = 1;
        self.pageSlider.value = self.currentBookProgress;        
    }       
    
    [self updateScrubberLabel];
}

- (IBAction)scrubValueStartChanges:(UISlider *)slider
{
    if (self.currentPageIndex == NSUIntegerMax) {
        self.currentBookProgress = [slider value];
    } else {
        self.currentPageIndex = roundf([slider value]);
    }
    
    // add the scrub view here
    // adjust the height of the scrubber info view first, then update the thumb
    if (self.layoutType == SCHReadingViewLayoutTypeFixed) {
        UIImage *scrubImage = [self.xpsProvider thumbnailForPage:self.currentPageIndex + 1];
        self.scrubberThumbImage.image = scrubImage;
        [self adjustScrubberInfoViewHeightForImageSize:scrubImage.size];
    } else {
        self.scrubberThumbImage.image = nil;
        [self adjustScrubberInfoViewHeightForImageSize:CGSizeZero];
    }

    [self updateScrubberLabel];
    
    [self.scrubberInfoView setAlpha:1.0f];
    [self.view addSubview:self.scrubberInfoView];
            
	[self cancelInitialTimer];
    
    self.currentlyScrubbing = YES;
    
}

- (IBAction)scrubValueEndChanges:(UISlider *)slider
{
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
    
    if (self.currentPageIndex == NSUIntegerMax) {
        self.currentBookProgress = [slider value];
    } else {
        self.currentPageIndex = roundf([slider value]);
    }
    
    [self jumpToCurrentPlaceInBookAnimated:YES];
    
    [self updateScrubberLabel];
    self.currentlyScrubbing = NO;
}

- (IBAction)scrubValueChanged:(UISlider *)slider
{
    if (!self.currentlyScrubbing) {
        return;
    }
    
    // this boolean prevents unnecessary frame size changes/thumb loading when the scrubber doesn't
    // change between pages
    BOOL adjustScrubInfo = NO;
    
    if (self.currentPageIndex == NSUIntegerMax) {
        self.currentBookProgress = [slider value];
        adjustScrubInfo = YES;
    } else {
        int newValue = roundf([slider value]);
        if (newValue != self.currentPageIndex) {
            self.currentPageIndex = newValue;
            adjustScrubInfo = YES;
        }
    }
    
    if (adjustScrubInfo) {
        [self adjustScrubberInfoViewHeightForImageSize:self.scrubberThumbImage.image.size];
        [self updateScrubberLabel];
    }
}

#pragma mark - Toolbar Methods - including timer

- (void)hideToolbarsFromTimer
{
	[self setToolbarVisibility:NO animated:YES];
	[self.initialFadeTimer invalidate];
	self.initialFadeTimer = nil;
}

- (void)setToolbarVisibility:(BOOL)visibility animated:(BOOL)animated
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
            [self.olderBottomToolbar setAlpha:1.0f];
        }
        [self.optionsView setAlpha:1.0f];
        [self.topShadow setAlpha:1.0f];   
        [self.bottomShadow setAlpha:1.0f];  
	} else {
        [self.navigationController.navigationBar setAlpha:0.0f];
        [self.scrubberToolbar setAlpha:0.0f];
        if (!youngerMode) {
            [self.olderBottomToolbar setAlpha:0.0f];
        }
        
        [self.optionsView setAlpha:0.0f];
        [self.topShadow setAlpha:0.0f];
        [self.bottomShadow setAlpha:0.0f];
	}
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)toggleToolbarVisibility
{
	NSLog(@"Toggling visibility.");
	[self setToolbarVisibility:!self.toolbarsVisible animated:YES];
}

- (void)cancelInitialTimer
{
	if (self.initialFadeTimer && [self.initialFadeTimer isValid]) {
		[self.initialFadeTimer invalidate];
		self.initialFadeTimer = nil;
	}
}	

@end
