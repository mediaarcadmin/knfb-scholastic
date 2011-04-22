//
//  SCHProfileViewController.m
//  Tester
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import "SCHProfileViewController.h"

#import "SCHProfilePasswordViewController.h"
#import "SCHSettingsViewController.h"
#import "SCHBookShelfViewController.h"
#import "SCHLoginViewController.h"
#import "SCHAuthenticationManager.h"
#import "SCHLibreAccessWebService.h"
#import "SCHContentProfileItem.h"
#import "SCHProfileItem.h"
#import "SCHBookShelfViewController.h"
#import "SCHSyncManager.h"
#import "SCHProfileViewCell.h"
#import "SCHThemeManager.h"
#import "SCHCustomNavigationBar.h"

// Cell Icons 
static NSString * const kRootViewControllerProfileIcon = @"Profile.png";
static NSString * const kRootViewControllerProfileLockedIcon = @"ProfileLocked.png";
static NSString * const kRootViewControllerSettingsIcon = @"Settings.png";

@interface SCHProfileViewController ()

- (void)themeUpdate;
- (void)configureCell:(SCHProfileViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void) pushSettingsController;
@end


@implementation SCHProfileViewController

@synthesize profilePasswordViewController;
@synthesize tableView;
@synthesize backgroundView;
@synthesize settingsController;
@synthesize loginController;
@synthesize webServiceSync;
@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;


#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.profilePasswordViewController.delegate = self;
    
    [self themeUpdate];
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(themeUpdate) 
                                                 name:kSCHThemeManagerThemeChangeNotification 
                                               object:nil];
    
    CGFloat buttonPadding = 7;
    CGFloat containerHeight = CGRectGetHeight(self.navigationController.navigationBar.frame);
    
    settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [settingsButton setImage:[UIImage imageNamed:@"settings"] forState:UIControlStateNormal];
    [settingsButton addTarget:self action:@selector(pushSettingsController) forControlEvents:UIControlEventTouchUpInside]; 
//    settingsButton.backgroundColor = [UIColor greenColor];
    [settingsButton sizeToFit];
    
    CGRect buttonFrame = settingsButton.frame;
    buttonFrame.origin.x = buttonPadding;
    buttonFrame.origin.y = floorf((containerHeight - CGRectGetHeight(buttonFrame)) / 2.0f);
    buttonFrame.size.width = ceilf(buttonFrame.size.width);
    settingsButton.frame = buttonFrame;
    settingsButton.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    UIView *rightHandView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetMaxX(settingsButton.frame), containerHeight)] autorelease];
    
//        rightHandView.backgroundColor = [UIColor orangeColor];
    
    rightHandView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    
    [rightHandView addSubview:settingsButton];
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightHandView] autorelease];
    
    backgroundView.image = [UIImage imageNamed:@"admin-iphone-users-portrait"];

}

- (void)themeUpdate
{
//    self.backgroundView.image = [[SCHThemeManager sharedThemeManager] imageForBackground:self.interfaceOrientation];
}    

- (void) viewWillAppear:(BOOL)animated
{
    UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = headerImage;
    [headerImage release];
    
//    [(SCHCustomNavigationBar *)self.navigationController.navigationBar setTheme:kSCHThemeManagerNavigationBarImage];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-landscape-top-toolbar"]];
        backgroundView.image = [UIImage imageNamed:@"admin-iphone-users-landscape"];
    } else {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-portrait-top-toolbar"]];
        backgroundView.image = [UIImage imageNamed:@"admin-iphone-users-portrait"];
    }

    [super viewWillAppear:animated];
}

- (void)viewDidUnload {
    [self setTableView:nil];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    
	self.settingsController = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (YES);
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
#if !LOCALDEBUG	
	SCHAuthenticationManager *authenticationManager = [SCHAuthenticationManager sharedAuthenticationManager];
	
	if ([authenticationManager hasUsernameAndPassword] == NO) {
		[self presentModalViewController:self.loginController animated:NO];	
		[self.loginController removeCancelButton];
	}
#endif
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
//    [(SCHCustomNavigationBar *)self.navigationController.navigationBar setTheme:kSCHThemeManagerNavigationBarImage];
    
    if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-portrait-top-toolbar"]];
        backgroundView.image = [UIImage imageNamed:@"admin-iphone-users-portrait"];
    } else {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-landscape-top-toolbar"]];
        backgroundView.image = [UIImage imageNamed:@"admin-iphone-users-landscape"];
    }
    
    
}


- (void)configureCell:(SCHProfileViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
	NSManagedObject *managedObject = nil;
	
	switch (indexPath.section) {
		case 0:
			managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
			cell.textLabel.text = [NSString stringWithFormat:@"%@%@", 
								   [managedObject valueForKey:kSCHLibreAccessWebServiceFirstName], 
								   NSLocalizedString(@"'s Bookshelf", @"")];
			if ([[managedObject valueForKey:kSCHLibreAccessWebServiceProfilePasswordRequired] boolValue] == NO) {
//				cell.imageView.image = [UIImage imageNamed:kRootViewControllerProfileIcon];
			} else {
//				cell.imageView.image = [UIImage imageNamed:kRootViewControllerProfileLockedIcon];
			}			
			break;
/*		case 1:
			cell.textLabel.text = NSLocalizedString(@"Settings", @"");
//			cell.imageView.image = [UIImage imageNamed:kRootViewControllerSettingsIcon];		
			break;*/
	}	
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated {

    // Prevent new objects being added when in editing mode.
    [super setEditing:(BOOL)editing animated:(BOOL)animated];
    self.navigationItem.rightBarButtonItem.enabled = !editing;
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return(1);
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	NSInteger ret = 0;
	id <NSFetchedResultsSectionInfo> sectionInfo = nil;
	
	switch (section) {
		case 0:
			sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
			ret = [sectionInfo numberOfObjects];
			break;
/*		case 1:
			ret = 1;
			break;*/
	}
	
	return(ret);
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    SCHProfileViewCell *cell = (SCHProfileViewCell*) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[SCHProfileViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Configure the cell.
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


// Override to support editing the table view.
- (void)tableView:(UITableView *)aTableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the managed object for the given index path
        NSManagedObjectContext *context = [self.fetchedResultsController managedObjectContext];
        [context deleteObject:[self.fetchedResultsController objectAtIndexPath:indexPath]];
        
        // Save the context.
        NSError *error = nil;
        if (![context save:&error]) {
            /*
             Replace this implementation with code to handle the error appropriately.
             
             abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
             */
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }   
}


- (BOOL)tableView:(UITableView *)aTableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // The table view should not be re-orderable.
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        return 44;
    } else {
        return 11;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 44)];
        return [view autorelease];
    } else {
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 11)];
        return [view autorelease];
    }
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44;
}

- (void)pushBookshelvesControllerWithProfileItem: (SCHProfileItem *) profileItem
 {
	SCHBookShelfViewController *bookShelfViewController = nil;
	if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
		bookShelfViewController = [[SCHBookShelfViewController alloc] initWithNibName:NSStringFromClass([SCHBookShelfViewController class]) bundle:nil];
        bookShelfViewController.profileItem = profileItem;
	}
		
	[self.navigationController pushViewController:bookShelfViewController animated:YES];
	[bookShelfViewController release];
}

- (void) pushSettingsController
{
    settingsController.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:self.settingsController animated:YES];
}

#pragma mark -
#pragma mark Profile Password View Controller delegate

- (void)profilePasswordViewControllerDidComplete:(SCHProfilePasswordViewController *)profilePassword
{
/*	if([books count] < 1 && [SCHSyncManager sharedSyncManager].isSynchronizing == YES) {
		UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:@"Please Wait" 
															 message:@"We are retrieving book information"
															delegate:nil 
												   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												   otherButtonTitles:nil]; 
		[errorAlert show]; 
		[errorAlert release];
	} else {*/
		// controller to view book shelf with books filtered to profile
		[self pushBookshelvesControllerWithProfileItem:profilePassword.profileItem];	
//	}
}

#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here -- for example, create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     NSManagedObject *selectedObject = [[self fetchedResultsController] objectAtIndexPath:indexPath];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
	
    switch (indexPath.section) {
		case 0: {
            
#if LOCALDEBUG
            // controller to view book shelf with books filtered to profile
            [self pushBookshelvesControllerWithProfileItem:[[self fetchedResultsController] objectAtIndexPath:indexPath]];	
#else	    
            SCHProfileItem *profileItem = [[self fetchedResultsController] objectAtIndexPath:indexPath];
            
            if ([profileItem.ProfilePasswordRequired boolValue] == NO) {                
                [self pushBookshelvesControllerWithProfileItem:profileItem];            
            } else {
                profilePasswordViewController.managedObjectContext = self.managedObjectContext;
                profilePasswordViewController.profileItem = profileItem;
                [self presentModalViewController:profilePasswordViewController animated:YES];
            }
#endif	
		}	break;
	}
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
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
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHProfileItem inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kSCHLibreAccessWebServiceScreenName ascending:NO];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest managedObjectContext:self.managedObjectContext sectionNameKeyPath:nil cacheName:@"Root"];
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


//- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView beginUpdates];
//}
//
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeSection:(id <NSFetchedResultsSectionInfo>)sectionInfo
//           atIndex:(NSUInteger)sectionIndex forChangeType:(NSFetchedResultsChangeType)type {
//    
//    switch(type) {
//        case NSFetchedResultsChangeInsert:
//            [self.tableView insertSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [self.tableView deleteSections:[NSIndexSet indexSetWithIndex:sectionIndex] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//
//- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject
//       atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type
//      newIndexPath:(NSIndexPath *)newIndexPath {
//    
//    UITableView *tableView = self.tableView;
//    
//    switch(type) {
//            
//        case NSFetchedResultsChangeInsert:
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeDelete:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            break;
//            
//        case NSFetchedResultsChangeUpdate:
//            [self configureCell:[tableView cellForRowAtIndexPath:indexPath] atIndexPath:indexPath];
//            break;
//            
//        case NSFetchedResultsChangeMove:
//            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
//            [tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:newIndexPath]withRowAnimation:UITableViewRowAnimationFade];
//            break;
//    }
//}
//
//
//- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
//    [self.tableView endUpdates];
//}


// Implementing the above methods to update the table view in response to individual changes may have performance implications if a large number of changes are made simultaneously. If this proves to be an issue, you can instead just implement controllerDidChangeContent: which notifies the delegate that all section and object changes have been processed. 
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	self.profilePasswordViewController = nil;
	self.settingsController = nil;
	self.webServiceSync = nil;
	
    [fetchedResultsController_ release];
    [managedObjectContext_ release];
    [tableView release];
    [super dealloc];
}


@end

