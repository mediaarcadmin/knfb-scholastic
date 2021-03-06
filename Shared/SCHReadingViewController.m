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
#import "SCHCustomToolbar.h"
#import "SCHSyncManager.h"
#import "SCHProfileItem.h"
#import "SCHBookRange.h"
#import "SCHBookPoint.h"
#import "SCHLastPage.h"
#import "SCHBookAnnotations.h"
#import "SCHAudioBookPlayer.h"
#import "SCHNote.h"
#import "SCHDictionaryViewController.h"
#import "SCHDictionaryAccessManager.h"
#import "SCHDictionaryDownloadManager.h"
#import "SCHHelpManager.h"
#import "SCHNotesCountView.h"
#import "SCHBookStoryInteractions+XPS.h"
#import "SCHStoryInteractionController.h"
#import "SCHStoryInteractionStandaloneViewController.h"
#import "SCHHighlight.h"
#import "SCHStoryInteractionTypes.h"
#import "SCHQueuedAudioPlayer.h"
#import "SCHBookStatistics.h"
#import "SCHContentSyncComponent.h"
#import "SCHAnnotationSyncComponent.h"
#import "LambdaAlert.h"
#import "SCHAppContentProfileItem.h"
#import "SCHUserDefaults.h"
#import "SCHContentProfileItem.h"
#import "SCHBooksAssignment.h"
#import "SCHReadingStoryInteractionButton.h"
#import "SCHProfileSyncComponent.h"
#import "NSDate+ServerDate.h"
#import "SCHRecommendationListView.h"
#import "SCHRecommendationContainerView.h"
#import "SCHAppStateManager.h"
#import "SCHAppRecommendationItem.h"
#import "SCHCoreDataHelper.h"
#import "Reachability.h"
#import "SCHRetrieveRecommendationsForBooksOperation.h"
#import "SCHRecommendationViewDelegate.h"
#import "SCHRecommendationViewDataSource.h"
#import "SCHAppBookFeatures.h"
#import <libEucalyptus/THUIDeviceAdditions.h>

// constants
NSString *const kSCHReadingViewErrorDomain  = @"com.knfb.scholastic.ReadingViewErrorDomain";

static const CGFloat kReadingViewStandardScrubHeight = 47.0f;
static const CGFloat kReadingViewOlderScrubberToolbarHeight = 44;
static const CGFloat kReadingViewYoungerScrubberToolbarHeight = 60.0f;
static const CGFloat kReadingViewBackButtonPadding = 7.0f;
static const NSUInteger kReadingViewMaxRecommendationsCount = 4;
static const CGFloat kReadingViewMinimumBookHeightForFourRecommendations = 280.0;

#pragma mark - Class Extension

@interface SCHReadingViewController () <SCHRecommendationListViewDelegate, SCHRecommendationViewDataSource>

@property (nonatomic, retain) SCHBookIdentifier *bookIdentifier;

@property (nonatomic, retain) SCHProfileItem *profile;
@property (nonatomic, retain) SCHBookAnnotations *bookAnnotations;
@property (nonatomic, retain) SCHBookStatistics *bookStatistics;
@property (nonatomic, retain) NSDate *bookStatisticsReadingStartTime;

// the page view, either fixed or flow
@property (nonatomic, retain) SCHReadingView *readingView;
@property (nonatomic, retain) SCHReadingViewNavigationToolbar *navigationToolbar;

// toolbars/nav bar visible/not visible
@property (nonatomic, assign) BOOL toolbarsVisible;
@property (nonatomic, assign) BOOL suppressToolbarToggle;

// timer used to fade toolbars out after a certain period of time
@property (nonatomic, retain) NSTimer *initialFadeTimer;

@property (nonatomic, retain) NSTimer *cornerCoverFadeTimer;

// the first page that the view is currently showing
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, assign) NSRange currentPageIndices;
@property (nonatomic, assign) CGFloat currentBookProgress;

// Book data provider
@property (nonatomic, retain) id<SCHBookPackageProvider> bookPackageProvider;

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
@property (nonatomic, retain) NSManagedObjectContext *scratchNoteManagedObjectContext;

@property (nonatomic, retain) SCHBookStoryInteractions *bookStoryInteractions;
@property (nonatomic, retain) SCHStoryInteractionController *storyInteractionController;
@property (nonatomic, retain) SCHStoryInteractionStandaloneViewController *storyInteractionViewController;

@property (nonatomic, retain) SCHQueuedAudioPlayer *queuedAudioPlayer;
@property (nonatomic, assign) NSInteger lastPageInteractionSoundPlayedOn;
@property (nonatomic, assign) BOOL pauseAudioOnNextPageTurn;

@property (nonatomic, retain) UIImageView *sampleSICoverMarker;
@property (nonatomic, assign) BOOL coverMarkerShouldAppear;
@property (nonatomic, assign) BOOL shouldShowChapters;
@property (nonatomic, assign) BOOL shouldShowPageNumbersForFixedLayout;
@property (nonatomic, assign) NSNumber *forceOpenToCover;
@property (nonatomic, assign) SCHReadingViewLayoutType forceLayoutType;

@property (nonatomic, assign) BOOL highlightsModeEnabled;
@property (nonatomic, assign) BOOL firstTimePlayForHelpController;

@property (nonatomic, retain) UINib *recommendationsContainerNib;
@property (nonatomic, retain) UINib *recommendationSampleViewNib;
@property (nonatomic, retain) NSArray *recommendationsDictionaries;
@property (nonatomic, retain) NSArray *wishListDictionaries;
@property (nonatomic, retain) NSMutableArray *modifiedWishListDictionaries;

@property (nonatomic, assign) BOOL isInBackground;
@property (nonatomic, assign) BOOL appBookIsSuppressingHighlights;

@property (nonatomic, retain) UIView <SCHRecommendationViewDelegate> *recommendationView;

- (void)updateNotesCounter;
- (id)initFailureWithErrorCode:(NSInteger)code error:(NSError **)error;
- (NSError *)errorWithCode:(NSInteger)code;
- (void)releaseViewObjects;

- (void)bookAudioPlayerStartedPlaying;
- (void)bookAudioPlayerFailed;
- (void)reportNoAudioForLastPage;

- (void)toolbarButtonPressed;
- (void)toggleToolbarVisibility;
- (void)setToolbarVisibility:(BOOL)visibility animated:(BOOL)animated;
- (void)startFadeTimer;
- (void)cancelInitialTimer;
- (void)updateScrubberValue;
- (void)updateScrubberHUD;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)pauseAudioPlayback;

- (void)readingViewHasMoved;
- (void)saveLastPageLocation;
- (void)updateBookState;
- (SCHBookPoint *)lastPageLocation;
- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated; 
- (void)jumpToCurrentPlaceInBookAnimated:(BOOL)animated;
- (BOOL)bookHasReadingChallenge;

- (void)presentHelpAnimated:(BOOL)animated;

- (void)setDictionarySelectionMode;

- (NSRange)storyInteractionPageIndices;
- (void)setupStoryInteractionButtonForCurrentPagesAnimated:(BOOL)animated;
- (void)setStoryInteractionButtonVisible:(BOOL)visible animated:(BOOL)animated withSound:(BOOL)sound completion:(void (^)(BOOL finished))completion;
- (void)presentStoryInteraction:(SCHStoryInteraction *)storyInteraction;
- (void)pushStoryInteractionController:(SCHStoryInteractionController *)storyInteractionController;
- (void)save;

- (void)setupOptionsViewForMode:(SCHReadingViewLayoutType)newLayoutType;
- (void)setupOptionsViewForMode:(SCHReadingViewLayoutType)newLayoutType orientation:(UIInterfaceOrientation)orientation;
- (void)updateFontSegmentStateForIndex:(NSInteger)index;

- (void)positionCoverCornerViewForOrientation:(UIInterfaceOrientation)newOrientation;
- (UIImage *)imageForFeature:(SCHAppBookFeatures *)bookFeatures;
- (void)dismissCoverCornerViewWithAnimation:(BOOL)animated;
- (void)checkCornerAudioButtonVisibilityWithAnimation:(BOOL)animated;
- (void)positionCornerAudioButtonForOrientation:(UIInterfaceOrientation)newOrientation;
- (BOOL)shouldShowBookRecommendationsForReadingView:(SCHReadingView *)readingView;
- (void)updateRecommendations;
- (void)commitWishListChanges;

@end

#pragma mark - SCHReadingViewController

@implementation SCHReadingViewController

#pragma mark Object Synthesis

@synthesize managedObjectContext;
@synthesize bookIdentifier;
@synthesize profile;
@synthesize bookAnnotations;
@synthesize bookStatistics;
@synthesize bookStatisticsReadingStartTime;
@synthesize readingView;
@synthesize navigationToolbar;
@synthesize youngerMode;
@synthesize readingQuizButton;
@synthesize toolbarsVisible;
@synthesize suppressToolbarToggle;
@synthesize initialFadeTimer;
@synthesize currentPageIndex;
@synthesize currentPageIndices;
@synthesize currentBookProgress;
@synthesize bookPackageProvider;
@synthesize currentlyRotating;
@synthesize currentlyScrubbing;
@synthesize currentFontSizeIndex;
@synthesize paperType;
@synthesize layoutType;
@synthesize popover;
@synthesize notesView;
@synthesize notesCountView;
@synthesize scratchNoteManagedObjectContext;

@synthesize optionsView;
@synthesize customOptionsView;
@synthesize originalButtons;
@synthesize customButtons;
@synthesize largeOptionsButtons;
@synthesize smallOptionsButtons;
@synthesize fontSegmentedControl;
@synthesize paperTypeSegmentedControl;
@synthesize popoverOptionsViewController;
@synthesize storyInteractionButton;
@synthesize storyInteractionButtonView;
@synthesize toolbarToggleView;
@synthesize cornerAudioButtonView;
@synthesize notesButton;
@synthesize storyInteractionsListButton;
@synthesize pageSlider;
@synthesize scrubberThumbImage;

@synthesize scrubberInfoView;
@synthesize pageLabel;
@synthesize optionsPhoneTopBackground;
@synthesize popoverNavigationTitleLabel;

@synthesize scrubberToolbar;
@synthesize olderBottomToolbar;
@synthesize highlightsToolbar;
@synthesize bottomShadow;

@synthesize audioBookPlayer;
@synthesize bookStoryInteractions;
@synthesize storyInteractionController;
@synthesize storyInteractionViewController;
@synthesize queuedAudioPlayer;
@synthesize lastPageInteractionSoundPlayedOn;
@synthesize pauseAudioOnNextPageTurn;

@synthesize sampleSICoverMarker;
@synthesize coverMarkerShouldAppear;
@synthesize shouldShowChapters;
@synthesize shouldShowPageNumbersForFixedLayout;
@synthesize forceOpenToCover;
@synthesize forceLayoutType;
@synthesize highlightsModeEnabled;
@synthesize highlightsInfoButton;
@synthesize highlightsCancelButton;
@synthesize cornerCoverFadeTimer;
@synthesize firstTimePlayForHelpController;
@synthesize recommendationsContainerNib;
@synthesize recommendationSampleViewNib;
@synthesize recommendationsDictionaries;
@synthesize wishListDictionaries;
@synthesize modifiedWishListDictionaries;
@synthesize isInBackground;
@synthesize appBookIsSuppressingHighlights;
@synthesize recommendationView;
@synthesize appController;

#pragma mark - Dealloc and View Teardown

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self releaseViewObjects];
    
    if (bookPackageProvider && self.bookIdentifier) {
        [[SCHBookManager sharedBookManager] checkInBookPackageProviderForBookIdentifier:self.bookIdentifier];
    }
    
    [bookPackageProvider release], bookPackageProvider = nil;
    
    [managedObjectContext release], managedObjectContext = nil;
    [bookIdentifier release], bookIdentifier = nil;
    [popover release], popover = nil;
    [profile release], profile = nil;
    [bookAnnotations release], bookAnnotations = nil;
    [bookStatistics release], bookStatistics = nil;
    [bookStatisticsReadingStartTime release], bookStatisticsReadingStartTime = nil;
    [audioBookPlayer release], audioBookPlayer = nil;
    [scratchNoteManagedObjectContext release], scratchNoteManagedObjectContext = nil;
    [bookStoryInteractions release], bookStoryInteractions = nil;
    [popoverOptionsViewController release], popoverOptionsViewController = nil;
    [queuedAudioPlayer release], queuedAudioPlayer = nil;
    
    storyInteractionController.delegate = nil; // we don't want callbacks
    [storyInteractionController release], storyInteractionController = nil;
    [storyInteractionViewController release], storyInteractionViewController = nil;
    [cornerCoverFadeTimer release], cornerCoverFadeTimer = nil;
    [forceOpenToCover release], forceOpenToCover = nil;
    [recommendationView release], recommendationView = nil;
    [recommendationsContainerNib release], recommendationsContainerNib = nil;
    [recommendationSampleViewNib release], recommendationSampleViewNib = nil;
    [recommendationsDictionaries release], recommendationsDictionaries = nil;
    [wishListDictionaries release], wishListDictionaries = nil;
    [modifiedWishListDictionaries release], modifiedWishListDictionaries = nil;
    
    // Ideally the readingView would be release it viewDidUnload but it contains 
    // logic that this view controller uses while it is potentially off-screen (e.g. when a story interaction is being shown)
    [readingView release], readingView = nil;
    
    [readingQuizButton release];
    [super dealloc];
}

- (void)releaseViewObjects
{
    if (self.notesView != nil) {
        [self.notesView removeFromView];
    }
    
    [notesView release], notesView = nil;
    [notesCountView release], notesCountView = nil;
    [notesButton release], notesButton = nil;
    [readingQuizButton release], readingQuizButton = nil;
    [storyInteractionsListButton release], storyInteractionsListButton = nil;

    [scrubberToolbar release], scrubberToolbar = nil;
    [olderBottomToolbar release], olderBottomToolbar = nil;
    [highlightsToolbar release], highlightsToolbar = nil;
    [bottomShadow release], bottomShadow = nil;
    [pageSlider release], pageSlider = nil;
    [scrubberThumbImage release], scrubberThumbImage = nil;
    [scrubberInfoView release], scrubberInfoView = nil;
    [pageLabel release], pageLabel = nil;
    [optionsView release], optionsView = nil;
    [customOptionsView release], customOptionsView = nil;
    [storyInteractionButton release], storyInteractionButton = nil;
    [storyInteractionButtonView release], storyInteractionButtonView = nil;
    [toolbarToggleView release], toolbarToggleView = nil;
    [cornerAudioButtonView release], cornerAudioButtonView = nil;
    [optionsPhoneTopBackground release], optionsPhoneTopBackground = nil;
    
    [originalButtons release], originalButtons = nil;
    [customButtons release], customButtons = nil;
    [largeOptionsButtons release], largeOptionsButtons = nil;
    [smallOptionsButtons release], smallOptionsButtons = nil;
    [fontSegmentedControl release], fontSegmentedControl = nil;
    [paperTypeSegmentedControl release], paperTypeSegmentedControl = nil;
    [popoverNavigationTitleLabel release], popoverNavigationTitleLabel = nil;
    [sampleSICoverMarker release], sampleSICoverMarker = nil;
    [highlightsInfoButton release], highlightsInfoButton = nil;
    [highlightsCancelButton release], highlightsCancelButton = nil;
    
    [navigationToolbar release], navigationToolbar = nil;

}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    [self saveLastPageLocation]; // Needed in case the view unloads while a modal popover is being displayed
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
        case kSCHReadingViewBookPackageCheckoutFailedForUnspecifiedReasonError:
            description = NSLocalizedString(@"An unexpected error occured (XPS checkout failed). Please try again.", @"XPS Checkout failed due to unspecified error message from ReadingViewController");
            break;
        case kSCHReadingViewBookPackageCheckoutFailedDueToInsufficientDiskSpaceError:
            description = NSLocalizedString(@"You do not have enough storage on your device to complete this function. Please clear some space and then try again.", @"XPS Checkout failed due to insufficient space error message from ReadingViewController");
            break;
        case kSCHReadingViewDecryptionUnavailableError:
            description = NSLocalizedString(@"It has not been possible to acquire a DRM license for this eBook. Please make sure this device is authorized and connected to the internet.", @"Decryption not available error message from ReadingViewController");
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

- (id)initFailureWithErrorCode:(NSInteger)code error:(NSError **)error
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
            return [self initFailureWithErrorCode:kSCHReadingViewMissingParametersError error:error];
        }
        
        bookIdentifier = [aIdentifier retain];
        NSError *packageError;
        
        bookPackageProvider = [[[SCHBookManager sharedBookManager] checkOutBookPackageProviderForBookIdentifier:bookIdentifier inManagedObjectContext:moc error:&packageError] retain];

        if (!bookPackageProvider || ([bookPackageProvider isValid] == NO)) {
            if ([packageError code] == kKNFBXPSProviderNotEnoughDiskSpaceError) {
                return [self initFailureWithErrorCode:kSCHReadingViewBookPackageCheckoutFailedDueToInsufficientDiskSpaceError error:error];
            } else {
                return [self initFailureWithErrorCode:kSCHReadingViewBookPackageCheckoutFailedForUnspecifiedReasonError error:error];
            }
        }
                
        if ([bookPackageProvider isEncrypted]) {
            if (![bookPackageProvider decryptionIsAvailable]) {
                return [self initFailureWithErrorCode:kSCHReadingViewDecryptionUnavailableError error:error];
            }
        }
                
        profile = [aProfile retain];
        bookStatistics = [[SCHBookStatistics alloc] init];
        bookAnnotations = [[profile annotationsForBook:bookIdentifier] retain];
        
        currentlyRotating = NO;
        currentlyScrubbing = NO;
        appBookIsSuppressingHighlights = NO;
        currentPageIndex = NSUIntegerMax;
        
        managedObjectContext = [moc retain];
        
        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:aIdentifier inManagedObjectContext:self.managedObjectContext];       

        SCHAppContentProfileItem *appContentProfileItem = [aProfile appContentProfileItemForBookIdentifier:aIdentifier];
        [appContentProfileItem openedBook];
        [self save];
        
        self.shouldShowChapters = book.shouldShowChapters;
        self.shouldShowPageNumbersForFixedLayout = book.shouldShowPageNumbers;
        self.forceOpenToCover = [NSNumber numberWithBool:book.alwaysOpenToCover];

#if FLOW_VIEW_DISABLED
        // If Flow View is disabled, always use fixed view
        self.forceLayoutType = SCHReadingViewLayoutTypeFixed;
#else
        if (![bookPackageProvider containsFixedRepresentation]) {
            self.forceLayoutType = SCHReadingViewLayoutTypeFlow;
        } else if (![bookPackageProvider containsFlowedRepresentation]) {
            self.forceLayoutType = SCHReadingViewLayoutTypeFixed;
        }
#endif
        
        [[SCHSyncManager sharedSyncManager] openBookSyncForced:YES
                                               booksAssignment:book.ContentMetadataItem.booksAssignment
                                              forProfile:profile
                                           requestReadingStats:[self bookHasReadingChallenge]];
        [[SCHSyncManager sharedSyncManager] backOfBookRecommendationSync:self.bookIdentifier];
        [[SCHSyncManager sharedSyncManager] wishListSyncForced:NO];

        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(willResignActiveNotification:)
                                                     name:UIApplicationWillResignActiveNotification
                                                   object:nil];

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
                                                 selector:@selector(annotationChanges:)
                                                     name:SCHAnnotationSyncComponentDidCompleteNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(profileDeleted:)
                                                     name:SCHProfileSyncComponentWillDeleteNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(dictionaryStateChange:) 
                                                     name:kSCHDictionaryStateChange 
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];
        
        self.lastPageInteractionSoundPlayedOn = -1;
        
        self.queuedAudioPlayer = [[[SCHQueuedAudioPlayer alloc] init] autorelease];

        self.coverMarkerShouldAppear = YES;
        self.firstTimePlayForHelpController = NO;
        
        self.recommendationsContainerNib = [UINib nibWithNibName:@"SCHRecommendationListView-ReadingViewContainer" bundle:nil];
        self.recommendationSampleViewNib = [UINib nibWithNibName:@"SCHRecommendationSampleView" bundle:nil];

    } else {
        return [self initFailureWithErrorCode:kSCHReadingViewUnspecifiedError error:error];
    }
    
    return self;
}

- (SCHBookStoryInteractions *)bookStoryInteractions
{
    if (bookStoryInteractions == nil) {
        bookStoryInteractions = [[SCHBookStoryInteractions alloc] initWithXPSProvider:(SCHXPSProvider *)self.bookPackageProvider
                                                                       oddPagesOnLeft:YES
                                                                             delegate:self];
        
        if ([self.profile storyInteractionsDisabled]) {
            bookStoryInteractions.storyInteractions = nil;
        }
    }
    return bookStoryInteractions;
}

- (void)setManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    if (managedObjectContext != aManagedObjectContext) {
        [[NSNotificationCenter defaultCenter] removeObserver:self
                                                        name:NSManagedObjectContextDidSaveNotification
                                                      object:nil];
        if (aManagedObjectContext != nil) {        
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(managedObjectContextDidSaveNotification:)
                                                         name:NSManagedObjectContextDidSaveNotification
                                                       object:aManagedObjectContext];                    
        }
        [aManagedObjectContext retain];        
        [managedObjectContext release];
        managedObjectContext = aManagedObjectContext;
    }
}

#pragma mark - View Lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	self.toolbarsVisible = YES;
    self.pauseAudioOnNextPageTurn = YES;
    
    self.wantsFullScreenLayout = YES;
    [self.navigationController setNavigationBarHidden:YES];
    
    // The story interaction button setup causes a layoutSubviews to be triggered so we perform
    // this before the readingView is added to the hierarchy to prevent
    // an inefficient double-layout in that view (also fixes a visual glitch)
    [self.storyInteractionButton setIsYounger:self.youngerMode];
    CGRect buttonFrame = self.storyInteractionButtonView.frame;
    buttonFrame.size = [self.storyInteractionButton imageForState:UIControlStateNormal].size;
    buttonFrame.origin.x = CGRectGetWidth(self.view.frame) - buttonFrame.size.width;
    self.storyInteractionButtonView.frame = buttonFrame;
    [self setupStoryInteractionButtonForCurrentPagesAnimated:NO];

    if (self.readingView) {
        [self.readingView setFrame:self.view.bounds];
        [self.view addSubview:self.readingView];
        [self.view sendSubviewToBack:self.readingView];
    }

    // Older reader defaults: fixed view for iPad, flow view for iPhone
    // Younger reader defaults: always fixed, no need to save
    if (self.youngerMode) {
        self.layoutType = SCHReadingViewLayoutTypeFixed;
        self.paperType = SCHReadingViewPaperTypeWhite;
    } else {
        
        // Default layout type
        if (self.forceLayoutType != SCHReadingViewLayoutTypeUnspecified) {
            self.layoutType = self.forceLayoutType;
        } else {
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
        if (savedPaperType && self.layoutType == SCHReadingViewLayoutTypeFlow) {
            self.paperType = [savedPaperType intValue];
        } else {
            // set defaults if they don't exist already
            self.paperType = SCHReadingViewPaperTypeWhite;
            [[self.profile AppProfile] setPaperType:[NSNumber numberWithInt:SCHReadingViewPaperTypeWhite]];
        }
    }  

    // on the iPad if we have a narrow horizontal book then 4 recommendations
    // has problems with the limited space so reduce to 3 recommendations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (CGRectGetHeight([self.readingView pageRect]) <= kReadingViewMinimumBookHeightForFourRecommendations) {
            // MQC 8162: without the class check, a SCHRecommendationSampleView causes
            // a crash because it has no maxRecommendations
            if ([((SCHRecommendationContainerView *)self.recommendationView) isKindOfClass:[SCHRecommendationContainerView class]]) {
                ((SCHRecommendationContainerView *)self.recommendationView).maxRecommendations = 3;
                [self updateRecommendations];
            }
        }
    }
    
    [self.paperTypeSegmentedControl setSelectedSegmentIndex:self.paperType];
    
    [self.paperTypeSegmentedControl addTarget:self action:@selector(paperTypeSegmentChanged:) forControlEvents:UIControlEventValueChanged];

	self.scrubberInfoView.layer.cornerRadius = 5.0f;
	self.scrubberInfoView.layer.masksToBounds = YES;
    
    if (self.youngerMode) {
        [self.olderBottomToolbar removeFromSuperview];
    }
    
    BOOL pictureStarter = NO;
    
    if ([[self.bookStoryInteractions storyInteractionsOfClass:[SCHStoryInteractionPictureStarter class]] count]) {
        pictureStarter = YES;
    }
    
    BOOL readingChallenge = [self bookHasReadingChallenge];
        
    SCHReadingViewNavigationToolbarStyle style = 0;
    
    if (self.youngerMode) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (pictureStarter && readingChallenge) {
                style = kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterAndReadingChallengePhone;
            } else if (pictureStarter) {
                style = kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPhone;
            } else if (readingChallenge) {
                style = kSCHReadingViewNavigationToolbarStyleYoungerReadingChallengePhone;
            } else {
                style = kSCHReadingViewNavigationToolbarStyleYoungerPhone;
            }
        } else {
            if (pictureStarter && readingChallenge) {
                style = kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterAndReadingChallengePad;
            } else if (pictureStarter) {
                style = kSCHReadingViewNavigationToolbarStyleYoungerPictureStarterPad;
            } else if (readingChallenge) {
                style = kSCHReadingViewNavigationToolbarStyleYoungerReadingChallengePad;
            } else {
                style = kSCHReadingViewNavigationToolbarStyleYoungerPad; 
            }
        }
    } else {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            style = kSCHReadingViewNavigationToolbarStyleOlderPhone; 
        } else {
            style = kSCHReadingViewNavigationToolbarStyleOlderPad;
        }
    }
    
    // if the book has no audio, hide the audio button
    BOOL allowReadthrough = [self shouldAllowReadthrough];
    
    // if the help isn't yet downloaded, hide the help button
    BOOL showHelpButton = [[SCHHelpManager sharedHelpManager] haveHelpVideosDownloaded];
    
    SCHReadingViewNavigationToolbar *aNavigationToolbar = [[SCHReadingViewNavigationToolbar alloc] initWithStyle:style 
                                                                                                 showAudioButton:allowReadthrough
                                                                                                  showHelpButton:showHelpButton
                                                                                                     orientation:self.interfaceOrientation];
    
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier inManagedObjectContext:self.managedObjectContext];
    [aNavigationToolbar setTitle:book.Title];
    [aNavigationToolbar setDelegate:self];
    
    self.navigationToolbar = aNavigationToolbar;
    [aNavigationToolbar release];
 
    [self.view addSubview:self.navigationToolbar];
    
    BOOL bookReadThroughCompletely = [self bookHasBeenReadThroughCompletely];
    [self.navigationToolbar setReadingQuizItemActive:bookReadThroughCompletely];
    
    // Set non-rotation specific graphics
    [self.bottomShadow setImage:[UIImage imageNamed:@"reading-view-bottom-shadow.png"]];
    [self.scrubberToolbar setBackgroundImage:[UIImage imageNamed:@"reading-view-scrubber-bar.png"]];
    [self.olderBottomToolbar setBackgroundImage:[UIImage imageNamed:@"reading-view-bottom-bar.png"]];        
    [self.highlightsToolbar setBackgroundImage:[[UIImage imageNamed:@"reading-view-navigation-toolbar.png"] stretchableImageWithLeftCapWidth:5 topCapHeight:5]];

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
    self.notesCountView = [[[SCHNotesCountView alloc] initWithImage:[bgImage stretchableImageWithLeftCapWidth:10.0f topCapHeight:0]] autorelease];
    [self.notesButton addSubview:self.notesCountView];
    
    [self updateNotesCounter];
    
    [self setDictionarySelectionMode];
    
    [self save];
    
    self.bookStatisticsReadingStartTime = [NSDate serverDate];
    // MQC 8656: count the page we open to as having been read, so it shows up in
    // reading statistics even if the user doesn't flip any pages.
    [self.bookStatistics increasePagesReadBy:1];
    
    [self setupOptionsViewForMode:self.layoutType];
    self.optionsPhoneTopBackground.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"OptionsViewTopBackground"]];
    self.optionsPhoneTopBackground.layer.opaque = NO;
 
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    self.highlightsToolbar.alpha = 0.0f;
    [self.view addSubview:self.highlightsToolbar];
    [CATransaction commit];
    
    [self setToolbarVisibility:NO animated:NO];
    
    NSMutableArray *toolbarArray = [[NSMutableArray alloc] initWithArray:self.olderBottomToolbar.items];
    
    // Conditional Button Logic - remove buttons in reverse order to guarantee
    // that buttons and spacers are where we expect
    
    BOOL showOptions = YES;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        showOptions = NO;
    }
    
#if FLOW_VIEW_DISABLED
    showOptions = NO;
#else
    if (![self.bookPackageProvider containsFixedRepresentation]) {
        showOptions = NO;
    } else if (![bookPackageProvider containsFlowedRepresentation]) {
        showOptions = NO;
    }
#endif
    
    if (!showOptions) {
    // if flow view is disabled, then remove the options button
        if ([toolbarArray count] >= 11) {
            [toolbarArray removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(8, 2)]];
        }
    }
    
    // Reading Quiz
    if (!readingChallenge && [toolbarArray count] >= 9) {
        [toolbarArray removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(6, 2)]];
    }
    
    BOOL alreadyRemovedHighlights = NO;
    
#if IPHONE_HIGHLIGHTS_DISABLED
    // if highlights are disabled on iPhone, remove the highlights button
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone && [toolbarArray count] >= 5) {
        [toolbarArray removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)]];
        alreadyRemovedHighlights = YES;
    }
#endif
    
    self.appBookIsSuppressingHighlights = [[book valueForKey:kSCHAppBookSuppressFollowAlongHighlights] boolValue];

    if (self.appBookIsSuppressingHighlights && !alreadyRemovedHighlights && [toolbarArray count] >= 5) {
        [toolbarArray removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(2, 2)]];
    }
    
    // if the book has no story interactions remove the SI button
    if ([[self.bookStoryInteractions allStoryInteractionsExcludingInteractionWithPage:NO] count] <= 0 
        && [toolbarArray count] >= 2) {
        [toolbarArray removeObjectsAtIndexes:[NSIndexSet indexSetWithIndexesInRange:NSMakeRange(0, 2)]];
    }

    self.olderBottomToolbar.items = [NSArray arrayWithArray:toolbarArray];
    [toolbarArray release];
    
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
    
    // Hide the corner button until audio is checked in viewDidAppear
    self.cornerAudioButtonView.hidden = YES;
    
    [self updateScrubberValue];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (!self.firstTimePlayForHelpController) {
        [self positionCoverCornerViewForOrientation:self.interfaceOrientation];
        [self positionCornerAudioButtonForOrientation:self.interfaceOrientation];

        self.cornerAudioButtonView.hidden = ![self shouldAllowReadthrough];
        [self startFadeTimer];
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

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{    
    [self.navigationToolbar setOrientation:orientation];
    
    // set the highlights toolbar to the same size as the navigation toolbar
    CGRect toolbarFrame = self.navigationToolbar.frame;
    toolbarFrame.size.height -= kSCHReadingViewNavigationToolbarShadowHeight;
    self.highlightsToolbar.frame = toolbarFrame;

    // Adjust scrubber dimensions and graphics for younger mode (portrait only for iPhone)
    CGFloat scrubberToolbarHeight = kReadingViewOlderScrubberToolbarHeight;
    [self.pageSlider setThumbImage:nil forState:UIControlStateNormal];
    [self.pageSlider setThumbImage:nil forState:UIControlStateHighlighted];
    [self.pageSlider setMinimumTrackImage:nil forState:UIControlStateNormal];
    [self.pageSlider setMaximumTrackImage:nil forState:UIControlStateNormal];
    
    if (self.youngerMode) {
        if ((UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) ||
            (UIInterfaceOrientationIsPortrait(orientation))) {
            scrubberToolbarHeight = kReadingViewYoungerScrubberToolbarHeight;
            
            UIImage *leftSliderImage = [UIImage imageNamed:@"reading-view-scrubber-leftcap-large"];
            leftSliderImage = [leftSliderImage stretchableImageWithLeftCapWidth:6 topCapHeight:0];
            
            UIImage *rightSliderImage = [UIImage imageNamed:@"reading-view-scrubber-rightcap-large"];
            rightSliderImage = [rightSliderImage stretchableImageWithLeftCapWidth:6 topCapHeight:0];
            
            [self.pageSlider setThumbImage:[UIImage imageNamed:@"reading-view-scrubber-knob-large"] forState:UIControlStateNormal];
            [self.pageSlider setThumbImage:[UIImage imageNamed:@"reading-view-scrubber-knob-large"] forState:UIControlStateHighlighted];
            [self.pageSlider setMinimumTrackImage:leftSliderImage forState:UIControlStateNormal];
            [self.pageSlider setMaximumTrackImage:rightSliderImage forState:UIControlStateNormal];
        }
    }
    
    CGRect scrubberFrame = self.scrubberToolbar.bounds;
    if (CGRectGetHeight(scrubberFrame) != scrubberToolbarHeight) {
        scrubberFrame.size.height = scrubberToolbarHeight;
        scrubberFrame.origin.y = CGRectGetHeight(self.scrubberToolbar.superview.bounds) - scrubberToolbarHeight;
        self.scrubberToolbar.frame = scrubberFrame;
        
        CGRect bottomShadowFrame = self.bottomShadow.frame;
        bottomShadowFrame.origin.y = CGRectGetMinY(scrubberFrame) - CGRectGetHeight(bottomShadowFrame);
        self.bottomShadow.frame = bottomShadowFrame;
    }
    
    // highlights bar
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad || UIInterfaceOrientationIsPortrait(orientation)) {
        [self.highlightsInfoButton setImage:[UIImage imageNamed:@"icon-higlights-active"] forState:UIControlStateNormal];
        [self.highlightsCancelButton setImage:[UIImage imageNamed:@"icon-higlights-cancel"] forState:UIControlStateNormal];
    } else {
        [self.highlightsInfoButton setImage:[UIImage imageNamed:@"icon-higlights-active-landscape"] forState:UIControlStateNormal];
        [self.highlightsCancelButton setImage:[UIImage imageNamed:@"icon-higlights-cancel-landscape"] forState:UIControlStateNormal];
    }
    
    // options buttons
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self setupOptionsViewForMode:self.layoutType orientation:orientation];
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
    [self positionCoverCornerViewForOrientation:self.interfaceOrientation];

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

    [self dismissCoverCornerViewWithAnimation:NO];
    self.cornerAudioButtonView.alpha = 0;
    
    [self.readingView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
}

- (void)updateBookState
{
    if (self.managedObjectContext == nil) {
        return;
    }
    
    if (self.bookIdentifier != nil) {
 
        [self commitWishListChanges];

        if ([self.bookStatistics hasStatistics] == YES) {
            NSTimeInterval readingDuration = [[NSDate serverDate] timeIntervalSinceDate:self.bookStatisticsReadingStartTime];
            [self.bookStatistics increaseReadingDurationBy:floor(readingDuration)];
            self.bookStatisticsReadingStartTime = [NSDate serverDate];
            [self.profile newStatistics:self.bookStatistics forBook:self.bookIdentifier];
            self.bookStatistics = nil;
        }
        
        [self saveLastPageLocation];
        
        [self save];        
    }
}

#pragma mark - Notification methods

- (void)willResignActiveNotification:(NSNotification *)notification
{
    // On iOS < 5.0 UIApplicationDidEnterBackgroundNotification is not sent
    // when the device enters the lock screen instead we pause the audio on
    // UIApplicationWillResignActiveNotification
    if([[UIDevice currentDevice] compareSystemVersion:@"5.0"] < NSOrderedSame) {
        [self.readingView dismissFollowAlongHighlighter];  
        [self pauseAudioPlayback];
    }
}

- (void)didEnterBackgroundNotification:(NSNotification *)notification
{
    // If the user kills the app while we are performing background tasks the 
    // DidEnterBackground notification is called again, so we use a BOOL value to detect this
    // This is also used to prtect against updating highlights after backgrounding the app
    // enable it in the foreground
    if (!self.isInBackground) {
        self.isInBackground = YES;
    
        [self updateBookState];
        [self.readingView dismissFollowAlongHighlighter];  
        [self pauseAudioPlayback];

        SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier
                                                           inManagedObjectContext:self.managedObjectContext];
        [[SCHSyncManager sharedSyncManager] closeBookSyncForced:NO
                                                booksAssignment:book.ContentMetadataItem.booksAssignment
                                                     forProfile:self.profile];
        [[SCHSyncManager sharedSyncManager] wishListSyncForced:YES];
    }
}

- (void)willTerminateNotification:(NSNotification *)notification
{
    [self updateBookState];
    [self.bookPackageProvider reportReadingIfRequired];

    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier
                                                       inManagedObjectContext:self.managedObjectContext];
    [[SCHSyncManager sharedSyncManager] closeBookSyncForced:YES
                                            booksAssignment:book.ContentMetadataItem.booksAssignment
                                                 forProfile:self.profile];
    [[SCHSyncManager sharedSyncManager] wishListSyncForced:YES];
}

- (void)willEnterForegroundNotification:(NSNotification *)notification
{
    self.isInBackground = NO;
    self.bookStatisticsReadingStartTime = [NSDate serverDate];

    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier
                                                       inManagedObjectContext:self.managedObjectContext];
    [[SCHSyncManager sharedSyncManager] openBookSyncForced:NO
                                           booksAssignment:book.ContentMetadataItem.booksAssignment
                                                forProfile:self.profile
                                       requestReadingStats:[self bookHasReadingChallenge]];
    [[SCHSyncManager sharedSyncManager] backOfBookRecommendationSync:self.bookIdentifier];
    [[SCHSyncManager sharedSyncManager] wishListSyncForced:NO];
}

#pragma mark - Sync Propagation methods

- (void)bookDeleted:(NSNotification *)notification
{    
    if (self.managedObjectContext == nil) {
        return;
    }
    
    NSArray *bookIdentifiers = [notification.userInfo objectForKey:self.profile.ID];
    
    for (SCHBookIdentifier *bookId in bookIdentifiers) {
        if ([bookId isEqual:self.bookIdentifier] == YES) {
            SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier inManagedObjectContext:self.managedObjectContext];
            NSString *localizedMessage = [NSString stringWithFormat:
                                          NSLocalizedString(@"%@ has been removed", nil), book.Title];
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"eBook Removed", @"eBook Removed") 
                                  message:localizedMessage];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK") block:^{}];
            [alert show];
            [alert release];
            [[SCHBookManager sharedBookManager] checkInBookPackageProviderForBookIdentifier:self.bookIdentifier];
            self.bookIdentifier = nil;
            if (self.modalViewController != nil) {
                [self.modalViewController dismissModalViewControllerAnimated:NO];
            }              
            [self.storyInteractionController removeFromHostView];
            [self performSelector:@selector(backAction:) withObject:nil];
            break;
        }
    }
}

- (void)profileDeleted:(NSNotification *)notification
{
    // Immediately deregister for any more book related notifications so we don't try to handle following annotationChanges or bookDeleted notifications
    // The bookshelf view controller will actually tear us down and push back to the root when it receives the same notification
    if (self.profile.ID != nil) {
        NSArray *profileIDs = [notification.userInfo objectForKey:SCHProfileSyncComponentDeletedProfileIDs];
        
        for (NSNumber *profileID in profileIDs) {
            if ([profileID isEqualToNumber:self.profile.ID] == YES) {
                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:SCHContentSyncComponentWillDeleteNotification
                                                              object:nil];
                [[NSNotificationCenter defaultCenter] removeObserver:self
                                                                name:SCHAnnotationSyncComponentDidCompleteNotification
                                                              object:nil];
            }
        }
    }
}

- (void)annotationChanges:(NSNotification *)notification
{    
    if (self.profile.ID != nil) {
        NSNumber *profileID = [notification.userInfo objectForKey:SCHAnnotationSyncComponentProfileIDs];
        
        if ([profileID isEqualToNumber:self.profile.ID] == YES) {
            SCHReadingViewController *weakSelf = self;
            // dispatch this onto the main thread to avoid a race condition with the notification going to the SCHBookAnnotations object
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf updateNotesCounter];
                NSRange visibleIndices = [weakSelf storyInteractionPageIndices];
                
                // We don't want to update the views if we are in the background
                // Normally we shouldn't have time to dispatch to the main thread during backgrouding but it can happen
                // so this BOOL check is required
                if (!self.isInBackground) {
                    if ((visibleIndices.location != NSNotFound) && (visibleIndices.length != NSNotFound)) {
                        for (NSUInteger i = 0; i < visibleIndices.length; i++) {
                            [weakSelf.readingView refreshHighlightsForPageAtIndex:visibleIndices.location + i];
                        }
                    }
                }
            });
        }
    }
}

- (void)dictionaryStateChange:(NSNotification *)notification
{    
    if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryIsAvailable] == YES &&
        (self.readingView.selectionMode == SCHReadingViewSelectionModeYoungerNoDictionary)) {
        [self setDictionarySelectionMode];
    }
}

// detect any changes to the data
- (void)managedObjectContextDidSaveNotification:(NSNotification *)notification
{    
    // update the book name with the change
    for (SCHContentMetadataItem *object in [[notification userInfo] objectForKey:NSUpdatedObjectsKey]) {
        if ([object isKindOfClass:[SCHContentMetadataItem class]] == YES &&
            [[object bookIdentifier] isEqual:self.bookIdentifier] == YES) {
            [self.navigationToolbar setTitle:object.Title];
        }
    }    
}

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    // This is actually an error condition - we should *not* be changing the core data stack whilst in a book.
    // However as a defensive measure, make sure we release any retained managed object properties when this happens

    NSLog(@"WARNING: SCHReadingViewController is still in existence when the core data stack is reset. This is an error condition!");
    
    self.profile = nil;
    self.bookAnnotations = nil;
    self.bookStatistics = nil;
    self.managedObjectContext = nil;
    
    // Also, as an optimisation, check if our reading view is actually on screen. If not then release those objects too, otherwise we will run out of memory soon
    if ([self.readingView window] == nil) {
        [self releaseViewObjects];
    }
}    
    

#pragma mark - Book Positions

- (void)saveLastPageLocation
{
    if (self.bookAnnotations != nil) {
        SCHBookPoint *currentBookPoint = [self.readingView currentBookPoint];
        SCHLastPage *lastPage = [self.bookAnnotations lastPage];
        
        // We don't actually want to persist a generated last page as the current page
        NSUInteger pageCount = [self.readingView pageCount];
        NSUInteger currentPage = MIN(currentBookPoint.layoutPage, pageCount);
        lastPage.LastPageLocation = [NSNumber numberWithInteger:currentPage];
        
        // Progress should not be exactly 0 once a book is opened so always set a min of 0.001f and a max of 1.0f
        CGFloat progress = MIN(MAX([self.readingView currentProgressPosition], 0.001f), 1.0f);
        lastPage.Percentage = [NSNumber numberWithFloat:progress];
        [self save];
    }
}

- (SCHBookPoint *)lastPageLocation
{        
    SCHAppContentProfileItem *appContentProfileItem = [self.profile appContentProfileItemForBookIdentifier:self.bookIdentifier];
    SCHContentProfileItem *contentProfileItem = appContentProfileItem.ContentProfileItem;
    SCHLastPage *annotationsLastPage = [self.bookAnnotations lastPage];
    
    NSNumber *lastPageLocation = nil;
    
    // If we havnt yet received the annotations from the sync then use the contentprofileitem
    // lastpage, see SCHProfileItem:allBookIdentifiers where we do the same for the last modified date
    NSDate *contentProfileLastModified = [contentProfileItem LastModified];
    NSDate *annotationLastPageLastModified = [annotationsLastPage LastModified];
    if (contentProfileLastModified != nil && 
        annotationLastPageLastModified != nil &&
        [contentProfileLastModified compare:annotationLastPageLastModified] == NSOrderedDescending) {
        lastPageLocation = [contentProfileItem LastPageLocation];
    } else {
        lastPageLocation = [annotationsLastPage LastPageLocation];
    }
    
    SCHBookPoint *lastPoint = [[[SCHBookPoint alloc] init] autorelease];
    
    if (lastPageLocation) {
        lastPoint.layoutPage = MAX([lastPageLocation integerValue], 1);
    } else {
        lastPoint.layoutPage = 1;
    }
  
    if (lastPoint.layoutPage != 1) {
        self.coverMarkerShouldAppear = NO;
    }
    
    return lastPoint;
}

- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated 
{
    if (bookPoint) {
        
        NSLog(@"Layout page: %d", bookPoint.layoutPage);
        if (bookPoint.layoutPage != 1) {
            self.coverMarkerShouldAppear = NO;
        }
        
        [self.readingView jumpToBookPoint:bookPoint animated:animated];
    }
}

- (void)jumpToCurrentPlaceInBookAnimated:(BOOL)animated
{
    if (self.currentPageIndex == NSUIntegerMax) {
        self.coverMarkerShouldAppear = NO;
        [self.readingView jumpToProgressPositionInBook:self.currentBookProgress animated:YES];
    } else {
        if (self.currentPageIndex != 1) {
            self.coverMarkerShouldAppear = NO;
        }
        [self.readingView jumpToPageAtIndex:self.currentPageIndex animated:YES];
    }
}

- (BOOL)bookHasReadingChallenge
{
    return [[self.bookStoryInteractions storyInteractionsOfClass:[SCHStoryInteractionReadingChallenge class]] count];
}

#pragma mark - SCHReadingViewNavigationToolbarDelegate

- (void)backAction:(id)sender
{
    [self toolbarButtonPressed];
    
    [self updateBookState];
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier
                                                       inManagedObjectContext:self.managedObjectContext];
    [[SCHSyncManager sharedSyncManager] closeBookSyncForced:YES
                                            booksAssignment:book.ContentMetadataItem.booksAssignment
                                                 forProfile:self.profile];
    [[SCHSyncManager sharedSyncManager] wishListSyncForced:YES];
    [self.bookPackageProvider reportReadingIfRequired];
    [self.audioBookPlayer cleanAudio];
    
    [self.appController exitBook];
}

- (void)helpAction:(id)sender
{
    [self toolbarButtonPressed];
    
    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }

    [self presentHelpAnimated:YES];
    
    [self pauseAudioPlayback];        
}

- (void)pictureStarterAction:(id)sender
{
    [self toolbarButtonPressed];
    
    NSArray *storyInteractions = [self.bookStoryInteractions storyInteractionsOfClass:[SCHStoryInteractionPictureStarter class]];
    if ([storyInteractions count] < 1) {
        NSLog(@"No PictureStarter found - button should be disabled");
        return;
    }
    
    [self presentStoryInteraction:[storyInteractions lastObject]];
}

- (IBAction)readingQuizAction:(UIButton *)sender 
{
    [self toolbarButtonPressed];
    
    NSArray *storyInteractions = [self.bookStoryInteractions storyInteractionsOfClass:[SCHStoryInteractionReadingChallenge class]];
    if ([storyInteractions count] < 1) {
        NSLog(@"No Reading Quiz found - button should be disabled");
        return;
    }
    
    [self presentStoryInteraction:[storyInteractions lastObject]];
}

- (IBAction)audioAction:(id)sender
{
    NSLog(@"Audio Play action");
    
    [self toolbarButtonPressed];
    
    NSUInteger layoutPage = 0;
    NSUInteger pageWordOffset = 0;
    [self.readingView currentLayoutPage:&layoutPage pageWordOffset:&pageWordOffset];
    
    if (layoutPage <= [self.readingView pageCount]) {
        if (self.audioBookPlayer == nil) {            
            SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier inManagedObjectContext:self.managedObjectContext];
            NSArray *audioBookReferences = [book valueForKey:kSCHAppBookAudioBookReferences];
            NSError *error = nil;
        
            if(audioBookReferences != nil && [audioBookReferences count] > 0) {        
                self.audioBookPlayer = [[[SCHAudioBookPlayer alloc] init] autorelease];
                self.audioBookPlayer.xpsProvider = (SCHXPSProvider *)self.bookPackageProvider;
                BOOL success = [self.audioBookPlayer prepareAudio:audioBookReferences error:&error];
                if (success) {
                    self.audioBookPlayer.delegate = self;
                
                    success = [self.audioBookPlayer playAtLayoutPage:layoutPage
                                                      pageWordOffset:pageWordOffset
                                            priorToPlayingAudioBlock:^(NSUInteger wordsStartOnLayoutPage, SCHAudioBookPlayerStartPlayingAudioBlock startPlayingAudioBlock){
                                                if (wordsStartOnLayoutPage != layoutPage) {
                                                    if (self.layoutType == SCHReadingViewLayoutTypeFixed) {
                                                        self.pauseAudioOnNextPageTurn = NO;
                                                        __block SCHReadingViewController *weakSelf = self;
                                                        [self.readingView jumpToPageAtIndex:wordsStartOnLayoutPage - 1 animated:YES withCompletionHandler:^{
                                                            weakSelf.pauseAudioOnNextPageTurn = YES;
                                                            if (startPlayingAudioBlock() == YES) {
                                                                [weakSelf bookAudioPlayerStartedPlaying];
                                                            } else {
                                                                [weakSelf bookAudioPlayerFailed];
                                                            }
                                                        }];
                                                    }
                                                } else {
                                                    if (startPlayingAudioBlock() == YES) {
                                                        [self bookAudioPlayerStartedPlaying];
                                                    } else {
                                                        [self bookAudioPlayerFailed];
                                                    }
                                                }
                                            }];
                }

                if (success == NO) {
                    [self bookAudioPlayerFailed];
                }
            }
        } else if(self.audioBookPlayer.isPlaying == NO) {
            [self.audioBookPlayer playAtLayoutPage:layoutPage
                                    pageWordOffset:pageWordOffset
                          priorToPlayingAudioBlock:^(NSUInteger wordsStartOnLayoutPage, SCHAudioBookPlayerStartPlayingAudioBlock startPlayingAudioBlock){
                              if (startPlayingAudioBlock() == YES) {
                                  [self bookAudioPlayerStartedPlaying];
                              } else {
                                  [self bookAudioPlayerFailed];
                              }
                          }];
        } else {
            [self.readingView dismissFollowAlongHighlighter];  
            [self pauseAudioPlayback];
        }
    }
    else {
        [self reportNoAudioForLastPage];
    }
    
    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }    
    
    [self checkCornerAudioButtonVisibilityWithAnimation:YES];
}

- (void)reportNoAudioForLastPage
{
    self.audioBookPlayer = nil;
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                         message:NSLocalizedString(@"You have reached the end of this book.  Please return to an earlier place and tap the icon again.", @"")
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                               otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
}

- (void)bookAudioPlayerStartedPlaying
{
    [self setToolbarVisibility:NO animated:YES];
}

- (void)bookAudioPlayerFailed
{
    self.audioBookPlayer = nil;    
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error")
                                                         message:NSLocalizedString(@"Due to a problem with the audio we cannot play this audiobook.", @"")
                                                        delegate:nil
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                               otherButtonTitles:nil];
    [errorAlert show];
    [errorAlert release];
}

#pragma mark -
#pragma mark Button Actions

- (void)toolbarButtonPressed
{
    [self cancelInitialTimer];
    [self.readingView dismissSelector];
    [self pauseAudioPlayback];
}

- (void)presentHelpAnimated:(BOOL)animated
{
    SCHHelpViewController *helpViewController = [[SCHHelpViewController alloc] initWithNibName:nil 
                                                                                        bundle:nil
                                                                                   youngerMode:self.youngerMode];
    helpViewController.delegate = self;
    
    helpViewController.modalPresentationStyle = UIModalPresentationFullScreen;
    helpViewController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    
    [self.navigationController presentModalViewController:helpViewController animated:animated];
    [helpViewController release];
}

- (IBAction)storyInteractionAction:(id)sender
{
    [self toolbarButtonPressed];
    NSLog(@"List Story Interactions action");

    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }
    
    BOOL excludeInteractionWithPage = NO;
    if (self.layoutType == SCHReadingViewLayoutTypeFlow) {
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
    [self toolbarButtonPressed];
    
    NSLog(@"HighlightsAction action");
//    UIButton *highlightsButton = (UIButton *)sender;
//    [highlightsButton setSelected:![highlightsButton isSelected]];
    
    self.highlightsModeEnabled = !self.highlightsModeEnabled;

    // turn off the corner cover view if necessary
    [self dismissCoverCornerViewWithAnimation:YES];

    if (self.highlightsModeEnabled) {
        // set up the highlights toolbar
        [self setToolbarVisibility:YES animated:YES];
        
        // Need to dismiss selector now to ensure a highlight isn't added immediately
        [self.readingView dismissSelector];
        [self.readingView setSelectionMode:SCHReadingViewSelectionModeHighlights];
    } else {
        [self setToolbarVisibility:YES animated:YES];
        [self setDictionarySelectionMode];
    }
    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }
    
    [self pauseAudioPlayback];
}

- (IBAction)notesAction:(id)sender
{
    [self toolbarButtonPressed];
    
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
    
    [self toolbarButtonPressed];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (self.optionsView.superview) {
            [self.optionsView removeFromSuperview];
        } else {
            
            CGRect optionsFrame = self.optionsView.frame;
            optionsFrame.origin.x = 0;
            optionsFrame.origin.y = olderBottomToolbar.frame.origin.y - optionsFrame.size.height;
            
            optionsFrame.size.width = self.view.frame.size.width;
            self.optionsView.frame = optionsFrame;
            
            [self.view insertSubview:self.optionsView belowSubview:self.olderBottomToolbar];
        }
    } else {
        if (self.popover) {
            [self.popover dismissPopoverAnimated:YES];
            self.popover = nil;
        } else {

            UINavigationController *navController = [[[UINavigationController alloc] initWithRootViewController:self.popoverOptionsViewController] autorelease];
            self.popoverNavigationTitleLabel.autoresizingMask = UIViewAutoresizingNone; // Needed to display it in the popover titleView
            self.popoverOptionsViewController.navigationItem.titleView = self.popoverNavigationTitleLabel;

            self.popover = [[[UIPopoverController alloc] initWithContentViewController:navController] autorelease];
            
            self.popover.delegate = self;
            
            CGRect popoverRect = sender.frame;
            popoverRect.origin.x -= 0;
            
            [self.popover presentPopoverFromRect:popoverRect inView:self.olderBottomToolbar permittedArrowDirections:UIPopoverArrowDirectionDown animated:YES];
            [self setupOptionsViewForMode:self.layoutType];

        }
    }

    [self pauseAudioPlayback];
}

- (IBAction)storyInteractionButtonAction:(id)sender
{    
    NSLog(@"Pressed story interaction button");
    
    [self pauseAudioPlayback];
    [self.queuedAudioPlayer cancelPlaybackExecutingSynchronizedBlocks:YES beforeCompletionHandler:nil];
    
    if (self.optionsView.superview) {
        [self.optionsView removeFromSuperview];
    }

    BOOL excludeInteractionWithPage = (self.layoutType == SCHReadingViewLayoutTypeFlow);
    NSArray *storyInteractions = [self.bookStoryInteractions storyInteractionsForPageIndices:[self storyInteractionPageIndices]
                                                         excludingInteractionWithPage:excludeInteractionWithPage];
    
    if ([storyInteractions count]) {
        [self presentStoryInteraction:[storyInteractions objectAtIndex:0]];
    }
}

- (IBAction)toggleToolbarButtonAction:(id)sender
{
    // Setting highlight stops the flicker
    [self pauseAudioPlayback];
    
    [self dismissCoverCornerViewWithAnimation:YES];
    
    // Perform this after a delay to allow the button to unhighlight before teh animation starts
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(toggleToolbarVisibility) object:nil];
    [self performSelector:@selector(toggleToolbarVisibility) withObject:nil afterDelay:0.2f];
}


#pragma mark - Story Interactions methods

- (float)storyInteractionButtonFillLevelForCurrentPage
{
    NSRange pageIndices = [self storyInteractionPageIndices];
    NSInteger questionCount = [self.bookStoryInteractions storyInteractionQuestionCountForPageIndices:pageIndices];
    NSInteger completedCount = [self.bookStoryInteractions storyInteractionQuestionsCompletedForPageIndices:pageIndices];
    BOOL allDone = [self.bookStoryInteractions allQuestionsCompletedForPageIndices:pageIndices];
        
    float fillLevel;
    if (allDone) {
        fillLevel = 1.0f;
    } else if (questionCount == 0) {
        fillLevel = 0.0f;
    } else {
        fillLevel = (float)completedCount / questionCount;
    }
    
    return fillLevel;
}

- (NSInteger)numberOfStoryInteractionsOnCurrentPages
{
    BOOL excludeInteractionWithPage = (self.layoutType == SCHReadingViewLayoutTypeFlow);
    NSRange pageIndices = [self storyInteractionPageIndices];
    NSArray *storyInteractions = [self.bookStoryInteractions storyInteractionsForPageIndices:pageIndices
                                                                excludingInteractionWithPage:excludeInteractionWithPage];
    NSLog(@"pages = %d,%d interactions=%d", pageIndices.location, pageIndices.length, [storyInteractions count]);
    return [storyInteractions count];
}

- (void)setupStoryInteractionButtonForCurrentPagesAnimated:(BOOL)animated
{     
    // if a story interaction is active, hide the button
    if (self.storyInteractionController != nil) {
        // But still set up the fill level
        float fillLevel = [self storyInteractionButtonFillLevelForCurrentPage];
        [self.storyInteractionButton setFillLevel:fillLevel animated:NO];
        [self setStoryInteractionButtonVisible:NO animated:YES withSound:NO completion:nil];
        return;
    }
    
    NSInteger totalInteractionCount = [self numberOfStoryInteractionsOnCurrentPages];
    
    // only play sounds if the appearance is animated
    BOOL playAppearanceSound = animated;
    
    // override this if we've already played a sound for this page
    if (self.lastPageInteractionSoundPlayedOn == [self storyInteractionPageIndices].location) {
        playAppearanceSound = NO;
    }

    self.lastPageInteractionSoundPlayedOn = [self storyInteractionPageIndices].location;
    
    // if the audio book is playing, hide the story interaction button
    if (totalInteractionCount < 1 && (self.audioBookPlayer && self.audioBookPlayer.isPlaying)) {
        // No interactions, audio playing. Hiding button without animation
        [self setStoryInteractionButtonVisible:NO animated:NO withSound:NO completion:nil];
    } else if (totalInteractionCount < 1) {
        // No interactions. Hiding button with animation
        [self setStoryInteractionButtonVisible:NO animated:YES withSound:playAppearanceSound completion:nil];
    } else {
        if (totalInteractionCount >= 1 && (self.audioBookPlayer && self.audioBookPlayer.isPlaying)) {
            // Interactions while reading. Showing button without animation
            playAppearanceSound = NO;
            animated = NO;
        } // else Interactions while not reading. Showing button with animation
        
        float fillLevel = [self storyInteractionButtonFillLevelForCurrentPage];
        [self.storyInteractionButton setFillLevel:fillLevel animated:NO];
        
        [self setStoryInteractionButtonVisible:YES animated:animated withSound:playAppearanceSound completion:nil];
    }
}

- (void)setStoryInteractionButtonVisible:(BOOL)visible animated:(BOOL)animated withSound:(BOOL)sound completion:(void (^)(BOOL finished))completionBlock
{
    if (visible) {
                
        // if the frame is out of screen, move it back on
        if (!CGAffineTransformIsIdentity(self.storyInteractionButtonView.transform)) {
            void (^movementBlock)(void) = ^{
                self.storyInteractionButtonView.transform = CGAffineTransformIdentity;
                self.storyInteractionButtonView.alpha = 1.0f;
            };
            
            self.storyInteractionButtonView.alpha = 0.0f;
            
            if (animated) {
                [UIView animateWithDuration:0.3f 
                                      delay:0
                                    options:UIViewAnimationOptionAllowUserInteraction
                                 animations:movementBlock
                                 completion:completionBlock];
            } else {
                movementBlock();
                if (completionBlock) {
                    completionBlock(YES);
                }
            }
            
            // play the sound effect
            if (sound && !self.storyInteractionController && (!self.audioBookPlayer || !self.audioBookPlayer.isPlaying)) {
                // play sound effect only if requested - e.g. toolbar hide/show doesn't play sound
                // play sound effect only if there isn't a story interaction visible
                // play sound effect only if the book reading is not happening (which should never happen!)
                
                NSString *audioFilename = self.youngerMode ? @"sfx_siappears_y2B" : @"sfx_siappears_o";
                NSString *bundlePath = [[NSBundle mainBundle] pathForResource:audioFilename ofType:@"mp3"];
                
                [self.queuedAudioPlayer cancelPlaybackExecutingSynchronizedBlocks:NO beforeCompletionHandler:nil];
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
                                 completion:completionBlock];
            } else {
                animationBlock();
                if (completionBlock) {
                    completionBlock(YES);
                }
            }

        }
    } else {
        // hide the button
        
        void (^movementBlock)(void) = ^{
            CGRect frame = self.storyInteractionButtonView.frame;
            self.storyInteractionButtonView.transform = CGAffineTransformMakeTranslation(CGRectGetWidth(frame), 0);
            self.storyInteractionButtonView.alpha = 0.0f;
        };
        
        if (animated) {
            [UIView animateWithDuration:0.3f 
                                  delay:0
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:movementBlock
                             completion:completionBlock];
        } else {
            movementBlock();
            if (completionBlock) {
                completionBlock(YES);
            }
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

- (NSRange)storyInteractionPageIndices
{
    NSRange pageIndices = NSMakeRange(0, 0);
    
    if (self.layoutType == SCHReadingViewLayoutTypeFixed) {
        if (self.currentPageIndices.location != NSNotFound) {
            pageIndices = self.currentPageIndices;
        } else {
            pageIndices = NSMakeRange(self.currentPageIndex, 1);
        }
    } else if (self.layoutType == SCHReadingViewLayoutTypeFlow) {
        // If pagination isn't complete bail out
        if (self.currentPageIndex != NSUIntegerMax) {
            SCHBookRange *pageRange = [self.readingView currentBookRange];
            pageIndices = NSMakeRange(pageRange.startPoint.layoutPage - 1, pageRange.endPoint.layoutPage - pageRange.startPoint.layoutPage + 1);
        }
    }
    return pageIndices;
}

- (void)pushStoryInteractionController:(SCHStoryInteractionController *)aStoryInteractionController
{
    [self.bookStatistics increaseStoryInteractionsBy:1];
    [self setToolbarVisibility:NO animated:YES];
    
    SCHStoryInteractionStandaloneViewController *standalone = [[SCHStoryInteractionStandaloneViewController alloc] init];
    standalone.storyInteractionController = aStoryInteractionController;

    if ([aStoryInteractionController shouldAttachReadingView]) {
        [standalone attachBackgroundView:self.readingView];
    } else if ([aStoryInteractionController shouldSnapshotReadingView]) {
        [aStoryInteractionController attachSnapshot:[self.readingView pageSnapshot]];
    }

    if (aStoryInteractionController.shouldLockInterfaceOrientation) {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            [self.appController setLockedInterfaceOrientations:UIInterfaceOrientationMaskLandscape];
        } else {
            [self.appController setLockedInterfaceOrientations:UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown];
        }
    }
    
    // ensure the hosting view is the correct size before laying out the SI view
    standalone.view.frame = self.navigationController.view.bounds;
    
    [self.navigationController pushViewController:standalone animated:NO];
    [aStoryInteractionController presentInHostView:standalone.view
                              withInterfaceOrientation:standalone.interfaceOrientation];

    self.storyInteractionViewController = standalone;
    [standalone release];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self setupStoryInteractionButtonForCurrentPagesAnimated:YES];
    }

}

- (void)presentStoryInteraction:(SCHStoryInteraction *)storyInteraction
{
    [[UIApplication sharedApplication] beginIgnoringInteractionEvents];

    [self.readingView dismissReadingViewAdornments];
        
    self.storyInteractionController = [SCHStoryInteractionController storyInteractionControllerForStoryInteraction:storyInteraction];
    self.storyInteractionController.bookIdentifier= self.bookIdentifier;
    self.storyInteractionController.delegate = self;
    self.storyInteractionController.xpsProvider = (SCHXPSProvider *)self.bookPackageProvider;
    
    NSRange pageIndices = [self storyInteractionPageIndices];
    if (pageIndices.length == 2) {
        self.storyInteractionController.pageAssociation = SCHStoryInteractionQuestionOnBothPages;
    } else {
        self.storyInteractionController.pageAssociation = (pageIndices.location & 1) ? SCHStoryInteractionQuestionOnLeftPage : SCHStoryInteractionQuestionOnRightPage;
    }
    
    __block SCHReadingViewController *weakSelf = self;
    void (^presentStoryInteractionBlock)(void) = ^{
        [weakSelf setStoryInteractionButtonVisible:NO animated:YES withSound:NO completion:nil];
        [weakSelf pushStoryInteractionController:self.storyInteractionController];
        [[UIApplication sharedApplication] endIgnoringInteractionEvents];
    };
    
    if (self.layoutType == SCHReadingViewLayoutTypeFixed) {
        [(SCHLayoutView *)self.readingView zoomOutToCurrentPageWithCompletionHandler:presentStoryInteractionBlock];
    } else if (self.layoutType == SCHReadingViewLayoutTypeFlow) {
        presentStoryInteractionBlock();
    }
}

#pragma mark - Audio Control

- (void)pauseAudioPlayback
{
    if (self.audioBookPlayer) {
        [self.audioBookPlayer pause];
        [self.readingView dismissFollowAlongHighlighter];  
        [self setupStoryInteractionButtonForCurrentPagesAnimated:YES];
    }
    
    [self.navigationToolbar setAudioItemActive:NO];
}

#pragma mark - Audio Book Delegate methods

- (void)audioBookPlayerHighlightWordOld:(SCHAudioBookPlayer *)player
                             layoutPage:(NSUInteger)layoutPage
                         pageWordOffset:(NSUInteger)pageWordOffset
{
    //NSLog(@"WORD UP! at layoutPage %d pageWordOffset %d", layoutPage, pageWordOffset);
    self.pauseAudioOnNextPageTurn = NO;

    __block SCHReadingViewController *weakSelf = self;
    [self.readingView followAlongHighlightWordForLayoutPage:layoutPage
                                             pageWordOffset:pageWordOffset
                                      withCompletionHandler:^{
                                          weakSelf.pauseAudioOnNextPageTurn = YES;
                                      }];
}

- (void)audioBookPlayerHighlightWordNew:(SCHAudioBookPlayer *)player
                             layoutPage:(NSUInteger)layoutPage
                           audioBlockID:(NSUInteger)audioBlockID
                            audioWordID:(NSUInteger)audioWordID
{
    //NSLog(@"WORD UP! at layoutPage %d blockIndex %d wordIndex %d", layoutPage, audioBlockID, audioWordID);
    self.pauseAudioOnNextPageTurn = NO;
    // this assumes the RTX file format uses the same blockID and wordID as the textFlow
    SCHBookPoint *bookPoint = [[[SCHBookPoint alloc] init] autorelease];
    bookPoint.layoutPage = layoutPage;
    bookPoint.blockOffset = audioBlockID;
    bookPoint.wordOffset = audioWordID;

    __block SCHReadingViewController *weakSelf = self;
    [self.readingView followAlongHighlightWordAtPoint:bookPoint
                                withCompletionHandler:^{
                                    weakSelf.pauseAudioOnNextPageTurn = YES;
                                }];
}

- (void)audioBookPlayerPageTurn:(SCHAudioBookPlayer *)player
               turnToLayoutPage:(NSUInteger)turnToLayoutPage
{
    //NSLog(@"Turn to layoutPage %d", turnToLayoutPage);
    if (self.layoutType == SCHReadingViewLayoutTypeFixed) {
        self.pauseAudioOnNextPageTurn = NO;
        __block SCHReadingViewController *weakSelf = self;
        [self.readingView jumpToPageAtIndex:turnToLayoutPage - 1 animated:YES withCompletionHandler:^{
            weakSelf.pauseAudioOnNextPageTurn = YES;
        }];
    }
}

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

#pragma mark - Options View Setup and Button Actions

- (void)setupOptionsViewForMode:(SCHReadingViewLayoutType)newLayoutType
{
    [self setupOptionsViewForMode:newLayoutType orientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

- (void)setupOptionsViewForMode:(SCHReadingViewLayoutType)newLayoutType orientation:(UIInterfaceOrientation)orientation
{
    
    // initialise state
    BOOL iPhone = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone);
    BOOL landscape = UIInterfaceOrientationIsLandscape(orientation);
    
    BOOL isFlow = YES;

    if (newLayoutType == SCHReadingViewLayoutTypeFixed) {
        isFlow = NO;
    }
    
    // buttons - set the correct states and button types
    for (UIButton *button in self.customButtons) {
        button.selected = isFlow;
    }

    for (UIButton *button in self.originalButtons) {
        button.selected = !isFlow;
    }
    
    for (UIButton *button in self.largeOptionsButtons) {
        button.hidden = landscape;
    }

    for (UIButton *button in self.smallOptionsButtons) {
        button.hidden = !landscape;
    }
    
    
    if (iPhone) {
        NSInteger optionsViewHeight = 134;
        
        if (landscape && iPhone) {
            optionsViewHeight = 84;
        }
        
        if (isFlow) {
            
            // show the additional options and resize the parent view
            float totalHeight = ceilf(optionsViewHeight + self.customOptionsView.frame.size.height);
            
            if (!self.customOptionsView.superview) {
                CGRect frame = self.customOptionsView.frame;
                frame.origin.y = optionsViewHeight;
                frame.origin.x = 0;
                frame.size.width = self.view.frame.size.width;
                self.customOptionsView.frame = frame;
                self.customOptionsView.alpha = 0;
                
                [self.optionsView addSubview:self.customOptionsView];
            }
            
            // show the custom options
            [UIView animateWithDuration:0.25 
                                  delay:0.1 
                                options:UIViewAnimationOptionCurveEaseInOut 
                             animations:^{
                                 
                                 CGRect frame = self.optionsView.frame;
                                 frame.origin.y = CGRectGetMinY(self.olderBottomToolbar.frame) - totalHeight;
                                 frame.size.height = totalHeight;
                                 self.optionsView.frame = frame;
                                 
                                 frame = self.customOptionsView.frame;
                                 frame.origin.y = optionsViewHeight;
                                 self.customOptionsView.frame = frame;
                                 
                                 self.customOptionsView.alpha = 1;
                             } 
                             completion:nil];
            
        } else {
            
            // hide the additional options and resize the parent view
            [UIView animateWithDuration:0.25
                                  delay:0.1 
                                options:UIViewAnimationOptionCurveEaseInOut 
                             animations:^{
              
                                 CGRect frame = self.optionsView.frame;
                                 frame.origin.y = CGRectGetMinY(self.olderBottomToolbar.frame) - optionsViewHeight;
                                 frame.size.height = optionsViewHeight;
                                 self.optionsView.frame = frame;
                                 
                             }
                             completion:nil];
            
            self.customOptionsView.alpha = 0;
        }
        
        [self dismissCoverCornerViewWithAnimation:YES];
    } else {
        NSInteger optionsViewHeight = 110;

        if (isFlow) {
            // show the additional options and resize the popover
            float totalHeight = ceilf(optionsViewHeight + self.customOptionsView.frame.size.height);

            NSLog(@"Changing popover height.");
            self.popoverOptionsViewController.contentSizeForViewInPopover = CGSizeMake(200, totalHeight);
            
            NSLog(@"Frame for custom view BEFORE: %@", NSStringFromCGRect(self.customOptionsView.frame));
            
            [self.customOptionsView removeFromSuperview];
            
            if (!self.customOptionsView.superview) {
                CGRect frame = self.customOptionsView.frame;
                frame.origin.x = 0;
                frame.origin.y = optionsViewHeight;
                frame.size.width = 200;
                self.customOptionsView.frame = frame;
                
                [self.popoverOptionsViewController.view addSubview:self.customOptionsView];
            }
            
            NSLog(@"Frame for custom view AFTER: %@", NSStringFromCGRect(self.customOptionsView.frame));

            if (self.customOptionsView.alpha < 1) {
                [UIView animateWithDuration:0.25 animations:^{
                    self.customOptionsView.alpha = 1;
                }];
            }
            
        } else {
            // hide the additional options and resize the popover
            
            float totalHeight = 106;
            
            NSLog(@"Changing popover height.");
            self.popoverOptionsViewController.contentSizeForViewInPopover = CGSizeMake(200, totalHeight);
            
            if (self.customOptionsView.alpha > 0) {
                self.customOptionsView.alpha = 0;
            }
        }
    }
}

- (IBAction)fixedButtonPressed:(id)sender {
    if (self.layoutType != SCHReadingViewLayoutTypeFixed) {
        [self setupOptionsViewForMode:SCHReadingViewLayoutTypeFixed];
        [self.readingView dismissSelector];
        [self saveLastPageLocation];
        
        // Dispatch this after a delay to allow the slector to be immediately dismissed
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.1);
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            self.layoutType = SCHReadingViewLayoutTypeFixed;
            [self updateScrubberValue];
        });
    }
}

- (IBAction)flowedButtonPressed:(id)sender {
    
    if (self.layoutType != SCHReadingViewLayoutTypeFlow) {
        [self setupOptionsViewForMode:SCHReadingViewLayoutTypeFlow];
        [self.readingView dismissSelector];
        [self saveLastPageLocation];
        
        // Dispatch this after a delay to allow the slector to be immediately dismissed
        dispatch_time_t delay = dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.1);
        dispatch_after(delay, dispatch_get_main_queue(), ^{
            self.layoutType = SCHReadingViewLayoutTypeFlow;
            [self updateScrubberValue];
        });
    }
}

#pragma mark - Flowed/Fixed Toggle

- (void)setLayoutType:(SCHReadingViewLayoutType)newLayoutType
{
    if (newLayoutType != layoutType) {
                
        layoutType = newLayoutType;
        
        SCHReadingViewSelectionMode currentMode = [self.readingView selectionMode];
        
        NSNumber *savedLayoutType = [[self.profile AppProfile] LayoutType];
        
        if (!savedLayoutType || [savedLayoutType intValue] != newLayoutType) {
            savedLayoutType = [NSNumber numberWithInt:newLayoutType];
            [[self.profile AppProfile] setLayoutType:savedLayoutType];
        }
        
        BOOL useSavedFontAndPaperSettings = NO;
        
        [self.readingView removeFromSuperview];
        self.readingView = nil;
        
        SCHBookPoint *openingPoint = nil;
        
        if ([self.forceOpenToCover boolValue]) {
            self.forceOpenToCover = nil;
            openingPoint = [[[SCHBookPoint alloc] init] autorelease];
            openingPoint.layoutPage = 1;
        } else {
            openingPoint = [self lastPageLocation];
        }
        
        switch (newLayoutType) {
            case SCHReadingViewLayoutTypeFlow: {
                SCHFlowView *flowView = [[SCHFlowView alloc] initWithFrame:self.view.bounds 
                                                            bookIdentifier:self.bookIdentifier 
                                                      managedObjectContext:self.managedObjectContext 
                                                                  delegate:self
                                                                     point:openingPoint
                                              recommendationViewDataSource:self];
                self.readingView = flowView;
                [self setDictionarySelectionMode];
                
                [flowView release];
                
                [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:0];
                [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:1];
                
                useSavedFontAndPaperSettings = YES;
                
                break;
            }
            case SCHReadingViewLayoutTypeFixed: 
            default: {
                SCHLayoutView *layoutView = [[SCHLayoutView alloc] initWithFrame:self.view.bounds 
                                                                  bookIdentifier:self.bookIdentifier 
                                                            managedObjectContext:self.managedObjectContext                                          
                                                                        delegate:self
                                                                           point:openingPoint];
                self.readingView = layoutView;
                
                [self setDictionarySelectionMode];
                
                [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:0];
                [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:1];
                
                [layoutView release];
                
                break;
            }
        }
        
        self.readingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
        [self.readingView setSelectionMode:currentMode];
        [self.view addSubview:self.readingView];
        [self.view sendSubviewToBack:self.readingView];
        
        if (useSavedFontAndPaperSettings) {
            NSNumber *savedPaperType = [[self.profile AppProfile] PaperType];
            self.paperType = [savedPaperType intValue];
            
            NSNumber *savedFontSizeIndex = [[self.profile AppProfile] FontIndex];
            self.currentFontSizeIndex = [savedFontSizeIndex intValue];
        } else {
            self.paperType = SCHReadingViewPaperTypeWhite;
        }
    }
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
    [[self.profile AppProfile] setPaperType:[NSNumber numberWithInt:segControl.selectedSegmentIndex]];
}

#pragma mark - Font Size Toggle

- (void)updateFontSegmentStateForIndex:(NSInteger)index
{
    if (index >= [self.readingView maximumFontIndex]) {
        [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:1];
    } else {
        [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:1];
    }
    
    if (index <= 0) {
        [self.fontSegmentedControl setEnabled:NO forSegmentAtIndex:0];
    } else {
        [self.fontSegmentedControl setEnabled:YES forSegmentAtIndex:0];
    }

}

- (void)setCurrentFontSizeIndex:(int)newFontSizeIndex
{
    currentFontSizeIndex = newFontSizeIndex;
    
    // Suppress toolbar toggle (setting font size will cause the moveToPage callbackto fire and hide the toolbars)
    self.suppressToolbarToggle = YES; 
    [self.readingView setFontSizeIndex:newFontSizeIndex];
    self.suppressToolbarToggle = NO; 
    
    [self updateFontSegmentStateForIndex:newFontSizeIndex];
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
    
    index = MIN(MAX(index, 0), [self.readingView maximumFontIndex]);
    
    [self updateFontSegmentStateForIndex:index];
    
    self.currentFontSizeIndex = index;
}

#pragma mark - Dictionary

- (void)setDictionarySelectionMode
{
    if (self.youngerMode) {
        if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryIsAvailable] == NO) {
            [self.readingView setSelectionMode:SCHReadingViewSelectionModeYoungerNoDictionary];
        } else {
            [self.readingView setSelectionMode:SCHReadingViewSelectionModeYoungerDictionary];
        }
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
    if (self.bookAnnotations != nil) {
        SCHHighlight *newHighlight = [self.bookAnnotations createHighlightBetweenStartPage:startPage startWord:startWord endPage:endPage endWord:endWord color:[self highlightColor]];

        SCHAppContentProfileItem *appContentProfileItem = [profile appContentProfileItemForBookIdentifier:self.bookIdentifier];
        if (appContentProfileItem != nil) {
            newHighlight.Version = appContentProfileItem.ContentProfileItem.booksAssignment.version;
        }
        [self save];
    }
}

- (void)deleteHighlightBetweenStartPage:(NSUInteger)startPage startWord:(NSUInteger)startWord endPage:(NSUInteger)endPage endWord:(NSUInteger)endWord;
{    
    for (int page = startPage; page <= endPage; page++) {
        for (SCHHighlight *highlight in [self.bookAnnotations highlightsForPage:page]) {
            if (([highlight startLayoutPage] == startPage) &&
                ([highlight startWordOffset] == startWord) &&
                ([highlight endLayoutPage] == endPage) &&
                ([highlight endWordOffset] == endWord)) {
                [self.bookAnnotations deleteHighlight:highlight];
            }
        }
    }
    [self save];
}

- (NSArray *)highlightsForLayoutPage:(NSUInteger)page
{
    
#if IPHONE_HIGHLIGHTS_DISABLED
    // disable highlights if we're on the iPhone and the toggle is set
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return nil;
    }
#endif
    
    // check if the app book suppressing highlights
    if (self.appBookIsSuppressingHighlights) {
        return nil;
    } 

    return [self.bookAnnotations highlightsForPage:page];    
}

- (void)readingViewWillBeginTurning:(SCHReadingView *)readingView
{
    if (self.layoutType == SCHReadingViewLayoutTypeFixed) {
        if (self.pauseAudioOnNextPageTurn) {
            [self pauseAudioPlayback];
        }
        [self.queuedAudioPlayer cancelPlaybackExecutingSynchronizedBlocks:NO beforeCompletionHandler:nil];
    }

    // hide the toolbar if it's showing
    if (self.toolbarsVisible) {
        [self setToolbarVisibility:NO animated:YES];
    }

    // hide the book corner view if we need to
    if (self.coverMarkerShouldAppear) {
        self.coverMarkerShouldAppear = NO;
        
        [self dismissCoverCornerViewWithAnimation:YES];
    }
    
    // Hide the corner button until audio is checked in viewDidAppear
    [UIView animateWithDuration:0.1
                     animations:^{
                         self.cornerAudioButtonView.alpha = 0;
                     }];
    
    // hide the audio button
    if (self.audioBookPlayer && self.audioBookPlayer.isPlaying) {
        [self setStoryInteractionButtonVisible:NO animated:NO withSound:YES completion:nil];
    } else {
        [self setStoryInteractionButtonVisible:NO animated:YES withSound:YES completion:nil];
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
    [self setupStoryInteractionButtonForCurrentPagesAnimated:YES];
    
    BOOL bookReadThroughCompletely = [self bookHasBeenReadThroughCompletely];
    [self.navigationToolbar setReadingQuizItemActive:bookReadThroughCompletely];
    
    if (bookReadThroughCompletely) {
        [self.readingQuizButton setImage:[UIImage imageNamed:@"icon-readingquiz"] forState:UIControlStateNormal];
    } else {
        [self.readingQuizButton setImage:[UIImage imageNamed:@"icon-readingquiz-disabled"] forState:UIControlStateNormal];
    }
    
    BOOL changingFromOptionsView = (self.optionsView.superview || self.popover);
    
    // FIXME: decide if we want to hide the toolbars on change, or not
    if (self.toolbarsVisible && !self.initialFadeTimer && !changingFromOptionsView) {
        [self setToolbarVisibility:NO animated:YES];
    }
    
    [self positionCornerAudioButtonForOrientation:self.interfaceOrientation];
    [self checkCornerAudioButtonVisibilityWithAnimation:YES];
}

- (void)readingView:(SCHReadingView *)aReadingView hasMovedToPageAtIndex:(NSUInteger)pageIndex
{
    if (self.readingView == aReadingView) {
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
        
        // check to see if we've read this far before - if not, update furthest page read
        SCHBookPoint *currentBookPoint = [self.readingView currentBookPoint];
        
        // We don't actually want to persist a generated last page as the current page
        NSUInteger pageCount = [self.readingView pageCount];
        NSUInteger currentPage = MIN(currentBookPoint.layoutPage, pageCount);
        
        SCHAppContentProfileItem *appContentProfileItem = [self.profile appContentProfileItemForBookIdentifier:self.bookIdentifier];
        NSUInteger furthestPageRead = [appContentProfileItem.pageRead unsignedIntegerValue];
        
        if (furthestPageRead < currentPage) {
            furthestPageRead = currentPage;
            appContentProfileItem.PageRead = [NSNumber numberWithUnsignedInteger:furthestPageRead];
            [self save];
        }
        
        [self readingViewHasMoved];
    }
}

- (void)readingView:(SCHReadingView *)aReadingView hasRenderedPageAtIndex:(NSUInteger)pageIndex
{
    if (self.readingView == aReadingView) {
        //NSLog(@"Has rendered page %d", pageIndex);
        SCHStoryInteractionController *currentController = self.storyInteractionViewController.storyInteractionController;
        
        if ([currentController shouldSnapshotReadingView]) {            
            NSRange pageIndices = [self storyInteractionPageIndices];
            if (NSLocationInRange(pageIndex, pageIndices)) {
                [currentController attachSnapshot:[self.readingView pageSnapshot]];
            }
        }
    }
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
    
    // check to see if we've read this far before - if not, update furthest page read
    SCHBookPoint *currentBookPoint = [self.readingView currentBookPoint];
    
    // We don't actually want to persist a generated last page as the current page
    NSUInteger pageCount = [self.readingView pageCount];
    NSUInteger currentPage = MIN(currentBookPoint.layoutPage, pageCount);
    
    SCHAppContentProfileItem *appContentProfileItem = [self.profile appContentProfileItemForBookIdentifier:self.bookIdentifier];
    NSUInteger furthestPageRead = [appContentProfileItem.pageRead unsignedIntegerValue];
    
    if (furthestPageRead < currentPage) {
        furthestPageRead = currentPage;
        appContentProfileItem.PageRead = [NSNumber numberWithUnsignedInteger:furthestPageRead];
        [self save];
    }

    [self readingViewHasMoved];
}

- (void)readingView:(SCHReadingView *)readingView hasMovedToProgressPositionInBook:(CGFloat)progress
{
    // N.B. We don't increment pages read at all when pagination is in progress. We cannot reliably differentiate
    // between a user initiated page turn and a scrubber or book launch because we have no concept of page ordinality
    // We could in theory translate the previous and current page prgress into an index and try to differentiate large jumps
    // but it doesn't seem worthwhile for an unreliable result
    //
    // We also don't update the furthest page read here, for the same reasons.
    
    //NSLog(@"hasMovedToProgressPositionInBook %f", progress);
    self.currentPageIndex = NSUIntegerMax;
    self.currentBookProgress = progress;
    self.currentPageIndices = NSMakeRange(NSNotFound, 0);
    
    [self readingViewHasMoved];
}

- (void)readingView:(SCHReadingView *)readingView hasChangedFontPointToSizeAtIndex:(NSUInteger)fontSizeIndex
{
    NSNumber *savedFontSizeIndex = [[self.profile AppProfile] FontIndex];
    NSNumber *newFontSizeIndex = [NSNumber numberWithInt:fontSizeIndex];
    
    if (newFontSizeIndex && ![savedFontSizeIndex isEqualToNumber:newFontSizeIndex]) {
        [self updateFontSegmentStateForIndex:[newFontSizeIndex intValue]];
        [[self.profile AppProfile] setFontIndex:newFontSizeIndex];
        //NSLog(@"Saving fontSizeIndex as %@", newFontSizeIndex);
    }
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

- (NSUInteger)generatedPageCountForReadingView:(SCHReadingView *)aReadingView
{
    NSUInteger pageCount = [aReadingView pageCount];
    
    if ([self shouldShowBookRecommendationsForReadingView:aReadingView]) {
        pageCount = pageCount + 1;
    }
    
    return pageCount;
}

- (BOOL)readingView:(SCHReadingView *)aReadingView shouldGenerateViewForPageAtIndex:(NSUInteger)pageIndex
{
    if ([self shouldShowBookRecommendationsForReadingView:aReadingView]) {
        if (pageIndex == [self generatedPageCountForReadingView:aReadingView] - 1) {
            return YES;
        }
    }
    
    return NO;
}

- (UIView *)generatedViewForPageAtIndex:(NSUInteger)pageIndex
{
    return self.recommendationView;
}

- (void)updateRecommendations
{
    self.recommendationsDictionaries = nil;

    dispatch_block_t updateRecommendations = ^{
        [self.recommendationView updateWithRecommendationDictionaries:self.recommendationsDictionaries wishListDictionaries:self.modifiedWishListDictionaries];
    };
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), updateRecommendations);
    } else {
        updateRecommendations();
    }
}

- (void)recommendationDidUpdate:(NSNotification *)notification
{
    NSDictionary *recommendationItemDictionary = notification.userInfo;
    NSString *updatedRecommendationISBN = [recommendationItemDictionary objectForKey:kSCHAppRecommendationItemISBN];
    
    BOOL match = NO;
    
    if (updatedRecommendationISBN != nil) {
        SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
        SCHAppBook *book = [bookManager bookWithIdentifier:self.bookIdentifier inManagedObjectContext:bookManager.mainThreadManagedObjectContext];
        [[SCHRecommendationManager sharedManager] beginProcessingForRecommendationItems:[book appRecommendationItemsForBook]];

        for (SCHAppRecommendationItem *recommendationItem in [book appRecommendationItemsForBook]) {
            NSString *recommendationISBN = [recommendationItem ContentIdentifier];

            if (recommendationISBN != nil && [updatedRecommendationISBN isEqualToString:recommendationISBN] == YES) {
                match = YES;
                break;
            }
        }
    }
    
    if (match) {
        [self updateRecommendations];
    }
}

- (void)retrieveRecommendationsForBooksOperationCreateOrUpdateBooks:(NSNotification *)notification
{
    NSArray *booksCreatedOrUpdated = [notification.userInfo objectForKey:SCHRetrieveRecommendationsForBooksOperationBookIdentifiers];

    for (SCHBookIdentifier *bookId in booksCreatedOrUpdated) {
        if ([bookId isEqual:self.bookIdentifier] == YES) {

            // We are about to update recommendations so start processing them
            SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
            SCHAppBook *book = [bookManager bookWithIdentifier:self.bookIdentifier inManagedObjectContext:bookManager.mainThreadManagedObjectContext];
            [[SCHRecommendationManager sharedManager] beginProcessingForRecommendationItems:[book appRecommendationItemsForBook]];
            
            [self updateRecommendations];

            break;
        }
    }
}

#pragma mark - SCHReadingViewDelegate Toolbars methods

- (void)hideToolbars
{
    [self setToolbarVisibility:NO animated:YES];
}

#pragma mark - Scrubber

- (void)updateScrubberHUD
{
    BOOL suppressPageNumbers = NO;

    if (self.layoutType == SCHReadingViewLayoutTypeFixed &&
        self.shouldShowPageNumbersForFixedLayout == NO) {
        suppressPageNumbers = YES;
    }

    if (self.currentPageIndex != NSUIntegerMax) {
        
        if (!suppressPageNumbers) {
            [self.pageLabel setText:[self.readingView pageLabelForPageAtIndex:self.currentPageIndex showChapters:self.shouldShowChapters]];
        } else {
            [self.pageLabel setText:nil];
        }
    } else {
        [self.pageLabel setText:nil];
    }  
    
    if (self.layoutType == SCHReadingViewLayoutTypeFixed) {
        UIImage *scrubImage = [self.bookPackageProvider thumbnailForPage:self.currentPageIndex + 1];
        self.scrubberThumbImage.image = scrubImage;
    } else {
        self.scrubberThumbImage.image = nil;
    }
    
    CGSize imageSize = self.scrubberThumbImage.image.size;
    
    CGRect scrubFrame = self.scrubberInfoView.frame;
    scrubFrame.origin.x = self.view.bounds.size.width / 2 - (scrubFrame.size.width / 2);
    
    CGRect statusFrame = [[UIApplication sharedApplication] statusBarFrame];
    float statusBarHeight = MIN(statusFrame.size.height, statusFrame.size.width);

    if (!suppressPageNumbers) {
        self.pageLabel.hidden = NO;
    } else {
        self.pageLabel.hidden = YES;
    }
    
    // if we're in fixed view, and there's an image size set, then check if we're showing an image
    if ((self.layoutType == SCHReadingViewLayoutTypeFixed) && imageSize.width > 0 && imageSize.height > 0) {
        
        // the maximum space available for an image
        int maxImageHeight = (self.view.frame.size.height - scrubberToolbar.frame.size.height - self.navigationToolbar.frame.size.height - kReadingViewStandardScrubHeight - 60);
        
        // if we don't need page numbers, adjust the frame
        // if the page numbers are not showing, increase available space
        if (suppressPageNumbers) {
            CGRect imageFrame = self.scrubberThumbImage.frame;
            CGFloat heightDiff = imageFrame.origin.y - self.pageLabel.frame.origin.y;
            imageFrame.size.height = imageFrame.size.height + heightDiff;
            imageFrame.origin.y = self.pageLabel.frame.origin.y + 5;
            self.scrubberThumbImage.frame = imageFrame;
        }

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
    
    float topLimit = statusBarHeight + self.navigationToolbar.frame.size.height;
    float bottomLimit = self.view.frame.size.height - scrubberToolbar.frame.size.height;
    
    if ([self.olderBottomToolbar superview]) {
        bottomLimit -= self.olderBottomToolbar.frame.size.height;
    }
    
    if ([self.optionsView superview] && UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        bottomLimit -= self.optionsView.frame.size.height;
    }
    
    float topPoint = ((bottomLimit - topLimit) / 2) - (scrubFrame.size.height / 2);
    
    scrubFrame.origin.y = floorf(topLimit + topPoint);

    // if the page numbers are not showing, shrink the background to match the new cover position
    if (suppressPageNumbers) {
        scrubFrame.size.height -= self.pageLabel.frame.size.height;
    }
    
    self.scrubberInfoView.frame = CGRectIntegral(scrubFrame);

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
}

- (IBAction)scrubValueStartChanges:(UISlider *)slider
{
    [self.readingView dismissSelector];
    
    [self.optionsView removeFromSuperview];
    
    if (self.currentPageIndex == NSUIntegerMax) {
        self.currentBookProgress = [slider value];
    } else {
        self.currentPageIndex = roundf([slider value]);
    }
    
    [self updateScrubberHUD];
    
    // Only show the scrubber if it has contents
    if ([self.pageLabel.text length] || self.scrubberThumbImage.image) {
        [self.scrubberInfoView setAlpha:1.0f];
    } else {
        [self.scrubberInfoView setAlpha:0.0f];
    }
    
    [self.view addSubview:self.scrubberInfoView];
            
	[self cancelInitialTimer];
    
    self.currentlyScrubbing = YES;
    
}

- (IBAction)scrubValueEndChanges:(UISlider *)slider
{
    if (!self.currentlyScrubbing) {
        return;
    }
    
    [self dismissCoverCornerViewWithAnimation:YES];

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
        [self updateScrubberHUD];
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

	self.toolbarsVisible = visibility;

    if (self.toolbarsVisible) {
        if (!self.highlightsModeEnabled) {
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        }
        self.toolbarToggleView.alpha = 0.0f;
        self.cornerAudioButtonView.alpha = 0.0f;
        [self.readingView dismissReadingViewAdornments];

	} else {
        if (!self.highlightsModeEnabled) {
            [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationFade];
            self.toolbarToggleView.alpha = 1.0f;
        } else {
            self.toolbarToggleView.alpha = 0.0f;
        }
        
        [self checkCornerAudioButtonVisibilityWithAnimation:YES];
	}
    

	if (animated) {
		[UIView beginAnimations:@"toolbarFade" context:nil];
		[UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
		[UIView setAnimationDuration:0.3f];
		[UIView setAnimationBeginsFromCurrentState:YES];
	}
	
	if (self.toolbarsVisible) {
        if (self.highlightsModeEnabled) {
            [self.navigationToolbar setAlpha:1.0f];
            [self.scrubberToolbar setAlpha:0.0f];
            [self.bottomShadow setAlpha:0.0f];  
            if (!self.youngerMode) {
                [self.olderBottomToolbar setAlpha:0.0f];
            }
            [self.highlightsToolbar setAlpha:1.0f];
        } else {
            [self.navigationToolbar setAlpha:1.0f];
            [self.highlightsToolbar setAlpha:0.0f];
            [self.scrubberToolbar setAlpha:1.0f];
            if (!self.youngerMode) {
                [self.olderBottomToolbar setAlpha:1.0f];
            }

            [self.bottomShadow setAlpha:1.0f];  
        }

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.optionsView setAlpha:1.0f];
        }
        
	} else {
        if (!self.highlightsModeEnabled) {
            [self.highlightsToolbar setAlpha:0.0f];
            [self.navigationToolbar setAlpha:0.0f];
        }
        [self.scrubberToolbar setAlpha:0.0f];
        if (!self.youngerMode) {
            [self.olderBottomToolbar setAlpha:0.0f];
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self.optionsView setAlpha:0.0f];
        }
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
//    if (self.initialFadeTimer) {
//        [self.initialFadeTimer invalidate];
//        self.initialFadeTimer = nil;
//    }
//    
//    self.initialFadeTimer = [NSTimer scheduledTimerWithTimeInterval:5.0f
//                                                             target:self
//                                                           selector:@selector(hideToolbarsFromTimer)
//                                                           userInfo:nil
//                                                            repeats:NO];

    self.cornerCoverFadeTimer = [NSTimer scheduledTimerWithTimeInterval:4.0f 
                                                                 target:self selector:@selector(dismissCoverCornerView)
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
    NSUInteger noteCount = [self.bookAnnotations notesCount];
    self.notesCountView.noteCount = noteCount;
}

#pragma mark - SCHReadingNotesListControllerDelegate methods

- (NSInteger)countOfNotesForReadingNotesView:(SCHReadingNotesListController *)readingNotesView
{
    return [self.bookAnnotations notesCount];
}

- (SCHNote *)readingNotesView:(SCHReadingNotesListController *)readingNotesView noteAtIndex:(NSUInteger)index
{
    return [self.bookAnnotations noteAtIndex:index];
}

- (void)readingNotesViewCreatingNewNote:(SCHReadingNotesListController *)readingNotesView
{
    NSLog(@"Requesting a new note be created!");
    if (self.scratchNoteManagedObjectContext != nil) {
        SCHNote *scratchNote = [self.bookAnnotations createEmptyScratchNoteInManagedObjectContext:self.scratchNoteManagedObjectContext];
        
        SCHAppContentProfileItem *appContentProfileItem = [profile appContentProfileItemForBookIdentifier:self.bookIdentifier];
        if (appContentProfileItem != nil) {
            scratchNote.Version = appContentProfileItem.ContentProfileItem.booksAssignment.version;
        }
        
        SCHBookPoint *currentPoint = [self.readingView currentBookPoint];
        
        NSUInteger layoutPage = 0;
        NSUInteger pageWordOffset = 0;
        [self.readingView layoutPage:&layoutPage pageWordOffset:&pageWordOffset forBookPoint:currentPoint includingFolioBlocks:YES];
        
        NSLog(@"Current book point: %@", currentPoint);
        scratchNote.noteLayoutPage = layoutPage;
        
        SCHReadingNoteView *aNotesView = [[SCHReadingNoteView alloc] initWithNote:scratchNote];    
        aNotesView.delegate = self;
        aNotesView.newNote = YES;
        
        [self setupStoryInteractionButtonForCurrentPagesAnimated:YES];
        [self setToolbarVisibility:NO animated:YES];
        
        [aNotesView showInView:self.view animated:YES];
        [aNotesView release];
        [self save];
    }
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
    [self.bookAnnotations deleteNote:note];
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

- (NSString *)displayPageLabelForBookPoint:(SCHBookPoint *)bookPoint
{
    return [self.readingView displayPageLabelForBookPoint:bookPoint];
}

#pragma mark - SCHNotesViewDelegate methods

// We are only using this to create a temporary scratch version of a Note
// until the user says save then it's create on the main NSManagedObjectContext
- (NSManagedObjectContext *)scratchNoteManagedObjectContext
{
    if (scratchNoteManagedObjectContext == nil && 
        self.managedObjectContext != nil) {
        scratchNoteManagedObjectContext = [[NSManagedObjectContext alloc] init];
        [scratchNoteManagedObjectContext setPersistentStoreCoordinator:self.managedObjectContext.persistentStoreCoordinator];
    }
    
    return scratchNoteManagedObjectContext;
}

- (void)notesView:(SCHReadingNoteView *)aNotesView savedNote:(SCHNote *)note;
{
    NSLog(@"Saving note...");
    
    if (note != nil && note.PrivateAnnotations == nil) {
        [self.bookAnnotations createNoteWithNote:note];        
    }    
    self.scratchNoteManagedObjectContext = nil;
    // a new object will already have been created and added to the data store
    [self save];    
    [self setupStoryInteractionButtonForCurrentPagesAnimated:YES];
    [self setToolbarVisibility:YES animated:YES];
    
    [self updateNotesCounter];
    self.notesView = nil;    
}

- (void)notesViewCancelled:(SCHReadingNoteView *)aNotesView
{    
    self.scratchNoteManagedObjectContext = nil;
    
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
    NSParameterAssert(interaction < [[self.bookStoryInteractions allStoryInteractionsExcludingInteractionWithPage:interactionsView.excludeInteractionWithPage] count]);
    
    SCHStoryInteraction *storyInteraction = [[self.bookStoryInteractions allStoryInteractionsExcludingInteractionWithPage:interactionsView.excludeInteractionWithPage] objectAtIndex:interaction];
    
    SCHBookPoint *notePoint = [self.readingView bookPointForLayoutPage:[storyInteraction documentPageNumber]
                                                        pageWordOffset:0
                                                  includingFolioBlocks:YES];
    
    __block SCHReadingViewController *weakSelf = self;
    void (^presentStoryInteractionAfterDelay)(NSTimeInterval) = ^(NSTimeInterval delay) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * delay), dispatch_get_main_queue(), ^{
            [weakSelf presentStoryInteraction:storyInteraction];
            [[UIApplication sharedApplication] endIgnoringInteractionEvents];
        });
    };
    
    void (^jumpToPageAndPresentStoryInteractionBlock)(void) = ^{
        [[UIApplication sharedApplication] beginIgnoringInteractionEvents];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, NSEC_PER_SEC * 0.1), dispatch_get_main_queue(), ^{
            if ([[self.readingView currentBookPoint] isEqual:notePoint] == NO) {
                [self.readingView jumpToBookPoint:notePoint animated:YES withCompletionHandler:^{
                    presentStoryInteractionAfterDelay(1.2);
                }];
            } else {
                presentStoryInteractionAfterDelay(0.1);
            }
        });
    };
    
    if (self.layoutType == SCHReadingViewLayoutTypeFixed) {
        [(SCHLayoutView *)self.readingView zoomOutToCurrentPageWithCompletionHandler:jumpToPageAndPresentStoryInteractionBlock];
    } else if (self.layoutType == SCHReadingViewLayoutTypeFlow) {
        jumpToPageAndPresentStoryInteractionBlock();
    }
}

#pragma mark - SCHStoryInteractionControllerDelegate methods

- (void)storyInteractionController:(SCHStoryInteractionController *)aStoryInteractionController willDismissWithSuccess:(BOOL)success 
{
    // if the current reading view was attached to the SI view controller as a background, get it back
    UIView *view = [self.storyInteractionViewController detachBackgroundView];
    if (view) {
        [self.view insertSubview:view atIndex:0];
    }
    
    NSRange pageIndices = [self storyInteractionPageIndices];
    
    if (success || [aStoryInteractionController.storyInteraction alwaysIncrementsQuestionIndex]) {
        [self.bookStoryInteractions incrementQuestionIndexForPageIndices:pageIndices];
    }

    if (success) {
        [self.bookStoryInteractions incrementQuestionsCompletedForStoryInteraction:aStoryInteractionController.storyInteraction
                                                                       pageIndices:pageIndices];
    }
}

- (void)storyInteractionControllerDidDismiss:(SCHStoryInteractionController *)aStoryInteractionController
{
    [self.appController setLockedInterfaceOrientations:0];
    
    if (aStoryInteractionController == self.storyInteractionController) {
        if ([self.navigationController topViewController] != self) {
            [self.navigationController popViewControllerAnimated:NO];
        }
        self.storyInteractionController = nil;
        self.storyInteractionViewController = nil;
    }
    
    if ([self numberOfStoryInteractionsOnCurrentPages] > 0) {
        [self setStoryInteractionButtonVisible:YES animated:NO withSound:NO completion:nil];
    
        NSData * (^audioData)(void) = ^NSData*(void){
            NSString *audioFilename = @"sfx_si_fill";
            NSString *bundlePath = [[NSBundle mainBundle] pathForResource:audioFilename ofType:@"mp3"];
            return [NSData dataWithContentsOfFile:bundlePath
                                          options:NSDataReadingMapped
                                            error:nil];
        };
        float fillLevel = [self storyInteractionButtonFillLevelForCurrentPage];
        if (fillLevel != self.storyInteractionButton.fillLevel) {
            [self.queuedAudioPlayer enqueueAudioTaskWithFetchBlock:audioData
                                            synchronizedStartBlock:^{
                                                [self.storyInteractionButton setFillLevel:fillLevel animated:YES];
                                            }
                                              synchronizedEndBlock:nil];
        }
    }
}

- (NSInteger)currentQuestionForStoryInteraction
{
    NSRange pageIndices = [self storyInteractionPageIndices];
    return [self.bookStoryInteractions storyInteractionQuestionIndexForPageIndices:pageIndices];
}

- (void)advanceToNextQuestionForStoryInteraction
{
    NSRange pageIndices = [self storyInteractionPageIndices];
    
    if ([self.storyInteractionController.storyInteraction alwaysIncrementsQuestionIndex]) {
        [self.bookStoryInteractions incrementQuestionIndexForPageIndices:pageIndices];
    }
    
    [self.bookStoryInteractions incrementQuestionsCompletedForStoryInteraction:self.storyInteractionController.storyInteraction
                                                                   pageIndices:pageIndices];
}

- (BOOL)storyInteractionFinished
{
    return [self.bookStoryInteractions allQuestionsCompletedForPageIndices:[self storyInteractionPageIndices]];
}

- (BOOL)isOlderStoryInteraction
{
    return !self.youngerMode;
}

- (CGAffineTransform)viewToPageTransform
{
    if (self.layoutType != SCHReadingViewLayoutTypeFixed) {
        NSLog(@"WARNING: viewToPageTransformForPageIndex requested in flow view");
        return CGAffineTransformIdentity;
    }

    NSInteger pageIndex = [self storyInteractionPageIndices].location;
    if (self.readingView) {
        CGAffineTransform pageToView = [(SCHLayoutView *)self.readingView pageTurningViewTransformForPageAtIndex:pageIndex];
        return CGAffineTransformInvert(pageToView);
    } else {
        return CGAffineTransformIdentity;
    }
}

- (NSString *)storyInteractionCacheDirectory
{
    if (self.profile && self.profile.ID && self.bookIdentifier) {
        SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
        SCHAppBook *book = [bookManager bookWithIdentifier:self.bookIdentifier inManagedObjectContext:bookManager.mainThreadManagedObjectContext];    
        return [book storyInteractionsCacheDirectoryWithProfileID:[self.profile.ID stringValue]];
    } else {
        return nil;
    }
}

- (BOOL)bookHasBeenReadThroughCompletely
{
    NSUInteger pageCount = [self.readingView pageCount];
    
    SCHAppContentProfileItem *appContentProfileItem = [self.profile appContentProfileItemForBookIdentifier:self.bookIdentifier];
    NSUInteger furthestPageRead = [appContentProfileItem.pageRead unsignedIntegerValue];
    
    if (furthestPageRead >= (pageCount - 1)) {
        return YES;
    }
    
    return NO;
}

- (void)addQuizScore:(int)score total:(int)total
{
    SCHAppContentProfileItem *appContentProfileItem = [self.profile appContentProfileItemForBookIdentifier:self.bookIdentifier];
    
    [appContentProfileItem setBestScoreIfBetter:[NSNumber numberWithInt:score]];
    [self save];
    
    [bookStatistics addQuizTrialsItemScore:score total:total];
}

- (NSNumber *)bestQuizScore
{
    SCHAppContentProfileItem *appContentProfileItem = [self.profile appContentProfileItemForBookIdentifier:self.bookIdentifier];
    
    return appContentProfileItem.bestScore;
}

#pragma mark - SCHBookStoryInteractionsDelegate

- (CGSize)sizeOfPageAtIndex:(NSInteger)pageIndex
{
    if (pageIndex < 0) {
        NSLog(@"WARNING: sizeOfPageAtIndex requested for page %d", pageIndex);
        return CGSizeZero;
    }
    if (self.layoutType != SCHReadingViewLayoutTypeFixed) {
        return CGSizeZero;
    }
    
    CGRect viewRect = [self.readingView pageRect];
    CGAffineTransform viewToPage = [self viewToPageTransform];
    CGRect pageRect = CGRectApplyAffineTransform(viewRect, viewToPage);
    
    return pageRect.size;
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
    if ([self.managedObjectContext hasChanges] == YES &&
        [self.managedObjectContext save:&error] == NO) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

#pragma mark - Sample/SI Cover Corner

- (void)positionCoverCornerViewForOrientation: (UIInterfaceOrientation) newOrientation
{
    BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    if (iPad) {
        self.coverMarkerShouldAppear = NO;
    }
    
    if (self.highlightsModeEnabled) {
        self.coverMarkerShouldAppear = NO;
    }
    
    if (self.coverMarkerShouldAppear) {
        //        NSLog(@"reading view bounds: %@", NSStringFromCGRect([self.readingView pageRect]));
        
        // load the reading view
        if (self.sampleSICoverMarker) {
            [self.sampleSICoverMarker removeFromSuperview];
        }
        
        SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
        SCHAppBook *book = [bookManager bookWithIdentifier:self.bookIdentifier inManagedObjectContext:bookManager.mainThreadManagedObjectContext];    
        
        UIImage *coverMarkerImage = [self imageForFeature:book.bookFeatures];
        if (coverMarkerImage) {
            self.sampleSICoverMarker = [[[UIImageView alloc] initWithImage:coverMarkerImage] autorelease];
            
            // put it in the top right corner of the book
            CGRect bookCoverFrame = [self.readingView pageRect];
            
            CGRect frame = self.sampleSICoverMarker.frame;
            
            // offsets are to accommodate borders in the images
            frame.origin.x = ceilf((bookCoverFrame.origin.x + bookCoverFrame.size.width) - frame.size.width);
            frame.origin.y = ceilf(bookCoverFrame.origin.y);
            
            self.sampleSICoverMarker.frame = frame;
            
            self.sampleSICoverMarker.alpha = 0;
            [self.view insertSubview:self.sampleSICoverMarker belowSubview:self.navigationToolbar];
            
            [UIView animateWithDuration:0.3
                                  delay:0.1
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                self.sampleSICoverMarker.alpha = 1;
            }
                             completion:nil];
        }
    }
}

- (UIImage *)imageForFeature:(SCHAppBookFeatures *)bookFeatures
{
    UIImage *ret = nil;

    if (bookFeatures.features != kSCHAppBookFeaturesNone) {
        NSMutableString *imageName = [NSMutableString stringWithString:@"reading-"];

        if ([bookFeatures isSample] == YES) {
            [imageName appendFormat:@"sample"];
        }

        if ([bookFeatures hasStoryInteractions] == YES) {
            [imageName appendFormat:@"si"];
        }

        ret = [UIImage imageNamed:imageName];
        NSAssert(ret != nil, @"failed to load image '%@' for features %@", imageName, bookFeatures);        
    }
    
    return ret;
}

- (void)dismissCoverCornerView
{
    if (self.sampleSICoverMarker) {
        [self dismissCoverCornerViewWithAnimation:YES];
        self.coverMarkerShouldAppear = NO;
    }
}

- (void)dismissCoverCornerViewWithAnimation:(BOOL)animated
{
    if (!animated) {
        if ([self.sampleSICoverMarker superview]) {
            [self.sampleSICoverMarker removeFromSuperview];
            self.sampleSICoverMarker = nil;
        }
    } else {
        [UIView animateWithDuration:0.1 
                              delay:0
                            options:UIViewAnimationOptionAllowUserInteraction
                         animations:^{
                             self.sampleSICoverMarker.alpha = 0;
                         }
                         completion:^(BOOL finished) {
                             [self.sampleSICoverMarker removeFromSuperview];
                             self.sampleSICoverMarker = nil;
                         }];
    }
}

- (void)checkCornerAudioButtonVisibilityWithAnimation:(BOOL)animated
{
    // only show on the first page, if toolbars are not visible, not in highlights mode
    // and the audio isn't already playing (and it's in younger mode!)
    BOOL shouldShow = (self.currentPageIndex == 0 && !self.toolbarsVisible && !self.audioBookPlayer.isPlaying 
                       && self.youngerMode && !self.highlightsModeEnabled);
    float buttonAlpha = 0.0f;
    
    if (shouldShow) {
        buttonAlpha = 1.0f;
    }

    // don't try to change alpha if it's already set
    if (self.cornerAudioButtonView.alpha != buttonAlpha) {
    
        if (!animated) {
            self.cornerAudioButtonView.alpha = buttonAlpha;
        } else {
            [UIView animateWithDuration:0.3 
                                  delay:0
                                options:UIViewAnimationOptionAllowUserInteraction
                             animations:^{
                                 self.cornerAudioButtonView.alpha = buttonAlpha;
                             }
                             completion:nil];
        }
    }
}

- (void)positionCornerAudioButtonForOrientation:(UIInterfaceOrientation)newOrientation
{
    BOOL shouldShow = (self.currentPageIndex == 0 && !self.toolbarsVisible && !self.audioBookPlayer.isPlaying 
                       && self.youngerMode && !self.highlightsModeEnabled);
    
    if (shouldShow) {
        CGRect bookCoverFrame = [self.readingView pageRect];
        
        CGRect frame = self.cornerAudioButtonView.frame;
        
        // offsets are to accommodate borders in the images
        frame.origin.x = bookCoverFrame.origin.x + 5;
        frame.origin.y = bookCoverFrame.origin.y + ceilf(bookCoverFrame.size.height - frame.size.height) - 5;
        
        self.cornerAudioButtonView.frame = frame;
    }
}

#pragma mark - Help View Delegate

- (void)helpViewWillClose:(SCHHelpViewController *)helpViewController
{
    // clear the firstTimePlay flag if it was set - this allows the corner view to appear
    if (self.firstTimePlayForHelpController) {
        self.firstTimePlayForHelpController = NO;
    }
}

#pragma mark - Book Audio Readthrough Check

- (BOOL)shouldAllowReadthrough
{
    BOOL ret = NO;
    
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.bookIdentifier inManagedObjectContext:self.managedObjectContext];
    BOOL bookHasAudio = [[book HasAudio] boolValue];

    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore] == YES) {
        ret = bookHasAudio;
    } else {
        
        NSNumber *allowReadthrough = [self.profile allowReadThrough];
        
        // if the value is not set, then default to YES
        if (allowReadthrough == nil) {
            ret = bookHasAudio;
        } else {
            if (![allowReadthrough boolValue]) {
                ret = NO;
            } else {
                ret = bookHasAudio;
            }
        }
    }
    
    return ret;
}

#pragma mark - Book Recommendations

- (BOOL)shouldShowBookRecommendationsForReadingView:(SCHReadingView *)aReadingView
{
    BOOL ret = NO;
    
    if ([self recommendationsActive] == YES) {

        if ([[Reachability reachabilityForInternetConnection] isReachable] == YES) {
            ret = YES;
        } else {
            ret = ([[self recommendationsDictionaries] count] > 0);
        }
    }
    
    return ret;
}

- (BOOL)recommendationsActive
{
    BOOL ret = NO;
    
    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore] == YES) {
        ret = NO;
    } else if ([[self.profile recommendationsOn] boolValue] == YES) {
        ret = YES;
    }
    
    return ret;
}

- (NSArray *)recommendationsDictionaries
{
    if (!recommendationsDictionaries) {
        NSAssert([NSThread isMainThread], @"recommendationDictionaries must be created on the main thread");

        SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
        SCHAppBook *book = [bookManager bookWithIdentifier:self.bookIdentifier inManagedObjectContext:bookManager.mainThreadManagedObjectContext];    
        NSArray *allRecommendationsDictionaries = [book recommendationDictionaries];
                
        if ([book isSampleBook]) {
            NSString *sampleIsbn = [[self bookIdentifier] isbn];
            if (sampleIsbn) {
                for (NSDictionary *recommendationDictionary in allRecommendationsDictionaries) {
                    if ([[recommendationDictionary valueForKey:kSCHAppRecommendationItemISBN] isEqualToString:sampleIsbn]) {
                        recommendationsDictionaries = [[NSArray arrayWithObject:recommendationDictionary] retain];
                        break;
                    }
                }
            }
        } else {
            // all books that are not already on the wishlist
            NSIndexSet *recommendationsNotOnWishlist = [allRecommendationsDictionaries indexesOfObjectsPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                NSString *recommendationISBN = [obj objectForKey:kSCHAppRecommendationItemISBN];
                
                if (recommendationISBN != nil && recommendationISBN != (id)[NSNull null]) {
                    for (NSDictionary *wishlistItem in [self wishListDictionaries]) {
                        NSString *wishListISBN = [wishlistItem objectForKey:kSCHWishListISBN];
                        
                        if ([wishListISBN isEqualToString:recommendationISBN] == YES) {
                            return NO;
                        }
                    }                
                }
                
                return YES;
            }];
            
            NSArray *notOnWishlist = [allRecommendationsDictionaries objectsAtIndexes:recommendationsNotOnWishlist];
            if ([notOnWishlist count] < 4) {
                NSMutableArray *onWishlist = [[allRecommendationsDictionaries mutableCopy] autorelease];
                [onWishlist removeObjectsAtIndexes:recommendationsNotOnWishlist];
                
                recommendationsDictionaries = [[notOnWishlist arrayByAddingObjectsFromArray:onWishlist] retain];
            } else {
                recommendationsDictionaries = [notOnWishlist retain];
            }
        }
    }
    
    return recommendationsDictionaries;
}

- (NSMutableArray *)modifiedWishListDictionaries
{
    if (!modifiedWishListDictionaries) {
        modifiedWishListDictionaries = [[self wishListDictionaries] mutableCopy];
    }
    
    return modifiedWishListDictionaries;
}

- (NSArray *)wishListDictionaries
{
    if (!wishListDictionaries) {
        NSArray *wishListItemDictionaries = [[self.profile AppProfile] wishListItemDictionaries];
        wishListDictionaries = [wishListItemDictionaries mutableCopy];
    }
    
    return wishListDictionaries;
}

#pragma mark - SCHRecommendationSampleViewDelegate

- (void)recommendationSampleView:(SCHRecommendationListView *)listView addedISBNToWishList:(NSString *)ISBN
{
    [self recommendationListView:nil addedISBNToWishList:ISBN];
}

- (void)recommendationSampleView:(SCHRecommendationSampleView *)sampleView removedISBNFromWishList:(NSString *)ISBN
{
    [self recommendationListView:nil removedISBNFromWishList:ISBN];    
}

#pragma mark - SCHRecommendationListViewDelegate

- (void)recommendationListView:(SCHRecommendationListView *)listView addedISBNToWishList:(NSString *)ISBN
{
    // find the recommendation item
    NSUInteger index = [self.recommendationsDictionaries indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        return [[(NSDictionary *)obj objectForKey:kSCHAppRecommendationItemISBN] isEqualToString:ISBN];
    }];
    
    if (index != NSNotFound) {
        NSDictionary *recommendationItem = [self.recommendationsDictionaries objectAtIndex:index];
        
        // create the wishlist dictionary
        // add it to the profile
        NSMutableDictionary *wishListItem = [NSMutableDictionary dictionary];
        
        [wishListItem setValue:([recommendationItem objectForKey:kSCHAppRecommendationItemAuthor] == nil ? (id)[NSNull null] : [recommendationItem objectForKey:kSCHAppRecommendationItemAuthor]) 
                        forKey:kSCHWishListAuthor];
        [wishListItem setValue:([recommendationItem objectForKey:kSCHAppRecommendationItemISBN] == nil ? (id)[NSNull null] : [recommendationItem objectForKey:kSCHAppRecommendationItemISBN]) 
                        forKey:kSCHWishListISBN];
        [wishListItem setValue:([recommendationItem objectForKey:kSCHAppRecommendationItemTitle] == nil ? (id)[NSNull null] : [recommendationItem objectForKey:kSCHAppRecommendationItemTitle]) 
                        forKey:kSCHWishListTitle];
        
        [self.modifiedWishListDictionaries addObject:wishListItem];
    }
}
     
- (void)recommendationListView:(SCHRecommendationListView *)listView removedISBNFromWishList:(NSString *)ISBN
{
    // find the item in the modified list and remove it
    NSUInteger modifiedItemsIndex = [self.modifiedWishListDictionaries
                                     indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        return [[(NSDictionary *)obj objectForKey:kSCHAppRecommendationItemISBN] isEqualToString:ISBN];
    }];
    
    if (modifiedItemsIndex != NSNotFound) {
        [self.modifiedWishListDictionaries removeObjectAtIndex:modifiedItemsIndex];
    }
}

- (void)commitWishListChanges
{
    // look for items that are in the new list but not in the original list
    // those need to be added
    for (NSDictionary *item in self.modifiedWishListDictionaries) {
        if (![[self wishListDictionaries] containsObject:item]) {
            [[self.profile AppProfile] addToWishList:item];
        }
    }
    
    // look for items that are in the original but not in the new list
    // those need to be deleted
    for (NSDictionary *item in [self wishListDictionaries]) {
        if (![self.modifiedWishListDictionaries containsObject:item]) {
            [[self.profile AppProfile] removeFromWishList:item];
        }
    }
    
    [wishListDictionaries release], wishListDictionaries = nil;
}

#pragma mark - SCHRecommendationViewDataSource

- (UIView *)recommendationView
{
    if (!recommendationView) {
        NSAssert([NSThread mainThread], @"Cannot create recommendationView on background thread");
        
        if ([NSThread mainThread]) {
            SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
            SCHAppBook *book = [bookManager bookWithIdentifier:self.bookIdentifier inManagedObjectContext:bookManager.mainThreadManagedObjectContext];
            
            if ([book isSampleBook]) {
                // show the sample book version of recommendations
                SCHRecommendationSampleView *sampleView = [[self.recommendationSampleViewNib instantiateWithOwner:self options:nil] objectAtIndex:0];
                sampleView.delegate = self;
                
                if (![[SCHAppStateManager sharedAppStateManager] shouldShowWishList] ||
                    [[book purchasedBooks] containsObject:self.bookIdentifier.isbn]) {
                    [sampleView hideWishListButton];
                }
                
                recommendationView = [sampleView retain];
            } else {
                // show the recommendations container
                SCHRecommendationContainerView *containerView = [[self.recommendationsContainerNib instantiateWithOwner:self options:nil] objectAtIndex:0];
                containerView.listViewDelegate = self;
                
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    containerView.maxRecommendations = 3;
                }
                
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(retrieveRecommendationsForBooksOperationCreateOrUpdateBooks:)
                                                             name:SCHRetrieveRecommendationsForBooksOperationCreateOrUpdateBooksNotification
                                                           object:nil];
                
                recommendationView = [containerView retain];
            }
            
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(recommendationDidUpdate:)
                                                         name:kSCHRecommendationStateUpdateNotification
                                                       object:nil];
            
            [[SCHRecommendationManager sharedManager] beginProcessingForRecommendationItems:[book appRecommendationItemsForBook]];
            [self updateRecommendations];
        }
    }
    
    return recommendationView;
}

- (BOOL)shouldShowRecommendationView
{
    return [self shouldShowBookRecommendationsForReadingView:self.readingView];
}

@end
