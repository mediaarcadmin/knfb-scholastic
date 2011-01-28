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
#import "SCHContentMetadataItem.h"
#import "SCHLocalDebug.h"

@interface SCHBookShelfViewController ()

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
#ifdef LOCALDEBUG
- (void) checkAndCopyLocalFilesToApplicationSupport;
#endif
@end

@implementation SCHBookShelfViewController

@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;
@synthesize profileID;
@synthesize tableView, gridView;

- (void)releaseViewObjects 
{
	self.gridView = nil;
	self.tableView = nil;
}

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
#ifdef LOCALDEBUG
	NSError *error = nil;
	NSArray *xpsFiles = nil;
	
	[self checkAndCopyLocalFilesToApplicationSupport];

//	NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
	
	NSArray  *applicationSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportPath = ([applicationSupportPaths count] > 0) ? [applicationSupportPaths objectAtIndex:0] : nil;
	
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:applicationSupportPath error:&error];
	
	if (error) {
		NSLog(@"Error: %@", [error localizedDescription]);
	}

	NSArray *xpsContents = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.xps'"]];
	
	NSMutableArray *trimmedXpsContents = [[NSMutableArray alloc] init];
	for (NSString *item in xpsContents) {
		[trimmedXpsContents addObject:[item stringByDeletingPathExtension]];
	}
	
	xpsFiles = [NSArray arrayWithArray:trimmedXpsContents];
	[trimmedXpsContents release];
	
	SCHLocalDebug *localDebug = [[SCHLocalDebug alloc] init];
	localDebug.managedObjectContext = self.managedObjectContext;
	[localDebug setupLocalDataWithXPSFiles:xpsFiles];
	[localDebug release], localDebug = nil;
	
	self.title = @"Bookshelf (Local)";
#endif
	
	UISegmentedControl *bookshelfToggle = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"List", @"Grid", nil]];
	bookshelfToggle.selectedSegmentIndex = 0;
	bookshelfToggle.segmentedControlStyle = UISegmentedControlStyleBar;
	[bookshelfToggle addTarget:self action:@selector(bookshelfToggled:) forControlEvents:UIControlEventValueChanged];

	self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:bookshelfToggle] autorelease];
	[bookshelfToggle release];
	
	[self.gridView setCellSize:CGSizeMake(80,118) withBorderSize:20];
	[self.gridView setBackgroundColor:[UIColor colorWithPatternImage:[UIImage imageNamed:@"Shelf"]]];

}

#ifdef LOCALDEBUG

- (void)checkAndCopyLocalFilesToApplicationSupport
{

	// first, check the application support directory exists, and if
	// not, create it. (code from Blio)
	NSArray  *applicationSupportPaths = NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES);
    NSString *applicationSupportPath = ([applicationSupportPaths count] > 0) ? [applicationSupportPaths objectAtIndex:0] : nil;
	
	BOOL isDir;
	if (![[NSFileManager defaultManager] fileExistsAtPath:applicationSupportPath isDirectory:&isDir] || !isDir) {
		NSError * createApplicationSupportDirError = nil;
		
		if (![[NSFileManager defaultManager] createDirectoryAtPath:applicationSupportPath 
									   withIntermediateDirectories:YES 
														attributes:nil 
															 error:&createApplicationSupportDirError]) 
		{
			NSLog(@"Error: could not create Application Support directory in the Library directory! %@, %@", 
				  createApplicationSupportDirError, [createApplicationSupportDirError userInfo]);
			return;
		} else {
			NSLog(@"Created Application Support directory within Library.");
		}
	}
	
	
	// now create a list of bundle XPS files
	NSError *error = nil;
	NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
	NSArray *bundleDirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleRoot error:&error];
	
	if (error) {
		NSLog(@"Error: %@", [error localizedDescription]);
		return;
	}
	
	NSArray *bundleXPSContents = [bundleDirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.xps'"]];

	NSArray *appDirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:applicationSupportPath error:&error];
	if (error) {
		NSLog(@"Error: %@", [error localizedDescription]);
		return;
	}

	NSArray *supportDirXPSContents = [appDirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.xps'"]];

	
	for (NSString *item in bundleXPSContents) {
		
		bool fileAlreadyCopied = NO;
		
		for (NSString *appItem in supportDirXPSContents) {
			if ([[item stringByDeletingPathExtension] compare:[appItem stringByDeletingPathExtension]] == NSOrderedSame) {
				fileAlreadyCopied = YES;
				break;
			}
		}
		
		if (!fileAlreadyCopied) {
			NSString *fullSourcePath = [NSString stringWithFormat:@"%@/%@", bundleRoot, item];
			NSString *fullDestinationPath = [NSString stringWithFormat:@"%@/%@", applicationSupportPath, item];
			
			[[NSFileManager defaultManager] copyItemAtPath:fullSourcePath toPath:fullDestinationPath error:&error];
			if (error) {
				NSLog(@"File copy error: %@, %@",
					  error, [error userInfo]);
			}
		}
	}
}

#endif

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
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

#pragma mark -
#pragma mark Core Data Table View Methods

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {	
	SCHContentMetadataItem *contentMetadataItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	cell.textLabel.text = contentMetadataItem.Title; 
	cell.detailTextLabel.text = contentMetadataItem.Author;
	
	if (contentMetadataItem.FileName != nil) {
		NSString *xpsPath = [[NSBundle mainBundle] pathForResource:contentMetadataItem.FileName ofType:@"xps"];
		BWKXPSProvider *provider = [[BWKXPSProvider alloc] initWithPath:xpsPath];
		provider.title = contentMetadataItem.FileName;
		cell.imageView.image = [provider coverThumbForList];
		[provider release], provider = nil;	
	} else {
		cell.imageView.image = nil;
	}
}

#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return [[self.fetchedResultsController sections] count];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
	
	SCHContentMetadataItem *contentMetadataItem = [self.fetchedResultsController objectAtIndexPath:indexPath];
	
	BWKTestPageViewController *pageView = [[BWKTestPageViewController alloc] initWithNibName:nil bundle:nil];
	pageView.xpsPath = [[NSBundle mainBundle] pathForResource:contentMetadataItem.FileName ofType:@"xps"];
	
	BWKReadingOptionsView *optionsView = [[BWKReadingOptionsView alloc] initWithNibName:nil bundle:nil];
	optionsView.pageViewController = pageView;
	
	[self.navigationController pushViewController:optionsView animated:YES];
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
	
	SCHContentMetadataItem *contentMetadataItem = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
	UIImage *thumb = nil;
	
	if (contentMetadataItem.FileName == nil) {
		thumb = [UIImage imageNamed:@"PlaceholderBook"];
	} else {
		NSString *xpsPath = [[NSBundle mainBundle] pathForResource:contentMetadataItem.FileName ofType:@"xps"];
		BWKXPSProvider *provider = [[BWKXPSProvider alloc] initWithPath:xpsPath];
		provider.title = contentMetadataItem.FileName;
		thumb = [provider coverThumbForList];
		[provider release];
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
	id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:0];
    return [sectionInfo numberOfObjects];
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
	SCHContentMetadataItem *contentMetadataItem = [self.fetchedResultsController objectAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
	BWKTestPageViewController *pageView = [[BWKTestPageViewController alloc] initWithNibName:nil bundle:nil];
	pageView.xpsPath = [[NSBundle mainBundle] pathForResource:contentMetadataItem.FileName ofType:@"xps"];
	
	BWKReadingOptionsView *optionsView = [[BWKReadingOptionsView alloc] initWithNibName:nil bundle:nil];
	optionsView.pageViewController = pageView;
	
	[self.navigationController pushViewController:optionsView animated:YES];
	[optionsView release];
	[pageView release];	
}

-(void)gridView:(MRGridView *)gridView confirmationForDeletionAtIndex:(NSInteger)index 
{
	
}

#pragma mark -
#pragma mark Fetched results controller


- (NSFetchedResultsController *)fetchedResultsController {
    
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
    
    /*
     Set up the fetched results controller.
	 */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"SCHContentMetadataItem" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kSCHLibreAccessWebServiceTitle ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Books"];
    aFetchedResultsController.delegate = self;
    self.fetchedResultsController = aFetchedResultsController;
    
    [aFetchedResultsController release];
    [fetchRequest release];
    [sortDescriptor release];
    [sortDescriptors release];
    
    NSError *error = nil;
    if (![fetchedResultsController_ performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         
         abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return fetchedResultsController_;
}    


#pragma mark -
#pragma mark Fetched results controller delegate


- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}


- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
    
    switch(type) {
        case NSFetchedResultsChangeInsert:
            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
      newIndexPath:(NSIndexPath *)newIndexPath {
    
    UITableView *aTableView = self.tableView;
    
    switch(type) {
            
        case NSFetchedResultsChangeInsert:
            [aTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeDelete:
            [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            break;
            
        case NSFetchedResultsChangeUpdate:
            [self configureCell:[aTableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
            break;
            
        case NSFetchedResultsChangeMove:
            [aTableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [aTableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
            break;
    }
}


- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

/*
 // Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
 // In the simplest, most efficient, case, reload the table view.
 [self.tableView reloadData];
 }
 */

#pragma mark -
#pragma mark Actions

- (void)bookshelfToggled:(id)sender 
{
	NSUInteger selectedSegment = [(UISegmentedControl *)sender selectedSegmentIndex];
	
	switch (selectedSegment) {
		case 0:
			[self.view bringSubviewToFront:self.tableView];
			break;
		case 1:
			[self.view bringSubviewToFront:self.gridView];
			//[self.gridView setFrame:CGRectMake(0, 0, 320, 460)];
//			[self.gridView reloadData];

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
    [fetchedResultsController_ release];
    [managedObjectContext_ release];	

	[self releaseViewObjects];
	
    [super dealloc];
}


@end

