//
//  SCHBookShelfViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 14/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "SCHReadingOptionsView.h"
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

static NSInteger const kSCHBookShelfViewControllerGridCellHeightPortrait = 138;
static NSInteger const kSCHBookShelfViewControllerGridCellHeightLandscape = 150;

@interface SCHBookShelfViewController () <UIGestureRecognizerDelegate>

@property (nonatomic, retain) UIBarButtonItem *themeButton;
@property (nonatomic, assign) int moveToValue;

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)updateTheme;
- (void)setEditing:(BOOL)editing animated:(BOOL)animated;
- (void)finishEditing:(id)sender;

@end

@implementation SCHBookShelfViewController

@synthesize gridView;
@synthesize shadowView;
@synthesize loadingView;
@synthesize themePickerContainer;
@synthesize customNavigationBar;
@synthesize componentCache;
@synthesize books;
@synthesize profileItem;
@synthesize themeButton;
@synthesize moveToValue;

#pragma mark - Object lifecycle

- (void)releaseViewObjects 
{
    [gridView release], gridView = nil;
    [shadowView release], shadowView = nil;
    [loadingView release], loadingView = nil;
    [themePickerContainer release], themePickerContainer = nil;
    [customNavigationBar release], customNavigationBar = nil;
    
    [componentCache release], componentCache = nil;
    
    [themeButton release], themeButton = nil;
    
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc 
{    
    [books release], books = nil;
    [profileItem release], profileItem = nil;
    
    [self releaseViewObjects];   
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];

    SCHThemeButton *button = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [button setThemeIcon:kSCHThemeManagerThemeIcon];
    [button sizeToFit];    
    [button addTarget:self action:@selector(changeTheme) forControlEvents:UIControlEventTouchUpInside];    
    self.themeButton = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    self.navigationItem.rightBarButtonItem = self.themeButton;

    button = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [button setThemeIcon:kSCHThemeManagerHomeIcon];
    [button sizeToFit];    
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
    
    [self updateTheme];
    
	[self.gridView setCellSize:CGSizeMake(80,118) withBorderSize:20];
    [self.gridView setBackgroundColor:[UIColor clearColor]];
    [self.gridView setMinimumNumberOfShelves:10];
    
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
	
    [customNavigationBar setTheme:kSCHThemeManagerNavigationBarImage];
		
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
    
    if ([[self.profileItem.FirstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@%@", self.profileItem.FirstName, NSLocalizedString(@"'s Books", @"")];
    } else {
        self.navigationItem.title = NSLocalizedString(@"'s Books", @"");
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateTheme) name:kSCHThemeManagerThemeChangeNotification object:nil];              
    
    [self setupAssetsForOrientation:self.interfaceOrientation];
    
    [self.shadowView setImage:[[UIImage imageNamed:@"bookshelf-iphone-top-shadow.png"] stretchableImageWithLeftCapWidth:15.0f topCapHeight:0]];
    
    [self.gridView reloadData];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
	[self releaseViewObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

#pragma mark - Orientation methods

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self.gridView setShelfImage:[[SCHThemeManager sharedThemeManager] imageForShelf:interfaceOrientation]];        
    [self.view.layer setContents:(id)[[SCHThemeManager sharedThemeManager] imageForBackground:interfaceOrientation].CGImage];
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar updateTheme:interfaceOrientation];
    
    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        [self.gridView setShelfHeight:kSCHBookShelfViewControllerGridCellHeightLandscape];
        [self.gridView setShelfInset:CGSizeMake(0, -1)];
    } else {
        [self.gridView setShelfHeight:kSCHBookShelfViewControllerGridCellHeightPortrait];
        [self.gridView setShelfInset:CGSizeMake(0, -2)];
        
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

- (void)updateTheme
{
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

- (void)changeTheme
{
	[self presentModalViewController:self.themePickerContainer animated:YES];		
}

#pragma mark - Action methods

- (IBAction)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer 
{
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

#pragma mark - Accessor Methods

- (void)setProfileItem:(SCHProfileItem *)newProfileItem
{
    [newProfileItem retain];	    
	[profileItem release];
    profileItem = newProfileItem;
    
    if ([[profileItem.FirstName stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        self.navigationItem.title = [NSString stringWithFormat:@"%@%@", profileItem.FirstName, NSLocalizedString(@"'s Books", @"")];
    } else {
        self.navigationItem.title = NSLocalizedString(@"Books", @"");
    }
    
	self.books = [self.profileItem allISBNs];
}

- (void)setBooks:(NSMutableArray *)newBooks
{
    [newBooks retain];
	[books release];
    books = newBooks;
    
	[self.gridView reloadData];
}

#pragma mark - Core Data Table View Methods

- (void)updateTable:(NSNotification *)notification
{
	self.books = [self.profileItem allISBNs];
	self.loadingView.hidden = YES;
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

	[gridCell setIsbn:[self.books objectAtIndex:index]];
	
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

- (void)gridView:(MRGridView*)gridView finishedMovingCellToIndex:(NSInteger)toIndex
{
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
	
	SCHReadingOptionsView *optionsView = [[SCHReadingOptionsView alloc] initWithNibName:nil bundle:nil];
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
	[optionsView release], optionsView = nil;
}

- (void)gridView:(MRGridView *)gridView confirmationForDeletionAtIndex:(NSInteger)index 
{
	// nop
}

@end

