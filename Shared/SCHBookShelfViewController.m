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
#import "SCHBookAnnotations.h"

static NSInteger const kSCHBookShelfViewControllerGridCellHeightPortrait = 138;
static NSInteger const kSCHBookShelfViewControllerGridCellHeightLandscape = 131;

@interface SCHBookShelfViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, retain) SCHThemeButton *themeButton;
@property (nonatomic, retain) SCHThemeButton *backButton;
@property (nonatomic, assign) int moveToValue;
@property (nonatomic, assign) BOOL updateShelfOnReturnToShelf;
@property (nonatomic, assign) BOOL gridViewNeedsRefreshed;
@property (nonatomic, assign) BOOL listViewNeedsRefreshed;
@property (nonatomic, assign) int currentlyLoadingIndex;
@property (nonatomic, retain) LambdaAlert *loadingView;
@property (nonatomic, assign) BOOL shouldShowBookshelfFailedErrorMessage;

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)updateTheme;
- (CGSize)cellSize;
- (CGFloat)cellBorderSize;
- (void)reloadData;
- (void)save;
- (BOOL)canOpenBook:(SCHBookIdentifier *)identifier;

- (IBAction)changeToListView:(UIButton *)sender;
- (IBAction)changeToGridView:(UIButton *)sender;


@property (nonatomic, retain) UINib *listTableCellNib;

@end

@implementation SCHBookShelfViewController

@synthesize themeButton;
@synthesize backButton;
@synthesize listTableView;
@synthesize listTableCellNib;
@synthesize gridView;
@synthesize themePickerContainer;
@synthesize customNavigationBar;
@synthesize gridButton;
@synthesize listButton;
@synthesize listToggleView;
@synthesize gridViewToggleView;
@synthesize componentCache;
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

#pragma mark - Object lifecycle

- (void)releaseViewObjects 
{
    [gridView release], gridView = nil;
    [themePickerContainer release], themePickerContainer = nil;
    [customNavigationBar release], customNavigationBar = nil;
    
    [componentCache release], componentCache = nil;
    
    [themeButton release], themeButton = nil;
    [backButton release], backButton = nil;    
    [listTableView release], listTableView = nil;
    [gridButton release], gridButton = nil;
    [listButton release], listButton = nil;
    [listToggleView release], listToggleView = nil;
    [listTableCellNib release], listTableCellNib = nil;
    [gridViewToggleView release], gridViewToggleView = nil;
    [backgroundView release], backgroundView = nil;
    [loadingView release], loadingView = nil;
    
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
    
    [self.listTableView setAlwaysBounceVertical:NO]; // For some reason this doesn't work when set from the nib
    
    // because we're using iOS 4 and above, use UINib to cache access to the NIB
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.listTableCellNib = [UINib nibWithNibName:@"SCHBookShelfTableViewCell_iPad" bundle:nil];
    } else {
        self.listTableCellNib = [UINib nibWithNibName:@"SCHBookShelfTableViewCell_iPhone" bundle:nil];
    }
    
    self.sortType = [[[self.profileItem AppProfile] SortType] intValue];
    
    self.themeButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [self.themeButton setThemeIcon:kSCHThemeManagerThemeIcon iPadQualifier:kSCHThemeManagerPadQualifierSuffix];
    [self.themeButton sizeToFit];    
    [self.themeButton addTarget:self action:@selector(changeTheme) forControlEvents:UIControlEventTouchUpInside];    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.themeButton] autorelease];

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
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:nil action:nil];
    longPress.delaysTouchesBegan = YES;
    longPress.delegate = self;
    [self.gridView addGestureRecognizer:longPress];
    [longPress release], longPress = nil;
	self.moveToValue = -1;
	
	KNFBTimeOrderedCache *aCache = [[KNFBTimeOrderedCache alloc] init];
	aCache.countLimit = 30; // Arbitrary 30 object limit
	aCache.totalCostLimit = 1024*1024; // Arbitrary 1MB limit. This may need wteaked or set on a per-device basis
	self.componentCache = aCache;
	[aCache release], aCache = nil;
	
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

	if (![[SCHSyncManager sharedSyncManager] havePerformedFirstSyncUpToBooks] && [[SCHSyncManager sharedSyncManager] isSynchronizing]) {
        self.loadingView = [[LambdaAlert alloc]
                            initWithTitle:NSLocalizedString(@"Syncing", @"")
                            message:@"\n\n\n"];
        __block SCHBookShelfViewController *weakSelf = self;
        [self.loadingView addButtonWithTitle:NSLocalizedString(@"Back", @"") block:^{
            [weakSelf dismissLoadingView];
            [weakSelf performSelector:@selector(back)];
        }];
        [self.loadingView setSpinnerHidden:NO];
        [self.loadingView show];
        [self.loadingView release];
	} else {
        [self dismissLoadingView];
	}
    
    if (![[SCHAppStateManager sharedAppStateManager] isSampleStore]) {
        self.navigationItem.title = [self.profileItem bookshelfName:YES];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme) name:kSCHThemeManagerThemeChangeNotification object:nil];              
    
    [self.listTableView setSeparatorColor:[UIColor clearColor]];

    CGRect listFrame = self.listTableView.tableHeaderView.frame;
    CGRect gridFrame = self.gridViewToggleView.frame;

    listFrame.size.width = self.view.frame.size.width;
    gridFrame.size.width = self.view.frame.size.width;
    
    // this is the height of the top toggle view for both iPad and iPhone
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        listFrame.size.height = 66;
        gridFrame.size.height = 66;
    } else {
        listFrame.size.height = 44;
        gridFrame.size.height = 44;
    }
    self.listTableView.tableHeaderView.frame = listFrame;
    self.gridViewToggleView.frame = gridFrame;
    
    self.gridView.toggleView = self.gridViewToggleView;
    
    self.currentlyLoadingIndex = -1;

    if ([self.profileItem.AppProfile.ShowListView boolValue] == YES) {
        [self changeToListView:nil];
    }
    
    if ([[SCHSyncManager sharedSyncManager] isSynchronizing] == NO) {
        [[SCHSyncManager sharedSyncManager] firstSync:NO requireDeviceAuthentication:NO];
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

- (void)reloadData
{
    dispatch_async(dispatch_get_main_queue(), ^{
        
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
    });
}

#pragma mark - Orientation methods

// Note: this is overridden in the iPad subclass
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self.gridView setShelfImage:[[SCHThemeManager sharedThemeManager] imageForShelf:interfaceOrientation]];       
    [self.themeButton updateTheme:interfaceOrientation];
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

- (void)changeTheme
{
    self.themePickerContainer.modalPresentationStyle = UIModalPresentationFormSheet;
    self.themePickerContainer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.themePickerContainer.title = @"";
    
	[self presentModalViewController:self.themePickerContainer animated:YES];		
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

- (IBAction)back
{
    self.profileItem.AppProfile.ShowListView = [NSNumber numberWithBool:self.listTableView.hidden == NO];

    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore] == YES) {
        [self.navigationController popToRootViewControllerAnimated:YES];        
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
        self.gridButton.highlighted = YES;
        self.listButton.highlighted = NO;
        self.listTableView.hidden = YES;
        self.gridView.hidden = NO;
        [self reloadData];
    }
}

- (IBAction)changeToListView:(UIButton *)sender
{
    if (self.listTableView.hidden == YES) {
        self.gridButton.highlighted = NO;
        self.listButton.highlighted = YES;
        self.listTableView.hidden = NO;
        self.gridView.hidden = YES;
        [self reloadData];
    }
}

#pragma mark - Sync Propagation methods

- (void)profileDeleted:(NSNotification *)notification
{
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
    
    for (SCHContentProfileItem *object in [[notification userInfo] objectForKey:NSInsertedObjectsKey]) {
        // check for new books on the shelf
        if ([object isKindOfClass:[SCHContentProfileItem class]] == YES) {
            if ([object.ProfileID isEqualToNumber:self.profileItem.ID] == YES) {
                refreshBooks = YES;
                break;
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
        abort();
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

    cell.identifier = identifier;
    SCHAppContentProfileItem *appContentProfileItem = [self.profileItem appContentProfileItemForBookIdentifier:identifier];
    cell.isNewBook = [appContentProfileItem.IsNewBook boolValue];
    
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
        return 100;
    } else {
        return 62;
    }
}

#pragma mark - UITableViewDelegate methods

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([indexPath section] != 0 || [indexPath row] >= [self.books count]) {
        return;
    }
    
    if (self.currentlyLoadingIndex != -1) {
        return;
    }
    
	NSLog(@"Calling table row selection.");
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.currentlyLoadingIndex = [indexPath row];

    SCHBookIdentifier *identifier = [self.books objectAtIndex:[indexPath row]];

    if ([self canOpenBook:identifier]) {
        SCHBookShelfTableViewCell *cell = (SCHBookShelfTableViewCell *) [aTableView cellForRowAtIndexPath:indexPath];
        [cell setLoading:YES];
    }

    //[self reloadData];
  
    double delayInSeconds = 0.02;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSError *error;
        
        SCHReadingViewController *readingController = [self openBook:[self.books objectAtIndex:[indexPath row]] error:&error];
        if (readingController != nil) {
            self.updateShelfOnReturnToShelf = YES;

            [self.navigationController pushViewController:readingController animated:YES]; 
            self.currentlyLoadingIndex = -1;
        } else {
            if (error && !([[error domain] isEqualToString:kSCHAppBookErrorDomain] && ([error code] == kSCHAppBookStillBeingProcessedError))) {
                LambdaAlert *alert = [[LambdaAlert alloc]
                                      initWithTitle:NSLocalizedString(@"This eBook Could Not Be Opened", @"Could not open eBook")
                                      message:[error localizedDescription]];
                [alert addButtonWithTitle:@"Cancel" block:^{}];
                [alert addButtonWithTitle:@"Retry" block:^{
                    [[SCHProcessingManager sharedProcessingManager] userRequestedRetryForBookWithIdentifier:identifier];
                
                }];
                [alert show];
                [alert release];
            }
        }
        self.currentlyLoadingIndex = -1;

        SCHBookShelfTableViewCell *cell = (SCHBookShelfTableViewCell *) [aTableView cellForRowAtIndexPath:indexPath];
        [cell setLoading:NO];
    });
}

#pragma mark - SCHBookShelfGridViewDataSource methods

- (void)gridView:(MRGridView*)aGridView configureCell:(SCHBookShelfGridViewCell *)gridCell forGridIndex:(NSInteger)index
{
    [gridCell beginUpdates];
    gridCell.frame = [aGridView frameForCellAtGridIndex:index];
    
	[gridCell setIdentifier:[self.books objectAtIndex:index]];
    SCHAppContentProfileItem *appContentProfileItem = [self.profileItem appContentProfileItemForBookIdentifier:[self.books objectAtIndex:index]];
    gridCell.isNewBook = [appContentProfileItem.IsNewBook boolValue];
    
    if (self.currentlyLoadingIndex == index) {
        gridCell.loading = YES;
    } else {
        gridCell.loading = NO;
    }
    
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
	if (self.moveToValue != -1 && (fromIndex != self.moveToValue)) {
        id book = [self.books objectAtIndex:fromIndex];
        [book retain];
        [self.books removeObjectAtIndex:fromIndex];

        NSUInteger toIndex = self.moveToValue;
        
        [self.books insertObject:book atIndex:toIndex];
        [book release];
        [self.profileItem saveBookOrder:self.books];
        NSError *error = nil;
        
        if (![self.profileItem.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }                
	}

    [self.gridView setEditing:NO animated:YES];
}

- (void)gridView:(MRGridView *)gridView commitEditingStyle:(MRGridViewCellEditingStyle)editingStyle 
        forIndex:(NSInteger)index
{
    // nop
}

#pragma mark - MRGridViewDelegate methods

- (void)gridView:(MRGridView *)aGridView didSelectCellAtIndex:(NSInteger)index 
{
    if (index >= [self.books count]) {
        return;
    }

    if (self.currentlyLoadingIndex != -1) {
        return;
    }
    
    self.currentlyLoadingIndex = index;

    SCHBookIdentifier *identifier = [self.books objectAtIndex:index];

    if ([self canOpenBook:identifier]) {
        SCHBookShelfGridViewCell *cell = (SCHBookShelfGridViewCell *) [aGridView cellAtGridIndex:index];
        [cell setLoading:YES];
    }
    
    
    double delayInSeconds = 0.02;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        NSError *error;

        SCHReadingViewController *readingController = [self openBook:[self.books objectAtIndex:index] error:&error];
        if (readingController != nil) {
            self.updateShelfOnReturnToShelf = YES;

            [self.navigationController pushViewController:readingController animated:YES]; 

            SCHBookShelfGridViewCell *cell = (SCHBookShelfGridViewCell *) [aGridView cellAtGridIndex:index];
            [cell setLoading:NO];
        } else {
            if (error && !([[error domain] isEqualToString:kSCHAppBookErrorDomain] && ([error code] == kSCHAppBookStillBeingProcessedError))) {
                LambdaAlert *alert = [[LambdaAlert alloc]
                                      initWithTitle:NSLocalizedString(@"This eBook Could Not Be Opened", @"Could not open eBook")
                                      message:[error localizedDescription]];
                [alert addButtonWithTitle:@"Cancel" block:^{}];
                [alert addButtonWithTitle:@"Retry" block:^{
                    [[SCHProcessingManager sharedProcessingManager] userRequestedRetryForBookWithIdentifier:identifier];
                    
                }];
                [alert show];
                
                [alert release];

                
                SCHBookShelfGridViewCell *cell = (SCHBookShelfGridViewCell *) [aGridView cellAtGridIndex:index];
                [cell setLoading:NO];
            }
        }
        
        self.currentlyLoadingIndex = -1;
    });
}

- (BOOL)canOpenBook:(SCHBookIdentifier *)identifier
{
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:self.managedObjectContext];
    
    NSError *error = nil;
    BOOL canOpen = [book canOpenBookError:&error];
    
    if (canOpen && !error) {
        return YES;
    } else {
        return NO;
    }
}

- (SCHReadingViewController *)openBook:(SCHBookIdentifier *)identifier error:(NSError **)error
{
    SCHReadingViewController *ret = nil;
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:self.managedObjectContext];
    
    // notify the processing manager that the user touched a book info object.
	// this allows it to pause and resume items, etc.
	// will do nothing if the book has already been fully downloaded.
	[[SCHProcessingManager sharedProcessingManager] userSelectedBookWithIdentifier:identifier];
	
	// if the processing manager is working, do not open the book    
	if ([book canOpenBookError:error]) {
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

@end
