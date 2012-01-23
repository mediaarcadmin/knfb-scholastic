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
#import "SCHProfileSyncComponent.h"
#import "BITModalSheetController.h"

@interface SCHProfileViewController_Shared()  

@property (nonatomic, retain) SCHBookUpdates *bookUpdates;
@property (nonatomic, retain) BITModalSheetController *webParentToolsPopoverController;
@property (nonatomic, retain) SCHParentalToolsWebViewController *parentalToolsWebViewController; 

- (void)checkForBookUpdates;
- (void)showUpdatesBubble:(BOOL)show;
- (void)updatesBubbleTapped:(UIGestureRecognizer *)gr;
- (void)obtainPasswordThenPushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (void)queryPasswordBeforePushingBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (SCHBookIdentifier *)bookToLaunchForBookbookShelfViewController:(SCHBookShelfViewController *)bookShelfViewController;
- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem 
                                        animated:(BOOL)animated;
- (void)pushSettingsControllerAnimated:(BOOL)animated;

@end

@implementation SCHProfileViewController_Shared

@synthesize tableView;
@synthesize backgroundView;
@synthesize headerView;
@synthesize headerLabel;
@synthesize fetchedResultsController=fetchedResultsController_;
@synthesize managedObjectContext=managedObjectContext_;
@synthesize modalNavigationController;
@synthesize settingsViewController;
@synthesize bookUpdates;
@synthesize updatesBubble;
@synthesize profileSetupDelegate;
@synthesize webParentToolsPopoverController;
@synthesize parentalToolsWebViewController;

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
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(profileSyncDidComplete:)
                                                     name:SCHProfileSyncComponentDidCompleteNotification
                                                   object:nil];
    }
    return(self);
}

- (void)releaseViewObjects
{    
    [tableView release], tableView = nil;
    [backgroundView release], backgroundView = nil;
    [headerView release], headerView = nil;
    [headerLabel release], headerLabel = nil;
    [modalNavigationController release], modalNavigationController = nil;
    [settingsViewController release], settingsViewController = nil;
    [updatesBubble release], updatesBubble = nil;
    
    if ([webParentToolsPopoverController isModalSheetVisible]) {
        [webParentToolsPopoverController dismissSheetAnimated:NO completion:nil];
    }
    [webParentToolsPopoverController release], webParentToolsPopoverController = nil;
    [parentalToolsWebViewController release], parentalToolsWebViewController = nil;
}

- (void)dealloc 
{    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:SCHCoreDataHelperManagedObjectContextDidChangeNotification 
                                               object:nil];	
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:SCHAuthenticationManagerReceivedServerDeregistrationNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:SCHProfileSyncComponentDidCompleteNotification
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
    
    [self.navigationController setNavigationBarHidden:NO];
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
	[cell setLeftButtonTitle:[managedObject bookshelfName:NO]
               leftIndexPath:indexPath
            rightButtonTitle:nil
              rightIndexPath:nil];
    
    return(cell);
}

#pragma mark - scroll view delegate

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    [self showUpdatesBubble:NO];
}


#pragma mark - SCHProfileViewCellDelegate

- (void)profileViewCell:(SCHProfileViewCell *)cell 
didSelectButtonAnimated:(BOOL)animated
              indexPath:(NSIndexPath *)indexPath 
{
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
    
    if ([[fetchedResultsController_ fetchedObjects] count] > 0) {
        [self.headerLabel setText:NSLocalizedString(@"Choose Your Bookshelf", @"Profile header text for > 0 bookshelves")];
        [self.headerLabel setNumberOfLines:1];
    } else {
        [self.headerLabel setText:NSLocalizedString(@"Please go to Parent Tools to create bookshelves.", @"Profile header text for 0 bookshelves")];
        [self.headerLabel setNumberOfLines:2];
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
        if (bottomFieldText != nil && 
            [topFieldText isEqualToString:bottomFieldText]) {
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

- (NSArray *)viewControllersForProfileItem:(SCHProfileItem *)profileItem showWelcome:(BOOL)welcome
{
    NSMutableArray *viewControllers = [NSMutableArray array];
    
    SCHBookShelfViewController *bookShelfViewController = [[self newBookShelfViewController] autorelease];
    bookShelfViewController.profileItem = profileItem;
    bookShelfViewController.managedObjectContext = self.managedObjectContext;
    bookShelfViewController.profileSetupDelegate = self.profileSetupDelegate;
    bookShelfViewController.showWelcome = welcome;
    
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
    
    NSArray *profileControllers = [self viewControllersForProfileItem:profileItem showWelcome:NO];
    if (profileControllers) {
        [viewControllers addObjectsFromArray:profileControllers];
    }
    
    [self.navigationController setViewControllers:viewControllers animated:animated];
}

- (SCHBookShelfViewController *)newBookShelfViewController
{
    NSLog(@"WARNING: must override newBookShelfViewController");
    return nil;
}

- (void)pushSettingsController
{
    [self pushSettingsControllerAnimated:YES];
}

- (void)pushSettingsControllerAnimated:(BOOL)animated
{
    NSArray *viewControllers = [self.settingsViewController currentSettingsViewControllers];
    [self.modalNavigationController setViewControllers:viewControllers];
    [self.modalNavigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.modalNavigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self.modalNavigationController.navigationBar setTintColor:[UIColor SCHRed2Color]];
    [self presentModalViewController:self.modalNavigationController animated:animated];
    [self showUpdatesBubble:NO];
}

#pragma mark - SCHSettingsDelegate

- (void)dismissModalViewControllerAnimated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion;
{
    
    [CATransaction begin];
    
    if (completion) {
        [CATransaction setCompletionBlock:completion];
    }
    
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:animated];
    }
    
    [CATransaction commit];
}

- (void)popToRootViewControllerAnimated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion
{
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:animated];
        [self.profileSetupDelegate popToRootViewControllerAnimated:NO withCompletionHandler:completion];
    } else {
        [self.profileSetupDelegate popToRootViewControllerAnimated:animated withCompletionHandler:completion];
    }
}

- (void)presentWebParentToolsModallyWithToken:(NSString *)token 
                                        title:(NSString *)title 
                                   modalStyle:(UIModalPresentationStyle)style 
                        shouldHideCloseButton:(BOOL)shouldHide 
{    
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:NO];
    }
    
    SCHParentalToolsWebViewController *aParentalToolsWebViewController = [[[SCHParentalToolsWebViewController alloc] init] autorelease];
    aParentalToolsWebViewController.title = title;
    aParentalToolsWebViewController.modalPresenterDelegate = self;
    aParentalToolsWebViewController.pToken = token;
    aParentalToolsWebViewController.shouldHideCloseButton = shouldHide;
    self.parentalToolsWebViewController = aParentalToolsWebViewController;
    
    BITModalSheetController *aPopoverController = [[BITModalSheetController alloc] initWithContentViewController:aParentalToolsWebViewController];
    aPopoverController.contentSize = CGSizeMake(540, 620);
    aPopoverController.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.webParentToolsPopoverController = aPopoverController;
    [aPopoverController release];
    
    __block BITModalSheetController *weakPopover = self.webParentToolsPopoverController;
    __block SCHProfileViewController_Shared *weakSelf = self;
    
    [self.webParentToolsPopoverController presentSheetInViewController:self animated:NO completion:^{
        weakSelf.parentalToolsWebViewController.textView.alpha = 0;
        
        CGSize expandedSize;
        
        if (UIInterfaceOrientationIsPortrait(weakSelf.interfaceOrientation)) {
            expandedSize = CGSizeMake(700, 530);
        } else {
            expandedSize = CGSizeMake(964, 530);
        }
        
        [weakPopover setContentSize:expandedSize animated:YES completion:^{
            weakSelf.parentalToolsWebViewController.textView.alpha = 1;
        }];
    }];    
    
    [CATransaction commit];
}

- (void)dismissModalWebParentToolsAnimated:(BOOL)animated withSync:(BOOL)shouldSync showValidation:(BOOL)showValidation
{
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:NO];
    }
    
    __block SCHProfileViewController_Shared *weakSelf = self;
    
    dispatch_block_t completion = ^{
        [weakSelf setWebParentToolsPopoverController:nil];
        [weakSelf setParentalToolsWebViewController:nil];
        
        if ([[weakSelf.modalNavigationController viewControllers] count] == 0) {
            // The view has been unloaded due to memory pressure
            // Just push the settings screen, don't bother with re-adding the validation controller
            [weakSelf pushSettingsControllerAnimated:NO];
        } else {
            if (!showValidation) {
                NSMutableArray *currentControllers = [[[weakSelf.modalNavigationController viewControllers] mutableCopy] autorelease];
                [currentControllers removeLastObject];
                [weakSelf.modalNavigationController setViewControllers:currentControllers];
                [weakSelf presentModalViewController:self.modalNavigationController animated:NO];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            if (shouldSync) {
                [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:YES];
            }
        });
    };
        
    if ([self.webParentToolsPopoverController isModalSheetVisible]) {
        
        self.parentalToolsWebViewController.textView.alpha = 0;
        
        if (animated) {
            [self.webParentToolsPopoverController setContentSize:CGSizeMake(540, 620) animated:YES completion:^{
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                [weakSelf.webParentToolsPopoverController dismissSheetAnimated:NO completion:^{
                    completion();
                    [CATransaction commit];
                }];
            }];
        } else {
            [weakSelf.webParentToolsPopoverController dismissSheetAnimated:NO completion:nil];
            completion();
        }
    } else {
        completion();
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

- (void)profileSyncDidComplete:(NSNotification *)notification
{
    self.fetchedResultsController = nil;
    [self.tableView reloadData];
}

@end

