//
//  SCHBookShelfViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 14/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfViewController.h"
#import "BWKTestPageViewController.h"
#import "BWKReadingOptionsView.h"
#import "SCHLibreAccessWebService.h"
#import "SCHContentMetadataItem+Extensions.h"
#import "SCHLocalDebug.h"
#import "SCHMultipleBookshelvesController.h"
#import "SCHBookManager.h"
#import "SCHBookInfo.h"
#import "SCHProcessingManager.h"
#import "SCHBookShelfTableViewCell.h"
#import "SCHThumbnailFactory.h"
#import "SCHAsyncImageView.h"
#import "SCHSyncManager.h"
#import "SCHBookShelfGridViewCell.h"
#import <QuartzCore/QuartzCore.h>

@interface SCHBookShelfViewController ()

//- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

NSInteger bookSort(SCHBookInfo *book1, SCHBookInfo *book2, void *context)
{
	return([book1.contentMetadata.Title localizedCaseInsensitiveCompare:book2.contentMetadata.Title]);
}

@implementation SCHBookShelfViewController

@synthesize bookshelvesController;
#ifdef LOCALDEBUG
@synthesize managedObjectContext;
#endif
@synthesize books;
@synthesize tableView, gridView, loadingView, componentCache;
@synthesize profileItem;

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
	
	BlioTimeOrderedCache *aCache = [[BlioTimeOrderedCache alloc] init];
	aCache.countLimit = 30; // Arbitrary 30 object limit
	aCache.totalCostLimit = 1024*1024; // Arbitrary 1MB limit. This may need wteaked or set on a per-device basis
	self.componentCache = aCache;
	[aCache release];
	
	
#ifdef LOCALDEBUG
	self.bookshelvesController.navigationItem.title = @"Local Bookshelf";
#endif
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateTable:)
												 name:@"SCHBookDownloadStatusUpdate"
											   object:nil];
	
	[[NSNotificationCenter defaultCenter] addObserver:self
											 selector:@selector(updateTable:)
												 name:@"SCHBookshelfSyncComponentComplete"
											   object:nil];
	
	
	self.loadingView.layer.cornerRadius = 5.0f;
	[self.view bringSubviewToFront:self.loadingView];
	
	if (![[SCHSyncManager sharedSyncManager] havePerformedFirstSyncUpToBooks] && [[SCHSyncManager sharedSyncManager] isSynchronizing]) {
		NSLog(@"Showing loading view...");
		self.loadingView.hidden = NO;
	} else {
		NSLog(@"Hiding loading view...");
		self.loadingView.hidden = YES;
	}
	
}

- (void)setBooks:(NSArray *)newBooks
{
	[books release];
	books = [newBooks sortedArrayUsingFunction:bookSort context:NULL];
	[books retain];
	
	
	BOOL spaceSaverMode = [[NSUserDefaults standardUserDefaults] boolForKey:@"kSCHSpaceSaverMode"];
	
	if (!spaceSaverMode) {
		//NSLog(@"Space saver mode is off - setting all books to download.");
		
		for (SCHBookInfo *bookInfo in self.books) {
			
			BookFileProcessingState state = [bookInfo processingState];
			
			if (!([bookInfo isCurrentlyDownloading] || [bookInfo isWaitingForDownload])) {
				switch (state) {
					case bookFileProcessingStateError:
						break;
					case bookFileProcessingStateNoFileDownloaded:
					case bookFileProcessingStatePartiallyDownloaded:
						[[SCHProcessingManager defaultManager] downloadBookFile:bookInfo];
						break;
					default:
						break;
				}	
			}
		}
	} else {
		//NSLog(@"Space saver mode is on!");
	}
	
	[self.tableView reloadData];
	[self.gridView reloadData];
	
}

#pragma mark -
#pragma mark Core Data Table View Methods

- (void) updateTable:(NSNotification *)notification
{
	self.books = [self.profileItem allContentMetadataItems];
	self.loadingView.hidden = YES;
	
	// FIXME: more specific updates of cells
	//[self.tableView reloadData];
	//[self.gridView reloadData];
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
	SCHBookInfo *bookInfo = [self.books objectAtIndex:indexPath.row];
	[cell setBookInfo:bookInfo];
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	
	SCHBookInfo *bookInfo = [self.books objectAtIndex:indexPath.row];

	if ([bookInfo isCurrentlyDownloading] || [bookInfo isWaitingForDownload]) {
		[[SCHProcessingManager defaultManager] removeBookFromDownload:bookInfo];
		return;
	}
	
	BookFileProcessingState state = [bookInfo processingState];
	
	[aTableView reloadData];

	switch (state) {
		case bookFileProcessingStateError:
			return;
			break;
		case bookFileProcessingStateNoFileDownloaded:
		case bookFileProcessingStatePartiallyDownloaded:
			[[SCHProcessingManager defaultManager] downloadBookFile:bookInfo];
			return;
			break;
		default:
			break;
	}	
	
	NSLog(@"Showing book %@.", [bookInfo.contentMetadata Title]);
	NSLog(@"Filename %@.", [bookInfo.contentMetadata FileName]);
	
	SCHContentMetadataItem *contentMetadataItem = bookInfo.contentMetadata;
	
	BWKTestPageViewController *pageView = [[BWKTestPageViewController alloc] initWithNibName:nil bundle:nil];
	pageView.bookInfo = bookInfo;
	
	BWKReadingOptionsView *optionsView = [[BWKReadingOptionsView alloc] initWithNibName:nil bundle:nil];
	optionsView.pageViewController = pageView;
	optionsView.bookInfo = bookInfo;
	
	NSString *thumbKey = [NSString stringWithFormat:@"thumb-%@", contentMetadataItem.ContentIdentifier];
	NSData *imageData = [self.componentCache objectForKey:thumbKey];
	
	if ([imageData length]) {
		optionsView.thumbnailImage = [UIImage imageWithData:imageData];
	} else {
		BWKXPSProvider *provider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBook:bookInfo];
		provider.title = contentMetadataItem.FileName;
		imageData = [provider coverThumbData];
		[[SCHBookManager sharedBookManager] checkInXPSProviderForBook:bookInfo];

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
	
	SCHBookInfo *bookInfo = [self.books objectAtIndex:index];

	[gridCell setBookInfo:bookInfo];
		
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

-(BOOL) gridView:(MRGridView*)gridView canMoveCellAtIndex: (NSInteger)index { return NO;}
-(void) gridView:(MRGridView*)gridView moveCellAtIndex: (NSInteger)fromIndex toIndex: (NSInteger)toIndex{}
-(void) gridView:(MRGridView*)gridView finishedMovingCellToIndex:(NSInteger)toIndex{}
-(void) gridView:(MRGridView*)gridView commitEditingStyle:(MRGridViewCellEditingStyle)editingStyle forIndex:(NSInteger)index{}

#pragma mark MRGridViewDelegate methods

-(void)gridView:(MRGridView *)aGridView didSelectCellAtIndex:(NSInteger)index 
{
	NSLog(@"Calling grid view selection.");
	SCHBookInfo *bookInfo = [self.books objectAtIndex:index];

	if ([bookInfo isCurrentlyDownloading] || [bookInfo isWaitingForDownload]) {
		[[SCHProcessingManager defaultManager] removeBookFromDownload:bookInfo];
		return;
	}
	
	SCHContentMetadataItem *contentMetadataItem = bookInfo.contentMetadata;
	BookFileProcessingState state = [bookInfo processingState];
	
	switch (state) {
		case bookFileProcessingStateError:
			return;
			break;
		case bookFileProcessingStateNoFileDownloaded:
		case bookFileProcessingStatePartiallyDownloaded:
			[[SCHProcessingManager defaultManager] downloadBookFile:bookInfo];
			[aGridView reloadData];
			return;
			break;
		default:
			break;
	}	

	[aGridView reloadData];
	
	NSLog(@"Showing book %@.", [bookInfo.contentMetadata Title]);
	NSLog(@"Filename %@.", [bookInfo.contentMetadata FileName]);
	
	BWKTestPageViewController *pageView = [[BWKTestPageViewController alloc] initWithNibName:nil bundle:nil];
	pageView.bookInfo = bookInfo;
	
	BWKReadingOptionsView *optionsView = [[BWKReadingOptionsView alloc] initWithNibName:nil bundle:nil];
	optionsView.pageViewController = pageView;
	optionsView.bookInfo = bookInfo;
	
	NSString *thumbKey = [NSString stringWithFormat:@"thumb-%@", contentMetadataItem.ContentIdentifier];
	NSData *imageData = [self.componentCache objectForKey:thumbKey];
	
	if ([imageData length]) {
		optionsView.thumbnailImage = [UIImage imageWithData:imageData];
	} else {
		BWKXPSProvider *provider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBook:bookInfo];
		provider.title = contentMetadataItem.FileName;
		imageData = [provider coverThumbData];
		[[SCHBookManager sharedBookManager] checkInXPSProviderForBook:bookInfo];
		
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
	

/*	BWKTestPageViewController *pageView = [[BWKTestPageViewController alloc] initWithNibName:nil bundle:nil];
	//pageView.book = contentMetadataItem;
	pageView.bookInfo = bookInfo;
	
	BWKReadingOptionsView *optionsView = [[BWKReadingOptionsView alloc] initWithNibName:nil bundle:nil];
	optionsView.pageViewController = pageView;
	optionsView.bookInfo = bookInfo;

	BWKXPSProvider *provider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBook:bookInfo];
	provider.title = contentMetadataItem.FileName;
	optionsView.thumbnailImage = [provider coverThumbForList];
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBook:bookInfo];
//	[provider release];
	
	[self.navigationController pushViewController:optionsView animated:YES];
	[optionsView release];
	[pageView release];	*/
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
    self.books = nil;
	[self releaseViewObjects];
	
	bookshelvesController = nil;
    [super dealloc];
}


@end

