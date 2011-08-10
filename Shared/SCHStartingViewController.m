//
//  SCHStartingViewController.m
//  Scholastic
//
//  Created by Neil Gall on 29/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStartingViewController.h"
#import "SCHLoginPasswordViewController.h"
#import "SCHProfileViewController_iPad.h"
#import "SCHProfileViewController_iPhone.h"
#import "SCHSetupBookshelvesViewController.h"
#import "SCHDownloadDictionaryViewController.h"
#import "SCHLoginPasswordViewController.h"
#import "SCHStartingViewCell.h"
#import "SCHCustomNavigationBar.h"
#import "SCHAuthenticationManager.h"
#import "SCHDictionaryDownloadManager.h"
#import "SCHSyncManager.h"
#import "SCHURLManager.h"
#import "LambdaAlert.h"
#import "AppDelegate_Shared.h"
#import "SCHProfileSyncComponent.h"
#import "SCHCoreDataHelper.h"

enum {
    kTableSectionSamples = 0,
    kTableSectionSignIn,
    kNumberOfTableSections,
};

enum {
    kNumberOfSampleBookshelves = 2,
    
    kTableOffsetPortrait_iPad = 240,
    kTableOffsetLandscape_iPad = 120,
    kTableOffsetPortrait_iPhone = 0,
    kTableOffsetLandscape_iPhone = 0
};

typedef enum {
	SCHStartingViewControllerYoungerBookshelf,
    SCHStartingViewControllerOlderBookshelf
} SCHStartingViewControllerBookshelf;

@interface SCHStartingViewController ()

@property (nonatomic, retain) SCHProfileViewController_Shared *profileViewController;

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (NSString *)sampleBookshelfTitleAtIndex:(NSInteger)index;
- (void)openSampleBookshelfAtIndex:(NSInteger)index;
- (void)showSignInForm;
- (void)advanceToNextSignInForm;
- (void)dismissKeyboard;

- (SCHProfileViewController_Shared *)profileViewController;
- (void)pushProfileView;

@end

@implementation SCHStartingViewController

@synthesize starterTableView;
@synthesize backgroundView;
@synthesize samplesHeaderView;
@synthesize signInHeaderView;
@synthesize modalNavigationController;
@synthesize profileViewController;

- (void)releaseViewObjects
{
    [starterTableView release], starterTableView = nil;
    [backgroundView release], backgroundView = nil;
    [samplesHeaderView release], samplesHeaderView = nil;
    [signInHeaderView release], signInHeaderView = nil;
    [modalNavigationController release], modalNavigationController = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self releaseViewObjects];
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
                                                 name:SCHProfileSyncComponentDidCompleteNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authenticationManagerDidDeregister:)
                                                 name:SCHAuthenticationManagerDidDeregisterNotification
                                               object:nil];

    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = logoImageView;
    [logoImageView release];
}

- (void)viewDidUnload
{
    [self releaseViewObjects];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
    [self.navigationController.navigationBar setAlpha:1.0f];
}

#pragma mark - Orientation methods

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat offset = iPad ? kTableOffsetLandscape_iPad : kTableOffsetLandscape_iPhone;
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-landscape.jpg"]];
        [self.starterTableView setContentInset:UIEdgeInsetsMake(offset, 0, 0, 0)];
    } else {
        CGFloat offset = iPad ? kTableOffsetPortrait_iPad : kTableOffsetPortrait_iPhone;
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.jpg"]];
        [self.starterTableView setContentInset:UIEdgeInsetsMake(offset, 0, 0, 0)];
    }
    
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self setupAssetsForOrientation:toInterfaceOrientation];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfTableSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kTableSectionSamples:
            return kNumberOfSampleBookshelves;
        case kTableSectionSignIn:
            return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kTableSectionSamples:
            return CGRectGetHeight(self.samplesHeaderView.bounds);
        case kTableSectionSignIn:
            return CGRectGetHeight(self.signInHeaderView.bounds);
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kTableSectionSamples:
            return self.samplesHeaderView;
        case kTableSectionSignIn:
            return self.signInHeaderView;
    }
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const CellIdentifier = @"Cell";
    
    SCHStartingViewCell *cell = (SCHStartingViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[SCHStartingViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.delegate = self;
    }
    
    switch (indexPath.section) {
        case kTableSectionSamples:
            [cell setTitle:[self sampleBookshelfTitleAtIndex:indexPath.row]];
            break;
        case kTableSectionSignIn:
            [cell setTitle:NSLocalizedString(@"Sign In", @"starter view sign in button title")];
            break;
    }

    cell.indexPath = indexPath;
    return cell;
}

- (void)cellButtonTapped:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kTableSectionSamples:
            [self openSampleBookshelfAtIndex:indexPath.row];
            break;
            
        case kTableSectionSignIn:
            [self showSignInForm];
            break;
    }
}

#pragma mark - Sample bookshelves

- (NSString *)sampleBookshelfTitleAtIndex:(NSInteger)index
{
    switch (index) {
        case SCHStartingViewControllerYoungerBookshelf: 
            return NSLocalizedString(@"Younger kids' bookshelf (3-6)", @"younger kids sample bookshelf name");
        case SCHStartingViewControllerOlderBookshelf: 
            return NSLocalizedString(@"Older kids' bookshelf (7+)", @"older kids sample bookshelf name");
    }
    return nil;
}

- (void)openSampleBookshelfAtIndex:(NSInteger)index
{
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];

    switch (index) {
        case SCHStartingViewControllerYoungerBookshelf: 
            [appDelegate.coreDataHelper setStoreType:SCHCoreDataHelperYoungerSampleStore];
            break;
        case SCHStartingViewControllerOlderBookshelf: 
            [appDelegate.coreDataHelper setStoreType:SCHCoreDataHelperOlderSampleStore];
            break;
    }
    
    [self.modalNavigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.modalNavigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentModalViewController:self.modalNavigationController animated:YES];    

    [self advanceToNextSignInForm];
}


#pragma mark - Sign In

- (void)showSignInForm
{
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
    [appDelegate.coreDataHelper setStoreType:SCHCoreDataHelperStandardStore];

    SCHLoginPasswordViewController *login = [[SCHLoginPasswordViewController alloc] initWithNibName:@"SCHLoginViewController" bundle:nil];
    login.controllerType = kSCHControllerLoginView;
    
    login.cancelBlock = ^{
        [self dismissModalViewControllerAnimated:YES];
    };
    
    login.retainLoopSafeActionBlock = ^BOOL(NSString *username, NSString *password) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:SCHAuthenticationManagerDidSucceedNotification object:nil];			
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:SCHAuthenticationManagerDidFailNotification object:nil];					
        [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithUserName:username withPassword:password];
        return YES;
    };
    
    [self.modalNavigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.modalNavigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self.modalNavigationController setViewControllers:[NSArray arrayWithObject:login]];
    [self presentModalViewController:self.modalNavigationController animated:YES];
    
    [login release];
}

- (void)authenticationManager:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCHAuthenticationManagerDidSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:SCHAuthenticationManagerDidFailNotification object:nil];
	
	if ([notification.name isEqualToString:SCHAuthenticationManagerDidSucceedNotification]) {
        [[SCHURLManager sharedURLManager] clear];
        [[SCHSyncManager sharedSyncManager] clear];
        [[SCHSyncManager sharedSyncManager] firstSync:YES];
	} else {
		NSError *error = [notification.userInfo objectForKey:kSCHAuthenticationManagerNSError];
		if (error != nil) {
            NSString *localizedMessage = [NSString stringWithFormat:
                                          NSLocalizedString(@"A problem occured. If this problem persists please contact support.\n\n '%@'", nil), 
                                          [error localizedDescription]];                      
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Login Error", @"Login Error") 
                                  message:localizedMessage];
            [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") block:^{
                [self dismissModalViewControllerAnimated:YES];
            }];
            [alert addButtonWithTitle:NSLocalizedString(@"Retry", @"Retry") block:^{}];
            [alert show];
            [alert release];
        }	
        
        SCHLoginPasswordViewController *login = (SCHLoginPasswordViewController *)[self.modalNavigationController topViewController];
        [login stopShowingProgress];
	}
}

- (void)advanceToNextSignInForm
{
    UIViewController *next = nil;
    
#if !LOCALDEBUG
    SCHProfileViewController_Shared *profile = [self profileViewController];
    if ([[profile.fetchedResultsController sections] count] == 0 
        || [[[profile.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] == 0) {
        SCHSetupBookshelvesViewController *setupBookshelves = [[SCHSetupBookshelvesViewController alloc] init];
        setupBookshelves.setupDelegate = self;
        next = setupBookshelves;
    }
    else
#endif
    if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] == SCHDictionaryProcessingStateUserSetup) {
        SCHDownloadDictionaryViewController *downloadDictionary = [[SCHDownloadDictionaryViewController alloc] init];
        downloadDictionary.setupDelegate = self;
        next = downloadDictionary;
    }
    
    if (next) {
        [self dismissKeyboard];
        [self.modalNavigationController pushViewController:next animated:YES];
        [next release];
    } else {
        [self dismissSettingsForm];
    }
}

- (void)dismissSettingsForm
{
    [self dismissModalViewControllerAnimated:YES];
    [self pushProfileView];
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

#pragma mark - Profile view

- (SCHProfileViewController_Shared *)profileViewController
{
    if (!profileViewController) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            profileViewController = [[SCHProfileViewController_iPad alloc] init];
        } else {
            profileViewController = [[SCHProfileViewController_iPhone alloc] init];
        }
        
        // access to the AppDelegate's managedObjectContext is deferred until we know we don't
        // want to use the same database any more
        AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
        profileViewController.managedObjectContext = appDelegate.coreDataHelper.managedObjectContext;
}
    return profileViewController;
}

- (void)pushProfileView
{   
    BOOL alreadyInUse = NO;
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if (vc == [self profileViewController]) {
            alreadyInUse = YES;
            break;
        }
    }
    if (alreadyInUse == NO) {
        [self.navigationController pushViewController:[self profileViewController] animated:NO];
    }
}

#pragma mark - notifications

// at the 'setup bookshelves' stage we punt the user over to Safari to set up their account;
// when we come back, kick off a sync to pick up the new profiles
- (void)willEnterForeground:(NSNotification *)note
{
    if ([self.modalNavigationController.topViewController isKindOfClass:[SCHSetupBookshelvesViewController class]]) {
        SCHSetupBookshelvesViewController *vc = (SCHSetupBookshelvesViewController *)self.modalNavigationController.topViewController;
        [vc showActivity:YES];
        [[SCHSyncManager sharedSyncManager] firstSync:YES];
    }
}

- (void)profileSyncDidComplete:(NSNotification *)note
{
    // we can get here directly from login screen...
    if ([self.modalNavigationController.topViewController isKindOfClass:[SCHLoginPasswordViewController class]]) {
        [self advanceToNextSignInForm];
        return;
    }
    
    // ... or from the setupBookshelves screen following a sync initiated by returning from background
    if ([self.modalNavigationController.topViewController isKindOfClass:[SCHSetupBookshelvesViewController class]]) {
        SCHSetupBookshelvesViewController *vc = (SCHSetupBookshelvesViewController *)self.modalNavigationController.topViewController;
        [vc showActivity:NO];
        [self advanceToNextSignInForm];
    }
}

- (void)authenticationManagerDidDeregister:(NSNotification *)notification
{
    if (self.modalViewController != nil) {
        [self.modalViewController dismissModalViewControllerAnimated:NO];
    }
    
    [self.navigationController popToRootViewControllerAnimated:NO];   
    
    LambdaAlert *alert = [[LambdaAlert alloc]
                          initWithTitle:NSLocalizedString(@"Device Deregistered", @"Device Deregistered") 
                          message:NSLocalizedString(@"This device has been deregistered. To read books, please register this device again.", @"") ];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK") block:^{}];
    [alert show];
    [alert release];    
}

@end
