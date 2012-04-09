//
//  SCHBookShelfViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 14/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfViewController.h"
#import "SCHBookShelfViewControllerProtected.h"

#import <QuartzCore/QuartzCore.h>
#import "SCHReadingViewController.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHBookManager.h"
#import "SCHSyncManager.h"
#import "SCHBookShelfGridViewCell.h"
#import "SCHXPSProvider.h"
#import "SCHAppBook.h"
#import "SCHCustomNavigationBar.h"
#import "SCHThemeManager.h"
#import "SCHThemeButton.h"
#import "SCHBookShelfGridView.h"
#import "KNFBTimeOrderedCache.h"
#import "SCHProfileItem.h"
#import "SCHAppProfile.h"
#import "SCHBookIdentifier.h"
#import "SCHProfileSyncComponent.h"
#import "LambdaAlert.h"
#import "SCHContentProfileItem.h"
#import "SCHAppContentProfileItem.h"
#import "SCHBookshelfSyncComponent.h"
#import "SCHAppStateManager.h"
#import "Reachability.h"
#import "BITModalSheetController.h"
#import "SCHStoriaWelcomeViewController.h"
#import "SCHUserDefaults.h"
#import "SCHVersionDownloadManager.h"
#import "SCHBookAnnotations.h"

static NSInteger const kSCHBookShelfViewControllerGridCellHeightPortrait = 138;
static NSInteger const kSCHBookShelfViewControllerGridCellHeightLandscape = 131;
static NSInteger const kSCHBookShelfViewControllerWelcomeShowMaximumCount = 2;

NSString * const kSCHBookShelfErrorDomain  = @"com.knfb.scholastic.BookShelfErrorDomain";

typedef enum 
{
	kSCHBookShelfNoInternet = 0
} SCHBookShelfError;

@interface SCHBookShelfViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, retain) SCHThemeButton *menuButton;
@property (nonatomic, retain) SCHThemeButton *backButton;
@property (nonatomic, assign) int moveToValue;
@property (nonatomic, assign) BOOL updateShelfOnReturnToShelf;
@property (nonatomic, assign) BOOL gridViewNeedsRefreshed;
@property (nonatomic, assign) BOOL listViewNeedsRefreshed;
@property (nonatomic, assign) int currentlyLoadingIndex;
@property (nonatomic, retain) LambdaAlert *loadingView;
@property (nonatomic, assign) BOOL shouldShowBookshelfFailedErrorMessage;
@property (nonatomic, assign) BOOL shouldWaitForCellsToLoad;
@property (nonatomic, retain) BITModalSheetController *welcomePopoverController;
@property (nonatomic, retain) BITModalSheetController *menuPopover;

- (void)showWelcomeView;
- (void)showWelcomeTwoView;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)updateTheme;
- (CGSize)cellSize;
- (CGFloat)cellBorderSize;
- (void)reloadDataImmediately:(BOOL)immediately;
- (void)reloadData;
- (void)save;
- (BOOL)canOpenBook:(SCHBookIdentifier *)identifier error:(NSError **)error;
- (void)selectBookAtIndex:(NSInteger)index startBlock:(dispatch_block_t)startBlock endBlock:(void (^)(BOOL didOpen))endBlock;

- (void)bookIdentifier:(SCHBookIdentifier *)identifier userRatingChanged:(NSInteger)newRating;

- (IBAction)changeToListView:(UIButton *)sender;
- (IBAction)changeToGridView:(UIButton *)sender;

- (void)showAppVersionOutdatedAlert;

@property (nonatomic, retain) UINib *listTableCellNib;

@end

@implementation SCHBookShelfViewController

@synthesize menuButton;
@synthesize backButton;
@synthesize listTableView;
@synthesize listTableCellNib;
@synthesize gridView;
@synthesize themePickerContainer;
@synthesize customNavigationBar;
@synthesize listToggleView;
@synthesize gridViewToggleView;
@synthesize books;
@synthesize profileItem;
@synthesize moveToValue;
@synthesize sortType;
@synthesize updateShelfOnReturnToShelf;
@synthesize listViewCell;
@synthesize managedObjectContext;
@synthesize currentlyLoadingIndex;
@synthesize backgroundView;
@synthesize gridViewNeedsRefreshed;
@synthesize listViewNeedsRefreshed;
@synthesize profileSetupDelegate;
@synthesize loadingView;
@synthesize shouldShowBookshelfFailedErrorMessage;
@synthesize shouldWaitForCellsToLoad;
@synthesize showWelcome;
@synthesize welcomePopoverController;
@synthesize showingRatings;
@synthesize menuPopover;

#pragma mark - Object lifecycle

- (void)releaseViewObjects 
{
    [gridView release], gridView = nil;
    [themePickerContainer release], themePickerContainer = nil;
    [customNavigationBar release], customNavigationBar = nil;
        
    [menuButton release], menuButton = nil;
    [backButton release], backButton = nil;    
    [listTableView release], listTableView = nil;
    [listToggleView release], listToggleView = nil;
    [listTableCellNib release], listTableCellNib = nil;
    [gridViewToggleView release], gridViewToggleView = nil;
    [backgroundView release], backgroundView = nil;
    [loadingView release], loadingView = nil;
    
    if ([welcomePopoverController isModalSheetVisible]) {
        [welcomePopoverController dismissSheetAnimated:NO completion:nil];
        [welcomePopoverController release], welcomePopoverController = nil;
    }
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SCHBookshelfSyncComponentBookReceivedNotification
                                                  object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self
												 name:SCHBookshelfSyncComponentDidCompleteNotification
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
												 name:SCHBookshelfSyncComponentDidFailNotification
											   object:nil];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Note that this needs to be registered outside viewDidLoad because when a readingViewController is pushed directly on from the profile view controller
        // The bookshelf view does not actually get loaded
        // but we want the bookshelfviewcontroller to orchestrate popping back to the root if it's profile is deleted
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(profileDeleted:)
                                                     name:SCHProfileSyncComponentWillDeleteNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(managedObjectContextDidSaveNotification:)
                                                     name:NSManagedObjectContextDidSaveNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc 
{    
    [self releaseViewObjects];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SCHProfileSyncComponentWillDeleteNotification
                                                  object:nil];
     
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:NSManagedObjectContextDidSaveNotification
                                                  object:nil];
    
    [books release], books = nil;
    [profileItem release], profileItem = nil;
    [managedObjectContext release], managedObjectContext = nil;
    profileSetupDelegate = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.gridViewNeedsRefreshed = YES;
    self.listViewNeedsRefreshed = YES;
    self.shouldShowBookshelfFailedErrorMessage = YES;
    self.showingRatings = NO;
    
    [self.listTableView setAlwaysBounceVertical:NO]; // For some reason this doesn't work when set from the nib
    
    // because we're using iOS 4 and above, use UINib to cache access to the NIB
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.listTableCellNib = [UINib nibWithNibName:@"SCHBookShelfTableViewCell_iPad" bundle:nil];
    } else {
        self.listTableCellNib = [UINib nibWithNibName:@"SCHBookShelfTableViewCell_iPhone" bundle:nil];
        self.showWelcome = NO;
    }
        
    self.menuButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [self.menuButton setThemeIcon:kSCHThemeManagerMenuIcon iPadQualifier:kSCHThemeManagerPadQualifierSuffix];
    [self.menuButton sizeToFit];    
    [self.menuButton addTarget:self action:@selector(presentMenu) forControlEvents:UIControlEventTouchUpInside];    

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.menuButton] autorelease];

    self.backButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [self.backButton setThemeIcon:kSCHThemeManagerHomeIcon iPadQualifier:kSCHThemeManagerPadQualifierSuffix];
    [self.backButton sizeToFit];    
    [self.backButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];    
    self.backButton.accessibilityLabel = @"Back To Bookshelves Button";
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.backButton] autorelease];
    
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar setTheme:kSCHThemeManagerNavigationBarImage];
    
    // uses the cellSize and cellBorderSize methods, which can be overridden
    [self.gridView setCellSize:[self cellSize] withBorderSize:[self cellBorderSize]];
    
    [self.gridView setBackgroundColor:[UIColor clearColor]];
    
    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore]) {
        [self.gridView setFooterText:NSLocalizedString(@"Notes and highlights made to sample eBooks will be lost when you sign in to your Scholastic account.", @"")];
        [self.gridView setFooterTextIsDark:[[SCHThemeManager sharedThemeManager] gridTextColorIsDark]];
    }
    
    self.sortType = [[[self.profileItem AppProfile] SortType] intValue];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:nil action:nil];
    longPress.delaysTouchesBegan = YES;
    longPress.delegate = self;
    [self.gridView addGestureRecognizer:longPress];
    [longPress release], longPress = nil;
	self.moveToValue = -1;
	
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(bookshelfSyncComponentBookReceived:)
												 name:SCHBookshelfSyncComponentBookReceivedNotification
											   object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(bookshelfSyncComponentDidComplete:)
												 name:SCHBookshelfSyncComponentDidCompleteNotification
											   object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(bookshelfSyncComponentDidFail:)
												 name:SCHBookshelfSyncComponentDidFailNotification
											   object:nil];

    if (!self.showWelcome) {
        if (![[SCHSyncManager sharedSyncManager] havePerformedFirstSyncUpToBooks] && [[SCHSyncManager sharedSyncManager] isSynchronizing]) {
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Syncing", @"")
                                  message:@"\n\n\n"];
            __block SCHBookShelfViewController *weakSelf = self;
            [alert addButtonWithTitle:NSLocalizedString(@"Back", @"") block:^{
                [weakSelf dismissLoadingView];
                [weakSelf performSelector:@selector(back)];
            }];
            
            if ([[SCHSyncManager sharedSyncManager] isSuspended]) {
                [alert addButtonWithTitle:NSLocalizedString(@"Dismiss", @"") block:^{
                    [weakSelf dismissLoadingView];
                }];
            }
            
            [alert setSpinnerHidden:NO];
            [alert show];
            self.loadingView = alert;
            [alert release];
        } else {
            [self dismissLoadingView];
        }
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme) name:kSCHThemeManagerThemeChangeNotification object:nil];              
    
    [self.listTableView setSeparatorColor:[UIColor clearColor]];

//    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
//
//        CGRect listFrame = self.listTableView.tableHeaderView.frame;
//        CGRect gridFrame = self.gridViewToggleView.frame;
//
//        listFrame.size.width = self.view.frame.size.width;
//        gridFrame.size.width = self.view.frame.size.width;
//
//        // this is the height of the top toggle view for both iPad and iPhone
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//            listFrame.size.height = 66;
//            gridFrame.size.height = 66;
//        } else {
//            listFrame.size.height = 44;
//            gridFrame.size.height = 44;
//        }
//        self.listTableView.tableHeaderView.frame = listFrame;
//        self.gridViewToggleView.frame = gridFrame;
//    
//        self.gridView.toggleView = self.gridViewToggleView;
//    }
    

        CGRect listFrame = self.listTableView.tableHeaderView.frame;
        CGRect gridFrame = self.gridViewToggleView.frame;

        listFrame.size.width = self.view.frame.size.width;
        gridFrame.size.width = self.view.frame.size.width;

        // this is the height of the top toggle view for both iPad and iPhone
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            listFrame.size.height = 0;
            gridFrame.size.height = 7;
        } else {
            listFrame.size.height = 0;
            gridFrame.size.height = 7;
        }
        self.listTableView.tableHeaderView.frame = listFrame;
        self.gridViewToggleView.frame = gridFrame;

    
    self.currentlyLoadingIndex = -1;

    if ([self.profileItem.AppProfile.ShowListView boolValue] == YES) {
        [self changeToListView:nil];
    }
    
    if (![[SCHAppStateManager sharedAppStateManager] isSampleStore]) {
        self.navigationItem.title = [self.profileItem bookshelfName:YES];
    } else {
        self.navigationItem.title = NSLocalizedString(@"My eBooks", @"Sample bookshelf title");
    }
    
    // Always force a sync if we are on the sample bookshelf
    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore]) {
        [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:NO];
        self.shouldWaitForCellsToLoad = YES;
        [self reloadDataImmediately:YES];
    } else {
        if ([[SCHSyncManager sharedSyncManager] isSynchronizing] == NO) {
            [[SCHSyncManager sharedSyncManager] firstSync:NO requireDeviceAuthentication:NO];
        }
        
        if ([[SCHSyncManager sharedSyncManager] isSuspended]) {
            [[SCHProcessingManager sharedProcessingManager] checkStateForAllBooks];
        }
    }
    
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
	[self releaseViewObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque]; // For the title text
    [self.navigationController setNavigationBarHidden:NO];
    
    [self setupAssetsForOrientation:self.interfaceOrientation];
    if (self.updateShelfOnReturnToShelf == YES) {
        self.updateShelfOnReturnToShelf = NO;
        self.books = [self.profileItem allBookIdentifiers];
    }    

    [self reloadData];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.shouldWaitForCellsToLoad = NO;
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSInteger currentWelcomeShowCount = [userDefaults integerForKey:kSCHUserDefaultsWelcomeViewShowCount];
    
    if (self.showWelcome &&
        currentWelcomeShowCount < kSCHBookShelfViewControllerWelcomeShowMaximumCount) {
        switch (currentWelcomeShowCount) {
            case 0:
                currentWelcomeShowCount++;
                [self showWelcomeView];        
                break;
            case 1:
                currentWelcomeShowCount++;
                [self showWelcomeTwoView];        
                break;
                
            default:
                break;
        }
        
        [userDefaults setInteger:currentWelcomeShowCount
                          forKey:kSCHUserDefaultsWelcomeViewShowCount];
        [userDefaults synchronize];
        
        self.showWelcome = NO;
    }
}

- (void)showWelcomeView
{
    SCHStoriaWelcomeViewController *welcomeVC = [[SCHStoriaWelcomeViewController alloc] init];
    
    BITModalSheetController *aWelcomePopoverController = [[BITModalSheetController alloc] initWithContentViewController:welcomeVC];
    [aWelcomePopoverController setContentSize:CGSizeMake(577, 241)];
    [aWelcomePopoverController setContentOffset:CGPointMake(0, -15)];
    
    __block BITModalSheetController *weakWelcomePopoverController = aWelcomePopoverController;
    __block SCHBookShelfViewController *weakSelf = self;
    
    welcomeVC.closeBlock = ^{
        [weakWelcomePopoverController dismissSheetAnimated:YES completion:nil];
        weakSelf.welcomePopoverController = nil;
    };
    
    [welcomeVC release];
    
    [aWelcomePopoverController presentSheetInViewController:self animated:YES completion:nil];
    
    self.welcomePopoverController = aWelcomePopoverController;
    
    [aWelcomePopoverController release];    
}

- (void)showWelcomeTwoView
{
    SCHStoriaWelcomeViewController *welcomeTwoVC = [[SCHStoriaWelcomeViewController alloc] initWithNibName:@"SCHStoriaWelcomeTwoViewController" bundle:nil];
    
    BITModalSheetController *aWelcomePopoverController = [[BITModalSheetController alloc] initWithContentViewController:welcomeTwoVC];
    [aWelcomePopoverController setContentSize:CGSizeMake(577, 241)];
    [aWelcomePopoverController setContentOffset:CGPointMake(0, -15)];
    
    __block BITModalSheetController *weakWelcomePopoverController = aWelcomePopoverController;
    __block SCHBookShelfViewController *weakSelf = self;
    
    welcomeTwoVC.closeBlock = ^{
        [weakWelcomePopoverController dismissSheetAnimated:YES completion:nil];
        weakSelf.welcomePopoverController = nil;
    };
    
    [welcomeTwoVC release];
    
    [aWelcomePopoverController presentSheetInViewController:self animated:YES completion:nil];
    
    self.welcomePopoverController = aWelcomePopoverController;
    
    [aWelcomePopoverController release];    
}

- (void)reloadData
{
    [self reloadDataImmediately:NO];
}

- (void)reloadDataImmediately:(BOOL)immediately
{
    dispatch_block_t reloadBlock = ^{ 
        if (![self.listTableView isHidden] && self.listViewNeedsRefreshed) {
            NSLog(@"Reloading the list view.");
            self.listViewNeedsRefreshed = NO;
            [self.listTableView reloadData];
        }
        
        if (![self.gridView isHidden] && self.gridViewNeedsRefreshed) {
            NSLog(@"Reloading the grid view.");
            self.gridViewNeedsRefreshed = NO;
            [self.gridView reloadData];
        }
    };
    
    if (immediately) {
        reloadBlock();
    } else {
        dispatch_async(dispatch_get_main_queue(), reloadBlock);
    }
    
}

#pragma mark - Orientation methods

// Note: this is overridden in the iPad subclass
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self.gridView setShelfImage:[[SCHThemeManager sharedThemeManager] imageForShelf:interfaceOrientation]];       
    [self.menuButton updateTheme:interfaceOrientation];
    [self.backButton updateTheme:interfaceOrientation];
    
    [self.backgroundView setImage:[[SCHThemeManager sharedThemeManager] imageForBackground:UIInterfaceOrientationPortrait]]; // Note we re-use portrait
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar updateTheme:interfaceOrientation];
    self.listTableView.backgroundColor = [[SCHThemeManager sharedThemeManager] colorForListBackground];
    self.listToggleView.backgroundColor = [[SCHThemeManager sharedThemeManager] colorForListBackground]; 
     
    CGFloat inset = 56;

    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
            [self.gridView setShelfHeight:kSCHBookShelfViewControllerGridCellHeightLandscape];
            [self.gridView setShelfInset:CGSizeMake(0, -inset)];
    } else {
            [self.gridView setShelfHeight:kSCHBookShelfViewControllerGridCellHeightPortrait];
            [self.gridView setShelfInset:CGSizeMake(0, -inset)];
    }    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return(YES);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    CGPoint curentOffset = self.gridView.contentOffset;
    [self setupAssetsForOrientation:toInterfaceOrientation];
    
    // Forcing a very small adjustment in content offset seems to be needed to get the books to layout correctly on shelves
    // Addresses ticket #439
    [self.gridView setContentOffset:CGPointMake(curentOffset.x, curentOffset.y + 1) animated:NO];
    [self.gridView setContentOffset:CGPointMake(curentOffset.x, curentOffset.y) animated:NO];
    
    // reload the views next time we switch to accommodate rotation
    self.gridViewNeedsRefreshed = YES;
    self.listViewNeedsRefreshed = YES;
}

// Note: this is subclassed in the iPad controller
- (void)updateTheme
{
    [self setupAssetsForOrientation:self.interfaceOrientation];
    
    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore]) {
        [self.gridView setFooterTextIsDark:[[SCHThemeManager sharedThemeManager] gridTextColorIsDark]];
    }
}

#pragma mark - Private methods

- (void)presentMenu
{
//    self.themePickerContainer.modalPresentationStyle = UIModalPresentationFormSheet;
//    self.themePickerContainer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
//    self.themePickerContainer.title = @"";
//    
//	[self presentModalViewController:self.themePickerContainer animated:YES];		
    
    NSLog(@"Presenting menu...");
    
    SCHBookShelfMenuController *menuTableController = [[SCHBookShelfMenuController alloc] initWithNibName:@"SCHBookShelfMenuController" 
                                                                                                   bundle:nil 
                                                                                     managedObjectContext:self.managedObjectContext];
    menuTableController.delegate = self;
    menuTableController.userIsAuthenticated = !TOP_TEN_DISABLED && [[SCHAppStateManager sharedAppStateManager] canAuthenticate];
    
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:menuTableController];
    SCHCustomNavigationBar *customBar = [[SCHCustomNavigationBar alloc] init];
    [navCon setValue:customBar forKeyPath:@"navigationBar"];
    
    [customBar setTheme:kSCHThemeManagerNavigationBarImage];
    [customBar release];
    
    
    // present from a modal sheet
    
    self.menuPopover = [[[BITModalSheetController alloc] initWithContentViewController:navCon] autorelease];
    [self.menuPopover setContentSize:CGSizeMake(320, 460)];
    [self.menuPopover setContentOffset:CGPointMake(0, 0)];
    
//    __block BITModalSheetController *weakPopoverController = self.menuPopover;
//    __block SCHBookShelfViewController *weakSelf = self;
    
//    menuTableController.closeBlock = ^{
//        [weakPopoverController dismissSheetAnimated:YES completion:nil];
//        weakSelf.recommendationPopover = nil;
//    };
    
    [self.menuPopover presentSheetInViewController:self animated:YES completion:nil];
    
    [menuTableController release];
    [navCon release];

}

- (void)dismissLoadingView
{
    if (self.loadingView != nil) {
        [self.loadingView setSpinnerHidden:YES];        
        [self.loadingView dismissAnimated:NO];        
        self.loadingView = nil;
    }
}

- (void)replaceLoadingAlertWithAlert:(LambdaAlert *)alert
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self.loadingView setSpinnerHidden:YES];
    [self.loadingView dismissAnimated:NO];
    self.loadingView = nil;
    
    [alert show];
    
    [CATransaction commit];
}

#pragma mark - Action methods

- (void)toggleRatings
{
    self.showingRatings = !self.showingRatings;
    
    NSLog(@"Toggling ratings to %@. FIXME: need to change icon.", self.showingRatings?@"Yes":@"No");

    self.gridViewNeedsRefreshed = YES;
    self.listViewNeedsRefreshed = YES;
    [self reloadData];
}

- (IBAction)back
{
    self.profileItem.AppProfile.ShowListView = [NSNumber numberWithBool:self.listTableView.hidden == NO];
    
    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore] == YES) {
        [self.profileItem clearBookOrder:self.books];
        [[self.profileItem AppProfile] setSortType:[NSNumber numberWithInt:kSCHBookSortTypeUser]];
        [self.navigationController popToRootViewControllerAnimated:NO];  
        [[SCHThemeManager sharedThemeManager] resetToDefault];
    } else {
        [self.profileSetupDelegate popToAuthenticatedProfileAnimated:YES];
    }
    
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer 
{
    [self.gridView setEditing:YES animated:YES];
    self.sortType = kSCHBookSortTypeUser;
    
    return NO;
}

#pragma mark - Bookshelf Menu Delegate

- (SCHBookSortType)sortTypeForBookShelfMenu:(SCHBookShelfMenuController *)controller
{
    return self.sortType;
}

- (void)bookShelfMenu:(SCHBookShelfMenuController *)controller changedSortType:(SCHBookSortType)newSortType
{
    self.sortType = newSortType;
    [[self.profileItem AppProfile] setSortType:[NSNumber numberWithInt:self.sortType]];
    
    self.books = [self.profileItem allBookIdentifiers];
    [self dismissLoadingView];
    
    if (self.menuPopover) {
        [self.menuPopover dismissSheetAnimated:YES completion:^{}];
    }
}

- (void)bookShelfMenuSwitchedToGridView:(SCHBookShelfMenuController *)controller
{
    if (self.menuPopover) {
        [self.menuPopover dismissSheetAnimated:YES completion:^{}];
    }

    [self changeToGridView:nil];
}

- (void)bookShelfMenuSwitchedToListView:(SCHBookShelfMenuController *)controller
{
    if (self.menuPopover) {
        [self.menuPopover dismissSheetAnimated:YES completion:^{}];
    }

    [self changeToListView:nil];
}

- (void)bookShelfMenuCancelled:(SCHBookShelfMenuController *)controller
{
    if (self.menuPopover) {
        [self.menuPopover dismissSheetAnimated:YES completion:^{}];
    }
}

- (SCHAppProfile *)appProfileForBookShelfMenu
{
    return self.profileItem.AppProfile;
}

#pragma mark - Accessor Methods

- (void)setProfileItem:(SCHProfileItem *)newProfileItem
{
    [newProfileItem retain];	    
	[profileItem release];
    profileItem = newProfileItem;
    
    if (![[SCHAppStateManager sharedAppStateManager] isSampleStore]) {
        self.navigationItem.title = [self.profileItem bookshelfName:YES];
    }

	self.books = [self.profileItem allBookIdentifiers];
        
    // tell the theme manager which profile to use for storage
    [SCHThemeManager sharedThemeManager].appProfile = self.profileItem.AppProfile;
}

- (void)setBooks:(NSMutableArray *)newBooks
{
    [newBooks retain];
	[books release];
    books = newBooks;
    
    self.gridViewNeedsRefreshed = YES;
    self.listViewNeedsRefreshed = YES;
    [self reloadData];
}

- (BOOL)isBookOnShelf:(SCHBookIdentifier *)aBookIdentifier
{
    BOOL ret = NO;
    
    for (SCHBookIdentifier *bookIdentifier in self.books) {
        if ([aBookIdentifier isEqual:bookIdentifier] == YES) {
            ret = YES;
            break;
        }
    }
    
    return(ret);
}

#pragma mark - View Type Toggle methods

- (IBAction)changeToGridView:(UIButton *)sender
{
    if (self.gridView.hidden == YES) {
        // save change to profile
        self.profileItem.AppProfile.ShowListView = [NSNumber numberWithBool:NO];
        [self save];

        self.listTableView.hidden = YES;
        self.gridView.hidden = NO;
        [self reloadData];
    }
}

- (IBAction)changeToListView:(UIButton *)sender
{
    if (self.listTableView.hidden == YES) {
        // save change to profile
        self.profileItem.AppProfile.ShowListView = [NSNumber numberWithBool:YES];
        [self save];

        self.listTableView.hidden = NO;
        self.gridView.hidden = YES;
        [self reloadData];
    }
}

#pragma mark - Sync Propagation methods

- (void)profileDeleted:(NSNotification *)notification
{
    if (self.profileItem.ID != nil) {
        NSArray *profileIDs = [notification.userInfo objectForKey:SCHProfileSyncComponentDeletedProfileIDs];
        
        for (NSNumber *profileID in profileIDs) {
            if ([profileID isEqualToNumber:self.profileItem.ID] == YES) {
                
                if (self.modalViewController != nil) {
                    [self.modalViewController dismissModalViewControllerAnimated:NO];
                }
                
                NSString *localizedMessage = [NSString stringWithFormat:
                                              NSLocalizedString(@"%@ has been removed", nil), [self.profileItem bookshelfName:YES]];  
                LambdaAlert *alert = [[LambdaAlert alloc]
                                      initWithTitle:NSLocalizedString(@"Bookshelf Removed", @"Bookshelf Removed") 
                                      message:localizedMessage];
                [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK") block:^{
                    [self.profileSetupDelegate popToAuthenticatedProfileAnimated:YES];
                }];
                
                self.profileItem = nil;
                                
                [alert show];
                [alert release];
                break;
            }
        }
    }
}

// detect any changes to the data
- (void)managedObjectContextDidSaveNotification:(NSNotification *)notification
{
    BOOL refreshTable = NO;
    BOOL refreshBooks = NO;
    
    // update the bookshelf name with the change
    for (SCHProfileItem *object in [[notification userInfo] objectForKey:NSUpdatedObjectsKey]) {
        if (object == self.profileItem) {
            if (![[SCHAppStateManager sharedAppStateManager] isSampleStore]) {
                self.navigationItem.title = [object bookshelfName:YES];
            }
        }
    }
    
    // update any book information
    for (SCHContentMetadataItem *object in [[notification userInfo] objectForKey:NSUpdatedObjectsKey]) {
        if ([object isKindOfClass:[SCHContentMetadataItem class]] == YES) {
            for (SCHBookIdentifier *bookIdentifer in self.books) {
                if ([bookIdentifer isEqual:[(id)object bookIdentifier]] == YES) {
                    refreshTable = YES;
                    break;                    
                }
            }
            if (refreshTable == YES) {
                self.gridViewNeedsRefreshed = YES;
                self.listViewNeedsRefreshed = YES;
                [self reloadData];
                break;
            }
        }
    }
    
    if (self.profileItem.ID != nil) {
        for (SCHContentProfileItem *object in [[notification userInfo] objectForKey:NSInsertedObjectsKey]) {
            // check for new books on the shelf
            if ([object isKindOfClass:[SCHContentProfileItem class]] == YES) {
                if ([object.ProfileID isEqualToNumber:self.profileItem.ID] == YES) {
                    refreshBooks = YES;
                    break;
                }
            }
        }
    }
    
    if (refreshBooks == NO) {
        // check for books removed from the shelf
        for (SCHContentProfileItem *object in [[notification userInfo] objectForKey:NSDeletedObjectsKey]) {
            if ([object isKindOfClass:[SCHContentProfileItem class]] == YES) {
                refreshBooks = YES;
                break;
            }
        }
    }
    
    if (refreshBooks == YES) {
        self.books = [self.profileItem allBookIdentifiers];
        [self dismissLoadingView];        
    }   
}

- (void)bookshelfSyncComponentBookReceived:(NSNotification *)notification
{
    NSArray *recievedBookIdentifiers = [[notification userInfo] objectForKey:@"bookIdentifiers"];
    
    if ([recievedBookIdentifiers count] > 0) {
        NSArray *profileBooks = [self.profileItem bookIdentifiersAssignedToProfile];
        
        for (SCHBookIdentifier *recievedBook in recievedBookIdentifiers) {
            if ([profileBooks containsObject:recievedBook] == YES) {
                self.gridViewNeedsRefreshed = YES;
                self.listViewNeedsRefreshed = YES;
                self.books = [self.profileItem allBookIdentifiers];
                [self reloadData];            
                break;
            }
        }
    }
}

- (void)bookshelfSyncComponentDidComplete:(NSNotification *)notification
{
    self.shouldShowBookshelfFailedErrorMessage = YES;
    [self dismissLoadingView];
}

- (void)bookshelfSyncComponentDidFail:(NSNotification *)notification
{
    if (self.shouldShowBookshelfFailedErrorMessage == YES &&
        [self.books firstObjectCommonWithArray:[[notification userInfo] objectForKey:SCHBookshelfSyncComponentBookIdentifiers]] != nil) {
        self.shouldShowBookshelfFailedErrorMessage = NO;
        [self reloadData];
        
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Unable to Retrieve all eBooks", @"Unable to Retrieve all eBooks") 
                              message:NSLocalizedString(@"There was a problem retrieving all eBooks on this bookshelf. Please try again.", @"") ];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK") block:^{}];
        [self replaceLoadingAlertWithAlert:alert];
        [alert release];
    }
}

#pragma mark - Core Data Table View Methods

- (void)save
{
    NSError *error = nil;
    if ([self.managedObjectContext save:&error] == NO) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
}

#pragma mark - SCHBookShelfTableViewCellDelegate / SCHBookShelfGridViewCellDelegate

- (void)bookshelfCell:(SCHBookShelfTableViewCell *)cell userRatingChanged:(NSInteger)newRating
{
    [self bookIdentifier:cell.identifier userRatingChanged:newRating];
    self.gridViewNeedsRefreshed = YES;
    [self reloadData];
}

- (void)gridCell:(SCHBookShelfGridViewCell *)cell userRatingChanged:(NSInteger)newRating
{
    [self bookIdentifier:cell.identifier userRatingChanged:newRating];
    self.listViewNeedsRefreshed = YES;
    [self reloadData];
}

- (void)bookIdentifier:(SCHBookIdentifier *)identifier userRatingChanged:(NSInteger)newRating
{
    NSLog(@"Book %@ changed to rating %d", identifier, newRating);
    
    SCHBookAnnotations *anno = [self.profileItem annotationsForBook:identifier];
    
    if (anno) {
        [anno setUserRating:newRating];
        [self save];
    }
}

#pragma mark - UITableViewDataSource methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"ScholasticBookshelfTableCell";

    SCHBookShelfTableViewCell *cell = (SCHBookShelfTableViewCell *) [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        
        if (self.listTableCellNib) {
            [self.listTableCellNib instantiateWithOwner:self options:nil];
        }
        
        // when the nib loads, it places an instantiated version of the cell in self.notesCell
        cell = self.listViewCell;
        
        // tidy up after ourselves
        self.listViewCell = nil;
    }

    [cell beginUpdates];

    SCHBookIdentifier *identifier = [self.books objectAtIndex:[indexPath row]];

    cell.delegate = self;
    cell.identifier = identifier;
    SCHAppContentProfileItem *appContentProfileItem = [self.profileItem appContentProfileItemForBookIdentifier:identifier];
    cell.isNewBook = [appContentProfileItem.IsNewBook boolValue];
    cell.disabledForInteractions = [self.profileItem storyInteractionsDisabled];
    
    if ([identifier isEqual:[self.books lastObject]]) {
        cell.lastCell = YES;
    } else {
        cell.lastCell = NO;
    }
    
    if (self.currentlyLoadingIndex == [indexPath row]) {
        cell.loading = YES;
    } else {
        cell.loading = NO;
    }
    
    
    SCHBookAnnotations *anno = [self.profileItem annotationsForBook:identifier];
    cell.userRating = [anno userRating];

    [cell endUpdates];
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && ![tableView isHidden]) {
        return [self.books count];
    } else {
        return 0;
    }
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (indexPath.row == 0) {
            return 113;
        } else {
            return 106;
        }
    } else {
        if (indexPath.row == 0) {
            return 77;
        } else {
            return 66;
        }
    }
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    SCHBookShelfTableViewCell *cell = (SCHBookShelfTableViewCell *) [aTableView cellForRowAtIndexPath:indexPath];
    
    if ([indexPath section] != 0) {
        return;
    }
    
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    [self selectBookAtIndex:[indexPath row] 
                 startBlock:^{
                     [cell setLoading:YES];
                 }
                   endBlock:^(BOOL didOpen){
                       if (didOpen) {
                           [cell setLoading:NO];
                       }
                   }];
}

#pragma mark - SCHBookShelfGridViewDataSource methods

- (void)gridView:(MRGridView*)aGridView configureCell:(SCHBookShelfGridViewCell *)gridCell forGridIndex:(NSInteger)index
{
    [gridCell beginUpdates];
    gridCell.shouldWaitForExistingCachedThumbToLoad = self.shouldWaitForCellsToLoad;
    
    gridCell.frame = [aGridView frameForCellAtGridIndex:index];
    
	[gridCell setIdentifier:[self.books objectAtIndex:index]];
    SCHAppContentProfileItem *appContentProfileItem = [self.profileItem appContentProfileItemForBookIdentifier:[self.books objectAtIndex:index]];
    gridCell.delegate = self;
        gridCell.isNewBook = [appContentProfileItem.IsNewBook boolValue];
    gridCell.disabledForInteractions = [self.profileItem storyInteractionsDisabled];
    gridCell.showRatings = self.showingRatings;

    if (self.currentlyLoadingIndex == index) {
        gridCell.loading = YES;
    } else {
        gridCell.loading = NO;
    }
    
    SCHBookAnnotations *anno = [self.profileItem annotationsForBook:[self.books objectAtIndex:index]];
    gridCell.userRating = [anno userRating];

    
    [gridCell endUpdates];
}

#pragma mark - MRGridViewDataSource methods

- (MRGridViewCell *)gridView:(MRGridView*)aGridView cellForGridIndex:(NSInteger)index 
{
	static NSString* cellIdentifier = @"ScholasticGridViewCell";

//    SCHBookShelfGridView *bookshelfGridView = (SCHBookShelfGridView *)aGridView;
//    SCHBookIdentifier *bookIdentifier = [self.books objectAtIndex:index];
    
	SCHBookShelfGridViewCell* gridCell = (SCHBookShelfGridViewCell *) [aGridView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (gridCell == nil) {
		gridCell = [[[SCHBookShelfGridViewCell alloc] initWithFrame:[aGridView frameForCellAtGridIndex:index] reuseIdentifier:cellIdentifier] autorelease];
	}
	
    [self gridView:aGridView configureCell:gridCell forGridIndex:index];
  
	return(gridCell);
}

- (NSInteger)numberOfItemsInGridView:(MRGridView*)aGridView 
{
    if ([aGridView isHidden]) {
        return 0;
    }
    return([self.books count]);
}

- (NSString *)contentDescriptionForCellAtIndex:(NSInteger)index 
{
	return(nil);
}

- (BOOL)gridView:(MRGridView*)gridView canMoveCellAtIndex: (NSInteger)index 
{ 
	self.moveToValue = -1;
    
    return(YES);
}

- (void)gridView:(MRGridView *)gridView moveCellAtIndex:(NSInteger)fromIndex 
         toIndex:(NSInteger)toIndex
{
	self.moveToValue = toIndex;
}

// Although this is called finishedMovingCellToIndex it actually passes the fromIndex
- (void)gridView:(MRGridView*)gridView finishedMovingCellToIndex:(NSInteger)fromIndex
{
    NSUInteger toIndex = self.moveToValue;
	if (toIndex != -1 && (fromIndex != toIndex) &&
        fromIndex < [self.books count] && toIndex <= [self.books count]) {
        id book = [self.books objectAtIndex:fromIndex];
        [book retain];
        [self.books removeObjectAtIndex:fromIndex];
        
        [self.books insertObject:book atIndex:toIndex];
        [book release];
        [self.profileItem saveBookOrder:self.books];
        NSError *error = nil;
        
        if (![self.profileItem.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        }                
	}

    [self.gridView setEditing:NO animated:YES];
}

- (void)gridView:(MRGridView *)gridView commitEditingStyle:(MRGridViewCellEditingStyle)editingStyle 
        forIndex:(NSInteger)index
{
    // nop
}

- (void)selectBookAtIndex:(NSInteger)index startBlock:(dispatch_block_t)startBlock endBlock:(void (^)(BOOL didOpen))endBlock
{
    if (index >= [self.books count]) {
        return;
    }
    
    if (self.currentlyLoadingIndex != -1) {
        return;
    }
    
    self.currentlyLoadingIndex = index;
    
    SCHBookIdentifier *identifier = [self.books objectAtIndex:index];
    NSError *canOpenError;
    BOOL canOpenBook = [self canOpenBook:identifier error:&canOpenError];
    
    if ((canOpenBook == NO) && 
        ([[SCHVersionDownloadManager sharedVersionManager] isAppVersionOutdated] == YES) &&
        ([[SCHAppStateManager sharedAppStateManager] isSampleStore] == NO)) {
        [self showAppVersionOutdatedAlert];
        self.currentlyLoadingIndex = -1;
    } else {
        if (canOpenBook) {
            if (startBlock) {
                startBlock();
            }
        }
        
        double delayInSeconds = 0.02;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            NSError *error;
            
            SCHReadingViewController *readingController = [self openBook:[self.books objectAtIndex:index] error:&error];
            BOOL didOpen = NO;
            
            if (readingController != nil) {
                self.updateShelfOnReturnToShelf = YES;
                didOpen = YES;
                [self.navigationController pushViewController:readingController animated:YES]; 
            } else {
                if (error) {
                    if ([[error domain] isEqualToString:kSCHBookShelfErrorDomain] && ([error code] == kSCHBookShelfNoInternet)) {
                        LambdaAlert *alert = [[LambdaAlert alloc]
                                              initWithTitle:NSLocalizedString(@"No Internet Connection", @"No Internet Connection")
                                              message:[error localizedDescription]];
                        [alert addButtonWithTitle:@"OK" block:nil];
                        [alert show];
                        [alert release];
                    } else if (!([[error domain] isEqualToString:kSCHAppBookErrorDomain] && ([error code] == kSCHAppBookStillBeingProcessedError))) {
                        LambdaAlert *alert = [[LambdaAlert alloc]
                                              initWithTitle:NSLocalizedString(@"This eBook Could Not Be Opened", @"Could not open eBook")
                                              message:[error localizedDescription]];
                        [alert addButtonWithTitle:@"Cancel" block:nil];
                        [alert addButtonWithTitle:@"Retry" block:^{
                            [[SCHProcessingManager sharedProcessingManager] userRequestedRetryForBookWithIdentifier:identifier];
                            
                        }];
                        [alert show];
                        [alert release];
                    }
                }
            }
            
            if (endBlock) {
                endBlock(didOpen);
            }
            
            self.currentlyLoadingIndex = -1;
        });
    }
}

#pragma mark - MRGridViewDelegate methods

- (void)gridView:(MRGridView *)aGridView didSelectCellAtIndex:(NSInteger)index 
{
    SCHBookShelfGridViewCell *cell = (SCHBookShelfGridViewCell *) [aGridView cellAtGridIndex:index];
    
    [self selectBookAtIndex:index 
                 startBlock:^{
                     [cell setLoading:YES];
                 }
                   endBlock:^(BOOL didOpen){
                       [cell setLoading:NO];
                   }];
}

- (BOOL)canOpenBook:(SCHBookIdentifier *)identifier error:(NSError **)error 
{
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:self.managedObjectContext];
    
    BOOL canOpen = NO;
    
    SCHBookCurrentProcessingState state = [[book State] intValue];
    
    if (((state == SCHBookProcessingStateReadyForBookFileDownload) ||
         (state == SCHBookProcessingStateDownloadPaused)) &&
        (![[Reachability reachabilityForInternetConnection] isReachable]) &&
        (![book bookCoverURLIsBundleURL])) {
        
        NSDictionary *eDict = [NSDictionary dictionaryWithObject:NSLocalizedString(@"This eBook has not yet been downloaded. Please connect to the Internet in order to download and read this eBook.", @"")
                                                          forKey:NSLocalizedDescriptionKey];
        
        if (error != NULL) {
            *error = [[[NSError alloc] initWithDomain:kSCHBookShelfErrorDomain
                                                 code:kSCHBookShelfNoInternet userInfo:eDict] autorelease];
        }
    } else {
        canOpen = [book canOpenBookError:error];
    }
    
    if (canOpen) {
        return YES;
    } else {
        return NO;
    }
}

- (SCHReadingViewController *)openBook:(SCHBookIdentifier *)identifier error:(NSError **)error
{
    BOOL canOpen = [self canOpenBook:identifier error:error];
    
    // If we have a bookshelf error, don't select the book, just return nil
    if (!canOpen && [[*error domain] isEqualToString:kSCHBookShelfErrorDomain]) {
        return nil;
    }
    
    SCHReadingViewController *ret = nil;    
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:self.managedObjectContext];

    // notify the processing manager that the user touched a book info object.
	// this allows it to pause and resume items, etc.
	// will do nothing if the book has already been fully downloaded.
	[[SCHProcessingManager sharedProcessingManager] userSelectedBookWithIdentifier:identifier];
	
	// if the processing manager is working, do not open the book    
	if (canOpen) {
        NSLog(@"Showing book %@.", book.Title);
        
        // grab the category from the XPS, 
        // if it doesnt exist then use the profile to derive the default reading view
        NSString *categoryType = book.categoryType;
        SCHBookshelfStyles bookshelfStyle;
        if (categoryType == nil) {
            switch ([self.profileItem.BookshelfStyle intValue]) {
                case kSCHBookshelfStyleYoungChild:
                    bookshelfStyle = kSCHBookshelfStyleYoungChild;                
                    break;
                case kSCHBookshelfStyleOlderChild:
                    bookshelfStyle = kSCHBookshelfStyleOlderChild;                        
                    break;            
            }        
        } else if ([categoryType isEqualToString:kSCHAppBookYoungReader] == YES) {
            bookshelfStyle = kSCHBookshelfStyleYoungChild;
        } else if ([categoryType isEqualToString:kSCHAppBookOldReader] == YES) {
            bookshelfStyle = kSCHBookshelfStyleOlderChild;        
        }
                
        switch (bookshelfStyle) {
            case kSCHBookshelfStyleYoungChild:
                ret = [[SCHReadingViewController alloc] initWithNibName:nil 
                                                                 bundle:nil 
                                                         bookIdentifier:identifier 
                                                                profile:profileItem
                                                   managedObjectContext:self.managedObjectContext
                                                                  error:error];
                ret.youngerMode = YES;
                break;
                
            case kSCHBookshelfStyleOlderChild:
            {
                ret = [[SCHReadingViewController alloc] initWithNibName:nil 
                                                                 bundle:nil 
                                                         bookIdentifier:identifier 
                                                                profile:profileItem
                                                   managedObjectContext:self.managedObjectContext
                                                                  error:error];

                ret.youngerMode = NO;
                break;     
            }
            default:
                NSLog(@"Warning: unrecognised bookshelf style.");
                break;
        }
        
    }
    
    return([ret autorelease]);
}

- (void)gridView:(MRGridView *)gridView confirmationForDeletionAtIndex:(NSInteger)index 
{
	// nop
}

#pragma mark - Cell Size methods

// overridden in iPad subclass
- (CGSize)cellSize
{
    return CGSizeMake(80,118);
}

- (CGFloat)cellBorderSize
{
    return 10;
}

#pragma mark - App Version checking methods

- (void)showAppVersionOutdatedAlert
{
    LambdaAlert *alert = [[LambdaAlert alloc]
                          initWithTitle:NSLocalizedString(@"Update Required", @"")
                          message:NSLocalizedString(@"This function requires that you update Storia. Please visit the App Store to update your app.", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
    [alert show];
    [alert release];         
}

@end

