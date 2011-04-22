//
//  SCHBookShelfViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 14/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfViewController.h"
#import "SCHReadingViewController.h"
#import "BITReadingOptionsView.h"
#import "SCHLibreAccessWebService.h"
#import "SCHLocalDebug.h"
#import "SCHBookManager.h"
#import "SCHBookShelfTableViewCell.h"
#import "SCHThumbnailFactory.h"
#import "SCHSyncManager.h"
#import "SCHBookShelfGridViewCell.h"
#import "SCHXPSProvider.h"
#import <QuartzCore/QuartzCore.h>
#import "SCHAppBook.h"
#import "SCHCustomNavigationBar.h"
#import "SCHThemeManager.h"
#import "SCHThemeButton.h"

static NSInteger const kSCHBookShelfViewControllerGridCellHeightPortrait = 138;
static NSInteger const kSCHBookShelfViewControllerGridCellHeightLandscape = 150;

@interface SCHBookShelfViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, retain) UIBarButtonItem *themeButton;
@property int moveToValue;

- (void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation;
- (void)updateTheme;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (void)finishEditing:(id)sender;

@end

@implementation SCHBookShelfViewController

@synthesize books;
@synthesize gridView, loadingView, componentCache;
@synthesize themePickerContainer;
@synthesize customNavigationBar;
@synthesize profileItem;
@synthesize themeButton;
@synthesize moveToValue;

- (void)releaseViewObjects 
{
	self.gridView = nil;
	self.componentCache = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];

    SCHThemeButton *button = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [button setThemeIcon:kSCHThemeManagerThemeIcon];
    [button sizeToFit];    
    [button addTarget:self action:@selector(changeTheme) forControlEvents:UIControlEventTouchUpInside];    
    themeButton = [[UIBarButtonItem alloc] initWithCustomView:button];
    self.navigationItem.rightBarButtonItem = self.themeButton;

    button = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [button setThemeIcon:kSCHThemeManagerHomeIcon];
    [button sizeToFit];    
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    
    [self updateTheme];
    
	[self.gridView setCellSize:CGSizeMake(80,118) withBorderSize:20];
    [self.gridView setBackgroundColor:[UIColor clearColor]];
    [self setInterfaceOrientation:self.interfaceOrientation];
    [self.gridView setShelfInset:CGSizeMake(0, -1)];
    [self.gridView setMinimumNumberOfShelves:10];
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:nil action:nil];
    longPress.delaysTouchesBegan = YES;
    longPress.delegate = self;
    [self.gridView addGestureRecognizer:longPress];
    [longPress release];
	self.moveToValue = -1;
	
	KNFBTimeOrderedCache *aCache = [[KNFBTimeOrderedCache alloc] init];
	aCache.countLimit = 30; // Arbitrary 30 object limit
	aCache.totalCostLimit = 1024*1024; // Arbitrary 1MB limit. This may need wteaked or set on a per-device basis
	self.componentCache = aCache;
	[aCache release];
	
    [customNavigationBar setTheme:kSCHThemeManagerNavigationBarImage];
		
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateTable:)
												 name:@"SCHBookshelfSyncComponentComplete"
											   object:nil];
	
	
	self.loadingView.layer.cornerRadius = 5.0f;
	[self.view bringSubviewToFront:self.loadingView];
	
	if (![[SCHSyncManager sharedSyncManager] havePerformedFirstSyncUpToBooks] && [[SCHSyncManager sharedSyncManager] isSynchronizing]) {
//		NSLog(@"Showing loading view...");
		self.loadingView.hidden = NO;
	} else {
//		NSLog(@"Hiding loading view...");
		self.loadingView.hidden = YES;
	}
    
    if ([[self.profileItem.FirstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@%@", self.profileItem.FirstName, NSLocalizedString(@"'s Books", @"")];
    } else {
        self.navigationItem.title = NSLocalizedString(@"'s Books", @"");
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme) name:kSCHThemeManagerThemeChangeNotification object:nil];                
}

- (void) viewWillAppear:(BOOL)animated
{
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar updateTheme];
    [super viewWillAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (YES);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self.gridView setShelfImage:[[SCHThemeManager sharedThemeManager] imageForShelf:self.interfaceOrientation]];        
    [self.view.layer setContents:(id)[[SCHThemeManager sharedThemeManager] imageForBackground:self.interfaceOrientation].CGImage];
    
    [self setInterfaceOrientation:toInterfaceOrientation];
}

- (void)setInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar updateTheme:interfaceOrientation];
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        [self.gridView setShelfHeight:kSCHBookShelfViewControllerGridCellHeightLandscape];
    } else {
        [self.gridView setShelfHeight:kSCHBookShelfViewControllerGridCellHeightPortrait];
    }
}

- (void)updateTheme
{
    [self.gridView setShelfImage:[[SCHThemeManager sharedThemeManager] imageForShelf:self.interfaceOrientation]];    
    [self.view.layer setContents:(id)[[SCHThemeManager sharedThemeManager] imageForBackground:self.interfaceOrientation].CGImage];
}

- (void)changeTheme
{
	[self presentModalViewController:self.themePickerContainer animated:YES];		
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer {
    [self setEditing:YES animated:YES];
    return NO;
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    if (editing) {
        if (![self.gridView isEditing]) {
            SCHThemeButton *button = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
            [button setFrame:CGRectMake(0, 0, 60, 30)];
            [button setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [button setTitleColor:[UIColor colorWithWhite:1 alpha:0.5f] forState:UIControlStateHighlighted];
            [button setReversesTitleShadowWhenHighlighted:YES];
            
            button.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            button.titleLabel.shadowOffset = CGSizeMake(0, -1);
            
            [button setThemeButton:kSCHThemeManagerDoneButtonImage leftCapWidth:5 topCapHeight:0];
            [button addTarget:self action:@selector(finishEditing:) forControlEvents:UIControlEventTouchUpInside];    
            self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
        }
    } else {
        [self.navigationItem setRightBarButtonItem:self.themeButton animated:animated];
    }
    
    [self.gridView setEditing:editing animated:animated];
}

- (void)finishEditing:(id)sender
{
    [self setEditing:NO animated:YES];
}

- (void)setProfileItem:(SCHProfileItem *)newProfileItem
{
	[profileItem release];
    profileItem = newProfileItem;
    [profileItem retain];	
    
    if ([[profileItem.FirstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@%@", profileItem.FirstName, NSLocalizedString(@"'s Books", @"")];
    } else {
        self.navigationItem.title = NSLocalizedString(@"Books", @"");
    }
    
	self.books = [self.profileItem allISBNs];
}

- (void)setBooks:(NSMutableArray *)newBooks
{
	[books release];
    books = newBooks;
    [books retain];	
    
	[self.gridView reloadData];
}

#pragma mark -
#pragma mark Core Data Table View Methods

- (void) updateTable:(NSNotification *)notification
{
	self.books = [self.profileItem allISBNs];
	self.loadingView.hidden = YES;
}

#pragma mark -
#pragma mark Core Data Grid View Methods
#pragma mark MRGridViewDataSource methods

-(MRGridViewCell*)gridView:(MRGridView*)aGridView cellForGridIndex:(NSInteger)index 
{
	static NSString* cellIdentifier = @"ScholasticGridViewCell";
	SCHBookShelfGridViewCell* gridCell = (SCHBookShelfGridViewCell *) [aGridView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (gridCell == nil) {
		gridCell = [[[SCHBookShelfGridViewCell alloc] initWithFrame:[aGridView frameForCellAtGridIndex:index] reuseIdentifier:cellIdentifier] autorelease];
	}
	else {
		gridCell.frame = [aGridView frameForCellAtGridIndex:index];
	}

	[gridCell setIsbn:[self.books objectAtIndex:index]];
	
	return gridCell;
}

-(NSInteger)numberOfItemsInGridView:(MRGridView*)gridView 
{
    return [self.books count];
}

-(NSString*)contentDescriptionForCellAtIndex:(NSInteger)index 
{
	return nil;
}

-(BOOL) gridView:(MRGridView*)gridView canMoveCellAtIndex: (NSInteger)index 
{ 
//	NSLog(@"Starting move for cell %d", index);
	self.moveToValue = -1;
	return YES;
}

-(void) gridView:(MRGridView*)gridView moveCellAtIndex: (NSInteger)fromIndex toIndex: (NSInteger)toIndex
{
//	NSLog(@"Moving cell from index %d to index %d", fromIndex, toIndex);
	
	self.moveToValue = toIndex;
}

-(void) gridView:(MRGridView*)gridView finishedMovingCellToIndex:(NSInteger)toIndex
{
//	NSLog(@"Finished moving cell to index %d", toIndex);
	
	if (self.moveToValue != -1 && (toIndex != self.moveToValue)) {
		NSLog(@"Moving cell from index %d to index %d", toIndex, self.moveToValue);
        [self.books exchangeObjectAtIndex:toIndex withObjectAtIndex:self.moveToValue];
        [self.profileItem saveBookOrder:self.books];
        NSError *error = nil;
        
        if (![self.profileItem.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }                 
	}
}
-(void) gridView:(MRGridView*)gridView commitEditingStyle:(MRGridViewCellEditingStyle)editingStyle forIndex:(NSInteger)index
{
}

#pragma mark MRGridViewDelegate methods

-(void)gridView:(MRGridView *)aGridView didSelectCellAtIndex:(NSInteger)index 
{
    
    if (index >= [self.books count]) {
        return;
    }
    
	NSLog(@"Calling grid view selection.");
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:[self.books objectAtIndex:index]];

	// notify the processing manager that the user touched a book info object.
	// this allows it to pause and resume items, etc.
	// will do nothing if the book has already been fully downloaded.
	[[SCHProcessingManager sharedProcessingManager] userSelectedBookWithISBN:book.ContentIdentifier];
	
	// if the processing manager is working, do not open the book
	if (![book canOpenBook]) {
		return;
	}
	
	
	NSLog(@"Showing book %@.", book.Title);
	
//	SCHReadingViewController *pageView = [[SCHReadingViewController alloc] initWithNibName:nil bundle:nil];
//	pageView.isbn = book.ContentIdentifier;

	BITReadingOptionsView *optionsView = [[BITReadingOptionsView alloc] initWithNibName:nil bundle:nil];
//	optionsView.pageViewController = pageView;
	optionsView.isbn = book.ContentIdentifier;
    optionsView.profileItem = self.profileItem;
	
	NSString *thumbKey = [NSString stringWithFormat:@"thumb-%@", book.ContentIdentifier];
	NSData *imageData = [self.componentCache objectForKey:thumbKey];
	
	if ([imageData length]) {
		optionsView.thumbnailImage = [UIImage imageWithData:imageData];
	} else {
		SCHXPSProvider *provider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:book.ContentIdentifier];
		imageData = [provider coverThumbData];
		[[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:book.ContentIdentifier];
		
		if (!imageData) {
			optionsView.thumbnailImage = [UIImage imageNamed:@"PlaceholderBook"];
		} else {
			[self.componentCache setObject:imageData forKey:thumbKey cost:[imageData length]];
			optionsView.thumbnailImage = [UIImage imageWithData:imageData];
		}
		
		optionsView.thumbnailImage = [UIImage imageWithData:imageData];
	}
	
	[self.navigationController pushViewController:optionsView animated:YES];
	[optionsView release];
//	[pageView release];	
	
}

-(void)gridView:(MRGridView *)gridView confirmationForDeletionAtIndex:(NSInteger)index 
{
	
}

#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[self releaseViewObjects];

}

@end

