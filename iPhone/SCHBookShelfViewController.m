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
#import "BWKBookManager.h"

@interface SCHBookShelfViewController ()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;

@end

NSInteger bookSort(SCHContentMetadataItem *book1, SCHContentMetadataItem *book2, void *context)
{
	return([book1.Title localizedCaseInsensitiveCompare:book2.Title]);
}

@implementation SCHBookShelfViewController

@synthesize bookshelvesController;
#ifdef LOCALDEBUG
@synthesize managedObjectContext;
#endif
@synthesize books;
@synthesize tableView, gridView, componentCache;

- (void)releaseViewObjects 
{
	self.gridView = nil;
	self.tableView = nil;
	self.componentCache = nil;
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
	self.bookshelvesController.navigationItem.title = @"Bookshelf (Local)";
#endif
	

}



/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/
/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)setBooks:(NSArray *)newBooks
{
	[books release];
	books = [newBooks sortedArrayUsingFunction:bookSort context:NULL];
	[books retain];
	
	[self.tableView reloadData];
	[self.gridView reloadData];
}

#pragma mark -
#pragma mark Core Data Table View Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {	
	SCHContentMetadataItem *contentMetadataItem = [self.books objectAtIndex:indexPath.row];
	
	cell.textLabel.text = contentMetadataItem.Title; 
	cell.detailTextLabel.text = contentMetadataItem.Author;
	
	if (contentMetadataItem.FileName != nil) {
		
		NSString *thumbKey = [NSString stringWithFormat:@"thumb-%@", contentMetadataItem.FileName];
		NSData *imageData = [self.componentCache objectForKey:thumbKey];
		
		if ([imageData length]) {
			cell.imageView.image = [UIImage imageWithData:imageData];
		} else {
			BWKXPSProvider *provider = [[BWKBookManager sharedBookManager] checkOutXPSProviderForBookWithID:[contentMetadataItem objectID]];
			provider.title = contentMetadataItem.FileName;
			imageData = [provider coverThumbData];
			[[BWKBookManager sharedBookManager] checkInXPSProviderForBookWithID:[contentMetadataItem objectID]];
			[self.componentCache setObject:imageData forKey:thumbKey cost:[imageData length]];
			cell.imageView.image = [UIImage imageWithData:imageData];
		}
		
	} else {
		cell.imageView.image = nil;
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [books count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"BookCell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier] autorelease];
		cell.textLabel.font = [UIFont systemFontOfSize:14.0];
		cell.detailTextLabel.font = [UIFont systemFontOfSize:12.0];
		cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	[aTableView deselectRowAtIndexPath:indexPath animated:YES];
	
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
	
	SCHContentMetadataItem *contentMetadataItem = [self.books objectAtIndex:indexPath.row];
	
	BWKTestPageViewController *pageView = [[BWKTestPageViewController alloc] initWithNibName:nil bundle:nil];
	pageView.book = contentMetadataItem;
	
	BWKReadingOptionsView *optionsView = [[BWKReadingOptionsView alloc] initWithNibName:nil bundle:nil];
	optionsView.pageViewController = pageView;
	optionsView.metadataItem = contentMetadataItem;
	
//	BWKXPSProvider *provider = [[BWKBookManager sharedBookManager] checkOutXPSProviderForBookWithID:[contentMetadataItem objectID]];
//	provider.title = contentMetadataItem.FileName;
//	optionsView.thumbnailImage = [provider coverThumbForList];
//	[[BWKBookManager sharedBookManager] checkInXPSProviderForBookWithID:[contentMetadataItem objectID]];

	NSString *thumbKey = [NSString stringWithFormat:@"thumb-%@", contentMetadataItem.FileName];
	NSData *imageData = [self.componentCache objectForKey:thumbKey];
	
	if ([imageData length]) {
		optionsView.thumbnailImage = [UIImage imageWithData:imageData];
	} else {
		BWKXPSProvider *provider = [[BWKBookManager sharedBookManager] checkOutXPSProviderForBookWithID:[contentMetadataItem objectID]];
		provider.title = contentMetadataItem.FileName;
		imageData = [provider coverThumbData];
		[[BWKBookManager sharedBookManager] checkInXPSProviderForBookWithID:[contentMetadataItem objectID]];
		[self.componentCache setObject:imageData forKey:thumbKey cost:[imageData length]];
		optionsView.thumbnailImage = [UIImage imageWithData:imageData];
	}
	
	
	[self.bookshelvesController.navigationController pushViewController:optionsView animated:YES];
	[optionsView release];
	[pageView release];	
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 88.0f;
}

#pragma mark -
#pragma mark Core Data Grid View Methods
#pragma mark MRGridViewDataSource methods

-(MRGridViewCell*)gridView:(MRGridView*)aGridView cellForGridIndex:(NSInteger)index 
{
	static NSString* cellIdentifier = @"ScholasticGridViewCell";
	MRGridViewCell* gridCell = [aGridView dequeueReusableCellWithIdentifier:cellIdentifier];
	if (gridCell == nil) {
		gridCell = [[[MRGridViewCell alloc]initWithFrame:[aGridView frameForCellAtGridIndex: index] reuseIdentifier:cellIdentifier] autorelease];
		UIImageView *coverView = [[UIImageView alloc] init];
		coverView.contentMode = UIViewContentModeScaleToFill;
		coverView.tag = 666;
		[gridCell.contentView addSubview:coverView];
		[coverView release];
	}
	else {
		gridCell.frame = [aGridView frameForCellAtGridIndex: index];
	}
	
	SCHContentMetadataItem *contentMetadataItem = [self.books objectAtIndex:index];
	UIImage *thumb = nil;
	
	if (contentMetadataItem.FileName == nil) {
		thumb = [UIImage imageNamed:@"PlaceholderBook"];
	} else {
		/*
		BWKXPSProvider *provider = [[BWKBookManager sharedBookManager] checkOutXPSProviderForBookWithID:[contentMetadataItem objectID]];
		provider.title = contentMetadataItem.FileName;
		thumb = [provider coverThumbForList];
		[[BWKBookManager sharedBookManager] checkInXPSProviderForBookWithID:[contentMetadataItem objectID]];*/

		NSString *thumbKey = [NSString stringWithFormat:@"thumb-%@", contentMetadataItem.FileName];
		NSData *imageData = [self.componentCache objectForKey:thumbKey];
		
		if ([imageData length]) {
			thumb = [UIImage imageWithData:imageData];
		} else {
			BWKXPSProvider *provider = [[BWKBookManager sharedBookManager] checkOutXPSProviderForBookWithID:[contentMetadataItem objectID]];
			provider.title = contentMetadataItem.FileName;
			imageData = [provider coverThumbData];
			[[BWKBookManager sharedBookManager] checkInXPSProviderForBookWithID:[contentMetadataItem objectID]];
			[self.componentCache setObject:imageData forKey:thumbKey cost:[imageData length]];
			thumb = [UIImage imageWithData:imageData];
		}
		
		
	}
		
	CGRect maxRect = UIEdgeInsetsInsetRect(gridCell.bounds, UIEdgeInsetsMake(0, 0, 23, 0));
	CGFloat fitScale = MAX(thumb.size.width / maxRect.size.width, thumb.size.height / maxRect.size.height);
	
	CGRect fitRect = CGRectZero;
	fitRect.size.width = thumb.size.width / fitScale;
	fitRect.size.height = thumb.size.height / fitScale;
	fitRect.origin.x = maxRect.origin.x + (maxRect.size.width - fitRect.size.width)/2.0f;
	fitRect.origin.y = maxRect.origin.y + (maxRect.size.height - fitRect.size.height);
	
	UIImageView *coverView = (UIImageView *)[gridCell viewWithTag:666];
	coverView.frame = fitRect;
	coverView.image = thumb;		

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

-(void)gridView:(MRGridView *)gridView didSelectCellAtIndex:(NSInteger)index 
{
	SCHContentMetadataItem *contentMetadataItem = [self.books objectAtIndex:index];
	BWKTestPageViewController *pageView = [[BWKTestPageViewController alloc] initWithNibName:nil bundle:nil];
	pageView.book = contentMetadataItem;
	
	BWKReadingOptionsView *optionsView = [[BWKReadingOptionsView alloc] initWithNibName:nil bundle:nil];
	optionsView.pageViewController = pageView;
	optionsView.metadataItem = contentMetadataItem;

	BWKXPSProvider *provider = [[BWKBookManager sharedBookManager] checkOutXPSProviderForBookWithID:[contentMetadataItem objectID]];
	provider.title = contentMetadataItem.FileName;
	optionsView.thumbnailImage = [provider coverThumbForList];
	[[BWKBookManager sharedBookManager] checkInXPSProviderForBookWithID:[contentMetadataItem objectID]];
//	[provider release];
	
	[self.navigationController pushViewController:optionsView animated:YES];
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

