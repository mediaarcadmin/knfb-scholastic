//
//  SCHProfileViewController.m
//  Tester
//
//  Created by John S. Eddie on 30/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import "SCHProfileViewController_Shared.h"
#import "SCHSettingsViewController.h"
#import "SCHBookShelfViewController.h"
#import "SCHLoginPasswordViewController.h"
#import "SCHLibreAccessConstants.h"
#import "SCHProfileItem.h"
#import "SCHAuthenticationManager.h"
#import "SCHThemeManager.h"
#import "SCHBookUpdates.h"
#import "SCHAppProfile.h"
#import "SCHBookIdentifier.h"
#import "SCHCoreDataHelper.h"
#import "SCHSyncManager.h"
#import "SCHParentalToolsWebViewController.h"
#import "LambdaAlert.h"
#import "Reachability.h"

@interface SCHProfileViewController_Shared()  

@property (nonatomic, retain) SCHBookUpdates *bookUpdates;

- (void)checkForBookUpdates;
- (void)showUpdatesBubble:(BOOL)show;
- (void)updatesBubbleTapped:(UIGestureRecognizer *)gr;
- (void)obtainPasswordThenPushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (void)queryPasswordBeforePushingBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (SCHBookIdentifier *)bookToLaunchForBookbookShelfViewController:(SCHBookShelfViewController *)bookShelfViewController;
- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem 
                                        animated:(BOOL)animated;

@end

@implementation SCHProfileViewController_Shared

@synthesize tableView;
@synthesize backgroundView;
@synthesize headerView;
@synthesize fetchedResultsController=fetchedResultsController_;
@synthesize managedObjectContext=managedObjectContext_;
@synthesize modalNavigationController;
@synthesize settingsViewController;
@synthesize bookUpdates;
@synthesize updatesBubble;
@synthesize profileSetupDelegate;

#pragma mark - Object lifecycle

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(coreDataHelperManagedObjectContextDidChangeNotification:) 
                                                     name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                                   object:nil];	
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(deviceDeregistered:)
                                                     name:SCHAuthenticationManagerReceivedServerDeregistrationNotification
                                                   object:nil];
    }
    return(self);
}

- (void)releaseViewObjects
{    
    [tableView release], tableView = nil;
    [backgroundView release], backgroundView = nil;
    [headerView release], headerView = nil;
    [modalNavigationController release], modalNavigationController = nil;
    [settingsViewController release], settingsViewController = nil;
    [updatesBubble release], updatesBubble = nil;
}

- (void)dealloc 
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                               object:nil];	
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:SCHAuthenticationManagerReceivedServerDeregistrationNotification
                                               object:nil];

    [self releaseViewObjects];
    
    [fetchedResultsController_ release], fetchedResultsController_ = nil;
    [managedObjectContext_ release], managedObjectContext_ = nil;
    [bookUpdates release], bookUpdates = nil;
    profileSetupDelegate = nil;
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [self.tableView setAlwaysBounceVertical:NO];
    
    [self.updatesBubble setAlpha:0];
    [self.updatesBubble setUserInteractionEnabled:YES];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updatesBubbleTapped:)];
    [self.updatesBubble addGestureRecognizer:tap];
    [tap release];
 
    self.settingsViewController.settingsDelegate = self;
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
    
    [self checkForBookUpdates];
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
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Incorrect Password", @"") 
                                                                 message:NSLocalizedString(@"The password you entered is not correct. If you have forgotten your password, you can ask your parent to reset it using Parent Tools.", @"")
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
                
                if (![[topFieldText substringToIndex:1] isEqualToString:@" "]) {
                    [profileItem setRawPassword:topFieldText];
                    if ([self.managedObjectContext save:nil] == YES) {
                        [[SCHSyncManager sharedSyncManager] profileSync]; 
                    }
                    [SCHThemeManager sharedThemeManager].appProfile = profileItem.AppProfile;
                    [self pushBookshelvesControllerWithProfileItem:profileItem animated:YES];
                    [self dismissModalViewControllerAnimated:YES];
                    return YES;
                } else {
                    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                                         message:NSLocalizedString(@"You cannot use spaces at the beginning of your password.", nil)
                                                                        delegate:nil 
                                                               cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                               otherButtonTitles:nil]; 
                    [errorAlert show];
                    [errorAlert release];
                    return NO;
                }
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

- (NSArray *)profileItems
{
    return [self.fetchedResultsController fetchedObjects];
}

#pragma mark - Push bookshelves controller

- (SCHBookIdentifier *)bookToLaunchForBookbookShelfViewController:(SCHBookShelfViewController *)bookShelfViewController
{
    SCHBookIdentifier *bookIdentifier = nil;
    SCHProfileItem *profileItem = bookShelfViewController.profileItem;
    
    if (profileItem.AppProfile.AutomaticallyLaunchBook != nil) {
        bookIdentifier = [[[SCHBookIdentifier alloc] initWithEncodedString:profileItem.AppProfile.AutomaticallyLaunchBook] autorelease];
    }
    
    if (bookIdentifier && [bookShelfViewController isBookOnShelf:bookIdentifier]) {
        return bookIdentifier;
    } else {
        return nil;
    }

}

- (NSArray *)viewControllersForProfileItem:(SCHProfileItem *)profileItem
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    SCHBookShelfViewController *bookShelfViewController = [[self newBookShelfViewController] autorelease];
    bookShelfViewController.profileItem = profileItem;
    bookShelfViewController.managedObjectContext = self.managedObjectContext;
    bookShelfViewController.profileSetupDelegate = self.profileSetupDelegate;
    
    [viewControllers addObject:bookShelfViewController];
    
    SCHBookIdentifier *bookIdentifier = [self bookToLaunchForBookbookShelfViewController:bookShelfViewController];
    
    if (bookIdentifier) {        
        NSError *error;
        SCHReadingViewController *readingViewController = [bookShelfViewController openBook:bookIdentifier error:&error];
        
        if (readingViewController) {
            [viewControllers addObject:readingViewController];
        } else {
            NSLog(@"Failed to automatically launch an eBook with error: %@ : %@", error, [error localizedDescription]);
        }
        
        profileItem.AppProfile.AutomaticallyLaunchBook = nil;
    }

    return viewControllers;
}

- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem 
                                        animated:(BOOL)animated
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    if (self.profileSetupDelegate) {
        [viewControllers addObject:self.profileSetupDelegate];
    }
    
    [viewControllers addObject:self];
    
    NSArray *profileControllers = [self viewControllersForProfileItem:profileItem];
    if (profileControllers) {
        [viewControllers addObjectsFromArray:profileControllers];
    }
    
    [self.navigationController setViewControllers:viewControllers animated:animated];
}

- (SCHBookShelfViewController *)newBookShelfViewController
{
    // must override
    abort();
}

- (void)pushSettingsController
{
    NSArray *viewControllers = [self.settingsViewController currentSettingsViewControllers];
    [self.modalNavigationController setViewControllers:viewControllers];
    [self.modalNavigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.modalNavigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self.modalNavigationController.navigationBar setTintColor:[UIColor SCHRed2Color]];
    [self presentModalViewController:self.modalNavigationController animated:YES];
    [self showUpdatesBubble:NO];
}

#pragma mark - SCHSettingsDelegate

- (void)dismissModalViewControllerAnimated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion;
{
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:animated];
    }
    
    // This is an inelegant solution but there isn't a straightforward way to perform the animation and then 
    // fire the completion when it is finished
    if (completion) {
        double delayInSeconds = animated ? 0.3 : 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), completion);
    }
}

- (void)popToRootViewControllerAnimated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion
{
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:animated];
        [self.navigationController popToRootViewControllerAnimated:NO];
    } else {
        [self.navigationController popToRootViewControllerAnimated:animated];
    }
    
    // This is an inelegant solution but there isn't a straightforward way to perform the animation and then 
    // fire the completion when it is finished
    if (completion) {
        double delayInSeconds = animated ? 0.3 : 0.0;
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), completion);
    }
}

- (void)presentWebParentToolsModallyWithToken:(NSString *)token 
                                        title:(NSString *)title 
                                   modalStyle:(UIModalPresentationStyle)style 
                        shouldHideCloseButton:(BOOL)shouldHide 
{
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:NO];
    }
    
    SCHParentalToolsWebViewController *parentalToolsWebViewController = [[[SCHParentalToolsWebViewController alloc] init] autorelease];
    parentalToolsWebViewController.title = title;
    parentalToolsWebViewController.modalPresenterDelegate = self;
    parentalToolsWebViewController.pToken = token;
    parentalToolsWebViewController.shouldHideCloseButton = shouldHide;
    parentalToolsWebViewController.modalPresentationStyle = style;
    
    [self presentModalViewController:parentalToolsWebViewController animated:NO];
}

- (void)dismissModalWebParentToolsWithSync:(BOOL)shouldSync showValidation:(BOOL)showValidation
{
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:NO];
    }
    
    if (!showValidation) {
        NSMutableArray *viewControllers = [[self.modalNavigationController viewControllers] mutableCopy];
        [viewControllers removeLastObject];
        [self.modalNavigationController setViewControllers:viewControllers];
        [viewControllers release];
    }
    
    [self presentModalViewController:self.modalNavigationController animated:NO];
    
    if (shouldSync) {
        [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:YES];
    } 
}

- (void)waitingForWebParentToolsToComplete
{
    // Do nothing
}

#pragma mark - Book updates

- (void)checkForBookUpdates
{
    if (!self.bookUpdates) {
        self.bookUpdates = [[[SCHBookUpdates alloc] init] autorelease];
        self.bookUpdates.managedObjectContext = self.managedObjectContext;
    }
    
    BOOL shouldShowUpdates = [self.bookUpdates areBookUpdatesAvailable] && 
                             [[Reachability reachabilityForInternetConnection] isReachable];
    
    [self showUpdatesBubble:shouldShowUpdates];
}

- (void)showUpdatesBubble:(BOOL)show
{
    [UIView animateWithDuration:0.1
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

- (void)deviceDeregistered:(NSNotification *)notification
{
    if (self.modalViewController != nil) {
        [self.modalViewController dismissModalViewControllerAnimated:NO];
    }
    
    [self.profileSetupDelegate popToRootViewControllerAnimated:YES withCompletionHandler:^{
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Device Deregistered", @"Device Deregistered") 
                              message:NSLocalizedString(@"This device has been deregistered. To read eBooks, please register this device again.", @"") ];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK") block:nil];
        [alert show];
        [alert release];
    }];  
}

@end

