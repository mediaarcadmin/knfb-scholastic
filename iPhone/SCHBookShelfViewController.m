//
//  SCHBookShelfViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 14/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfViewController.h"
#import "BITTestPageViewController.h"
#import "BITReadingOptionsView.h"
#import "SCHLibreAccessWebService.h"
#import "SCHLocalDebug.h"
#import "SCHMultipleBookshelvesController.h"
#import "SCHBookManager.h"
#import "SCHBookShelfTableViewCell.h"
#import "SCHThumbnailFactory.h"
#import "SCHSyncManager.h"
#import "SCHBookShelfGridViewCell.h"
#import "SCHXPSProvider.h"
#import <QuartzCore/QuartzCore.h>
#import "SCHAppBook.h"

@interface SCHBookShelfViewController ()

//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@property int moveToValue;

@end

@implementation SCHBookShelfViewController

@synthesize bookshelvesController;
#if LOCALDEBUG
@synthesize managedObjectContext;
#endif
@synthesize books;
@synthesize tableView, gridView, loadingView, componentCache;
@synthesize profileItem;
@synthesize moveToValue;

- (void)releaseViewObjects 
{
	self.gridView = nil;
	self.tableView = nil;
	self.componentCache = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
		
	[self.gridView setCellSize:CGSizeMake(80,118) withBorderSize:20];
	[self.gridView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Shelf"]]];
	[self.gridView setEditing:YES animated:NO];
	self.moveToValue = -1;
	
	KNFBTimeOrderedCache *aCache = [[KNFBTimeOrderedCache alloc] init];
	aCache.countLimit = 30; // Arbitrary 30 object limit
	aCache.totalCostLimit = 1024*1024; // Arbitrary 1MB limit. This may need wteaked or set on a per-device basis
	self.componentCache = aCache;
	[aCache release];
	
	
#if LOCALDEBUG
	self.bookshelvesController.navigationItem.title = @"Local Bookshelf";
#endif
	
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
	
}

- (void)setBooks:(NSMutableArray *)newBooks
{
	[books release];
    books = newBooks;
    [books retain];	
    
	[self.tableView reloadData];
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
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [books count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"BookCell";
    
    SCHBookShelfTableViewCell *cell = (SCHBookShelfTableViewCell *) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[SCHBookShelfTableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.titleLabel.font = [UIFont systemFontOfSize:14.0];
		cell.subtitleLabel.font = [UIFont systemFontOfSize:12.0];
    }
    
    // Configure the cell...
	[cell setIsbn:[self.books objectAtIndex:indexPath.row]];
	
	UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(startEditingTable:)];
    longPress.delegate = self;
	[cell addGestureRecognizer:longPress];
	[longPress release];
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:[self.books objectAtIndex:indexPath.row]];

	// notify the processing manager that the user touched a book info object.
	// this allows it to pause and resume items, etc.
	// will do nothing if the book has already been fully downloaded.
	[[SCHProcessingManager sharedProcessingManager] userSelectedBookWithISBN:book.ContentIdentifier];
	
	// if the processing manager is working, do not open the book
	if (![book canOpenBook]) {
		return;
	}
	
	NSLog(@"Showing book %@.", [book Title]);
	
	BITTestPageViewController *pageView = [[BITTestPageViewController alloc] initWithNibName:nil bundle:nil];
	pageView.isbn = book.ContentIdentifier;
	
	BITReadingOptionsView *optionsView = [[BITReadingOptionsView alloc] initWithNibName:nil bundle:nil];
	optionsView.pageViewController = pageView;
	optionsView.isbn = book.ContentIdentifier;
	
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
	
	[self.bookshelvesController.navigationController pushViewController:optionsView animated:YES];
	[optionsView release];
	[pageView release];	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 132.0f;
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return UITableViewCellEditingStyleNone;
}

- (BOOL)tableView:(UITableView *)tableview canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
	return YES;	
}

- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
	if (fromIndexPath.row != toIndexPath.row) {
		NSLog(@"Moving row %d to row %d.", fromIndexPath.row, toIndexPath.row);
        [self.books exchangeObjectAtIndex:fromIndexPath.row withObjectAtIndex:toIndexPath.row];
        [self.profileItem saveBookOrder:self.books];
        NSError *error = nil;
        
        if (![self.profileItem.managedObjectContext save:&error]) {
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }         
	}
}

#pragma mark Table Cell Editing Toggle

- (void) startEditingTable: (UILongPressGestureRecognizer *) gesture
{
    [self.tableView setEditing:YES animated:YES];
    [self.bookshelvesController showEditingButton:YES forTable:self.tableView];
}

- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    if ([gestureRecognizer isKindOfClass:[UILongPressGestureRecognizer class]]) {
        if ([self.tableView isEditing]) {
            return NO;
        }
    }
    
    return YES;
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
	[self.bookshelvesController stopSidewaysScrolling];
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
	[self.bookshelvesController resumeSidewaysScrolling];
	
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
	
	BITTestPageViewController *pageView = [[BITTestPageViewController alloc] initWithNibName:nil bundle:nil];
	pageView.isbn = book.ContentIdentifier;
	
	BITReadingOptionsView *optionsView = [[BITReadingOptionsView alloc] initWithNibName:nil bundle:nil];
	optionsView.pageViewController = pageView;
	optionsView.isbn = book.ContentIdentifier;
	
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
	
	[self.bookshelvesController.navigationController pushViewController:optionsView animated:YES];
	[optionsView release];
	[pageView release];	
	
}

-(void)gridView:(MRGridView *)gridView confirmationForDeletionAtIndex:(NSInteger)index 
{
	
}

#pragma mark -
#pragma mark Actions

- (void)bookshelfToggled:(NSUInteger)selectedSegment 
{	
	switch (selectedSegment) {
		case 0:
			[self.view bringSubviewToFront:self.tableView];
			[self.tableView reloadData];
			break;
		case 1:
			[self.view bringSubviewToFront:self.gridView];
			[self.gridView reloadData];
			break;
		default:
			break;
	}
	
	[self.view bringSubviewToFront:self.loadingView];
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


- (void)dealloc {
	[self releaseViewObjects];
	
    [books release], books = nil;
	bookshelvesController = nil;
    [super dealloc];
}


@end

