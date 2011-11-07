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
#import "SCHDrmSession.h"
#import "SCHSampleBooksImporter.h"

enum {
    kTableSectionSamples = 0,
    kTableSectionSignIn
};

enum {
    kTableOffsetPortrait_iPad = 240,
    kTableOffsetLandscape_iPad = 120,
    kTableOffsetPortrait_iPhone = 20,
    kTableOffsetLandscape_iPhone = 0
};

typedef enum {
	kSCHStartingViewControllerProfileSyncStateNone = 0,
    kSCHStartingViewControllerProfileSyncStateWaitingForLoginToComplete,
    kSCHStartingViewControllerProfileSyncStateWaitingForBookshelves,
    kSCHStartingViewControllerProfileSyncStateWaitingForPassword,
    kSCHStartingViewControllerProfileSyncStateWaitingForWebParentToolsToComplete
} SCHStartingViewControllerProfileSyncState;

@interface SCHStartingViewController ()

@property (nonatomic, retain) SCHProfileViewController_Shared *profileViewController;
@property (nonatomic, assign) SCHStartingViewControllerProfileSyncState profileSyncState;
@property (nonatomic, retain) LambdaAlert *checkProfilesAlert;

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)setStandardStore;
- (void)openSampleBookshelf;
- (void)showSignInForm;
- (BOOL)dictionaryDownloadRequired;
- (BOOL)bookshelfSetupRequired;
- (void)checkDictionaryDownloadForSamples;
- (void)recheckBookshelvesForProfile;
- (void)checkBookshelvesAndDictionaryDownloadForProfile;
- (void)checkBookshelvesAndDictionaryDownloadForProfile:(BOOL)rechecking;
- (void)replaceCheckProfilesAlertWithAlert:(LambdaAlert *)alert;
- (void)signInSucceeded;
- (void)signInFailedWithError:(NSError *)error;
- (SCHProfileViewController_Shared *)profileViewController;

@end

@implementation SCHStartingViewController

@synthesize checkProfilesAlert;
@synthesize starterTableView;
@synthesize backgroundView;
@synthesize samplesHeaderView;
@synthesize signInHeaderView;
@synthesize modalNavigationController;
@synthesize profileViewController;
@synthesize profileSyncState;

- (void)releaseViewObjects
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:SCHProfileSyncComponentDidCompleteNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:SCHProfileSyncComponentDidFailNotification 
                                                  object:nil];

    [checkProfilesAlert release], checkProfilesAlert = nil;
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
    
    [self.modalNavigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.modalNavigationController setModalPresentationStyle:UIModalPresentationFormSheet];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(profileSyncDidComplete:)
                                                 name:SCHProfileSyncComponentDidCompleteNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(profileSyncDidFail:)
                                                 name:SCHProfileSyncComponentDidFailNotification
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

    [self.navigationController.navigationBar setAlpha:1.0f];
    [self.navigationController.navigationBar setBarStyle:UIBarStyleBlackOpaque]; // For the title text
    [self.navigationController setNavigationBarHidden:NO];
    [self setupAssetsForOrientation:self.interfaceOrientation];

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
    return 2;   
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
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
            [cell setTitle: NSLocalizedString(@"Sample Bookshelf", @"")];
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
            [self openSampleBookshelf];
            break;
            
        case kTableSectionSignIn:
            [self showSignInForm];
            break;
    }
}

#pragma mark - Sample bookshelves

- (void)openSampleBookshelf
{
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
    [appDelegate setStoreType:kSCHStoreTypeSampleStore];
    
    NSString *localManifest = [[NSBundle mainBundle] pathForResource:kSCHSampleBooksLocalManifestFile ofType:nil];
    NSURL *localManifestURL = localManifest ? [NSURL fileURLWithPath:localManifest] : nil;
    
    [[SCHSampleBooksImporter sharedImporter] importSampleBooksFromRemoteManifest:[NSURL URLWithString:kSCHSampleBooksRemoteManifestURL] 
                                                                   localManifest:localManifestURL
                                                                    successBlock:^{
                                                                        [self checkDictionaryDownloadForSamples];
                                                                    }
                                                                    failureBlock:^(NSString * failureReason){
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Unable To Update Sample eBooks", @"")
                              message:[NSString stringWithFormat:NSLocalizedString(@"There was a problem whilst updating the sample eBooks. %@. Please try again.", @""), failureReason]];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
        }];
        
        [alert show]; 
        [alert release];  
    }];
}

- (void)setStandardStore
{
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
    [appDelegate setStoreType:kSCHStoreTypeStandardStore];
    
    // clear all books
    [SCHAppBook clearBooksDirectory];
}

#pragma mark - Sign In

- (void)showSignInForm
{
    SCHLoginPasswordViewController *login = [[SCHLoginPasswordViewController alloc] initWithNibName:@"SCHLoginViewController" bundle:nil];
    login.controllerType = kSCHControllerLoginView;
    
    login.cancelBlock = ^{
        [self dismissModalViewControllerAnimated:YES];
    };
    
    login.retainLoopSafeActionBlock = ^BOOL(NSString *username, NSString *password) {
        [self setStandardStore];
        
        self.profileSyncState = kSCHStartingViewControllerProfileSyncStateWaitingForLoginToComplete;
        
        if ([[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
            [[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {      
            [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithUser:username 
                                                                                password:password
                                                                            successBlock:^(BOOL offlineMode){
                                                                                [self signInSucceeded];
                                                                            }
                                                                            failureBlock:^(NSError * error){
                                                                                [self signInFailedWithError:error];
                                                                            }];            
            return(YES);
        } else {
            return(NO);
        }
    };
    
    [self.modalNavigationController setViewControllers:[NSArray arrayWithObject:login]];
    [self presentModalViewController:self.modalNavigationController animated:YES];
    
    [login release];
}

- (void)signInSucceeded
{
    [[SCHSyncManager sharedSyncManager] firstSync:YES];
}

- (void)signInFailedWithError:(NSError *)error
{    
    if (error != nil) {
        NSString *localizedMessage = nil;
        
        if ([error code] == kSCHDrmDeviceLimitError) {
            localizedMessage = NSLocalizedString(@"The Scholastic eReader is already installed on five devices, which is the maximum allowed. Before installing it on this device, you to need to deregister the eReader on one of your current devices.", nil);
        } else {
            localizedMessage = [NSString stringWithFormat:
                                NSLocalizedString(@"A problem occured. If this problem persists please contact support.\n\n '%@'", nil), 
                                [error localizedDescription]];   
        }
        
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Login Error", @"Login Error") 
                              message:localizedMessage];
        [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") block:^{
        }];
        [alert addButtonWithTitle:NSLocalizedString(@"Retry", @"Retry") block:^{
            // FIXME: this is not an acceptably robust way to do this
            [[self.modalNavigationController topViewController] performSelector:@selector(actionButtonAction:) withObject:nil afterDelay:0.0];
        }];
        [alert show];
        [alert release];
    }	
    
    SCHLoginPasswordViewController *login = (SCHLoginPasswordViewController *)[self.modalNavigationController topViewController];
    [login stopShowingProgress];
}

- (BOOL)dictionaryDownloadRequired
{
    BOOL downloadRequired = 
    ([[SCHDictionaryDownloadManager sharedDownloadManager] userRequestState] == SCHDictionaryUserNotYetAsked) 
    || ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] == SCHDictionaryProcessingStateUserSetup);

    return downloadRequired;
}

- (BOOL)bookshelfSetupRequired;
{
    SCHProfileViewController_Shared *profile = [self profileViewController];
    BOOL setupRequired = (([[profile.fetchedResultsController sections] count] == 0) ||
                          ([[[profile.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] == 0));
    
    return setupRequired;
}

- (void)checkDictionaryDownloadForSamples
{
    SCHDownloadDictionaryViewController *downloadDictionary = nil;
        
    if ([self dictionaryDownloadRequired]) {
        downloadDictionary = [[SCHDownloadDictionaryViewController alloc] init];
        downloadDictionary.profileSetupDelegate = self;
        [self.modalNavigationController setViewControllers:[NSArray arrayWithObject:downloadDictionary]];
        [self presentModalViewController:self.modalNavigationController animated:YES];
        [downloadDictionary release];
    } else {
        [self pushSamplesAnimated:YES];
    }
}

- (void)checkBookshelvesAndDictionaryDownloadForProfile:(BOOL)animated
{    
    UIViewController *next = nil;
    
    if ([self bookshelfSetupRequired]) {
        SCHSetupBookshelvesViewController *setupBookshelves = [[SCHSetupBookshelvesViewController alloc] init];
        setupBookshelves.profileSetupDelegate = self;
        next = setupBookshelves;
        self.profileSyncState = kSCHStartingViewControllerProfileSyncStateWaitingForBookshelves;
    }

    if (!next && [self dictionaryDownloadRequired]) {
        SCHDownloadDictionaryViewController *downloadDictionary = [[SCHDownloadDictionaryViewController alloc] init];
        downloadDictionary.profileSetupDelegate = self;
        next = downloadDictionary;
        animated = YES;
    }
     
    if (next) {
        [self.modalNavigationController setViewControllers:[NSArray arrayWithObject:next] animated:animated];
        
        if (!self.modalViewController) {
            [self presentModalViewController:self.modalNavigationController animated:animated];
        }
        
        [next release];
    } else {
        [self showCurrentProfileAnimated:YES];
    }
}

- (void)checkBookshelvesAndDictionaryDownloadForProfile
{
    [self checkBookshelvesAndDictionaryDownloadForProfile:YES];
}

- (void)recheckBookshelvesForProfile
{
    [self checkBookshelvesAndDictionaryDownloadForProfile:NO];
}

- (void)pushAuthenticatedProfileAnimated:(BOOL)animated
{
    if ([self bookshelfSetupRequired]) {
        // Force the view to load from the nib without requiring the run loop to complete
        [self view];
        
        // Start the sync in case they have been set up since last sync
        [[SCHSyncManager sharedSyncManager] firstSync:YES];
        
        [self checkBookshelvesAndDictionaryDownloadForProfile:animated];
    } else {
        [self showCurrentProfileAnimated:animated];
    }
}

- (void)popToAuthenticatedProfileAnimated:(BOOL)animated
{
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:animated];
    }
    
    if ([self bookshelfSetupRequired]) {
        [self.navigationController setViewControllers:[NSArray arrayWithObject:self] animated:animated];
        [self checkBookshelvesAndDictionaryDownloadForProfile:animated];
    } else {
        [self.navigationController setViewControllers:[NSArray arrayWithObjects:self, [self profileViewController], nil] animated:animated];
    }
}

#pragma mark - SCHProfileSetupDelegate

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

- (void)pushSamplesAnimated:(BOOL)animated
{       
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:YES];
    }
    
    SCHProfileViewController_Shared *profile = [self profileViewController];
    SCHProfileItem *profileItem = [[profile profileItems] lastObject]; // Only one sample bookshelf so any result will do
    
    if (profileItem) {
        NSMutableArray *viewControllers = [NSMutableArray arrayWithObjects:self, profile, nil];
        [viewControllers addObjectsFromArray:[profile viewControllersForProfileItem:profileItem]];
        [self.navigationController setViewControllers:viewControllers animated:animated];
    } else {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Unable To Open the Sample Bookshelf", @"")
                              message:NSLocalizedString(@"There was a problem whilst opening the sample bookshelf. Please try again.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
        }];
        
        [alert show]; 
        [alert release]; 
    }
}

//- (void)pushProfileAnimated:(BOOL)animated
//{
//    if (self.modalViewController) {
//        [self dismissModalViewControllerAnimated:YES];
//    }
//    
//    SCHProfileViewController_Shared *profile = [self profileViewController];
//    SCHProfileItem *profileItem = [[profile profileItems] lastObject]; // Only one sample bookshelf so any result will do
//    
//    if (profileItem) {
//        NSMutableArray *viewControllers = [NSMutableArray arrayWithObjects:self, profile, nil];
//        [viewControllers addObjectsFromArray:[profile viewControllersForProfileItem:profileItem]];
//        [self.navigationController setViewControllers:viewControllers animated:animated];
//    } else {
//        LambdaAlert *alert = [[LambdaAlert alloc]
//                              initWithTitle:NSLocalizedString(@"Unable To Open the Sample Bookshelf", @"")
//                              message:NSLocalizedString(@"There was a problem whilst opening the sample bookshelf. Please try again.", @"")];
//        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
//        }];
//        
//        [alert show]; 
//        [alert release]; 
//    }
//
//}


- (void)showCurrentProfileAnimated:(BOOL)animated
{   
    BOOL shouldAnimatePush = animated;

    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:YES];
        shouldAnimatePush = NO;
    }
    
    BOOL alreadyInUse = NO;
    SCHProfileViewController_Shared *profile = [self profileViewController];
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if (vc == profile) {
            alreadyInUse = YES;
            break;
        }
    }
    if (alreadyInUse == NO) {
        [self.navigationController pushViewController:profile animated:shouldAnimatePush];
    }
}

- (void)waitingForPassword
{
    self.profileSyncState = kSCHStartingViewControllerProfileSyncStateWaitingForPassword;
}

- (void)waitingForWebParentToolsToComplete
{
    self.profileSyncState = kSCHStartingViewControllerProfileSyncStateWaitingForWebParentToolsToComplete;
}

- (void)webParentToolsCompleted
{
    self.profileSyncState = kSCHStartingViewControllerProfileSyncStateWaitingForBookshelves;
    
    [[SCHSyncManager sharedSyncManager] firstSync:YES];      
    
    self.checkProfilesAlert = [[[LambdaAlert alloc]
                                initWithTitle:NSLocalizedString(@"Syncing with Your Account", @"")
                                message:@"\n"] autorelease];
    [self.checkProfilesAlert setSpinnerHidden:NO];
    [self.checkProfilesAlert show];
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
        profileViewController.profileSetupDelegate = self;
}
    return profileViewController;
}

- (void)replaceCheckProfilesAlertWithAlert:(LambdaAlert *)alert
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self.checkProfilesAlert setSpinnerHidden:YES];
    [self.checkProfilesAlert dismissAnimated:NO];
    self.checkProfilesAlert = nil;
    
    [alert show];
    
    [CATransaction commit];
}

#pragma mark - notifications

// at the 'setup bookshelves' stage we punt the user over to Safari to set up their account;
// when we come back, kick off a sync to pick up the new profiles
- (void)willEnterForeground:(NSNotification *)note
{
    if (self.profileSyncState == kSCHStartingViewControllerProfileSyncStateWaitingForBookshelves) {
        [[SCHSyncManager sharedSyncManager] firstSync:YES];
    }
}

- (void)profileSyncDidComplete:(NSNotification *)note
{
    SCHStartingViewControllerProfileSyncState currentSyncState = self.profileSyncState;
    self.profileSyncState = kSCHStartingViewControllerProfileSyncStateNone;
    
    if (self.checkProfilesAlert) {
        [self.checkProfilesAlert dismissAnimated:YES];
        self.checkProfilesAlert = nil;
    }
    
    switch (currentSyncState) {
        case kSCHStartingViewControllerProfileSyncStateWaitingForLoginToComplete:
            [self checkBookshelvesAndDictionaryDownloadForProfile];
            break;
        case kSCHStartingViewControllerProfileSyncStateWaitingForBookshelves:
            [self recheckBookshelvesForProfile];
            break;
        default:
            break;
    }
}

- (void)profileSyncDidFail:(NSNotification *)note
{
    if (self.checkProfilesAlert) {
        if (self.profileSyncState == kSCHStartingViewControllerProfileSyncStateWaitingForBookshelves) {
            [self recheckBookshelvesForProfile];
            
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Sync Failed", @"")
                                  message:NSLocalizedString(@"There was a problem whilst checking for new profiles. Please try again.", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            }];

            [self replaceCheckProfilesAlertWithAlert:alert];
            [alert release];  
        } else { 
            [self.checkProfilesAlert dismissAnimated:YES];
            self.checkProfilesAlert = nil;
        }
    }
}

@end
