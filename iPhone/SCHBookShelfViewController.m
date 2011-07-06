//
//  SCHBookShelfViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 14/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfViewController.h"

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

static NSInteger const kSCHBookShelfViewControllerGridCellHeightPortrait = 138;
static NSInteger const kSCHBookShelfViewControllerGridCellHeightLandscape = 150;

@interface SCHBookShelfViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, assign) int moveToValue;
@property (nonatomic, assign) BOOL updateShelfOnReturnToShelf;
@property (nonatomic, assign) int currentlyLoadingIndex;


- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)updateTheme;
- (CGSize)cellSize;
- (CGFloat)cellBorderSize;
- (void)updateTable:(NSNotification *)notification;

// FIXME: this isn't really necessary
- (IBAction)changeToListView:(UIButton *)sender;
- (IBAction)changeToGridView:(UIButton *)sender;


@property (nonatomic, retain) UINib *listTableCellNib;

@end

@implementation SCHBookShelfViewController

@synthesize listTableView;
@synthesize listTableCellNib;
@synthesize gridView;
@synthesize loadingView;
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

#pragma mark - Object lifecycle

- (void)releaseViewObjects 
{
    [gridView release], gridView = nil;
    [loadingView release], loadingView = nil;
    [themePickerContainer release], themePickerContainer = nil;
    [customNavigationBar release], customNavigationBar = nil;
    
    [componentCache release], componentCache = nil;
    
    [listTableView release], listTableView = nil;
    [gridButton release], gridButton = nil;
    [listButton release], listButton = nil;
    [listToggleView release], listToggleView = nil;
    [listTableCellNib release], listTableCellNib = nil;
    [gridViewToggleView release], gridViewToggleView = nil;
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc 
{    
    [books release], books = nil;
    [profileItem release], profileItem = nil;
    [managedObjectContext release], managedObjectContext = nil;
    
    [self releaseViewObjects];   
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    // because we're using iOS 4 and above, use UINib to cache access to the NIB
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.listTableCellNib = [UINib nibWithNibName:@"SCHBookShelfTableViewCell_iPad" bundle:nil];
    } else {
        self.listTableCellNib = [UINib nibWithNibName:@"SCHBookShelfTableViewCell_iPhone" bundle:nil];
    }
    
    self.sortType = [[[self.profileItem AppProfile] SortType] intValue];
    
    SCHThemeButton *button = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [button setThemeIcon:kSCHThemeManagerThemeIcon iPadSpecific:YES];
    [button sizeToFit];    
    [button addTarget:self action:@selector(changeTheme) forControlEvents:UIControlEventTouchUpInside];    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];

    button = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [button setThemeIcon:kSCHThemeManagerHomeIcon iPadSpecific:YES];
    [button sizeToFit];    
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar setTheme:kSCHThemeManagerNavigationBarImage];
    
    // uses the cellSize and cellBorderSize methods, which can be overridden
    [self.gridView setCellSize:[self cellSize] withBorderSize:[self cellBorderSize]];
    
    [self.gridView setBackgroundColor:[UIColor clearColor]];
    
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
	
//    [customNavigationBar setTheme:kSCHThemeManagerNavigationBarImage];
		
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateTable:)
												 name:@"SCHBookshelfSyncComponentComplete"
											   object:nil];
	
	
	self.loadingView.layer.cornerRadius = 5.0f;
	[self.view bringSubviewToFront:self.loadingView];
	
	if (![[SCHSyncManager sharedSyncManager] havePerformedFirstSyncUpToBooks] && [[SCHSyncManager sharedSyncManager] isSynchronizing]) {
		self.loadingView.hidden = NO;
	} else {
		self.loadingView.hidden = YES;
	}
    
    self.navigationItem.title = [self.profileItem bookshelfName:YES];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme) name:kSCHThemeManagerThemeChangeNotification object:nil];              
    
    [self setupAssetsForOrientation:self.interfaceOrientation];

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

    [self.gridView reloadData];
    [self.listTableView reloadData];
    
//    [self changeToListView:nil];
    self.currentlyLoadingIndex = -1;

}

- (void)viewDidUnload 
{
    [super viewDidUnload];
	[self releaseViewObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.navigationController.navigationBar.barStyle = UIBarStyleBlackOpaque;
    [self setupAssetsForOrientation:self.interfaceOrientation];
    if (self.updateShelfOnReturnToShelf == YES) {
        self.updateShelfOnReturnToShelf = NO;
        self.books = [self.profileItem allBookIdentifiers];
    }
}

#pragma mark - Orientation methods

// Note: this is overridden in the iPad subclass
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self.gridView setShelfImage:[[SCHThemeManager sharedThemeManager] imageForShelf:interfaceOrientation]];        
    [self.view.layer setContents:(id)[[SCHThemeManager sharedThemeManager] imageForBackground:interfaceOrientation].CGImage];
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
    [self setupAssetsForOrientation:toInterfaceOrientation];
}

#pragma mark - Private methods

// Note: this is overridden in the iPad controller
- (void)updateTheme
{
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

- (void)changeTheme
{
    self.themePickerContainer.modalPresentationStyle = UIModalPresentationFormSheet;
    self.themePickerContainer.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    self.themePickerContainer.title = @"";
    
	[self presentModalViewController:self.themePickerContainer animated:YES];		
}

#pragma mark - Action methods

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer 
{
    if (self.sortType == kSCHBookSortTypeUser) {
        [self.gridView setEditing:YES animated:YES];
    }
    
    return NO;
}

#pragma mark - Accessor Methods

- (void)setProfileItem:(SCHProfileItem *)newProfileItem
{
    [newProfileItem retain];	    
	[profileItem release];
    profileItem = newProfileItem;
    
    self.navigationItem.title = [self.profileItem bookshelfName:YES];
    
	self.books = [self.profileItem allBookIdentifiers];
}

- (void)setBooks:(NSMutableArray *)newBooks
{
    [newBooks retain];
	[books release];
    books = newBooks;
    
	[self.gridView reloadData];
    [self.listTableView reloadData];
}

#pragma mark - View Type Toggle methods

- (IBAction)changeToGridView:(UIButton *)sender
{
    if (self.gridView.hidden == YES) {
        self.gridButton.highlighted = YES;
        self.listButton.highlighted = NO;
        self.listTableView.hidden = YES;
        self.gridView.hidden = NO;
        [self.gridView reloadData];
    }
}

- (IBAction)changeToListView:(UIButton *)sender
{
    if (self.listTableView.hidden == YES) {
        self.gridButton.highlighted = NO;
        self.listButton.highlighted = YES;
        self.listTableView.hidden = NO;
        self.gridView.hidden = YES;
        [self.listTableView reloadData];
    }
}

#pragma mark - Core Data Table View Methods

- (void)updateTable:(NSNotification *)notification
{
	self.books = [self.profileItem allBookIdentifiers];
	self.loadingView.hidden = YES;
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
        
        // set the cell delegate
        cell.delegate = self;
    }
    
    SCHBookIdentifier *identifier = [self.books objectAtIndex:[indexPath row]];
    
    cell.identifier = identifier;
    cell.isNewBook = [self.profileItem bookIsNewForProfileWithIdentifier:identifier];
    cell.trashed = [self.profileItem bookIsTrashedWithIdentifier:identifier];
    
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
    
    return cell;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return [self.books count];
    } else {
        return 0;
    }
}

- (float) tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return 100;
    } else {
        return 62;
    }
}

#pragma mark - List View Cell Delegate

- (void)bookShelfTableViewCellSelectedDeleteForIdentifier:(SCHBookIdentifier *)identifier
{
    NSLog(@"Deleting list view row associated with identifier: %@", identifier);
    if ([self.profileItem bookIsTrashedWithIdentifier:identifier]) {
        [self.profileItem setTrashed:NO forBookWithIdentifier:identifier];
    } else {
        [self.profileItem setTrashed:YES forBookWithIdentifier:identifier];
    }
    [self.listTableView reloadData];
    [self.gridView reloadData];
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
    
    SCHBookIdentifier *identifier = [self.books objectAtIndex:[indexPath row]];
    if ([self.profileItem bookIsTrashedWithIdentifier:identifier]) {
        [self.profileItem setTrashed:NO forBookWithIdentifier:identifier];
        [self.listTableView reloadData];
        return;
    }
    
    self.currentlyLoadingIndex = [indexPath row];
    [self.listTableView reloadData];
  
    double delayInSeconds = 0.02;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        SCHReadingViewController *readingController = [self openBook:[self.books objectAtIndex:[indexPath row]]];
        if (readingController != nil) {
            self.updateShelfOnReturnToShelf = YES;
            [self.navigationController pushViewController:readingController animated:YES]; 
            self.currentlyLoadingIndex = -1;
        }
    });
}


#pragma mark - MRGridViewDataSource methods

- (MRGridViewCell *)gridView:(MRGridView*)aGridView cellForGridIndex:(NSInteger)index 
{
	static NSString* cellIdentifier = @"ScholasticGridViewCell";
	SCHBookShelfGridViewCell* gridCell = (SCHBookShelfGridViewCell *) [aGridView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (gridCell == nil) {
		gridCell = [[[SCHBookShelfGridViewCell alloc] initWithFrame:[aGridView frameForCellAtGridIndex:index] reuseIdentifier:cellIdentifier] autorelease];
	}
	else {
		gridCell.frame = [aGridView frameForCellAtGridIndex:index];
	}

	[gridCell setIdentifier:[self.books objectAtIndex:index]];
    gridCell.trashed = [self.profileItem bookIsTrashedWithIdentifier:[self.books objectAtIndex:index]];

	return(gridCell);
}

- (NSInteger)numberOfItemsInGridView:(MRGridView*)gridView 
{
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
        
        [self.gridView setEditing:NO animated:YES];
	}
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

    SCHBookIdentifier *identifier = [self.books objectAtIndex:index];
    if ([self.profileItem bookIsTrashedWithIdentifier:identifier]) {
        [self.profileItem setTrashed:NO forBookWithIdentifier:identifier];
        [self.gridView reloadData];
        return;
    }
    
    CGRect cellFrame = [aGridView frameForCellAtGridIndex:index];
    UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    spinner.center = CGPointMake(CGRectGetMidX(cellFrame), CGRectGetMidY(cellFrame));
    [spinner startAnimating];
    [aGridView addSubview:spinner];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        SCHReadingViewController *readingController = [self openBook:[self.books objectAtIndex:index]];
        if (readingController != nil) {
            if (self.sortType == kSCHBookSortTypeLastRead) {
                self.updateShelfOnReturnToShelf = YES;
            }            
            [self.navigationController pushViewController:readingController animated:YES]; 
        }
        [spinner removeFromSuperview];
    });
    [spinner release];
}

- (SCHReadingViewController *)openBook:(SCHBookIdentifier *)identifier
{
    SCHReadingViewController *ret = nil;
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:identifier inManagedObjectContext:self.managedObjectContext];
    
    // notify the processing manager that the user touched a book info object.
	// this allows it to pause and resume items, etc.
	// will do nothing if the book has already been fully downloaded.
	[[SCHProcessingManager sharedProcessingManager] userSelectedBookWithIdentifier:identifier];
	
	// if the processing manager is working, do not open the book
	if ([book canOpenBook]) {
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
                                                   managedObjectContext:self.managedObjectContext];
                ret.youngerMode = YES;
                break;
                
            case kSCHBookshelfStyleOlderChild:
            {
                ret = [[SCHReadingViewController alloc] initWithNibName:nil 
                                                                 bundle:nil 
                                                         bookIdentifier:identifier 
                                                                profile:profileItem
                                                   managedObjectContext:self.managedObjectContext];
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
    return 20;
}

@end

