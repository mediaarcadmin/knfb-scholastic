//
//  SCHProfileViewController.m
//  Tester
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import "SCHProfileViewController_Shared.h"
#import "AppDelegate_Shared.h"
#import "SCHSettingsViewController.h"
#import "SCHBookShelfViewController.h"
#import "SCHLoginPasswordViewController.h"
#import "SCHLibreAccessWebService.h"
#import "SCHProfileItem.h"
#import "SCHProfileViewCell.h"
#import "SCHCustomNavigationBar.h"
#import "SCHThemeManager.h"
#import "SCHBookshelfSyncComponent.h"
#import "SCHBookUpdates.h"
#import "SCHAppProfile.h"
#import "SCHBookIdentifier.h"
#import "SCHCoreDataHelper.h"

@interface SCHProfileViewController_Shared()  

@property (nonatomic, retain) SCHLoginPasswordViewController *parentPasswordController; // Lazily instantiated
@property (nonatomic, retain) SCHBookUpdates *bookUpdates;

- (void)checkForBookUpdates;
- (void)showUpdatesBubble:(BOOL)show;
- (void)updatesBubbleTapped:(UIGestureRecognizer *)gr;
- (void)obtainPasswordThenPushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (void)queryPasswordBeforePushingBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;

@end

@implementation SCHProfileViewController_Shared

@synthesize tableView;
@synthesize backgroundView;
@synthesize headerView;
@synthesize fetchedResultsController=fetchedResultsController_;
@synthesize managedObjectContext=managedObjectContext_;
@synthesize modalNavigationController;
@synthesize settingsViewController;
@synthesize parentPasswordController;
@synthesize bookUpdates;
@synthesize updatesBubble;

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];	
    }
    return(self);
}

- (void)releaseViewObjects
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [tableView release], tableView = nil;
    [backgroundView release], backgroundView = nil;
    [headerView release], headerView = nil;
    [modalNavigationController release], modalNavigationController = nil;
    [settingsViewController release], settingsViewController = nil;
    [updatesBubble release], updatesBubble = nil;
}

- (void)dealloc 
{    
    [self releaseViewObjects];
    
    [fetchedResultsController_ release], fetchedResultsController_ = nil;
    [managedObjectContext_ release], managedObjectContext_ = nil;
    [parentPasswordController release], parentPasswordController = nil;
    [bookUpdates release], bookUpdates = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [self.updatesBubble setAlpha:0];
    [self.updatesBubble setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updatesBubbleTapped:)];
    [self.updatesBubble addGestureRecognizer:tap];
    [tap release];
 
    self.settingsViewController.setupDelegate = self;
    self.settingsViewController.managedObjectContext = self.managedObjectContext;
}  

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];

    // get rid of the back button; the only way back from here is via deregistration
    UIView *empty = [[UIView alloc] initWithFrame:CGRectZero];
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:empty] autorelease];
    [empty release];
}

#pragma mark - NSManagedObjectContext Changed Notification

- (void)coreDataHelperManagedObjectContextDidChangeNotification:(NSNotification *)notification
{
    self.managedObjectContext = [[notification userInfo] objectForKey:SCHCoreDataHelperManagedObjectContext];
   
	 if (self.settingsViewController != nil) {
        self.settingsViewController.managedObjectContext = self.managedObjectContext;
    }
    if (self.bookUpdates != nil) {
        self.bookUpdates.managedObjectContext = self.managedObjectContext;
    }    

    self.fetchedResultsController = nil;
    [self.tableView reloadData];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    return(1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
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

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    SCHProfileViewCell *cell = (SCHProfileViewCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[SCHProfileViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                          reuseIdentifier:CellIdentifier] autorelease];
        cell.delegate = self;
    }
    
    SCHProfileItem *managedObject = [self.fetchedResultsController objectAtIndexPath:indexPath];
	[cell.cellButton setTitle:[managedObject bookshelfName:NO] forState:UIControlStateNormal];
    [cell setIndexPath:indexPath];
    
    return(cell);
}

#pragma mark - scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self showUpdatesBubble:NO];
}


#pragma mark - SCHProfileViewCellDelegate

- (void)profileViewCell:(SCHProfileViewCell *)cell didSelectAnimated:(BOOL)animated
{
    NSIndexPath *indexPath = cell.indexPath;
    if (indexPath.section != 0) {
        return;
    }

    SCHProfileItem *profileItem = [[self fetchedResultsController] objectAtIndexPath:indexPath];
    if ([profileItem.ProfilePasswordRequired boolValue] == NO) {
        [self pushBookshelvesControllerWithProfileItem:profileItem animated:YES];            
    } else if (![profileItem hasPassword]) {
        [self obtainPasswordThenPushBookshelvesControllerWithProfileItem:profileItem];
    } else {
        [self queryPasswordBeforePushingBookshelvesControllerWithProfileItem:profileItem];
    }
}

#pragma mark - Fetched results controller

- (NSFetchedResultsController *)fetchedResultsController 
{
    if (fetchedResultsController_ != nil) {
        return fetchedResultsController_;
    }
    
    /*
     Set up the fetched results controller.
     */
    // Create the fetch request for the entity.
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    // Edit the entity name as appropriate.
    NSEntityDescription *entity = [NSEntityDescription entityForName:kSCHProfileItem 
                                              inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Set the batch size to a suitable number.
    [fetchRequest setFetchBatchSize:20];
    
    // Edit the sort key as appropriate.
    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:kSCHLibreAccessWebServiceFirstName 
                                                                   ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
    
    [fetchRequest setSortDescriptors:sortDescriptors];
    
    // Edit the section name key path and cache name if appropriate.
    // nil for section name key path means "no sections".
    NSFetchedResultsController *aFetchedResultsController = [[NSFetchedResultsController alloc] initWithFetchRequest:fetchRequest 
                                                                                                managedObjectContext:self.managedObjectContext 
                                                                                                  sectionNameKeyPath:nil 
                                                                                                           cacheName:@"Root"];
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

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}


#pragma mark - Profile password

- (void)queryPasswordBeforePushingBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem
{
    SCHLoginPasswordViewController *passwordController = [[SCHLoginPasswordViewController alloc] initWithNibName:@"SCHProfilePasswordView" bundle:nil];
    
    [passwordController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [passwordController setModalPresentationStyle:UIModalPresentationFormSheet];

    passwordController.cancelBlock = ^{
        [self dismissModalViewControllerAnimated:YES];
    };
    
    passwordController.retainLoopSafeActionBlock = ^BOOL(NSString *topFieldString, NSString *bottomFieldString) {
        if ([profileItem validatePasswordWith:bottomFieldString] == NO) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                                 message:NSLocalizedString(@"Incorrect password", nil)
                                                                delegate:nil 
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                       otherButtonTitles:nil]; 
            [errorAlert show]; 
            [errorAlert release];
            return NO;
        } else {
            [SCHThemeManager sharedThemeManager].appProfile = profileItem.AppProfile;
            [self pushBookshelvesControllerWithProfileItem:profileItem animated:YES];            
            [self dismissModalViewControllerAnimated:YES];
            return YES;
        }	
    };
    
    passwordController.controllerType = kSCHControllerPasswordOnlyView;
    [passwordController.profileLabel setText:[profileItem bookshelfName:YES]];
    
    [self presentModalViewController:passwordController animated:YES];
    [passwordController release];
}

- (void)obtainPasswordThenPushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem
{
    SCHLoginPasswordViewController *passwordController = [[SCHLoginPasswordViewController alloc] initWithNibName:@"SCHSetProfilePasswordView" bundle:nil];

    [passwordController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [passwordController setModalPresentationStyle:UIModalPresentationFormSheet];

    passwordController.retainLoopSafeActionBlock = ^BOOL(NSString *topFieldText, NSString *bottomFieldText) {
        if ([topFieldText isEqualToString:bottomFieldText]) {
            if ([topFieldText length] > 0) {
                [profileItem setRawPassword:topFieldText];
                [SCHThemeManager sharedThemeManager].appProfile = profileItem.AppProfile;
                [self pushBookshelvesControllerWithProfileItem:profileItem animated:YES];
                [self dismissModalViewControllerAnimated:YES];
                return YES;
            } else {
                UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                                     message:NSLocalizedString(@"The password cannot be blank.", nil)
                                                                    delegate:nil 
                                                           cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                           otherButtonTitles:nil]; 
                [errorAlert show];
                [errorAlert release];
                return NO;
            }
        } else {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                                 message:NSLocalizedString(@"The passwords do not match.", nil)
                                                                delegate:nil 
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                       otherButtonTitles:nil]; 
            [errorAlert show];
            [errorAlert release];
            return NO;
        }
    };
    
    passwordController.controllerType = kSCHControllerDoublePasswordView;
    [passwordController.profileLabel setText:[profileItem bookshelfName:YES]];
    [self presentModalViewController:passwordController animated:YES];
    [passwordController release];
}

#pragma mark - Push bookshelves controller

- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem 
                                        animated:(BOOL)animated
{
	SCHBookShelfViewController *bookShelfViewController = [self newBookShelfViewController];
    bookShelfViewController.profileItem = profileItem;
    bookShelfViewController.managedObjectContext = self.managedObjectContext;
    
    SCHBookIdentifier *bookIdentifier = nil;
    if (profileItem.AppProfile.AutomaticallyLaunchBook != nil) {
        bookIdentifier = [[SCHBookIdentifier alloc] initWithEncodedString:profileItem.AppProfile.AutomaticallyLaunchBook];
    }
    if (bookIdentifier) {
        NSError *error;
        SCHReadingViewController *readingViewController = [bookShelfViewController openBook:bookIdentifier error:&error];
        [bookIdentifier release];
        
        if (readingViewController) {
            NSArray *viewControllers = [self.navigationController.viewControllers arrayByAddingObjectsFromArray:
                                        [NSArray arrayWithObjects:bookShelfViewController, readingViewController, nil]];
            [self.navigationController setViewControllers:(NSArray *)viewControllers animated:animated];
        } else {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"This Book Could Not Be Opened", @"Could not open book") 
                                                                 message:[error localizedDescription]
                                                                delegate:nil 
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                       otherButtonTitles:nil]; 
            [errorAlert show]; 
            [errorAlert release];
        }
        profileItem.AppProfile.AutomaticallyLaunchBook = nil;        
    } else {
        [self.navigationController pushViewController:bookShelfViewController animated:animated];
    }
	[bookShelfViewController release], bookShelfViewController = nil;
}

- (SCHBookShelfViewController *)newBookShelfViewController
{
    // must override
    abort();
}

#pragma mark - settings

- (void)dismissSettingsForm
{
    // check for deregistration
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
    if (![appDelegate isAuthenticated]) {
        [self dismissModalViewControllerAnimated:YES];
        [self.navigationController popViewControllerAnimated:NO];
    } else {
        [self dismissModalViewControllerAnimated:YES];
    }
}

- (SCHLoginPasswordViewController *)parentPasswordController
{
    if (!parentPasswordController) {
        parentPasswordController = [[[SCHLoginPasswordViewController alloc] initWithNibName:@"SCHParentToolsViewController" bundle:nil] retain];
        parentPasswordController.controllerType = kSCHControllerParentToolsView;
    }
    
    return parentPasswordController;
}

- (void)pushSettingsController
{
    self.parentPasswordController.actionBlock = ^{
        
        if ([[SCHAuthenticationManager sharedAuthenticationManager] validatePassword:[self.parentPasswordController password]] == NO) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                                 message:NSLocalizedString(@"Incorrect password", nil)
                                                                delegate:nil 
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                       otherButtonTitles:nil]; 
            [errorAlert show]; 
            [errorAlert release];
        } else {
            [self.modalNavigationController pushViewController:self.settingsViewController animated:YES];
        }
        
        [self.parentPasswordController clearFields]; 
    };
    
    [self.modalNavigationController setViewControllers:[NSArray arrayWithObject:self.parentPasswordController]];
    [self.modalNavigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.modalNavigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self.modalNavigationController.navigationBar setTintColor:[UIColor SCHRed2Color]];
    [self presentModalViewController:self.modalNavigationController animated:YES];
    [self showUpdatesBubble:NO];
}

#pragma mark - Book updates

- (void)checkForBookUpdates
{
    if (!self.bookUpdates) {
        self.bookUpdates = [[[SCHBookUpdates alloc] init] autorelease];
        self.bookUpdates.managedObjectContext = self.managedObjectContext;
    }
    
    [self showUpdatesBubble:[self.bookUpdates areBookUpdatesAvailable]];
}

- (void)showUpdatesBubble:(BOOL)show
{
    [UIView animateWithDuration:0.5
                          delay:0
                        options:UIViewAnimationOptionAllowUserInteraction
                     animations:^{
                         self.updatesBubble.alpha = show ? 1.0 : 0.0;
                     }
                     completion:nil];
}

- (void)updatesBubbleTapped:(UIGestureRecognizer *)gr
{
    [self pushSettingsController];
}

@end

