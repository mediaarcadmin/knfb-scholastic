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
#import "SCHSyncManager.h"
#import "SCHProfileItem.h"
#import "SCHBookRange.h"
#import "SCHBookPoint.h"
#import "SCHLastPage.h"
#import "SCHBookAnnotations.h"
#import "SCHAudioBookPlayer.h"
#import "SCHReadingNoteView.h"
#import "SCHBookAnnotations.h"
#import "SCHNote.h"
#import "SCHDictionaryViewController.h"
#import "SCHDictionaryAccessManager.h"
#import "KNFBXPSConstants.h"
#import "SCHNotesCountView.h"
#import "SCHBookStoryInteractions.h"
#import "SCHStoryInteractionController.h"
#import "SCHHighlight.h"

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

@property (nonatomic, retain) SCHAudioBookPlayer *audioBookPlayer;

@property (nonatomic, retain) UIPopoverController *popover;

@property (nonatomic, retain) SCHNotesCountView *notesCountView;

@property (nonatomic, retain) SCHBookStoryInteractions *bookStoryInteractions;
@property (nonatomic, retain) SCHStoryInteractionController *storyInteractionController;

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

- (void)setDictionarySelectionMode;

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
@synthesize popover;
@synthesize notesCountView;

@synthesize optionsView;
@synthesize popoverOptionsViewController;
@synthesize fontSegmentedControl;
@synthesize flowFixedSegmentedControl;
@synthesize flowFixedPopoverSegmentedControl;
@synthesize paperTypePopoverSegmentedControl;
@synthesize paperTypeSegmentedControl;
@synthesize notesButton;
@synthesize pageSlider;
@synthesize scrubberThumbImage;

@synthesize scrubberInfoView;
@synthesize pageLabel;
@synthesize panSpeedLabel;

@synthesize titleLabel;
@synthesize leftBarButtonItemContainer;
@synthesize youngerRightBarButtonItemContainer;
@synthesize olderRightBarButtonItemContainer;
@synthesize youngerRightBarButtonItemContainerPad;
@synthesize backButton;
@synthesize audioButton;
@synthesize scrubberToolbar;
@synthesize olderBottomToolbar;
@synthesize topShadow;
@synthesize bottomShadow;

@synthesize audioBookPlayer;
@synthesize bookStoryInteractions;
@synthesize storyInteractionController;

#pragma mark - Dealloc and View Teardown

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseViewObjects];
    [isbn release], isbn = nil;
    [popover release], popover = nil;
    [profile release], profile = nil;
    [audioBookPlayer release], audioBookPlayer = nil;
    [bookStoryInteractions release], bookStoryInteractions = nil;
    [popoverOptionsViewController release], popoverOptionsViewController = nil;
    
    storyInteractionController.delegate = nil; // we don't want callbacks
    [storyInteractionController release], storyInteractionController = nil;
    
    [super dealloc];
}

- (void)releaseViewObjects
{
    [titleLabel release], titleLabel = nil;
    [leftBarButtonItemContainer release], leftBarButtonItemContainer = nil;
    [youngerRightBarButtonItemContainer release], youngerRightBarButtonItemContainer = nil;
    [olderRightBarButtonItemContainer release], olderRightBarButtonItemContainer = nil;
    [youngerRightBarButtonItemContainerPad release], youngerRightBarButtonItemContainerPad = nil;
    [backButton release], backButton = nil;
    [audioButton release], audioButton = nil;
    [notesCountView release], notesCountView = nil;
    [notesButton release], notesButton = nil;

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
    [flowFixedPopoverSegmentedControl release], flowFixedPopoverSegmentedControl = nil;
    [paperTypePopoverSegmentedControl release], paperTypePopoverSegmentedControl = nil;
    
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
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil isbn:(NSString *)aIsbn profile:(SCHProfileItem *)aProfile
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        isbn = [aIsbn copy];
        profile = [aProfile retain];
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

- (SCHBookStoryInteractions *)bookStoryInteractions
{
    if (bookStoryInteractions == nil) {
        bookStoryInteractions = [[SCHBookStoryInteractions alloc] initWithXPSProvider:self.xpsProvider];
    }
    return bookStoryInteractions;
}


#pragma mark - View Lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.toolbarsVisible = YES;
    self.xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
	
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
    
    // Older reader defaults: fixed view for iPad, flow view for iPhone
    // Younger reader defaults: always fixed, no need to save

    if (self.youngerMode) {
        self.layoutType = SCHReadingViewLayoutTypeFixed;
    } else {
        
        // Default layout type
        NSNumber *savedLayoutType = [[self.profile AppProfile] LayoutType];
        if (savedLayoutType) {
            self.layoutType = [savedLayoutType intValue];
        } else {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                self.layoutType = SCHReadingViewLayoutTypeFlow;
            } else {
                self.layoutType = SCHReadingViewLayoutTypeFixed;
            }
        }

        // Default font size index
        NSNumber *savedFontSizeIndex = [[self.profile AppProfile] FontIndex];
        if (savedFontSizeIndex) {
            self.currentFontSizeIndex = [savedFontSizeIndex intValue];
        } else {
            self.currentFontSizeIndex = 2;
        }

        // Default paper type
        NSNumber *savedPaperType = [[self.profile AppProfile] PaperType];
        if (savedPaperType) {
            self.paperType = [savedPaperType intValue];
        } else {
            self.paperType = SCHReadingViewPaperTypeWhite;
        }
        
        [self.paperTypeSegmentedControl setSelectedSegmentIndex:self.paperType];
        [self.paperTypePopoverSegmentedControl setSelectedSegmentIndex:self.paperType];

        
        // set up the segmented controls
        if (self.layoutType == SCHReadingViewLayoutTypeFlow) {
            [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:0];
            [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:1];
        } else {
            [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:0];
            [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:1];
        }
        
        [self.flowFixedSegmentedControl setSelectedSegmentIndex:self.layoutType];
        [self.flowFixedPopoverSegmentedControl setSelectedSegmentIndex:self.layoutType];
        
        
        
        // add in the actions here for flowFixedSegmentedControl
        // to prevent actions being fired while setting defaults
        [self.flowFixedSegmentedControl addTarget:self action:@selector(flowedFixedSegmentChanged:) forControlEvents:UIControlEventValueChanged];
        [self.flowFixedPopoverSegmentedControl addTarget:self action:@selector(flowedFixedSegmentChanged:) forControlEvents:UIControlEventValueChanged];

    }

    
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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            CGRect rightBarButtonItemFrame = self.youngerRightBarButtonItemContainerPad.frame;
            rightBarButtonItemFrame.size.height = containerHeight;
            self.youngerRightBarButtonItemContainerPad.frame = rightBarButtonItemFrame;
            
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.youngerRightBarButtonItemContainerPad] autorelease];
        } else {
            CGRect rightBarButtonItemFrame = self.youngerRightBarButtonItemContainer.frame;
            rightBarButtonItemFrame.size.height = containerHeight;
            self.youngerRightBarButtonItemContainer.frame = rightBarButtonItemFrame;
            
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.youngerRightBarButtonItemContainer] autorelease];
        }
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
    
    // Set non-rotation specific graphics
    [self.topShadow    setImage:[UIImage imageNamed:@"reading-view-top-shadow.png"]];
    [self.bottomShadow setImage:[UIImage imageNamed:@"reading-view-bottom-shadow.png"]];
    [self.scrubberToolbar setBackgroundImage:[UIImage imageNamed:@"reading-view-scrubber-bar.png"]];
    [self.olderBottomToolbar setBackgroundImage:[UIImage imageNamed:@"reading-view-bottom-bar.png"]];        
    
    CGRect bottomShadowFrame = self.bottomShadow.frame;

    if (self.youngerMode) {
        bottomShadowFrame.origin.y = CGRectGetMinY(self.scrubberToolbar.frame) - 
        CGRectGetHeight(bottomShadowFrame);
    } else {
        bottomShadowFrame.origin.y = CGRectGetMinY(self.olderBottomToolbar.frame) - 
        CGRectGetHeight(bottomShadowFrame);
    }
    self.bottomShadow.frame = bottomShadowFrame;
    
    UIImage *bgImage = [UIImage imageNamed:@"notes-count"];
    self.notesCountView = [[SCHNotesCountView alloc] initWithImage:[bgImage stretchableImageWithLeftCapWidth:10.0f topCapHeight:0]];
    [self.notesButton addSubview:self.notesCountView];
    
    // update the note count
    NSInteger noteCount = [[[self.profile annotationsForBook:self.isbn] notes] count];
    self.notesCountView.noteCount = noteCount;

    
    [self setDictionarySelectionMode];

    [self jumpToLastPageLocation];
    
    // temporary button to get access to younger story interactions
    if (self.youngerMode) {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [button setTitle:@"SI" forState:UIControlStateNormal];
        [button setFrame:CGRectMake(CGRectGetMaxX(self.view.bounds)-30, 0, 30, 30)];
        [button addTarget:self action:@selector(storyInteractionAction:) forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
    }
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
        [self.audioButton setImage:[UIImage imageNamed:@"icon-play-active.png"] forState:UIControlStateSelected];
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reading-view-portrait-top-bar.png"]];
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.backButton setImage:[UIImage imageNamed:@"icon-books-landscape.png"] forState:UIControlStateNormal];
        } else {
            [self.backButton setImage:[UIImage imageNamed:@"icon-books.png"] forState:UIControlStateNormal];
        }
        
        [self.audioButton setImage:[UIImage imageNamed:@"icon-play-landscape.png"] forState:UIControlStateNormal];
        [self.audioButton setImage:[UIImage imageNamed:@"icon-play-landscape-active.png"] forState:UIControlStateSelected];
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reading-view-landscape-top-bar.png"]];
        } else {
            [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reading-view-portrait-top-bar.png"]];
        }
    }    
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGRect topShadowFrame = self.topShadow.frame;
        topShadowFrame.origin.y = CGRectGetMinY(self.navigationController.navigationBar.frame) + 
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar backgroundImage].size.height;
        self.topShadow.frame = topShadowFrame;
    }
    
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
    
    self.storyInteractionController.interfaceOrientation = self.interfaceOrientation;
    self.storyInteractionController.containerView.hidden = NO;
    
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
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
    
    self.storyInteractionController.containerView.hidden = YES;
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
    
    NSError *error = nil;
    if ([self.profile.managedObjectContext save:&error] == NO) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    } 
}

#pragma mark - Book Positions

- (void)saveLastPageLocation
{
    SCHBookAnnotations *annotations = [self.profile annotationsForBook:self.isbn];
    
    if (annotations != nil) {
        SCHBookPoint *currentBookPoint = [self.readingView currentBookPoint];
        SCHLastPage *lastPage = [annotations lastPage];
        
        lastPage.LastPageLocation = [NSNumber numberWithInteger:currentBookPoint.layoutPage];
    }
}

- (void)jumpToLastPageLocation
{
    SCHBookAnnotations *annotations = [self.profile annotationsForBook:self.isbn];
    SCHBookPoint *lastPoint = [[[SCHBookPoint alloc] init] autorelease];
    
    NSNumber *lastPageLocation = [[annotations lastPage] LastPageLocation];
    
    if (lastPageLocation) {
        lastPoint.layoutPage = MAX([lastPageLocation integerValue], 1);
    } else {
        lastPoint.layoutPage = 1;
    }
  
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

    [self.audioBookPlayer cleanAudio];
    
    [self cancelInitialTimer];
    [self setToolbarVisibility:YES animated:NO];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toolbarButtonPressed:(id)sender
{
    [self cancelInitialTimer];
    [self.readingView dismissSelector];
}

- (IBAction)toggleSmartZoom:(id)sender
{
    UIButton *smartZoomButton = (UIButton *)sender;
    [smartZoomButton setSelected:![smartZoomButton isSelected]];
    
    if ([smartZoomButton isSelected]) {
        [self.readingView didEnterSmartZoomMode];
    } else {
        [self.readingView didExitSmartZoomMode];
    }

    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }
}

- (IBAction)audioPlayAction:(id)sender
{
    NSLog(@"Audio Play action");
    
    UIButton *audioPlayButton = (UIButton *)sender;
    [audioPlayButton setSelected:![audioPlayButton isSelected]];
    
    NSUInteger layoutPage = 0;
    NSUInteger pageWordOffset = 0;
    [self.readingView currentLayoutPage:&layoutPage pageWordOffset:&pageWordOffset];
    
    if (self.audioBookPlayer == nil) {            
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
        NSArray *audioBookReferences = [book valueForKey:kSCHAppBookAudioBookReferences];
        NSError *error = nil;
        
        if(audioBookReferences != nil && [audioBookReferences count] > 0) {        
            self.audioBookPlayer = [[[SCHAudioBookPlayer alloc] init] autorelease];
            self.audioBookPlayer.xpsProvider = self.xpsProvider;
            if ([self.audioBookPlayer prepareAudio:audioBookReferences error:&error 
                                          wordBlock:^(NSUInteger layoutPage, NSUInteger pageWordOffset) {
                                              NSLog(@"WORD UP! at layoutPage %d pageWordOffset %d", layoutPage, pageWordOffset);
                                              [self.readingView followAlongHighlightWordForLayoutPage:layoutPage pageWordOffset:pageWordOffset];
                                          } pageTurnBlock:^(NSUInteger turnToLayoutPage) {
                                              NSLog(@"Turn to layoutPage %d", turnToLayoutPage);
                                              if (self.layoutType == SCHReadingViewLayoutTypeFixed) {
                                                  [self.readingView jumpToPageAtIndex:turnToLayoutPage - 1 animated:YES];
                                              }
                                          }] == YES) {
                                              self.audioBookPlayer.delegate = self;
                                              [self.audioBookPlayer playAtLayoutPage:layoutPage pageWordOffset:pageWordOffset];
                                          } else {
                                              self.audioBookPlayer = nil;   
                                              UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                                                                   message:NSLocalizedString(@"Due to a problem with the audio we can not play this audiobook.", @"") 
                                                                                                  delegate:nil 
                                                                                         cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                                                         otherButtonTitles:nil]; 
                                              [errorAlert show]; 
                                              [errorAlert release];                                               
                                          }
        }
    } else if(self.audioBookPlayer.playing == NO) {
        [self.audioBookPlayer playAtLayoutPage:layoutPage pageWordOffset:pageWordOffset];
    } else {
        [self.audioBookPlayer pause];
        [self.readingView dismissFollowAlongHighlighter];    
    }
    
    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }    
}

#pragma mark - Audio Book Delegate methods

- (void)audioBookPlayerDidFinishPlaying:(SCHAudioBookPlayer *)player successfully:(BOOL)flag
{
    NSLog(@"Audio Play finished playing");
    [self.readingView dismissFollowAlongHighlighter];    
}

- (void)audioBookPlayerErrorDidOccur:(SCHAudioBookPlayer *)player error:(NSError *)error
{
    NSLog(@"Audio Play erred!");
    
    [self.readingView dismissFollowAlongHighlighter];    
    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                         message:NSLocalizedString(@"Due to a problem with the audio we can not play this audiobook.", @"") 
                                                        delegate:nil 
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                               otherButtonTitles:nil]; 
    [errorAlert show]; 
    [errorAlert release];
}

- (IBAction)storyInteractionAction:(id)sender
{
    NSLog(@"Story Interactions action");

    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }
    
    SCHReadingInteractionsListController *interactionsController = [[SCHReadingInteractionsListController alloc] initWithNibName:nil bundle:nil];
    interactionsController.isbn = self.isbn;
    interactionsController.bookStoryInteractions = self.bookStoryInteractions;
    interactionsController.profile = self.profile;
    interactionsController.delegate = self;
    interactionsController.readingView = self.readingView;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        interactionsController.modalPresentationStyle = UIModalPresentationFormSheet;
        interactionsController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    
    [self.navigationController presentModalViewController:interactionsController animated:YES];
    [interactionsController release];

    
}

- (IBAction)highlightsAction:(id)sender
{
    NSLog(@"HighlightsAction action");
    UIButton *highlightsButton = (UIButton *)sender;
    [highlightsButton setSelected:![highlightsButton isSelected]];
    
    if ([highlightsButton isSelected]) {
        // Need to dismiss selector now to ensure a highlight isn't added immediately
        [self.readingView dismissSelector];
        [self.readingView setSelectionMode:SCHReadingViewSelectionModeHighlights];
    } else {
        [self setDictionarySelectionMode];
    }
    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }
    
}

- (IBAction)notesAction:(id)sender
{
    NSLog(@"Notes action");
    
    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }
    
    SCHReadingNotesListController *notesController = [[SCHReadingNotesListController alloc] initWithNibName:nil bundle:nil];
    notesController.isbn = self.isbn;
    notesController.profile = self.profile;
    notesController.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        notesController.modalPresentationStyle = UIModalPresentationFormSheet;
        notesController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    
    [self.navigationController presentModalViewController:notesController animated:YES];
    [notesController release];
    
}

- (IBAction)settingsAction:(UIButton *)sender
{
    NSLog(@"Settings action");
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
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
    } else {
        if (self.popover) {
            [self.popover dismissPopoverAnimated:YES];
            self.popover = nil;
        } else {

            self.popoverOptionsViewController.contentSizeForViewInPopover = CGSizeMake(320, 86);
            self.popover = [[UIPopoverController alloc] initWithContentViewController:self.popoverOptionsViewController];
            self.popover.delegate = self;
            
            CGRect popoverRect = sender.frame;
            popoverRect.origin.x -= 10;
            
            [self.popover presentPopoverFromRect:popoverRect inView:self.olderBottomToolbar permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];

        }
        
    }
}

#pragma mark - Flowed/Fixed Toggle

- (void)setLayoutType:(SCHReadingViewLayoutType)newLayoutType
{
    layoutType = newLayoutType;
    
    SCHReadingViewSelectionMode currentMode = [self.readingView selectionMode];
    
    NSNumber *savedLayoutType = [[self.profile AppProfile] LayoutType];

    if (!savedLayoutType || [savedLayoutType intValue] != newLayoutType) {
        savedLayoutType = [NSNumber numberWithInt:newLayoutType];
        [[self.profile AppProfile] setLayoutType:savedLayoutType];
    }
    
    [self.readingView removeFromSuperview];
    
    switch (newLayoutType) {
        case SCHReadingViewLayoutTypeFlow:
            [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:0];
            [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:1];
            
            SCHFlowView *flowView = [[SCHFlowView alloc] initWithFrame:self.view.bounds isbn:self.isbn delegate:self];
            self.readingView = flowView;
            [self setDictionarySelectionMode];

            [flowView release];
            
            break;
        case SCHReadingViewLayoutTypeFixed:    
        default:
            [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:0];
            [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:1];
            
            SCHLayoutView *layoutView = [[SCHLayoutView alloc] initWithFrame:self.view.bounds isbn:self.isbn delegate:self];
            self.readingView = layoutView;
            
            [self setDictionarySelectionMode];
            
            [layoutView release];
            
            break;
    }
    
    self.readingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.paperType = self.paperType; // Reload the paper
    
    [self.readingView setSelectionMode:currentMode];
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
    [self.readingView dismissSelector];
    
    // Dispatch this after a delay to allow the slector to be immediately dismissed
    dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.01);
    dispatch_after(delay, dispatch_get_main_queue(), ^{
        self.layoutType = segControl.selectedSegmentIndex;
        [self jumpToBookPoint:currentBookPoint animated:NO];
        [self updateScrubberValue];
    });
}

#pragma mark - Paper Type Toggle

- (void)setPaperType:(SCHReadingViewPaperType)newPaperType
{
    paperType = newPaperType;
    
    NSNumber *savedPaperType = [[self.profile AppProfile] PaperType];
    
    if (!savedPaperType || [savedPaperType intValue] != newPaperType) {
        savedPaperType = [NSNumber numberWithInt:newPaperType];
        [[self.profile AppProfile] setPaperType:savedPaperType];
    }

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
    
    NSNumber *savedFontSizeIndex = [[self.profile AppProfile] FontIndex];
    
    if (!savedFontSizeIndex || [savedFontSizeIndex intValue] != newFontSizeIndex) {
        savedFontSizeIndex = [NSNumber numberWithInt:newFontSizeIndex];
        [[self.profile AppProfile] setFontIndex:savedFontSizeIndex];
    }
    
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

#pragma mark - Dictionary

- (void)setDictionarySelectionMode
{
    if (self.youngerMode) {
        [self.readingView setSelectionMode:SCHReadingViewSelectionModeYoungerDictionary];
    } else {
        [self.readingView setSelectionMode:SCHReadingViewSelectionModeOlderDictionary];
    }
}

#pragma mark - SCHReadingViewDelegate methods

- (UIColor *)highlightColor
{
    return [[UIColor yellowColor] colorWithAlphaComponent:0.3f];
}

- (void)addHighlightBetweenStartPage:(NSUInteger)startPage startWord:(NSUInteger)startWord endPage:(NSUInteger)endPage endWord:(NSUInteger)endWord;
{
    SCHBookAnnotations *annotations = [self.profile annotationsForBook:self.isbn];
    
    if (annotations != nil) {
        SCHHighlight *newHighlight = [annotations createHighlightBetweenStartPage:startPage startWord:startWord endPage:endPage endWord:endWord color:[self highlightColor]];
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
        newHighlight.Version = [NSNumber numberWithInteger:[book.Version integerValue]];
    }
}

- (void)deleteHighlightBetweenStartPage:(NSUInteger)startPage startWord:(NSUInteger)startWord endPage:(NSUInteger)endPage endWord:(NSUInteger)endWord;
{
    NSLog(@"Delete highlight");
    //SCHBookAnnotations *annotations = [self.profile annotationsForBook:self.isbn];
}

- (NSArray *)highlightsForLayoutPage:(NSUInteger)page
{
    SCHBookAnnotations *annotations = [self.profile annotationsForBook:self.isbn];
    
    return [annotations highlightsForPage:page];    
}

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

- (void)readingView:(SCHReadingView *)readingView hasSelectedWordForSpeaking:(NSString *)word
{
    if (word) {
        [[SCHDictionaryAccessManager sharedAccessManager] speakWord:word category:kSCHDictionaryYoungReader];
    }
}

- (void)requestDictionaryForWord:(NSString *)word mode:(SCHReadingViewSelectionMode) mode
{
    SCHDictionaryViewController *dictionaryViewController = [[SCHDictionaryViewController alloc] initWithNibName:nil bundle:nil];
    dictionaryViewController.word = word;
    
    if (mode == SCHReadingViewSelectionModeYoungerDictionary) {
        dictionaryViewController.categoryMode = kSCHDictionaryYoungReader;
    } else if (mode == SCHReadingViewSelectionModeOlderDictionary) {
        dictionaryViewController.categoryMode = kSCHDictionaryOlderReader;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        dictionaryViewController.modalPresentationStyle = UIModalPresentationFormSheet;
        dictionaryViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    
    [self.navigationController presentModalViewController:dictionaryViewController animated:YES];
    [dictionaryViewController release];
}

#pragma mark - Toolbars

- (void)toggleToolbars
{
    [self toggleToolbarVisibility];
}

- (void)hideToolbars
{
    [self setToolbarVisibility:NO animated:YES];
}

#pragma mark - Scrubber

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
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            // if the options view is also visible, reduce available space
            if ([self.optionsView superview]) {
                maxImageHeight -= self.optionsView.frame.size.height;
            }
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
    
    if ([self.optionsView superview] && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        bottomLimit -= self.optionsView.frame.size.height;
    }
    
    float topPoint = ((bottomLimit - topLimit) / 2) - (scrubFrame.size.height / 2);
    
    //NSLog(@"Top limit: %f, bottom limit: %f", topLimit, bottomLimit);
    
//    scrubFrame.origin.y = statusBarHeight + self.navigationController.navigationBar.frame.size.height + 10;
    scrubFrame.origin.y = floorf(topLimit + topPoint);
    
    self.scrubberInfoView.frame = scrubFrame;
}


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
    
    [self.readingView dismissSelector];
    
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
//	NSLog(@"Setting visibility to %@.", visibility?@"True":@"False");
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
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.optionsView setAlpha:1.0f];
        }
        [self.topShadow setAlpha:1.0f];   
        [self.bottomShadow setAlpha:1.0f];  
	} else {
        [self.navigationController.navigationBar setAlpha:0.0f];
        [self.scrubberToolbar setAlpha:0.0f];
        if (!youngerMode) {
            [self.olderBottomToolbar setAlpha:0.0f];
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.optionsView setAlpha:0.0f];
        }
        [self.topShadow setAlpha:0.0f];
        [self.bottomShadow setAlpha:0.0f];
	}
	
	if (animated) {
		[UIView commitAnimations];
	}
}

- (void)toggleToolbarVisibility
{
//	NSLog(@"Toggling visibility.");
	[self setToolbarVisibility:!self.toolbarsVisible animated:YES];
}

- (void)cancelInitialTimer
{
	if (self.initialFadeTimer && [self.initialFadeTimer isValid]) {
		[self.initialFadeTimer invalidate];
		self.initialFadeTimer = nil;
	}
}	

#pragma mark - SCHReadingNotesListControllerDelegate methods

- (void)readingNotesViewCreatingNewNote:(SCHReadingNotesListController *)readingNotesView
{
    NSLog(@"Requesting a new note be created!");
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
    SCHBookAnnotations *annos = [self.profile annotationsForBook:self.isbn];
    SCHNote *newNote = [annos createEmptyNote];
    
    newNote.Version = [NSNumber numberWithInteger:[book.Version integerValue]];
    
    SCHBookPoint *currentPoint = [self.readingView currentBookPoint];
    
    NSUInteger layoutPage = 0;
    NSUInteger pageWordOffset = 0;
    [self.readingView layoutPage:&layoutPage pageWordOffset:&pageWordOffset forBookPoint:currentPoint];

    NSLog(@"Current book point: %@", currentPoint);
    newNote.noteLayoutPage = layoutPage;

    SCHReadingNoteView *aNotesView = [[SCHReadingNoteView alloc] initWithNote:newNote];    
    aNotesView.delegate = self;
    
    [self setToolbarVisibility:NO animated:YES];
    
    [aNotesView showInView:self.view animated:YES];
    [aNotesView release];
}

- (void)readingNotesView:(SCHReadingNotesListController *)readingNotesView didSelectNote:(SCHNote *)note
{
    NSUInteger layoutPage = note.noteLayoutPage;
    SCHBookPoint *notePoint = [self.readingView bookPointForLayoutPage:layoutPage pageWordOffset:0];

    [self.readingView jumpToBookPoint:notePoint animated:YES];
    
    SCHReadingNoteView *aNotesView = [[SCHReadingNoteView alloc] initWithNote:note];
    aNotesView.delegate = self;
    [aNotesView showInView:self.view animated:YES];
    [aNotesView release];
    
    [self setToolbarVisibility:NO animated:YES];
    
}

- (void)readingNotesView:(SCHReadingNotesListController *)readingNotesView didDeleteNote:(SCHNote *)note
{
    NSLog(@"Deleting note...");
    SCHBookAnnotations *bookAnnos = [self.profile annotationsForBook:self.isbn];
    [bookAnnos deleteNote:note];
    
    // update the note count
    NSInteger noteCount = [[[self.profile annotationsForBook:self.isbn] notes] count];
    self.notesCountView.noteCount = noteCount;

}

- (SCHBookPoint *)bookPointForNote:(SCHNote *)note
{
    if (self.currentPageIndex == NSUIntegerMax) {
        return nil; // return nil if still paginating
    } else {
        NSUInteger layoutPage = note.noteLayoutPage;
        SCHBookPoint *notePoint = [self.readingView bookPointForLayoutPage:layoutPage pageWordOffset:0];
    
        return notePoint;
    }
}

- (NSString *)displayPageNumberForBookPoint:(SCHBookPoint *)bookPoint
{
    return [self.readingView displayPageNumberForBookPoint:bookPoint];
}

#pragma mark - SCHNotesViewDelegate methods

- (void)notesView:(SCHReadingNoteView *)notesView savedNote:(SCHNote *)note;
{
    // FIXME: save note
    NSLog(@"Saving note...");
    SCHBookAnnotations *bookAnnos = [self.profile annotationsForBook:self.isbn];
    [bookAnnos addNote:note];
    
    [self setToolbarVisibility:YES animated:YES];
    
    // update the note count
    NSInteger noteCount = [[[self.profile annotationsForBook:self.isbn] notes] count];
    self.notesCountView.noteCount = noteCount;
    
}

- (void)notesViewCancelled:(SCHReadingNoteView *)notesView
{
    SCHBookAnnotations *bookAnnos = [self.profile annotationsForBook:self.isbn];
    [bookAnnos deleteNote:notesView.note];
    
    [self setToolbarVisibility:YES animated:YES];
    
    // update the note count
    NSInteger noteCount = [[[self.profile annotationsForBook:self.isbn] notes] count];
    self.notesCountView.noteCount = noteCount;
    
    
}

#pragma mark - SCHReadingInteractionsListControllerDelegate methods

- (void)readingInteractionsView:(SCHReadingInteractionsListController *)interactionsView didSelectInteraction:(NSInteger)interaction
{
    NSLog(@"Selected interaction %d.", interaction);
    SCHStoryInteraction *storyInteraction = [[self.bookStoryInteractions allStoryInteractions] objectAtIndex:interaction];
    self.storyInteractionController = [SCHStoryInteractionController storyInteractionControllerForStoryInteraction:storyInteraction];
    self.storyInteractionController.interfaceOrientation = self.interfaceOrientation;
    self.storyInteractionController.delegate = self;
    [self.storyInteractionController presentInHostView:self.view];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setNavigationBarHidden:YES animated:YES];
    }
}

#pragma mark - SCHStoryInteractionControllerDelegate methods

- (void)storyInteractionControllerDidDismiss:(SCHStoryInteractionController *)aStoryInteractionController
{
    if (aStoryInteractionController == self.storyInteractionController) {
        self.storyInteractionController = nil;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.navigationController setNavigationBarHidden:NO animated:YES];
        }
    }
}

#pragma mark - UIPopoverControllerDelegate methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self.optionsView removeFromSuperview];
    self.popover = nil;
}

@end
