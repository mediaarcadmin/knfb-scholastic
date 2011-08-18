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
#import "SCHBookIdentifier.h"
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
#import "SCHNote.h"
#import "SCHDictionaryViewController.h"
#import "SCHDictionaryAccessManager.h"
#import "KNFBXPSConstants.h"
#import "SCHNotesCountView.h"
#import "SCHBookStoryInteractions.h"
#import "SCHStoryInteractionController.h"
#import "SCHHighlight.h"
#import "SCHStoryInteractionTypes.h"
#import "SCHQueuedAudioPlayer.h"
#import "SCHBookStatistics.h"
#import "SCHContentSyncComponent.h"
#import "SCHAnnotationSyncComponent.h"
#import "LambdaAlert.h"
#import "SCHAppContentProfileItem.h"
#import "SCHHelpViewController.h"
#import "SCHUserDefaults.h"

// constants
NSString *const kSCHReadingViewErrorDomain  = @"com.knfb.scholastic.ReadingViewErrorDomain";

static const CGFloat kReadingViewStandardScrubHeight = 47.0f;
static const CGFloat kReadingViewBackButtonPadding = 7.0f;

#pragma mark - Class Extension

@interface SCHReadingViewController ()

@property (nonatomic, retain) SCHBookIdentifier *bookIdentifier;

@property (nonatomic, retain) SCHProfileItem *profile;
@property (nonatomic, retain) SCHBookStatistics *bookStatistics;
@property (nonatomic, retain) NSDate *bookStatisticsReadingStartTime;

// the page view, either fixed or flow
@property (nonatomic, retain) SCHReadingView *readingView;

// toolbars/nav bar visible/not visible
@property (nonatomic, assign) BOOL toolbarsVisible;
@property (nonatomic, assign) BOOL suppressToolbarToggle;

// timer used to fade toolbars out after a certain period of time
@property (nonatomic, retain) NSTimer *initialFadeTimer;

// updates the notes counter in the toolbar
- (void)updateNotesCounter;

// the first page that the view is currently showing
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, assign) NSRange currentPageIndices;
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

@property (nonatomic, retain) SCHReadingNoteView *notesView;
@property (nonatomic, retain) SCHNotesCountView *notesCountView;

@property (nonatomic, retain) SCHBookStoryInteractions *bookStoryInteractions;
@property (nonatomic, retain) SCHStoryInteractionController *storyInteractionController;
@property (nonatomic, assign) BOOL storyInteractionsCompleteOnCurrentPages;

@property (nonatomic, retain) SCHQueuedAudioPlayer *queuedAudioPlayer;
@property (nonatomic, assign) NSInteger lastPageInteractionSoundPlayedOn;
@property (nonatomic, assign) BOOL pauseAudioOnNextPageTurn;

- (id)failureWithErrorCode:(NSInteger)code error:(NSError **)error;
- (NSError *)errorWithCode:(NSInteger)code;
- (void)releaseViewObjects;

- (void)toggleToolbarVisibility;
- (void)setToolbarVisibility:(BOOL)visibility animated:(BOOL)animated;
- (void)startFadeTimer;
- (void)cancelInitialTimer;
- (void)adjustScrubberInfoViewHeightForImageSize:(CGSize)imageSize;
- (void)updateScrubberValue;
- (void)updateScrubberLabel;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)pauseAudioPlayback;

- (void)readingViewHasMoved;
- (void)saveLastPageLocation;
- (void)updateBookState;
- (void)jumpToLastPageLocation;
- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated; 
- (void)jumpToCurrentPlaceInBookAnimated:(BOOL)animated;

- (void)presentHelpAnimated:(BOOL)animated;

- (void)setDictionarySelectionMode;

- (NSInteger)storyInteractionPageNumberFromPageIndex:(NSUInteger)pageIndex;
- (NSUInteger)firstPageIndexWithStoryInteractionsOnCurrentPages;
- (void)setupStoryInteractionButtonForCurrentPagesAnimated:(BOOL)animated;
- (void)setStoryInteractionButtonVisible:(BOOL)visible animated:(BOOL)animated withSound:(BOOL)sound;
- (void)presentStoryInteraction:(SCHStoryInteraction *)storyInteraction;
- (void)save;

@end

#pragma mark - SCHReadingViewController

@implementation SCHReadingViewController

#pragma mark Object Synthesis

@synthesize managedObjectContext;
@synthesize bookIdentifier;
@synthesize profile;
@synthesize bookStatistics;
@synthesize bookStatisticsReadingStartTime;
@synthesize readingView;
@synthesize youngerMode;
@synthesize toolbarsVisible;
@synthesize suppressToolbarToggle;
@synthesize initialFadeTimer;
@synthesize currentPageIndex;
@synthesize currentPageIndices;
@synthesize currentBookProgress;
@synthesize xpsProvider;
@synthesize currentlyRotating;
@synthesize currentlyScrubbing;
@synthesize currentFontSizeIndex;
@synthesize paperType;
@synthesize layoutType;
@synthesize popover;
@synthesize notesView;
@synthesize notesCountView;

@synthesize optionsView;
@synthesize popoverOptionsViewController;
@synthesize fontSegmentedControls;
@synthesize paperTypeSegmentedControls;
@synthesize flowFixedSegmentedControls;
@synthesize storyInteractionButton;
@synthesize storyInteractionButtonView;
@synthesize toolbarToggleView;
@synthesize notesButton;
@synthesize storyInteractionsListButton;
@synthesize pageSlider;
@synthesize scrubberThumbImage;

@synthesize scrubberInfoView;
@synthesize pageLabel;

@synthesize titleLabel;
@synthesize leftBarButtonItemContainer;
@synthesize youngerRightBarButtonItemContainer;
@synthesize olderRightBarButtonItemContainer;
@synthesize backButton;
@synthesize audioButtons;
@synthesize scrubberToolbar;
@synthesize olderBottomToolbar;
@synthesize topShadow;
@synthesize bottomShadow;

@synthesize audioBookPlayer;
@synthesize bookStoryInteractions;
@synthesize storyInteractionController;
@synthesize queuedAudioPlayer;
@synthesize storyInteractionsCompleteOnCurrentPages;
@synthesize lastPageInteractionSoundPlayedOn;
@synthesize pauseAudioOnNextPageTurn;

#pragma mark - Dealloc and View Teardown

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseViewObjects];
    
    if (xpsProvider) {
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.bookIdentifier];
    }
    
    [xpsProvider release], xpsProvider = nil;
    
    [managedObjectContext release], managedObjectContext = nil;
    [bookIdentifier release], bookIdentifier = nil;
    [popover release], popover = nil;
    [profile release], profile = nil;
    [bookStatistics release], bookStatistics = nil;
    [bookStatisticsReadingStartTime release], bookStatisticsReadingStartTime = nil;
    [audioBookPlayer release], audioBookPlayer = nil;
    [bookStoryInteractions release], bookStoryInteractions = nil;
    [popoverOptionsViewController release], popoverOptionsViewController = nil;
    [queuedAudioPlayer release], queuedAudioPlayer = nil;
    
    storyInteractionController.delegate = nil; // we don't want callbacks
    [storyInteractionController release], storyInteractionController = nil;
    
    [super dealloc];
}

- (void)releaseViewObjects
{
    if (storyInteractionController != nil) {
        [storyInteractionController removeFromHostView];
    } else if (notesView != nil) {
        [notesView removeFromView];
    }
    
    [titleLabel release], titleLabel = nil;
    [leftBarButtonItemContainer release], leftBarButtonItemContainer = nil;
    [youngerRightBarButtonItemContainer release], youngerRightBarButtonItemContainer = nil;
    [olderRightBarButtonItemContainer release], olderRightBarButtonItemContainer = nil;
    [backButton release], backButton = nil;
    [audioButtons release], audioButtons = nil;
    [notesView release], notesView = nil;
    [notesCountView release], notesCountView = nil;
    [notesButton release], notesButton = nil;
    [storyInteractionsListButton release], storyInteractionsListButton = nil;

    [scrubberToolbar release], scrubberToolbar = nil;
    [olderBottomToolbar release], olderBottomToolbar = nil;
    [topShadow release], topShadow = nil;
    [bottomShadow release], bottomShadow = nil;
    [pageSlider release], pageSlider = nil;
    [scrubberThumbImage release], scrubberThumbImage = nil;
    [scrubberInfoView release], scrubberInfoView = nil;
    [pageLabel release], pageLabel = nil;
    [optionsView release], optionsView = nil;
    [fontSegmentedControls release], fontSegmentedControls = nil;
    [paperTypeSegmentedControls release], paperTypeSegmentedControls = nil;
    [flowFixedSegmentedControls release], flowFixedSegmentedControls = nil;
    [storyInteractionButton release], storyInteractionButton = nil;
    [storyInteractionButtonView release], storyInteractionButtonView = nil;
    [toolbarToggleView release], toolbarToggleView = nil;
    
    [readingView release], readingView = nil;
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

#pragma mark - Object Initialiser

- (NSError *)errorWithCode:(NSInteger)code
{
    NSString *description = nil;

    switch (code) {
        case kSCHReadingViewMissingParametersError:
            description = NSLocalizedString(@"An unexpected error occured (missing parameters). Please try again.", @"Missing paramaters error message from ReadingViewController");
            break;
        case kSCHReadingViewXPSCheckoutFailedError:
            description = NSLocalizedString(@"An unexpected error occured (XPS checkout failed). Please try again.", @"XPS Checkout failed error message from ReadingViewController");
            break;
        case kSCHReadingViewDecryptionUnavailableError:
            description = NSLocalizedString(@"It has not been possible to acquire a DRM license for this book. Please make sure this device is authorized and connected to the internet and try again.", @"Decryption not available error message from ReadingViewController");
            break;
        case kSCHReadingViewUnspecifiedError:
        default:
            description = NSLocalizedString(@"An unspecified error occured. Please try again.", @"Unspecified error message from ReadingViewController");
            break;
    }

    NSArray *objArray = [NSArray arrayWithObjects:description, nil];
    NSArray *keyArray = [NSArray arrayWithObjects:NSLocalizedDescriptionKey, nil];
    NSDictionary *eDict = [NSDictionary dictionaryWithObjects:objArray
                                                      forKeys:keyArray];
    
    return [[[NSError alloc] initWithDomain:kSCHReadingViewErrorDomain
                                           code:code userInfo:eDict] autorelease];
}

- (id)failureWithErrorCode:(NSInteger)code error:(NSError **)error
{
    if (error != NULL) {
        *error = [self errorWithCode:code];
    }
    
    [self release];
    return nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil
               bundle:(NSBundle *)nibBundleOrNil
       bookIdentifier:(SCHBookIdentifier *)aIdentifier 
              profile:(SCHProfileItem *)aProfile
 managedObjectContext:(NSManagedObjectContext *)moc
                error:(NSError **)error
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    
    if (self) {
        // Custom initialization
        if (!(aIdentifier && aProfile && moc)) {
            return [self failureWithErrorCode:kSCHReadingViewMissingParametersError error:error];
        }
        
        xpsProvider = [[[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:aIdentifier inManagedObjectContext:moc] retain];

        if (!xpsProvider) {
            return [self failureWithErrorCode:kSCHReadingViewXPSCheckoutFailedError error:error];
        }
        
        if ([xpsProvider isEncrypted]) {
            if (![xpsProvider decryptionIsAvailable]) {
                return [self failureWithErrorCode:kSCHReadingViewDecryptionUnavailableError error:error];
            }
        }
                
        bookIdentifier = [aIdentifier retain];
        profile = [aProfile retain];
        bookStatistics = [[SCHBookStatistics alloc] init];
        
        currentlyRotating = NO;
        currentlyScrubbing = NO;
        currentPageIndex = NSUIntegerMax;
        
        managedObjectContext = [moc retain];
        
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:aIdentifier inManagedObjectContext:self.managedObjectContext];        
        
        [[SCHSyncManager sharedSyncManager] openDocument:book.ContentMetadataItem.UserContentItem 
                                              forProfile:profile.ID];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(didEnterBackgroundNotification:) 
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(willTerminateNotification:) 
                                                     name:UIApplicationWillTerminateNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(willEnterForegroundNotification:) 
                                                     name:UIApplicationWillEnterForegroundNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(bookDeleted:)
                                                     name:SCHContentSyncComponentWillDeleteNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(managedObjectContextDidSaveNotification:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(annotationChanges:)
                                                     name:SCHAnnotationSyncComponentDidCompleteNotification
                                                   object:nil];
        
        
        
        self.lastPageInteractionSoundPlayedOn = -1;
        
        self.queuedAudioPlayer = [[[SCHQueuedAudioPlayer alloc] init] autorelease];

    } else {
        return [self failureWithErrorCode:kSCHReadingViewUnspecifiedError error:error];
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
    self.pauseAudioOnNextPageTurn = YES;
	
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier inManagedObjectContext:self.managedObjectContext];
    
    self.wantsFullScreenLayout = YES;
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackTranslucent;
    
    [self.view addSubview:self.readingView];
    [self.view sendSubviewToBack:self.readingView];

    // Older reader defaults: fixed view for iPad, flow view for iPhone
    // Younger reader defaults: always fixed, no need to save
    
    if (self.youngerMode) {
        self.layoutType = SCHReadingViewLayoutTypeFixed;
        self.paperType = SCHReadingViewPaperTypeWhite;
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
        
        for (UISegmentedControl* paperTypeSegmentedControl in self.paperTypeSegmentedControls) {
            [paperTypeSegmentedControl setSelectedSegmentIndex:self.paperType];
        }
        
        // add in the actions here for flowFixedSegmentedControl
        // to prevent actions being fired while setting defaults
        for (UISegmentedControl* flowFixedSegmentedControl in self.flowFixedSegmentedControls) {
            [flowFixedSegmentedControl setSelectedSegmentIndex:self.layoutType];
            [flowFixedSegmentedControl addTarget:self action:@selector(flowedFixedSegmentChanged:) forControlEvents:UIControlEventValueChanged];
        }
    }    
    
	self.scrubberInfoView.layer.cornerRadius = 5.0f;
	self.scrubberInfoView.layer.masksToBounds = YES;
    
	[self setToolbarVisibility:YES animated:NO];
	
	self.initialFadeTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                             target:self
                                                           selector:@selector(hideToolbarsFromTimer)
                                                           userInfo:nil
                                                            repeats:NO];
    [self startFadeTimer];
    
    CGFloat containerHeight = CGRectGetHeight(self.navigationController.navigationBar.bounds);
    
    CGRect leftBarButtonItemFrame = self.leftBarButtonItemContainer.frame;
    leftBarButtonItemFrame.size.height = containerHeight;
    self.leftBarButtonItemContainer.frame = leftBarButtonItemFrame;
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.leftBarButtonItemContainer] autorelease];
    
    CGRect rightBarButtonItemFrame = CGRectZero;
    if (self.youngerMode) {
        rightBarButtonItemFrame = self.youngerRightBarButtonItemContainer.frame;
        rightBarButtonItemFrame.size.height = containerHeight;
        self.youngerRightBarButtonItemContainer.frame = rightBarButtonItemFrame;
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.youngerRightBarButtonItemContainer] autorelease];
    } else {
        rightBarButtonItemFrame = self.olderRightBarButtonItemContainer.frame;
        rightBarButtonItemFrame.size.height = containerHeight;
        self.youngerRightBarButtonItemContainer.frame = rightBarButtonItemFrame;
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.olderRightBarButtonItemContainer] autorelease];
    }
    
    CGRect r = self.titleLabel.frame;
    r.size.width = (CGRectGetWidth(self.navigationController.navigationBar.bounds) - 
                    (MAX(CGRectGetWidth(leftBarButtonItemFrame),  
                    CGRectGetWidth(rightBarButtonItemFrame)) * 2.0));
    CGFloat widthDelta = CGRectGetWidth(self.navigationController.navigationBar.bounds) - r.size.width;
    r.origin.x = (widthDelta > 0 ? widthDelta / 2.0 : 0.0);
    r.size.height = containerHeight;
    self.titleLabel.frame = r;
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
    
    [self updateNotesCounter];
    
    [self setDictionarySelectionMode];
    [self setupStoryInteractionButtonForCurrentPagesAnimated:NO];
    
    SCHAppContentProfileItem *appContentProfileItem = [self.profile appContentProfileItemForBookIdentifier:self.bookIdentifier];
    appContentProfileItem.IsNew = [NSNumber numberWithBool:NO];
    [self save];
    
    self.bookStatisticsReadingStartTime = [NSDate date];
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
    
    if (youngerMode == YES) {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kSCHUserDefaultsYoungerHelpVideoFirstPlay] == YES) {
            [self presentHelpAnimated:NO];
            [self cancelInitialTimer];
        }
    } else {
        if ([[NSUserDefaults standardUserDefaults] boolForKey:kSCHUserDefaultsOlderHelpVideoFirstPlay] == YES) {
            [self presentHelpAnimated:NO];
            [self cancelInitialTimer];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self cancelInitialTimer];
    [super viewWillDisappear:animated];
    
    [self.popover dismissPopoverAnimated:NO];
    self.popover = nil;    
}

#pragma mark - Rotation

-(void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{    
    if (UIInterfaceOrientationIsPortrait(orientation)) {
        [self.backButton setImage:[UIImage imageNamed:@"icon-books.png"] forState:UIControlStateNormal];
        
        for (UIButton *audioButton in self.audioButtons) {
            [audioButton setImage:[UIImage imageNamed:@"icon-play.png"] forState:UIControlStateNormal];
            [audioButton setImage:[UIImage imageNamed:@"icon-play-active.png"] forState:UIControlStateSelected];
        }
        
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"reading-view-portrait-top-bar.png"]];
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.backButton setImage:[UIImage imageNamed:@"icon-books-landscape.png"] forState:UIControlStateNormal];
        } else {
            [self.backButton setImage:[UIImage imageNamed:@"icon-books.png"] forState:UIControlStateNormal];
        }
        
        for (UIButton *audioButton in self.audioButtons) {
            [audioButton setImage:[UIImage imageNamed:@"icon-play-landscape.png"] forState:UIControlStateNormal];
            [audioButton setImage:[UIImage imageNamed:@"icon-play-landscape-active.png"] forState:UIControlStateSelected];
        }
        
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
    [self.storyInteractionController didRotateToInterfaceOrientation:self.interfaceOrientation];
    
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    self.currentlyScrubbing = NO;
    [self.pageSlider cancelTrackingWithEvent:nil];
    [self.scrubberInfoView removeFromSuperview];
    
    self.currentlyRotating = YES;
    
    [self setupAssetsForOrientation:toInterfaceOrientation];
    
    [self.readingView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self.storyInteractionController willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
}

- (void)updateBookState
{
    if (self.bookIdentifier != nil) {
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier inManagedObjectContext:self.managedObjectContext];
        
        NSTimeInterval readingDuration = [[NSDate date] timeIntervalSinceDate:self.bookStatisticsReadingStartTime];
        [self.bookStatistics increaseReadingDurationBy:floor(readingDuration)];
        self.bookStatisticsReadingStartTime = [NSDate date];
        
        [self saveLastPageLocation];
        
        [self.profile newStatistics:self.bookStatistics forBook:self.bookIdentifier];
        self.bookStatistics = nil;
        [[SCHSyncManager sharedSyncManager] closeDocument:book.ContentMetadataItem.UserContentItem 
                                               forProfile:self.profile.ID];
        
        [self save];
    }    
}

#pragma mark -
#pragma mark Notification methods

- (void)didEnterBackgroundNotification:(NSNotification *)notification
{
    // relaunch the book
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier inManagedObjectContext:self.managedObjectContext];
    
    NSString *categoryType = book.categoryType;
    if (categoryType != nil && [categoryType isEqualToString:kSCHAppBookCategoryPictureBook] == NO) {
        self.profile.AppProfile.AutomaticallyLaunchBook = [self.bookIdentifier encodeAsString];
    }
    
    [self updateBookState];
        
    [self.readingView dismissFollowAlongHighlighter];  
    self.audioBookPlayer = nil;
}

- (void)willTerminateNotification:(NSNotification *)notification
{
    [self updateBookState];
    [self.xpsProvider reportReadingIfRequired];
}

- (void)willEnterForegroundNotification:(NSNotification *)notification
{
    self.bookStatisticsReadingStartTime = [NSDate date];
}

#pragma mark - Sync Propagation methods

- (void)bookDeleted:(NSNotification *)notification
{
    NSArray *bookIdentifiers = [notification.userInfo objectForKey:SCHContentSyncComponentDeletedBookIdentifiers];
    
    for (SCHBookIdentifier *bookId in bookIdentifiers) {
        if ([bookId isEqual:self.bookIdentifier] == YES) {
            SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier inManagedObjectContext:self.managedObjectContext];
            NSString *localizedMessage = [NSString stringWithFormat:
                                          NSLocalizedString(@"%@ has been removed", nil), book.Title];
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Book Removed", @"Book Removed") 
                                  message:localizedMessage];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK") block:^{}];
            [alert show];
            [alert release];
            self.bookIdentifier = nil;
            if (self.modalViewController != nil) {
                [self.modalViewController dismissModalViewControllerAnimated:NO];
            }              
            [self.storyInteractionController removeFromHostView];
            [self popViewController:self];
            break;
        }
    }
}

- (void)annotationChanges:(NSNotification *)notification
{
    NSNumber *profileID = [notification.userInfo objectForKey:SCHAnnotationSyncComponentCompletedProfileIDs];
    
    if ([profileID isEqualToNumber:self.profile.ID] == YES) {
        [self updateNotesCounter];
        [self.readingView refreshHighlightsForPageAtIndex:self.currentPageIndex];
    }
}

// detect any changes to the data
- (void)managedObjectContextDidSaveNotification:(NSNotification *)notification
{    
    // update the book name with the change
    for (SCHContentMetadataItem *object in [[notification userInfo] objectForKey:NSUpdatedObjectsKey]) {
        if ([object isKindOfClass:[SCHContentMetadataItem class]] == YES &&
            [[object bookIdentifier] isEqual:self.bookIdentifier] == YES) {
            self.titleLabel.text = object.Title;    
        }
    }    
}

#pragma mark - Book Positions

- (void)saveLastPageLocation
{
    SCHBookAnnotations *annotations = [self.profile annotationsForBook:self.bookIdentifier];
    
    if (annotations != nil) {
        SCHBookPoint *currentBookPoint = [self.readingView currentBookPoint];
        SCHLastPage *lastPage = [annotations lastPage];
        
        lastPage.LastPageLocation = [NSNumber numberWithInteger:currentBookPoint.layoutPage];
    }
}

- (void)jumpToLastPageLocation
{
    SCHBookAnnotations *annotations = [self.profile annotationsForBook:self.bookIdentifier];
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
    [self updateBookState];
    [self.xpsProvider reportReadingIfRequired];
    [self.audioBookPlayer cleanAudio];
    
    [self cancelInitialTimer];
    [self setToolbarVisibility:YES animated:NO];
	[self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)toolbarButtonPressed:(id)sender
{
    [self cancelInitialTimer];
    [self.readingView dismissSelector];
    [self pauseAudioPlayback];
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
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier inManagedObjectContext:self.managedObjectContext];
        NSArray *audioBookReferences = [book valueForKey:kSCHAppBookAudioBookReferences];
        NSError *error = nil;
        
        if(audioBookReferences != nil && [audioBookReferences count] > 0) {        
            self.audioBookPlayer = [[[SCHAudioBookPlayer alloc] init] autorelease];
            self.audioBookPlayer.xpsProvider = self.xpsProvider;
            BOOL success = [self.audioBookPlayer prepareAudio:audioBookReferences error:&error 
                                          wordBlock:^(NSUInteger layoutPage, NSUInteger pageWordOffset) {
                                              //NSLog(@"WORD UP! at layoutPage %d pageWordOffset %d", layoutPage, pageWordOffset);
                                              self.pauseAudioOnNextPageTurn = NO;
                                              [self.readingView followAlongHighlightWordForLayoutPage:layoutPage pageWordOffset:pageWordOffset withCompletionHandler:^{
                                                  self.pauseAudioOnNextPageTurn = YES;
                                              }];
                                          } pageTurnBlock:^(NSUInteger turnToLayoutPage) {
                                              //NSLog(@"Turn to layoutPage %d", turnToLayoutPage);
                                              if (self.layoutType == SCHReadingViewLayoutTypeFixed) {
                                                  self.pauseAudioOnNextPageTurn = NO;
                                                  [self.readingView jumpToPageAtIndex:turnToLayoutPage - 1 animated:YES withCompletionHandler:^{
                                                      self.pauseAudioOnNextPageTurn = YES;
                                                  }];
                                              }
                                          }];
            if (success) {
                self.audioBookPlayer.delegate = self;
                [self.audioBookPlayer playAtLayoutPage:layoutPage pageWordOffset:pageWordOffset];
                [self setToolbarVisibility:NO animated:YES];
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
        [self setToolbarVisibility:NO animated:YES];
    } else {
        [self.readingView dismissFollowAlongHighlighter];  
        [self pauseAudioPlayback];
    }
    
    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }    
}

- (IBAction)helpAction:(id)sender
{
    NSLog(@"Help action");

    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }

    [self presentHelpAnimated:YES];
    
    [self pauseAudioPlayback];        
}

- (void)presentHelpAnimated:(BOOL)animated
{
    SCHHelpViewController *helpViewController = [[SCHHelpViewController alloc] initWithNibName:nil 
                                                                                        bundle:nil
                                                                                   youngerMode:self.youngerMode];
    
    helpViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    helpViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self.navigationController presentModalViewController:helpViewController animated:animated];
    [helpViewController release];
}

- (IBAction)storyInteractionAction:(id)sender
{
    NSLog(@"List Story Interactions action");

    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }
    
    BOOL excludeInteractionWithPage = NO;
    if ([self.readingView isKindOfClass:[SCHFlowView class]]) {
        excludeInteractionWithPage = YES;
    }
        
    SCHReadingInteractionsListController *interactionsController = [[SCHReadingInteractionsListController alloc] initWithNibName:nil bundle:nil];
    interactionsController.bookIdentifier = self.bookIdentifier;
    interactionsController.bookStoryInteractions = self.bookStoryInteractions;
    interactionsController.profile = self.profile;
    interactionsController.delegate = self;
    interactionsController.readingView = self.readingView;
    interactionsController.excludeInteractionWithPage = excludeInteractionWithPage;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        interactionsController.modalPresentationStyle = UIModalPresentationFormSheet;
        interactionsController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    
    [self.navigationController presentModalViewController:interactionsController animated:YES];
    [interactionsController release];

    [self pauseAudioPlayback];    
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
    
    [self pauseAudioPlayback];
}

- (IBAction)notesAction:(id)sender
{
    NSLog(@"Notes action");
    
    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }
    
    SCHReadingNotesListController *notesController = [[SCHReadingNotesListController alloc] initWithNibName:nil bundle:nil];
    notesController.bookIdentifier = self.bookIdentifier;
    notesController.profile = self.profile;
    notesController.delegate = self;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        notesController.modalPresentationStyle = UIModalPresentationFormSheet;
        notesController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    }
    
    [self.navigationController presentModalViewController:notesController animated:YES];
    [notesController release];
    
    [self pauseAudioPlayback];
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

    [self pauseAudioPlayback];
}

- (IBAction)storyInteractionButtonAction:(id)sender
{
    NSLog(@"Pressed story interaction button");
    
    [self pauseAudioPlayback];
    [self.queuedAudioPlayer cancelPlaybackExecutingSynchronizedBlocksImmediately:YES];
    
    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }

    NSInteger page = [self storyInteractionPageNumberFromPageIndex:[self firstPageIndexWithStoryInteractionsOnCurrentPages]];
    
    BOOL excludeInteractionWithPage = NO;
    if ([self.readingView isKindOfClass:[SCHFlowView class]]) {
        excludeInteractionWithPage = YES;
    }
    
    NSArray *storyInteractions = [self.bookStoryInteractions storyInteractionsForPage:page
                                                         excludingInteractionWithPage:excludeInteractionWithPage];
    
    if ([storyInteractions count]) {
        SCHStoryInteraction *storyInteraction = [storyInteractions objectAtIndex:0];
        [self presentStoryInteraction:storyInteraction];
    }
}

- (IBAction)toggleToolbarButtonAction:(id)sender {
    // Setting highlight stops the flicker
    [self pauseAudioPlayback];
    
    // Perform this after a delay to allow the button to unhighlight before teh animation starts
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleToolbarVisibility) object:nil];
    [self performSelector:@selector(toggleToolbarVisibility) withObject:nil afterDelay:0.2f];
}


#pragma mark - Story Interactions methods

- (void)setupStoryInteractionButtonForCurrentPagesAnimated:(BOOL)animated
{     
    // if the story interaction is open, hide the button
    if (self.storyInteractionController != nil) {
        [self setStoryInteractionButtonVisible:NO animated:YES withSound:NO];
        return;
    }
    
    NSInteger page = [self storyInteractionPageNumberFromPageIndex:[self firstPageIndexWithStoryInteractionsOnCurrentPages]];
    
    BOOL excludeInteractionWithPage = NO;
    if ([self.readingView isKindOfClass:[SCHFlowView class]]) {
        excludeInteractionWithPage = YES;
    }
    
    NSArray *storyInteractions = [self.bookStoryInteractions storyInteractionsForPage:page
                                                         excludingInteractionWithPage:excludeInteractionWithPage];
    int totalInteractionCount = [storyInteractions count];
    int questionCount = [self.bookStoryInteractions storyInteractionQuestionCountForPage:page];
    
    BOOL interactionsFinished = [self.bookStoryInteractions storyInteractionsFinishedOnPage:page];
    
    NSInteger interactionsDone = [self.bookStoryInteractions storyInteractionQuestionsCompletedForPage:page];
    
    // only play sounds if the appearance is animated
    BOOL playSounds = animated;
    
    // override this if we've already played a sound for this page
    if (self.lastPageInteractionSoundPlayedOn == page) {
        playSounds = NO;
    }

    self.lastPageInteractionSoundPlayedOn = page;
    void(^buttonImageSelectionBlock)(void) = ^{
        NSString *imagePrefix = nil;
        
        if (self.youngerMode) {
            imagePrefix = @"young";
        } else {
            imagePrefix = @"old";
        }
        
        if (questionCount < 2) {
            if (interactionsFinished) {
                [self.storyInteractionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-lightning-bolt-3", imagePrefix]] forState:UIControlStateNormal];
            } else {
                [self.storyInteractionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-lightning-bolt-0", imagePrefix]] forState:UIControlStateNormal];
            }
        } else {
            if (interactionsFinished && interactionsDone == questionCount) {
                [self.storyInteractionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-lightning-bolt-3", imagePrefix]] forState:UIControlStateNormal];
            } else {
                [self.storyInteractionButton setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%@-lightning-bolt-%d", imagePrefix, interactionsDone]] forState:UIControlStateNormal];
            }
        }
        
        
        CGRect buttonFrame = self.storyInteractionButtonView.frame;
        buttonFrame.size = [self.storyInteractionButton imageForState:UIControlStateNormal].size;
        buttonFrame.origin.x = CGRectGetWidth(self.storyInteractionButtonView.superview.frame) - buttonFrame.size.width;
        self.storyInteractionButtonView.frame = buttonFrame;
    };
    
    // if the audio book is playing, hide the story interaction button
    if (totalInteractionCount < 1 && (self.audioBookPlayer && self.audioBookPlayer.playing)) {
        // No interactions, audio playing. Hiding button without animation
        [self setStoryInteractionButtonVisible:NO animated:NO withSound:NO];
    } else if (totalInteractionCount < 1) {
        // No interactions. Hiding button with animation
        [self setStoryInteractionButtonVisible:NO animated:YES withSound:playSounds];
    } else if (totalInteractionCount >= 1 && (self.audioBookPlayer && self.audioBookPlayer.playing)) {
        // Interactions while reading. Showing button without animation
        [self setStoryInteractionButtonVisible:YES animated:NO withSound:NO];
        buttonImageSelectionBlock();
    } else {
        // Interactions while not reading. Showing button with animation
        [self setStoryInteractionButtonVisible:YES animated:YES withSound:playSounds];
        buttonImageSelectionBlock();
    }
}

- (void)setStoryInteractionButtonVisible:(BOOL)visible animated:(BOOL)animated withSound:(BOOL)sound
{
    if (visible) {
        
        CGRect frame = self.storyInteractionButtonView.frame;
        
        // if the frame is out of screen, move it back on
        if ((frame.origin.x + frame.size.width) > self.view.frame.size.width) {
            void (^movementBlock)(void) = ^{
                CGRect frame = self.storyInteractionButtonView.frame;
                frame.origin.x = self.view.frame.size.width - frame.size.width;
                self.storyInteractionButtonView.frame = frame;
                self.storyInteractionButtonView.alpha = 1.0f;
            };
            
            self.storyInteractionButtonView.alpha = 0.0f;
            
            if (animated) {
                [UIView animateWithDuration:0.3f 
                                      delay:0
                                    options:UIViewAnimationOptionAllowUserInteraction
                                 animations:movementBlock
                                 completion:nil];
            } else {
                movementBlock();
            }
            
            // play the sound effect
            if (sound && !self.storyInteractionController && (!self.audioBookPlayer || !self.audioBookPlayer.playing)) {
                // play sound effect only if requested - e.g. toolbar hide/show doesn't play sound
                // play sound effect only if there isn't a story interaction visible
                // play sound effect only if the book reading is not happening (which should never happen!)
                
                NSString *audioFilename = self.youngerMode ? @"sfx_siappears_y2B" : @"sfx_siappears_o";
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:audioFilename ofType:@"mp3"];
                
                [self.queuedAudioPlayer cancelPlaybackExecutingSynchronizedBlocksImmediately:NO];
                [self.queuedAudioPlayer enqueueAudioTaskWithFetchBlock:^NSData*(void){
                    return [NSData dataWithContentsOfFile:bundlePath
                                                  options:NSDataReadingMapped
                                                    error:nil];
                }
                                                synchronizedStartBlock:nil
                                                  synchronizedEndBlock:nil];
            }

        } else {
            // just show the button
            void (^animationBlock)(void) = ^{
                self.storyInteractionButtonView.alpha = 1.0f;
            };
            
            if (animated) {
                [UIView animateWithDuration:0.3f 
                                      delay:0
                                    options:UIViewAnimationOptionAllowUserInteraction
                                 animations:animationBlock
                                 completion:nil];
            } else {
                animationBlock();
            }

        }
    } else {
        // hide the button
        // (hiding the button is acceptable in flow view)
        
        void (^movementBlock)(void) = ^{
            CGRect frame = self.storyInteractionButtonView.frame;
            frame.origin.x += frame.size.width;
            self.storyInteractionButtonView.frame = frame;
            self.storyInteractionButtonView.alpha = 0.0f;
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3f 
                                  delay:0
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:movementBlock
                             completion:nil];
        } else {
            movementBlock();
        }
    }
}

- (NSInteger)storyInteractionPageNumberFromPageIndex:(NSUInteger)pageIndex
{
    NSInteger page;
    
    if (pageIndex != NSUIntegerMax) {
        page = pageIndex + 1;
    } else {
        page = -1;
    }
    
    return page;
}

- (NSUInteger)firstPageIndexWithStoryInteractionsOnCurrentPages
{

    NSRange pageIndices = NSMakeRange(0, 0);
    BOOL excludeInteractionWithPage = NO;
    
    if ([self.readingView isKindOfClass:[SCHLayoutView class]]) {
        if (self.currentPageIndices.location != NSNotFound) {
            pageIndices = self.currentPageIndices;
        } else {
            pageIndices = NSMakeRange(self.currentPageIndex, 1);
        }
    } else if ([self.readingView isKindOfClass:[SCHFlowView class]]) {
        // If pagination isn't complete bail out
        if (self.currentPageIndex == NSUIntegerMax) {
            return NSUIntegerMax;
        } else {
            SCHBookRange *pageRange = [self.readingView currentBookRange];
            pageIndices = NSMakeRange(pageRange.startPoint.layoutPage - 1, pageRange.endPoint.layoutPage - pageRange.startPoint.layoutPage + 1);
        }
        
        excludeInteractionWithPage = YES;
    }
            
    for (int pageIndex = pageIndices.location; pageIndex < NSMaxRange(pageIndices); pageIndex++) {
        NSArray *storyInteractions = [self.bookStoryInteractions storyInteractionsForPage:pageIndex + 1
                                                             excludingInteractionWithPage:excludeInteractionWithPage];
            
        if ([storyInteractions count]) {
            return pageIndex;
        }
    }
    
    return NSUIntegerMax;
}

- (void)presentStoryInteraction:(SCHStoryInteraction *)storyInteraction
{
    [self.readingView dismissReadingViewAdornments];
    
    void (^presentStoryInteractionBlock)(void) = ^{
        [self setStoryInteractionButtonVisible:NO animated:YES withSound:NO];
        self.storyInteractionController = [SCHStoryInteractionController storyInteractionControllerForStoryInteraction:storyInteraction];
        self.storyInteractionController.bookIdentifier= self.bookIdentifier;
        self.storyInteractionController.delegate = self;
        self.storyInteractionController.xpsProvider = self.xpsProvider;
        [self.storyInteractionController presentInHostView:self.navigationController.view withInterfaceOrientation:self.interfaceOrientation];
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self setupStoryInteractionButtonForCurrentPagesAnimated:YES];
            [self setToolbarVisibility:NO animated:YES];
        }
    };
    
    if ([self.readingView isKindOfClass:[SCHLayoutView class]]) {
        [(SCHLayoutView *)self.readingView zoomOutToCurrentPageWithCompletionHandler:presentStoryInteractionBlock];
    } else if ([self.readingView isKindOfClass:[SCHFlowView class]]) {
        presentStoryInteractionBlock();
    }
    
    [self.bookStatistics increaseStoryInteractionsBy:1];
}

#pragma mark - Audio Control

- (void)pauseAudioPlayback
{
    if (self.audioBookPlayer != nil && [self.audioBookPlayer playing]) {
        [self.audioBookPlayer pause];
        [self.readingView dismissFollowAlongHighlighter];  
        [self setupStoryInteractionButtonForCurrentPagesAnimated:YES];
    }
    
    for (UIButton *audioButton in self.audioButtons) {
        [audioButton setSelected:NO];
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
        case SCHReadingViewLayoutTypeFlow: {
            SCHFlowView *flowView = [[SCHFlowView alloc] initWithFrame:self.view.bounds 
                                                        bookIdentifier:self.bookIdentifier 
                                                  managedObjectContext:self.managedObjectContext 
                                                              delegate:self];
            self.readingView = flowView;
            [self setDictionarySelectionMode];

            [flowView release];
                        
            for (UISegmentedControl* fontSegmentedControl in self.fontSegmentedControls) {
                [fontSegmentedControl setEnabled:YES forSegmentAtIndex:0];
                [fontSegmentedControl setEnabled:YES forSegmentAtIndex:1];
            }
            
            break;
        }
        case SCHReadingViewLayoutTypeFixed: 
        default: {
            SCHLayoutView *layoutView = [[SCHLayoutView alloc] initWithFrame:self.view.bounds 
                                                              bookIdentifier:self.bookIdentifier 
                                                        managedObjectContext:self.managedObjectContext                                          
                                                                    delegate:self];
            self.readingView = layoutView;
            
            [self setDictionarySelectionMode];
                        
            for (UISegmentedControl* fontSegmentedControl in self.fontSegmentedControls) {
                [fontSegmentedControl setEnabled:NO forSegmentAtIndex:0];
                [fontSegmentedControl setEnabled:NO forSegmentAtIndex:1];
            }

            [layoutView release];
            
            break;
        }
    }
    
    self.readingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
//    self.paperType = self.paperType; // Reload the paper
    
    [self.readingView setSelectionMode:currentMode];
    [self.view addSubview:self.readingView];
    [self.view sendSubviewToBack:self.readingView];
    
    NSNumber *savedPaperType = [[self.profile AppProfile] PaperType];
    self.paperType = [savedPaperType intValue];
    
    NSNumber *savedFontSizeIndex = [[self.profile AppProfile] FontIndex];
    self.currentFontSizeIndex = [savedFontSizeIndex intValue];

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
    
    if (!self.youngerMode && (!savedPaperType || [savedPaperType intValue] != newPaperType)) {
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
    
    // Suppress toolbar toggle (setting font size will cause the moveToPage callbackto fire and hide the toolbars)
    self.suppressToolbarToggle = YES; 
    [self.readingView setFontPointIndex:newFontSizeIndex];
    self.suppressToolbarToggle = NO; 
    
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
    return [[UIColor SCHYellowColor] colorWithAlphaComponent:0.4f];
}

- (void)addHighlightBetweenStartPage:(NSUInteger)startPage startWord:(NSUInteger)startWord endPage:(NSUInteger)endPage endWord:(NSUInteger)endWord;
{
    SCHBookAnnotations *annotations = [self.profile annotationsForBook:self.bookIdentifier];
    
    if (annotations != nil) {
        SCHHighlight *newHighlight = [annotations createHighlightBetweenStartPage:startPage startWord:startWord endPage:endPage endWord:endWord color:[self highlightColor]];
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier inManagedObjectContext:self.managedObjectContext];
        newHighlight.Version = [NSNumber numberWithInteger:[book.Version integerValue]];
    }
}

- (void)deleteHighlightBetweenStartPage:(NSUInteger)startPage startWord:(NSUInteger)startWord endPage:(NSUInteger)endPage endWord:(NSUInteger)endWord;
{
    NSLog(@"Delete highlight");
    SCHBookAnnotations *annotations = [self.profile annotationsForBook:self.bookIdentifier];
    
    for (int page = startPage; page <= endPage; page++) {
        for (SCHHighlight *highlight in [annotations highlightsForPage:page]) {
            if (([highlight startLayoutPage] == startPage) &&
                ([highlight startWordOffset] == startWord) &&
                ([highlight endLayoutPage] == endPage) &&
                ([highlight endWordOffset] == endWord)) {
                [annotations deleteHighlight:highlight];
            }
        }
    }
    [self save];
}

- (NSArray *)highlightsForLayoutPage:(NSUInteger)page
{
    SCHBookAnnotations *annotations = [self.profile annotationsForBook:self.bookIdentifier];
    
    return [annotations highlightsForPage:page];    
}

- (void)readingViewWillAppear: (SCHReadingView *) readingView
{
    [self jumpToLastPageLocation];
}

- (void)readingViewWillBeginTurning:(SCHReadingView *)readingView
{
    if (self.layoutType == SCHReadingViewLayoutTypeFixed) {
        if (self.pauseAudioOnNextPageTurn) {
            [self pauseAudioPlayback];
        }
        [self.queuedAudioPlayer cancelPlaybackExecutingSynchronizedBlocksImmediately:NO];
    }

    // hide the toolbar if it's showing
    if (self.toolbarsVisible) {
        [self setToolbarVisibility:NO animated:YES];
    }

    if (self.audioBookPlayer && self.audioBookPlayer.playing) {
        [self setStoryInteractionButtonVisible:NO animated:NO withSound:YES];
    } else {
        [self setStoryInteractionButtonVisible:NO animated:YES withSound:YES];
    }
}

- (void)readingViewWillBeginUserInitiatedZooming:(SCHReadingView *)readingView
{
    if (self.layoutType == SCHReadingViewLayoutTypeFixed) {
        [self pauseAudioPlayback];
    }
}

- (void)readingViewHasMoved
{
    [self updateScrubberValue];
    
    // check for story interactions
    self.storyInteractionsCompleteOnCurrentPages = NO;
    [self setupStoryInteractionButtonForCurrentPagesAnimated:YES];
    
    if (self.toolbarsVisible && !self.initialFadeTimer) {
        [self setToolbarVisibility:NO animated:YES];
    }
}

- (void)readingView:(SCHReadingView *)readingView hasMovedToPageAtIndex:(NSUInteger)pageIndex
{
    // Increment pages read only if we have moved forwards and only if the page advance is <= 1
    // This will exclude larger jumps made by the scrubber
    // It's actually a cheat because we don't differentiate between user initiated page turns and page turns from the scrubber or book opening
    // So we will incorrectly count it if you scrub forward 1 page or if you open the book to the page after the 1st page
    // We also fail to count the last page the user reads before closing the book
    // These are corner-cases so don't warrant a more complex solution that is triggered from something other than a page turn.
    if (self.currentPageIndex != NSUIntegerMax) {
        NSUInteger oldPageIndex = self.currentPageIndex;
        NSUInteger newPageIndex = pageIndex;
        
        if (newPageIndex > oldPageIndex) {
            NSUInteger pagesRead = newPageIndex - oldPageIndex;
            if (pagesRead <= 1) {
                [self.bookStatistics increasePagesReadBy:pagesRead];
            }
        }        
    }
    
    self.currentPageIndex = pageIndex;
    self.currentBookProgress = -1;
    self.currentPageIndices = NSMakeRange(NSNotFound, 0);
    
    [self readingViewHasMoved];
}

- (void)readingView:(SCHReadingView *)readingView hasMovedToPageIndicesInRange:(NSRange)pageIndicesRange withFocusedPageIndex:(NSUInteger)pageIndex;
{    
    // Increment pages read only if we have moved forwards and only if the page advance is <= 2
    // This will exclude larger jumps made by the scrubber
    // It's actually a cheat because we don't differentiate between user initiated page turns and page turns from the scrubber or book opening
    // So we will incorrectly count it if you scrub forward 1 or 2 pages or if you open the book to pages 2 or 3 (where page 1 is the cover)
    // We also fail to count the last page the user reads before closing the book
    // These are corner-cases so don't warrant a more complex solution that is triggered from something other than a page turn.
    if (self.currentPageIndex != NSUIntegerMax) {
        NSUInteger oldPageIndex;
        
        if (self.currentPageIndices.location == NSNotFound) {
            oldPageIndex = self.currentPageIndex;
        } else {
            oldPageIndex = self.currentPageIndices.location;
        }
        
        NSUInteger newPageIndex = pageIndicesRange.location;
        
        if (newPageIndex > oldPageIndex) {
            NSUInteger pagesRead = newPageIndex - oldPageIndex;
            if (pagesRead <= 2) {
                [self.bookStatistics increasePagesReadBy:pagesRead];
            }
        }        
    }
    
    self.currentPageIndex = pageIndex;
    self.currentBookProgress = -1;
    self.currentPageIndices = pageIndicesRange;
    
    [self readingViewHasMoved];
}

- (void)readingView:(SCHReadingView *)readingView hasMovedToProgressPositionInBook:(CGFloat)progress
{
    // N.B. We don't increment pages read at all when pagination is in progress. We cannot reliably differentiate
    // between a user initiated page turn and a scrubber or book launch because we have no concept of page ordinality
    // We could in theory translate the previous and current page prgress into an index and try to differentiate large jumps
    // but it doesn't seem worthwhile for an unreliable result
    
    //NSLog(@"hasMovedToProgressPositionInBook %f", progress);
    self.currentPageIndex = NSUIntegerMax;
    self.currentBookProgress = progress;
    self.currentPageIndices = NSMakeRange(NSNotFound, 0);
    
    [self readingViewHasMoved];
}

- (void)readingView:(SCHReadingView *)readingView hasSelectedWordForSpeaking:(NSString *)word
{
    [self pauseAudioPlayback];
    
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
    
    [self.bookStatistics addToDictionaryLookup:word];
}

#pragma mark - SCHReadingViewDelegate Toolbars methods

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
        [self.pageLabel setText:[self.readingView pageLabelForPageAtIndex:self.currentPageIndex]];
    } else {
        NSString *localisedText = NSLocalizedString(@"%d%% of book", @"%d%% of book");
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
    if (!self.currentlyScrubbing) {
        return;
    }

	[UIView animateWithDuration:0.3f 
                          delay:0.2f 
                        options:UIViewAnimationOptionCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationOptionAllowUserInteraction
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
    [self cancelInitialTimer];
    
    if (self.suppressToolbarToggle) {
        return;
    }

    // if the options view was left open from a previous view then remove it
    if (visibility == YES && self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }

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
        self.toolbarToggleView.alpha = 0.0f;
        [self.readingView dismissReadingViewAdornments];

	} else {
		[[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
        self.toolbarToggleView.alpha = 1.0f;
	}
    

	if (animated) {
		[UIView beginAnimations:@"toolbarFade" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationBeginsFromCurrentState:YES];
	}
	
	if (self.toolbarsVisible) {
        [self.navigationController.navigationBar setAlpha:1.0f];
        [self.scrubberToolbar setAlpha:1.0f];
        if (!self.youngerMode) {
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
        if (!self.youngerMode) {
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
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
}

- (void)toggleToolbarVisibility
{
//	NSLog(@"Toggling visibility.");
	[self setToolbarVisibility:!self.toolbarsVisible animated:YES];
    
    if (self.toolbarsVisible) {
        [self cancelInitialTimer];
    }
}

- (void)startFadeTimer
{
    if (self.initialFadeTimer) {
        [self.initialFadeTimer invalidate];
        self.initialFadeTimer = nil;
    }
    
    self.initialFadeTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
                                                             target:self
                                                           selector:@selector(hideToolbarsFromTimer)
                                                           userInfo:nil
                                                            repeats:NO];
}

- (void)cancelInitialTimer
{
	if (self.initialFadeTimer && [self.initialFadeTimer isValid]) {
		[self.initialFadeTimer invalidate];
		self.initialFadeTimer = nil;
	}
}	

- (void)updateNotesCounter
{
    NSInteger noteCount = [[[self.profile annotationsForBook:self.bookIdentifier] notes] count];
    self.notesCountView.noteCount = noteCount;
}

#pragma mark - SCHReadingNotesListControllerDelegate methods

- (void)readingNotesViewCreatingNewNote:(SCHReadingNotesListController *)readingNotesView
{
    NSLog(@"Requesting a new note be created!");
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier inManagedObjectContext:self.managedObjectContext];
    SCHBookAnnotations *annos = [self.profile annotationsForBook:self.bookIdentifier];
    SCHNote *newNote = [annos createEmptyNote];
    
    newNote.Version = [NSNumber numberWithInteger:[book.Version integerValue]];
    
    SCHBookPoint *currentPoint = [self.readingView currentBookPoint];
    
    NSUInteger layoutPage = 0;
    NSUInteger pageWordOffset = 0;
    [self.readingView layoutPage:&layoutPage pageWordOffset:&pageWordOffset forBookPoint:currentPoint includingFolioBlocks:YES];

    NSLog(@"Current book point: %@", currentPoint);
    newNote.noteLayoutPage = layoutPage;

    SCHReadingNoteView *aNotesView = [[SCHReadingNoteView alloc] initWithNote:newNote];    
    aNotesView.delegate = self;
    aNotesView.newNote = YES;
    
    [self setupStoryInteractionButtonForCurrentPagesAnimated:YES];
    [self setToolbarVisibility:NO animated:YES];
    
    [aNotesView showInView:self.view animated:YES];
    [aNotesView release];
}

- (void)readingNotesView:(SCHReadingNotesListController *)readingNotesView didSelectNote:(SCHNote *)note
{
    NSUInteger layoutPage = note.noteLayoutPage;
    SCHBookPoint *notePoint = [self.readingView bookPointForLayoutPage:layoutPage pageWordOffset:0 includingFolioBlocks:YES];

    [self.readingView jumpToBookPoint:notePoint animated:YES];
    
    SCHReadingNoteView *aNotesView = [[SCHReadingNoteView alloc] initWithNote:note];
    aNotesView.delegate = self;
    [aNotesView showInView:self.view animated:YES];
    self.notesView = aNotesView;
    [aNotesView release];
    
    [self setupStoryInteractionButtonForCurrentPagesAnimated:YES];
    [self setToolbarVisibility:NO animated:YES];
    
}

- (void)readingNotesView:(SCHReadingNotesListController *)readingNotesView didDeleteNote:(SCHNote *)note
{
    SCHBookAnnotations *bookAnnos = [self.profile annotationsForBook:self.bookIdentifier];
    
    NSLog(@"Deleting note...");
    [bookAnnos deleteNote:note];
    [self save];    
    [self updateNotesCounter];
}

- (SCHBookPoint *)bookPointForNote:(SCHNote *)note
{
    if (self.currentPageIndex == NSUIntegerMax) {
        return nil; // return nil if still paginating
    } else {
        NSUInteger layoutPage = note.noteLayoutPage;
        SCHBookPoint *notePoint = [self.readingView bookPointForLayoutPage:layoutPage pageWordOffset:0 includingFolioBlocks:YES];
    
        return notePoint;
    }
}

- (NSString *)displayPageNumberForBookPoint:(SCHBookPoint *)bookPoint
{
    return [self.readingView displayPageNumberForBookPoint:bookPoint];
}

#pragma mark - SCHNotesViewDelegate methods

- (void)notesView:(SCHReadingNoteView *)aNotesView savedNote:(SCHNote *)note;
{
    NSLog(@"Saving note...");
    // a new object will already have been created and added to the data store
    [self save];    
    [self setupStoryInteractionButtonForCurrentPagesAnimated:YES];
    [self setToolbarVisibility:YES animated:YES];
    
    [self updateNotesCounter];
    self.notesView = nil;    
}

- (void)notesViewCancelled:(SCHReadingNoteView *)aNotesView
{
    SCHBookAnnotations *bookAnnos = [self.profile annotationsForBook:self.bookIdentifier];
    
    // if we created the note but it's been cancelled, delete the note
    if (aNotesView.newNote) {
        [bookAnnos deleteNote:aNotesView.note];
        
        [self save];
    }
    
    [self setupStoryInteractionButtonForCurrentPagesAnimated:YES];
    [self setToolbarVisibility:YES animated:YES];
    
    [self updateNotesCounter];
    self.notesView = nil;
}

#pragma mark - SCHReadingInteractionsListControllerDelegate methods

- (SCHBookPoint *)bookPointForStoryInteractionDocumentPageNumber:(NSUInteger)pageNumber
{
    if (self.currentPageIndex == NSUIntegerMax) {
        return nil; // return nil if still paginating
    } else {
        NSUInteger layoutPage = pageNumber;
        SCHBookPoint *bookPoint = [self.readingView bookPointForLayoutPage:layoutPage pageWordOffset:0 includingFolioBlocks:YES];
        
        return bookPoint;
    }
}

- (void)readingInteractionsView:(SCHReadingInteractionsListController *)interactionsView didSelectInteraction:(NSInteger)interaction
{    
    SCHStoryInteraction *storyInteraction = [[self.bookStoryInteractions allStoryInteractionsExcludingInteractionWithPage:interactionsView.excludeInteractionWithPage] objectAtIndex:interaction];
    [self presentStoryInteraction:storyInteraction];
    
    SCHBookPoint *notePoint = [self.readingView bookPointForLayoutPage:[storyInteraction documentPageNumber] pageWordOffset:0 includingFolioBlocks:YES];
    [self.readingView jumpToBookPoint:notePoint animated:YES];
}

#pragma mark - SCHStoryInteractionControllerDelegate methods

- (void)storyInteractionController:(SCHStoryInteractionController *)aStoryInteractionController willDismissWithSuccess:(BOOL)success 
{
    if (success) {
        
        NSInteger page = [self storyInteractionPageNumberFromPageIndex:[self firstPageIndexWithStoryInteractionsOnCurrentPages]];
        
        [self.bookStoryInteractions incrementStoryInteractionQuestionsCompletedForPage:page];
        if ([self.bookStoryInteractions storyInteractionsFinishedOnPage:page]) {
            self.storyInteractionsCompleteOnCurrentPages = YES;
        }
    }
    
}

- (void)storyInteractionControllerDidDismiss:(SCHStoryInteractionController *)aStoryInteractionController
{
    if (aStoryInteractionController == self.storyInteractionController) {
        self.storyInteractionController = nil;
    }
    
    [self setupStoryInteractionButtonForCurrentPagesAnimated:YES];
}

- (NSInteger)currentQuestionForStoryInteraction
{
    NSInteger page = [self storyInteractionPageNumberFromPageIndex:[self firstPageIndexWithStoryInteractionsOnCurrentPages]];
    
    return [self.bookStoryInteractions storyInteractionQuestionsCompletedForPage:page];
}

- (BOOL)storyInteractionFinished
{
    return self.storyInteractionsCompleteOnCurrentPages;
}

- (UIImage *)currentPageSnapshot
{
    return [self.readingView pageSnapshot];
}

- (CGAffineTransform)viewToPageTransformForLayoutPage:(NSInteger)layoutPage
{
    
    NSInteger pageIndex = layoutPage - 1;
    
    if (pageIndex >= 0) {
        CGAffineTransform pageToView = [(SCHLayoutView *)self.readingView pageTurningViewTransformForPageAtIndex:layoutPage - 1];
        return CGAffineTransformInvert(pageToView);
    } else {
        NSLog(@"WARNING: viewToPageTransformForLayoutPage requested for pageIndex < 0");
        return CGAffineTransformIdentity;
    }
}

#pragma mark - UIPopoverControllerDelegate methods

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    [self.optionsView removeFromSuperview];
    self.popover = nil;
}

#pragma mark - Core Data methods

- (void)save
{
    NSError *error = nil;
    if ([self.managedObjectContext save:&error] == NO) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
    }
}
@end
