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
#import "SCHLibreAccessWebService.h"
#import "SCHProfileItem.h"
#import "SCHProfileViewCell.h"
#import "SCHCustomNavigationBar.h"

@interface SCHProfileViewController() <UITableViewDelegate> 

- (void)pushSettingsController;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)releaseViewObjects;

@property (nonatomic, retain) UIButton *settingsButton;

@end


@implementation SCHProfileViewController

@synthesize profilePasswordViewController;
@synthesize tableView;
@synthesize backgroundView;
@synthesize headerView;
@synthesize settingsButton;
@synthesize settingsController;
@synthesize loginController;
@synthesize fetchedResultsController=fetchedResultsController_, managedObjectContext=managedObjectContext_;


#pragma mark -
#pragma mark View lifecycle

- (void)releaseViewObjects
{
    [tableView release], tableView = nil;
    [backgroundView release], backgroundView = nil;
    [headerView release], headerView = nil;
    [settingsButton release], settingsButton = nil;
    
    [profilePasswordViewController release], profilePasswordViewController = nil;
    [settingsController release], settingsController = nil;
    [loginController release], loginController = nil;    
}

- (void)dealloc {    
    [fetchedResultsController_ release], fetchedResultsController_ = nil;
    [managedObjectContext_ release], managedObjectContext_ = nil;
    
    [self releaseViewObjects];
    [super dealloc];
}

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
         [UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-landscape.png"]];
        [self.settingsButton setImage:[UIImage imageNamed:@"settings-landscape.png"] forState:UIControlStateNormal];
        [self.settingsButton sizeToFit];
        
    } else {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
         [UIImage imageNamed:@"admin-iphone-portrait-top-toolbar.png"]];
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.png"]];
        [self.settingsButton setImage:[UIImage imageNamed:@"settings-portrait.png"] forState:UIControlStateNormal];
        [self.settingsButton sizeToFit];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
	
	self.profilePasswordViewController.delegate = self;
    
    settingsButton = [[UIButton buttonWithType:UIButtonTypeCustom] retain];
    [settingsButton addTarget:self action:@selector(pushSettingsController) forControlEvents:UIControlEventTouchUpInside]; 
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:settingsButton] autorelease];
    
    self.navigationItem.title = NSLocalizedString(@"Back", @"");
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = logoImageView;
    [logoImageView release];
    
    self.tableView.tableHeaderView = self.headerView;
    
}  

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

- (void)viewDidUnload {
	[self releaseViewObjects];
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
    [self setupAssetsForOrientation:toInterfaceOrientation];
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
	}
	
	return(ret);
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    SCHProfileViewCell *cell = (SCHProfileViewCell*) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[SCHProfileViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.delegate = self;
    }
    
    NSManagedObject *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell.cellButton setTitle:[NSString stringWithFormat:@"%@%@", 
								   [managedObject valueForKey:kSCHLibreAccessWebServiceFirstName], 
								   NSLocalizedString(@"'s Bookshelf", @"")] forState:UIControlStateNormal];
    [cell setIndexPath:indexPath];

    return cell;
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
    // controller to view book shelf with books filtered to profile
    [self pushBookshelvesControllerWithProfileItem:profilePassword.profileItem];	
}

#pragma mark -
#pragma mark UITableViewDelegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
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
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    }
    
    return fetchedResultsController_;
}    


#pragma mark -
#pragma mark Fetched results controller delegate
 
 - (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}

@end

