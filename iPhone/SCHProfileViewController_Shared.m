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
#import "SCHLibreAccessWebService.h"
#import "SCHProfileItem.h"
#import "SCHProfileViewCell.h"
#import "SCHCustomNavigationBar.h"
#import "SCHAuthenticationManager.h"
#import "SCHURLManager.h"
#import "SCHSyncManager.h"
#import "SCHThemeManager.h"
#import "SCHProfileSyncComponent.h"
#import "SCHBookshelfSyncComponent.h"
#import "SCHSetupBookshelvesViewController.h"
#import "SCHDownloadDictionaryViewController.h"
#import "SCHDictionaryDownloadManager.h"
#import "LambdaAlert.h"
#import "SCHBookUpdates.h"
#import "SCHAppProfile.h"
#import "SCHBookIdentifier.h"

enum LoginScreens {
    kLoginScreenNone,
    kLoginScreenPassword,
    kLoginScreenSetupBookshelves,
    kLoginScreenDownloadDictionary,
};

@interface SCHProfileViewController_Shared()  

@property (nonatomic, assign) enum LoginScreens loginScreen;
@property (nonatomic, retain) SCHLoginPasswordViewController *parentPasswordController; // Lazily instantiated
@property (nonatomic, retain) SCHBookUpdates *bookUpdates;
@property (nonatomic, assign) BOOL updatesBubbleHiddenUntilNextSync;

- (void)willEnterForeground:(NSNotification *)note;
- (void)showLoginControllerWithAnimation:(BOOL)animated;
- (void)dismissKeyboard;
- (void)advanceToNextLoginStep;
- (void)endLoginSequence;
- (void)performLogin;
- (void)checkForBookUpdates;
- (void)showUpdatesBubble:(BOOL)show;
- (void)updatesBubbleTapped:(UIGestureRecognizer *)gr;
- (void)obtainPasswordThenPushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (void)queryPasswordBeforePushingBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;

@end

@implementation SCHProfileViewController_Shared

@synthesize tableView;
@synthesize backgroundView;
@synthesize headerView;
@synthesize fetchedResultsController=fetchedResultsController_;
@synthesize managedObjectContext=managedObjectContext_;
@synthesize modalNavigationController;
@synthesize loginPasswordController;
@synthesize settingsViewController;
@synthesize setupBookshelvesViewController;
@synthesize downloadDictionaryViewController;
@synthesize loginScreen;
@synthesize parentPasswordController;
@synthesize bookUpdates;
@synthesize updatesBubble;
@synthesize updatesBubbleHiddenUntilNextSync;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [tableView release], tableView = nil;
    [backgroundView release], backgroundView = nil;
    [headerView release], headerView = nil;
    [loginPasswordController release], loginPasswordController = nil;
    [setupBookshelvesViewController release], setupBookshelvesViewController = nil;
    [downloadDictionaryViewController release], downloadDictionaryViewController = nil;
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(profileSyncDidComplete:)
                                                 name:SCHProfileSyncComponentCompletedNotification
                                               object:nil];
    
    [self.updatesBubble setAlpha:0];
    [self.updatesBubble setUserInteractionEnabled:YES];
    self.updatesBubbleHiddenUntilNextSync = NO;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(updatesBubbleTapped:)];
    [self.updatesBubble addGestureRecognizer:tap];
    [tap release];

    self.loginPasswordController.controllerType = kSCHControllerLoginView;
    self.loginPasswordController.actionBlock = ^{
        [self performLogin];
    };
    
    self.setupBookshelvesViewController.setupDelegate = self;
    self.downloadDictionaryViewController.setupDelegate = self;
    self.settingsViewController.setupDelegate = self;
    self.settingsViewController.managedObjectContext = self.managedObjectContext;

    [self advanceToNextLoginStep];
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
    self.updatesBubbleHiddenUntilNextSync = YES;
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
        [self pushBookshelvesControllerWithProfileItem:profileItem];            
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


#pragma mark - Login sequence

- (void)advanceToNextLoginStep
{
    self.loginScreen = kLoginScreenNone;
    
    // check for authentication
    BOOL isAuthenticated;
#if LOCALDEBUG	
    isAuthenticated = YES;
#elif NONDRMAUTHENTICATION
	SCHAuthenticationManager *authenticationManager = [SCHAuthenticationManager sharedAuthenticationManager];
	isAuthenticated = [authenticationManager hasUsernameAndPassword];
#else 
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];
    isAuthenticated = (deviceKey != nil);
#endif
    
    if (!isAuthenticated) {
        self.loginScreen = kLoginScreenPassword;
    }
#if !LOCALDEBUG
    else if ([[self.fetchedResultsController sections] count] == 0 
             || [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] == 0) {
        self.loginScreen = kLoginScreenSetupBookshelves;
    }
#endif
    else if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] == SCHDictionaryProcessingStateUserSetup) {
        self.loginScreen = kLoginScreenDownloadDictionary;
    }
    
    if (self.loginScreen == kLoginScreenNone) {
        if (self.modalViewController != nil) {
            [self dismissModalViewControllerAnimated:YES];
        }
        [self checkForBookUpdates];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showLoginControllerWithAnimation:YES];
        });
    }
}

- (void)endLoginSequence
{
    [self dismissModalViewControllerAnimated:YES];
    self.loginScreen = kLoginScreenNone;
}

- (void)performLogin
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerSuccess object:nil];			
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerFailure object:nil];					
    
    [self.loginPasswordController startShowingProgress];
    [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithUserName:[self.loginPasswordController username] withPassword:[self.loginPasswordController password]];
}

- (void)showLoginControllerWithAnimation:(BOOL)animated
{
    UIViewController *viewController = nil;
    
    switch (self.loginScreen) {
        case kLoginScreenNone:
            break;
            
        case kLoginScreenPassword:
            viewController = self.loginPasswordController;
            break;
            
        case kLoginScreenSetupBookshelves:
            viewController = self.setupBookshelvesViewController;
            [self.setupBookshelvesViewController showActivity:NO];
            break;
            
        case kLoginScreenDownloadDictionary:
            viewController = self.downloadDictionaryViewController;
            break;
    }
    
    if (!viewController) {
        return;
    }
    
    if (self.modalViewController == self.modalNavigationController) {
        [self dismissKeyboard];        
        if (![self.modalNavigationController.viewControllers containsObject:viewController]) {
            [self.modalNavigationController pushViewController:viewController animated:animated];
        } else {
            self.modalNavigationController.viewControllers = [NSArray arrayWithObject:viewController];
        }
    } else {
        [self.modalNavigationController setViewControllers:[NSArray arrayWithObject:viewController]];
        [self.modalNavigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
        [self.modalNavigationController setModalPresentationStyle:UIModalPresentationFormSheet];
        [self presentModalViewController:self.modalNavigationController animated:animated];
        [self showUpdatesBubble:NO];
    }
}


- (void)dismissKeyboard
{
    if ([[[UIDevice currentDevice] systemVersion] compare:@"4.3"] == NSOrderedAscending) {
        // pre-4.3 only - we have to dismiss the modal form and represent it to get the
        // keyboard to disappear; from 4.3-on the UINavigationController subclass takes
        // care of this.
        [CATransaction begin];
        [self dismissModalViewControllerAnimated:NO];
        [self presentModalViewController:self.modalNavigationController animated:NO];
        [CATransaction commit];
    }
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
            [self pushBookshelvesControllerWithProfileItem:profileItem];            
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
            [profileItem setRawPassword:topFieldText];
            [SCHThemeManager sharedThemeManager].appProfile = profileItem.AppProfile;
            [self pushBookshelvesControllerWithProfileItem:profileItem];
            [self dismissModalViewControllerAnimated:YES];
            return YES;
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
            [self.navigationController setViewControllers:(NSArray *)viewControllers animated:YES];
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
        [self.navigationController pushViewController:bookShelfViewController animated:YES];
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
    [self advanceToNextLoginStep];
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
            [self dismissKeyboard];
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

#pragma mark - notifications

// at the 'setup bookshelves' stage we punt the user over to Safari to set up their account;
// when we come back, kick off a sync to pick up the new profiles
- (void)willEnterForeground:(NSNotification *)note
{
    if (self.loginScreen == kLoginScreenSetupBookshelves) {
        [self.setupBookshelvesViewController showActivity:YES];
        [[SCHSyncManager sharedSyncManager] firstSync:YES];
    }
}

- (void)profileSyncDidComplete:(NSNotification *)note
{
    if (self.loginScreen == kLoginScreenPassword || self.loginScreen == kLoginScreenSetupBookshelves) {
        [self.setupBookshelvesViewController showActivity:NO];
        [self advanceToNextLoginStep];
    }
}

- (void)authenticationManager:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHAuthenticationManagerSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHAuthenticationManagerFailure object:nil];
	
	if ([notification.name isEqualToString:kSCHAuthenticationManagerSuccess]) {
        [[SCHURLManager sharedURLManager] clear];
        [[SCHSyncManager sharedSyncManager] clear];
        [[SCHSyncManager sharedSyncManager] firstSync:YES];
#if LOCALDEBUG
        [self advanceToNextLoginStep];
#endif
	} else {
		NSError *error = [notification.userInfo objectForKey:kSCHAuthenticationManagerNSError];
		if (error != nil) {
            NSString *localizedMessage = [NSString stringWithFormat:
                                          NSLocalizedString(@"A problem occured. If this problem persists please contact support.\n\n '%@'", nil), 
                                          [error localizedDescription]];                      
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Login Error", @"Login Error") 
                                  message:localizedMessage];
            [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") block:^{}];                        
            [alert addButtonWithTitle:NSLocalizedString(@"Retry", @"Retry") block:^{
                [self performLogin];
            }];
            [alert show];
            [alert release];
        }	
        [self.loginPasswordController stopShowingProgress];
	}
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
    if (self.updatesBubbleHiddenUntilNextSync) {
        show = NO;
    }
    
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
    self.updatesBubbleHiddenUntilNextSync = YES;
    [self showUpdatesBubble:NO];
}

@end

