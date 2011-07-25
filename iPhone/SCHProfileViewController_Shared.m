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
#import "SCHSetupBookshelvesViewController.h"
#import "SCHDownloadDictionaryViewController.h"
#import "SCHDictionaryDownloadManager.h"
#import "LambdaAlert.h"

enum LoginScreens {
    kLoginScreenNone,
    kLoginScreenPassword,
    kLoginScreenSetupBookshelves,
    kLoginScreenDownloadDictionary
};

@interface SCHProfileViewController_Shared()  

@property (nonatomic, assign) enum LoginScreens loginScreen;
@property (nonatomic, retain) SCHLoginPasswordViewController *parentPasswordController; // Lazily instantiated

- (void)willEnterForeground:(NSNotification *)note;
- (void)showLoginControllerWithAnimation:(BOOL)animated;
- (void)dismissKeyboard;
- (void)advanceToNextLoginStep;
- (void)endLoginSequence;
- (void)performLogin;

@end

@implementation SCHProfileViewController_Shared

@synthesize fetchedResultsController=fetchedResultsController_;
@synthesize managedObjectContext=managedObjectContext_;
@synthesize modalNavigationController;
@synthesize loginPasswordController;
@synthesize profilePasswordController;
@synthesize settingsViewController;
@synthesize setupBookshelvesViewController;
@synthesize downloadDictionaryViewController;
@synthesize loginScreen;
@synthesize parentPasswordController;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [loginPasswordController release], loginPasswordController = nil;
    [setupBookshelvesViewController release], setupBookshelvesViewController = nil;
    [downloadDictionaryViewController release], downloadDictionaryViewController = nil;
    [modalNavigationController release], modalNavigationController = nil;
    [profilePasswordController release], profilePasswordController = nil;
    [settingsViewController release], settingsViewController = nil;
}

- (void)dealloc 
{    
    [self releaseViewObjects];
    
    [fetchedResultsController_ release], fetchedResultsController_ = nil;
    [managedObjectContext_ release], managedObjectContext_ = nil;
    [parentPasswordController release], parentPasswordController = nil;
    
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

    self.loginPasswordController.controllerType = kSCHControllerLoginView;
    self.loginPasswordController.actionBlock = ^{
        [self performLogin];
    };
    
    self.profilePasswordController.controllerType = kSCHControllerPasswordOnlyView;
    self.profilePasswordController.cancelBlock = ^{
        [self endLoginSequence];
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
	isAuthenticated = [authenticationManager isAuthenticated];
#else 
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];
    isAuthenticated = (deviceKey != nil);
#endif
    
    if (!isAuthenticated) {
        self.loginScreen = kLoginScreenPassword;
    }
    else if ([[self.fetchedResultsController sections] count] == 0 
             || [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] == 0) {
        self.loginScreen = kLoginScreenSetupBookshelves;
    }
    else if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] == SCHDictionaryProcessingStateUserSetup) {
        self.loginScreen = kLoginScreenDownloadDictionary;
    }
    
    if (self.loginScreen == kLoginScreenNone) {
        if (self.modalViewController != nil) {
            [self dismissModalViewControllerAnimated:YES];
        }
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

#pragma mark - settings

- (void)dismissSettingsForm
{
    [super dismissModalViewControllerAnimated:YES];
    
    // allow the previous modal dialog to close before re-opening the login screen
    [self performSelector:@selector(advanceToNextLoginStep) withObject:nil afterDelay:1.0];
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
}

#pragma mark - notifications

// at the 'setup bookshelves' stage we punt the user over to Safari to set up their account;
// when we come back, kick off a sync to pick up the new profiles
- (void)willEnterForeground:(NSNotification *)note
{
    if (self.loginScreen == kLoginScreenSetupBookshelves) {
        [self.setupBookshelvesViewController showActivity:YES];
        [[SCHSyncManager sharedSyncManager] firstSync:NO];
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
		[[SCHSyncManager sharedSyncManager] firstSync:NO];
        [self advanceToNextLoginStep];
	} else {
		NSError *error = [notification.userInfo objectForKey:kSCHAuthenticationManagerNSError];
		if (error != nil) {
            NSString *localizedMessage = [NSString stringWithFormat:
                                          NSLocalizedString(@"A problem occured. If this problem persists please contact support quoting:\n\n '%@'", nil), 
                                          [error localizedDescription]];                      
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Login Error", @"Login Error") 
                                  message:localizedMessage];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK") block:^{}];                        
            [alert addButtonWithTitle:NSLocalizedString(@"Retry", @"Retry") block:^{
                [self performLogin];
            }];
            [alert show];
            [alert release];
        }	
        [self.loginPasswordController stopShowingProgress];
	}
}

@end

