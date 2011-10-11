//
//  SCHStartingViewController.m
//  Scholastic
//
//  Created by Neil Gall on 29/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStartingViewController.h"

#import "SCHProfileViewController_iPad.h"
#import "SCHProfileViewController_iPhone.h"
#import "SCHSetupBookshelvesViewController.h"
#import "SCHDownloadDictionaryViewController.h"
#import "SCHLoginPasswordViewController.h"
#import "SCHCustomNavigationBar.h"
#import "SCHAuthenticationManager.h"
#import "SCHDictionaryDownloadManager.h"
#import "SCHSyncManager.h"
#import "SCHURLManager.h"
#import "LambdaAlert.h"
#import "AppDelegate_Shared.h"
#import "SCHProfileSyncComponent.h"
#import "SCHCoreDataHelper.h"
#import "SCHAppStateManager.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHProfileItem.h"
#import "SCHUserDefaults.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"

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
    SCHStartingViewControllerOlderBookshelf,
    SCHStartingViewControllerNoSampleBookshelf
} SCHStartingViewControllerBookshelf;

@interface SCHStartingViewController ()

@property (nonatomic, retain) SCHProfileViewController_Shared *profileViewController;
@property (nonatomic, assign) SCHStartingViewControllerBookshelf sampleBookshelf;

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)firstLogin;
- (NSString *)sampleBookshelfTitleAtIndex:(NSInteger)index;
- (void)openSampleBookshelfAtIndex:(NSInteger)index;
- (void)showSignInForm;
- (void)advanceToNextSignInForm;

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
@synthesize sampleBookshelf;

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.sampleBookshelf = SCHStartingViewControllerNoSampleBookshelf;
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authenticationManagerDidDeregister:)
                                                 name:SCHAuthenticationManagerDidDeregisterNotification
                                               object:nil];
}

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
    
    [self.starterTableView setAlwaysBounceVertical:NO]; // For some reason this doesn't work when set from the nib
    
    self.starterTableView.accessibilityLabel = @"Starting Tableview";
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(profileSyncDidComplete:)
                                                 name:SCHProfileSyncComponentDidCompleteNotification
                                               object:nil];
    
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

    // if we logged in and deregistered then we will need to refresh so we 
    // don't show the Sample bookshelves
    [self.starterTableView reloadData];
}

#pragma mark - Orientation methods

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    CGFloat logoHeight = 44;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat offset = iPad ? kTableOffsetLandscape_iPad : kTableOffsetLandscape_iPhone;
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-landscape.jpg"]];
        [self.starterTableView setContentInset:UIEdgeInsetsMake(offset, 0, 0, 0)];
        logoHeight = iPad ? logoHeight : 32;
    } else {
        CGFloat offset = iPad ? kTableOffsetPortrait_iPad : kTableOffsetPortrait_iPhone;
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.jpg"]];
        [self.starterTableView setContentInset:UIEdgeInsetsMake(offset, 0, 0, 0)];
    }
    
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    
    CGRect logoFrame = CGRectZero;
    logoFrame.size.width = 320;
    logoFrame.size.height = logoHeight;
    logoImageView.frame = logoFrame;
    
    self.navigationItem.titleView = logoImageView;
    [logoImageView release];
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
    NSInteger section = indexPath.section;
    
    SCHStartingViewCell *cell = (SCHStartingViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[SCHStartingViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.delegate = self;
    }

    switch (section) {
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
    NSInteger section = indexPath.section;

    switch (section) {
        case kTableSectionSamples:
            [self openSampleBookshelfAtIndex:indexPath.row];
            break;
            
        case kTableSectionSignIn:
			self.sampleBookshelf = SCHStartingViewControllerNoSampleBookshelf;
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

    [appDelegate.coreDataHelper setupSampleStore];            
    
    switch (index) {
        case SCHStartingViewControllerYoungerBookshelf: 
            [appDelegate.coreDataHelper setStoreType:SCHCoreDataHelperSampleStore];
            self.sampleBookshelf = SCHStartingViewControllerYoungerBookshelf;
            break;
        case SCHStartingViewControllerOlderBookshelf: 
            [appDelegate.coreDataHelper setStoreType:SCHCoreDataHelperSampleStore];
            self.sampleBookshelf = SCHStartingViewControllerOlderBookshelf;
            break;
    }
    
    // if we were to actually login then a successful login would trigger a sync 
    // after which a profile complete notification would call 
    // advanceToNextSignInForm would to proceed, we are stepping over the login
    [[SCHSyncManager sharedSyncManager] firstSync:YES];
}

- (void)firstLogin
{
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];    
    
    // remove data store
    [appDelegate.coreDataHelper removeSampleStore];
    // clear all books
    [SCHAppBook clearBooksDirectory];
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
        
        if ([[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
            [[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {      
            [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithUserName:username withPassword:password];
            return(YES);
        } else {
            return(NO);
        }
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
        [self firstLogin];
        
        [[SCHAuthenticationManager sharedAuthenticationManager] clearAppProcessing];
        [[SCHSyncManager sharedSyncManager] firstSync:YES];
	} else {
        [[SCHAuthenticationManager sharedAuthenticationManager] clear];
		NSError *error = [notification.userInfo objectForKey:kSCHAuthenticationManagerNSError];
		if (error != nil) {
            NSString *localizedMessage = [NSString stringWithFormat:
                                          NSLocalizedString(@"A problem occured. If this problem persists please contact support.\n\n '%@'", nil), 
                                          [error localizedDescription]];                      
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Login Error", @"Login Error") 
                                  message:localizedMessage];
            [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") block:^{
            }];
            [alert addButtonWithTitle:NSLocalizedString(@"Retry", @"Retry") block:^{
                [[self.modalNavigationController topViewController] performSelector:@selector(actionButtonAction:) withObject:nil afterDelay:0.0];
            }];
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
    
    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore] == NO) {
        SCHProfileViewController_Shared *profile = [self profileViewController];
        if ([[profile.fetchedResultsController sections] count] == 0 
            || [[[profile.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] == 0) {
            SCHSetupBookshelvesViewController *setupBookshelves = [[SCHSetupBookshelvesViewController alloc] init];
            setupBookshelves.setupDelegate = self;
            next = setupBookshelves;
        }
    }

    if (next == nil && [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] == SCHDictionaryProcessingStateUserSetup) {
        SCHDownloadDictionaryViewController *downloadDictionary = [[SCHDownloadDictionaryViewController alloc] init];
        downloadDictionary.setupDelegate = self;
        next = downloadDictionary;
    }
    
    if (next) {
        if (self.modalViewController == nil) {
            [self.modalNavigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [self.modalNavigationController setModalPresentationStyle:UIModalPresentationFormSheet];
            [self.modalNavigationController setViewControllers:[NSArray arrayWithObject:next]];
            [self presentModalViewController:self.modalNavigationController animated:YES];
        } else {
            [self.modalNavigationController pushViewController:next animated:YES];
        }
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
    SCHProfileViewController_Shared *profile = [self profileViewController];
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if (vc == profile) {
            alreadyInUse = YES;
            break;
        }
    }
    if (alreadyInUse == NO) {
        [self.navigationController pushViewController:profile animated:NO];
    }
    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore] == YES) {
        for (SCHProfileItem *item in [profile.fetchedResultsController fetchedObjects]) {
            if ([item.ID integerValue] == sampleBookshelf + 1) {    // added 1 to convert from index to profileID
                [profile pushBookshelvesControllerWithProfileItem:item animated:YES];
                break;
            }
        }    
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
    if (self.sampleBookshelf != SCHStartingViewControllerNoSampleBookshelf || 
        [self.modalNavigationController.topViewController isKindOfClass:[SCHLoginPasswordViewController class]]) {
        // These checks don't work, they assume that the view is on screen which is not the case
        // FIXME: This is a workaround - please fix properly. See ticket 909
        if (self.modalNavigationController.topViewController.view.window) {
            [self advanceToNextSignInForm];
        }
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
