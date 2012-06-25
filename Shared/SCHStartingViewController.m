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
#import "SCHAccountValidation.h"
#import "SCHParentalToolsWebViewController.h"
#import "Reachability.h"
#import "BITModalSheetController.h"
#import "SCHStoriaLoginViewController.h"
#import "BITOperationWithBlocks.h"
#import "SCHVersionDownloadManager.h"
#import "SCHAccountValidationViewController.h"
#import "NSString+EmailValidation.h"
#import "BITAPIError.h"

typedef enum {
	kSCHStartingViewControllerProfileSyncStateNone = 0,
    kSCHStartingViewControllerProfileSyncStateWaitingForLoginToComplete,
    kSCHStartingViewControllerProfileSyncStateWaitingForBookshelves,
    kSCHStartingViewControllerProfileSyncStateWaitingForPassword,
    kSCHStartingViewControllerProfileSyncStateWaitingForWebParentToolsToComplete
} SCHStartingViewControllerProfileSyncState;

//static const NSTimeInterval kSCHStartingViewControllerNonForcedAlertInterval = 60 * 60 * 24 * 7; // 1 week
static const NSTimeInterval kSCHStartingViewControllerNonForcedAlertInterval = (60 * 5) - 1;

@interface SCHStartingViewController ()

@property (nonatomic, retain) SCHProfileViewController_Shared *profileViewController;
@property (nonatomic, assign) SCHStartingViewControllerProfileSyncState profileSyncState;
@property (nonatomic, retain) LambdaAlert *checkProfilesAlert;
@property (nonatomic, retain) BITModalSheetController *loginPopoverController;
@property (nonatomic, retain) BITModalSheetController *webParentToolsPopoverController;
@property (nonatomic, retain) NSOperationQueue *setupSequenceQueue;

- (void)setVersionText;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;

- (void)runInitialChoiceSequence;
- (void)runSetupSamplesSequence;
- (void)runLoginSequenceWithUsername:(NSString *)username password:(NSString *)password credentialsSuccessBlock:(void(^)(BOOL success, BOOL retrying, NSError *error))credentialsSuccessBlock;
- (void)runSetupProfileSequenceAnimated:(BOOL)animated;

- (void)pushSamplesAnimated:(BOOL)animated showWelcome:(BOOL)welcome;
- (void)pushBookshelfSetupModalControllerAnimated:(BOOL)animated showValidation:(BOOL)showValidation;
- (void)pushDictionaryDownloadModalControllerAnimated:(BOOL)animated;
- (void)runSetupProfileSequenceAnimated:(BOOL)animated pushProfile:(BOOL)pushProfile showValidation:(BOOL)showValidation;

- (void)setStandardStore;
- (BOOL)dictionaryDownloadRequired;
- (BOOL)bookshelfSetupRequired;
- (void)replaceCheckProfilesAlertWithAlert:(LambdaAlert *)alert;
- (SCHProfileViewController_Shared *)profileViewController;
- (void)checkState;

@end

@implementation SCHStartingViewController

@synthesize checkProfilesAlert;
@synthesize backgroundView;
@synthesize modalNavigationController;
@synthesize loginPopoverController;
@synthesize webParentToolsPopoverController;
@synthesize profileViewController;
@synthesize profileSyncState;
@synthesize versionLabel;
@synthesize setupSequenceQueue;

- (void)createInitialNavigationControllerStack
{
    if ([[SCHAuthenticationManager sharedAuthenticationManager] hasUsernameAndPassword] && 
        [[SCHAuthenticationManager sharedAuthenticationManager] hasDRMInformation] && 
        [[SCHSyncManager sharedSyncManager] havePerformedFirstSyncUpToBooks]) {
        [self runSetupProfileSequenceAnimated:NO pushProfile:YES showValidation:NO];
    } else if ([[SCHAppStateManager sharedAppStateManager] isSampleStore]) {
        [self pushSamplesAnimated:NO showWelcome:NO];
    }
}

- (void)setVersionText
{
    // Get the marketing version from Info.plist.
    NSString* version = (NSString*)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]; 
    NSString* buildnum = (NSString*)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    
    if (version && buildnum) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.versionLabel.text = [NSString stringWithFormat:@"Version %@ (%@)", version, buildnum];
        } else {
            self.versionLabel.text = [NSString stringWithFormat:@"v%@ (%@)", version, buildnum];
        }
    } else {
        self.versionLabel.alpha = 0;
    }
}

#pragma mark - View lifecycle

- (void)releaseViewObjects
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:SCHProfileSyncComponentDidCompleteNotification 
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:SCHProfileSyncComponentDidFailNotification 
                                                  object:nil];

    [checkProfilesAlert release], checkProfilesAlert = nil;
    [backgroundView release], backgroundView = nil;
    [modalNavigationController release], modalNavigationController = nil;
    
    if ([loginPopoverController isModalSheetVisible]) {
        [loginPopoverController dismissSheetAnimated:NO completion:nil];
    }
    [loginPopoverController release], loginPopoverController = nil;
    
    if ([webParentToolsPopoverController isModalSheetVisible]) {
        [webParentToolsPopoverController dismissSheetAnimated:NO completion:nil];
    }
    [webParentToolsPopoverController release], webParentToolsPopoverController = nil;
    
    [versionLabel release], versionLabel = nil;
    [setupSequenceQueue release], setupSequenceQueue = nil;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [self releaseViewObjects];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.modalNavigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.modalNavigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    
    [self setVersionText];
    
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

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(versionDownloadManagerCompleted:)
                                                 name:SCHVersionDownloadManagerCompletedNotification
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

    [self.navigationController setNavigationBarHidden:YES];
    [self setupAssetsForOrientation:self.interfaceOrientation];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self checkState];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
   [super viewDidAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self checkState];
    }
}

- (void)checkState
{
    // SyncManager should not be suspended
    if ([[SCHSyncManager sharedSyncManager] isSuspended]) {
        NSLog(@"Warning Sync Manager suspended when showing start view controller");
        [[SCHSyncManager sharedSyncManager] setSuspended:NO];
    }
    
    if ([[SCHAuthenticationManager sharedAuthenticationManager] hasUsernameAndPassword] &&
        [[SCHAuthenticationManager sharedAuthenticationManager] hasDRMInformation] && 
        [[SCHSyncManager sharedSyncManager] havePerformedFirstSyncUpToBooks]) {
        
        if ([self bookshelfSetupRequired]) {
            // Start the sync in case they have been set up since last sync
            [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:NO];
        }
    } else {
        [self runInitialChoiceSequence];
    }
}

#pragma mark - Orientation methods

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
        
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        if (iPad) {
            [self.backgroundView setImage:[UIImage imageNamed:@"storia-startviewcontroller-static-landscape~ipad.jpg"]];
        } else {
            [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-landscape.jpg"]];
        }
    } else {
        if (iPad) {
            [self.backgroundView setImage:[UIImage imageNamed:@"storia-startviewcontroller-static-portrait~ipad.jpg"]];
        } else {
            [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-landscape.jpg"]];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self setupAssetsForOrientation:toInterfaceOrientation];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (self.loginPopoverController) {
            if (UIInterfaceOrientationIsPortrait(toInterfaceOrientation)) {
                [self.loginPopoverController setContentSize:CGSizeMake(300, 400) animated:YES completion:nil];
                [self.loginPopoverController setContentOffset:CGPointZero animated:YES completion:nil];
            } else {
                [self.loginPopoverController setContentSize:CGSizeMake(400, 300) animated:YES completion:nil];
                [self.loginPopoverController setContentOffset:CGPointMake(0, -60) animated:YES completion:nil];
            }
        }
    }
}

#pragma mark - SCHProfileSetupDelegate

- (void)popToAuthenticatedProfileAnimated:(BOOL)animated
{
    dispatch_block_t completion = ^{
        
        if ([self bookshelfSetupRequired]) {
            [self.navigationController setViewControllers:[NSArray arrayWithObject:self] animated:animated];
            [self runSetupProfileSequenceAnimated:animated];
        } else {
            [self.navigationController setViewControllers:[NSArray arrayWithObjects:self, [self profileViewController], nil] animated:animated];
        }
    };
    
    [self dismissModalViewControllerAnimated:animated withCompletionHandler:completion];
}

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
    [CATransaction begin];
    
    if (completion) {
        [CATransaction setCompletionBlock:completion];
    }
    
    if (self.modalViewController) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self dismissModalViewControllerAnimated:animated];
            [self.navigationController popToRootViewControllerAnimated:NO];
        } else {
            [self.navigationController popToRootViewControllerAnimated:NO];
            [self dismissModalViewControllerAnimated:animated];
        }
    } else {
        [self.navigationController popToRootViewControllerAnimated:animated];
    }
    
    [CATransaction commit];
}

- (void)pushCurrentProfileAnimated:(BOOL)animated
{   
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        if (self.modalViewController) {
            [self dismissModalViewControllerAnimated:YES];
        }
    }
    
    BOOL alreadyInUse = NO;
    SCHProfileViewController_Shared *profile = [self profileViewController];
    
    for (UIViewController *vc in self.navigationController.viewControllers) {
        if (vc == profile) {
            alreadyInUse = YES;
            break;
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        animated = NO;
    }
                                                                 
    if (alreadyInUse == NO) {
        [self.navigationController pushViewController:profile animated:animated];
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
    
    SCHParentalToolsWebViewController *parentalToolsWebViewController = [[[SCHParentalToolsWebViewController alloc] init] autorelease];
    parentalToolsWebViewController.title = title;
    parentalToolsWebViewController.modalPresenterDelegate = self;
    parentalToolsWebViewController.pToken = token;
    parentalToolsWebViewController.shouldHideCloseButton = shouldHide;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        BITModalSheetController *aPopoverController = [[BITModalSheetController alloc] initWithContentViewController:parentalToolsWebViewController];
        aPopoverController.contentSize = CGSizeMake(540, 620);
        aPopoverController.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
        self.webParentToolsPopoverController = aPopoverController;
        [aPopoverController release];
        
        __block BITModalSheetController *weakPopover = self.webParentToolsPopoverController;
        __block UIViewController *weakSelf = self;
        __block SCHParentalToolsWebViewController *weakParentTools = parentalToolsWebViewController;
        
        [self.webParentToolsPopoverController presentSheetInViewController:[self profileViewController] animated:NO completion:^{
            weakParentTools.textView.alpha = 0;
            
            CGSize expandedSize;
            
            if (UIInterfaceOrientationIsPortrait(weakSelf.interfaceOrientation)) {
                expandedSize = CGSizeMake(700, 530);
            } else {
                expandedSize = CGSizeMake(964, 530);
            }
            
            [weakPopover setContentSize:expandedSize animated:YES completion:^{
                weakParentTools.textView.alpha = 1;
            }];
        }];    
    } else {
        [self presentModalViewController:parentalToolsWebViewController animated:YES];        
    }
    
    [CATransaction commit];
}

- (void)dismissModalWebParentToolsAnimated:(BOOL)animated withSync:(BOOL)shouldSync showValidation:(BOOL)showValidation
{
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:NO];
    }
    
    SCHStartingViewController *weakSelf = self;
    
    dispatch_block_t completion = ^{
        [weakSelf setWebParentToolsPopoverController:nil];
        
        if (showValidation) {
            weakSelf.profileSyncState = kSCHStartingViewControllerProfileSyncStateWaitingForPassword;
        } else {
            weakSelf.profileSyncState = kSCHStartingViewControllerProfileSyncStateWaitingForBookshelves;
        }
        
        [weakSelf runSetupProfileSequenceAnimated:NO pushProfile:NO showValidation:showValidation];
        
        if (shouldSync) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:YES];
                weakSelf.checkProfilesAlert = [[[LambdaAlert alloc]
                                                initWithTitle:NSLocalizedString(@"Syncing with Your Account", @"")
                                                message:@"\n"] autorelease];
                [weakSelf.checkProfilesAlert setSpinnerHidden:NO];
                [weakSelf.checkProfilesAlert show];
            });
        }
    };
    
    if ([self.webParentToolsPopoverController isModalSheetVisible]) {
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

- (void)waitingForPassword
{
    self.profileSyncState = kSCHStartingViewControllerProfileSyncStateWaitingForPassword;
}

- (void)waitingForBookshelves
{
    [self.modalNavigationController setViewControllers:nil];
    [self pushBookshelfSetupModalControllerAnimated:YES showValidation:NO];
}

- (void)waitingForWebParentToolsToComplete
{
    self.profileSyncState = kSCHStartingViewControllerProfileSyncStateWaitingForWebParentToolsToComplete;
    
    // Need to also sync here in case the user has has set up a bookshelf in WPT outside teh app
    // We never want to enter WPT not in wizard mode as there is no close button
    [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:YES];
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

#pragma mark - Notifications

- (void)willEnterForeground:(NSNotification *)note
{    
    if ((self.profileSyncState == kSCHStartingViewControllerProfileSyncStateWaitingForBookshelves) ||
        (self.profileSyncState == kSCHStartingViewControllerProfileSyncStateWaitingForPassword) ||
        (self.profileSyncState == kSCHStartingViewControllerProfileSyncStateWaitingForWebParentToolsToComplete)) {
        [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:YES];
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
            [self runSetupProfileSequenceAnimated:YES];
            break;
        case kSCHStartingViewControllerProfileSyncStateWaitingForBookshelves:
            [self runSetupProfileSequenceAnimated:NO pushProfile:NO showValidation:NO];
            break;
        case kSCHStartingViewControllerProfileSyncStateWaitingForPassword:
            if (![self bookshelfSetupRequired]) {
                [self runSetupProfileSequenceAnimated:NO];
            } else {
                self.profileSyncState = kSCHStartingViewControllerProfileSyncStateWaitingForPassword;
            }
            break;
        case kSCHStartingViewControllerProfileSyncStateWaitingForWebParentToolsToComplete:
            if (![self bookshelfSetupRequired]) {
                [self runSetupProfileSequenceAnimated:NO];
            } else {
                self.profileSyncState = kSCHStartingViewControllerProfileSyncStateWaitingForWebParentToolsToComplete;
            }
            break;
        default:
            break;
    }
}

- (void)profileSyncDidFail:(NSNotification *)note
{
    if (self.checkProfilesAlert) {
        if (self.profileSyncState == kSCHStartingViewControllerProfileSyncStateWaitingForBookshelves) {
            [self runSetupProfileSequenceAnimated:NO];
            
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Sync Failed", @"")
                                  message:NSLocalizedString(@"There was a problem while checking for new profiles. Please try again.", @"")];
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

#pragma mark - Required Setup Checks

- (BOOL)dictionaryDownloadRequired
{
    BOOL downloadRequired = 
    ([[SCHDictionaryDownloadManager sharedDownloadManager] userRequestState] == SCHDictionaryUserNotYetAsked) 
    || ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] == SCHDictionaryProcessingStateUserSetup);
    
    return (downloadRequired && [[Reachability reachabilityForLocalWiFi] isReachable]);
}

- (BOOL)bookshelfSetupRequired;
{
    SCHProfileViewController_Shared *profile = [self profileViewController];
    BOOL setupRequired = (([[profile.fetchedResultsController sections] count] == 0) ||
                          ([[[profile.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] == 0));
    
    return setupRequired;
}

#pragma mark - Setup Steps

- (void)runInitialChoiceSequence
{
    // run a sequence of user interactions as asynchronous operations
    BITOperationWithBlocks *setupSequencePresentLoginOperation = [[BITOperationWithBlocks alloc] init];
    setupSequencePresentLoginOperation.asyncMain = ^(BITOperationIsCancelledBlock isCancelled, BITOperationAsyncCompletionBlock completion) {
        
        // Clear the modal contents so we have a known starting point
        [self.modalNavigationController setViewControllers:nil];
        
        SCHStoriaLoginViewController *login = [[SCHStoriaLoginViewController alloc] initWithNibName:@"SCHStoriaLoginViewController" bundle:nil];
        
        login.previewBlock = ^{
            [self runSetupSamplesSequence];
            completion(nil);
        };
        
        __block SCHStoriaLoginViewController *weakLoginRef = login;
        
        login.loginBlock = ^(NSString *username, NSString *password) {
            [weakLoginRef startShowingProgress];
            [self runLoginSequenceWithUsername:username password:password credentialsSuccessBlock:^(BOOL success, BOOL retrying, NSError *error){
                if (success) {
                    [weakLoginRef setDisplayIncorrectCredentialsWarning:kSCHLoginHandlerCredentialsWarningNone];
                } else {
                    if (error && [[error domain] isEqualToString:kSCHAccountValidationErrorDomain] && ([error code] == kSCHAccountValidationCredentialsError)) {
                        [weakLoginRef setDisplayIncorrectCredentialsWarning:kSCHLoginHandlerCredentialsWarningMalformedEmail];
                    } else if (error && [[error domain] isEqualToString:kBITAPIErrorDomain]){
                        [weakLoginRef setDisplayIncorrectCredentialsWarning:kSCHLoginHandlerCredentialsWarningAuthenticationFailure];
                    } else {
                        [weakLoginRef setDisplayIncorrectCredentialsWarning:kSCHLoginHandlerCredentialsWarningNone];
                    }
                }
                
                [weakLoginRef stopShowingProgress];
                
                if (!success) {
                    if (retrying) {
                        [weakLoginRef startShowingProgress];
                    } else {
                        [weakLoginRef clearBottomField];
                    }
                }
            }];
            completion(nil);
        };
        
        
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            BITModalSheetController *aLoginPopoverController = [[BITModalSheetController alloc] initWithContentViewController:login];
            [aLoginPopoverController setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleBottomMargin];
            
            [aLoginPopoverController setContentSize:CGSizeMake(603, 496)];
            CGPoint offset;
            
            if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
                offset = CGPointMake(0, -64);
            } else {
                offset = CGPointMake(0, 130);
            }
            [aLoginPopoverController setContentOffset:offset];
            
            self.loginPopoverController = aLoginPopoverController;
            [aLoginPopoverController release];
            [login release];
            
            [self.loginPopoverController presentSheetInViewController:self animated:YES completion:nil];
        } else {
            [self.modalNavigationController setViewControllers:[NSArray arrayWithObject:login]];
             if (self.modalViewController) {
                 [self dismissModalViewControllerAnimated:NO];
             }
            [self presentModalViewController:self.modalNavigationController animated:NO];
            [login release];
        }
    };
    
    self.setupSequenceQueue = [[[NSOperationQueue alloc] init] autorelease];
    self.setupSequenceQueue.maxConcurrentOperationCount = 1;
    [self.setupSequenceQueue addOperations:[NSArray arrayWithObjects:setupSequencePresentLoginOperation, nil] waitUntilFinished:NO];
    
    [setupSequencePresentLoginOperation release];
}

- (void)runSetupSamplesSequence
{
    BITOperationWithBlocks *setupSequenceDismissLoginOperation = [[BITOperationWithBlocks alloc] init];
    setupSequenceDismissLoginOperation.asyncMain = ^(BITOperationIsCancelledBlock isCancelled, BITOperationAsyncCompletionBlock completion) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            [self.loginPopoverController dismissSheetAnimated:YES completion:^{
                self.loginPopoverController = nil;
                completion(nil);
            }];
        } else {
            // Don't dismiss the modal view for iPhone, we want to wait until we have the samples
            completion(nil);
        }
    };
    
    BITOperationWithBlocks *setupSequenceImportSamplesOperation = [[BITOperationWithBlocks alloc] init];
    setupSequenceImportSamplesOperation.asyncMain = ^(BITOperationIsCancelledBlock isCancelled, BITOperationAsyncCompletionBlock completion) {
        
        AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
        [appDelegate setStoreType:kSCHStoreTypeSampleStore];
        
        NSString *localManifest = [[NSBundle mainBundle] pathForResource:kSCHSampleBooksLocalManifestFile ofType:nil];
        NSURL *localManifestURL = localManifest ? [NSURL fileURLWithPath:localManifest] : nil;
        
        [[SCHSampleBooksImporter sharedImporter] importSampleBooksFromRemoteManifest:[NSURL URLWithString:kSCHSampleBooksRemoteManifestURL] 
                                                                       localManifest:localManifestURL
                                                                        successBlock:^{
                                                                            completion(nil);
                                                                        }
                                                                        failureBlock:^(NSString * failureReason){
                                                                            NSError *error = [NSError errorWithDomain:nil code:0 userInfo:[NSDictionary dictionaryWithObject:failureReason forKey:@"failureReason"]];
                                                                            completion(error);
                                                                        }];
    };
    
    setupSequenceImportSamplesOperation.failed = ^(NSError *error){
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Unable To Update Sample eBooks", @"")
                              message:[NSString stringWithFormat:NSLocalizedString(@"There was a problem while updating the sample eBooks. %@. Please try again.", @""), [[error userInfo] valueForKey:@"failureReason"]]];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            [self runInitialChoiceSequence];
        }];
        
        [alert show]; 
        [alert release];  
    };
    
    BITOperationWithBlocks *setupSequenceCheckDictionaryDownload = [[BITOperationWithBlocks alloc] init];
    [setupSequenceCheckDictionaryDownload addSuccessDependency:setupSequenceImportSamplesOperation];
    setupSequenceCheckDictionaryDownload.asyncMain = ^(BITOperationIsCancelledBlock isCancelled, BITOperationAsyncCompletionBlock completion) {
        
        if ([self dictionaryDownloadRequired]) {
            SCHDownloadDictionaryViewController *downloadDictionary = [[SCHDownloadDictionaryViewController alloc] init];
            downloadDictionary.completion = ^{
                [self pushSamplesAnimated:NO showWelcome:YES];
                completion(nil);
            };
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [self.modalNavigationController setViewControllers:[NSArray arrayWithObject:downloadDictionary]];
                [self presentModalViewController:self.modalNavigationController animated:YES];
            } else {
                [self.modalNavigationController pushViewController:downloadDictionary animated:YES];
            }
            [downloadDictionary release];
        } else {
            [self pushSamplesAnimated:NO showWelcome:YES];
            completion(nil);
        }
    };
    
    [self.setupSequenceQueue addOperations:[NSArray arrayWithObjects:setupSequenceDismissLoginOperation, setupSequenceImportSamplesOperation, setupSequenceCheckDictionaryDownload, nil] waitUntilFinished:NO];
    
    [setupSequenceDismissLoginOperation release];
    [setupSequenceImportSamplesOperation release];
    [setupSequenceCheckDictionaryDownload release];
}

- (void)pushBookshelfSetupModalControllerAnimated:(BOOL)animated showValidation:(BOOL)showValidation
{
    // TODO: this should really just build this up from scratch - it is a source of bugs because 
    // the contents of the viewCOntrollers might actually be the settings view controllers
    // Currently this is worked around by setting viewControllers nil in waitingForBookshelves
    NSMutableArray *controllers = [NSMutableArray arrayWithArray:[self.modalNavigationController viewControllers]];

    NSAssert([controllers count] <= 2, @"Don't expect there to be >2 controllers on the modalNavigationController stack");
    
    if (!([[controllers lastObject] isKindOfClass:NSClassFromString(@"SCHSetupBookshelvesViewController")]) &&
        !([[controllers lastObject] isKindOfClass:NSClassFromString(@"SCHAccountValidationViewController")])) {
        if ([controllers count] > 0) {
            // There must have been something else on the controllers stack (e.g. the deregistration controller)
            // Clear it out and start again
            controllers = [NSMutableArray array];
        }

        SCHSetupBookshelvesViewController *setupBookshelves = [[[SCHSetupBookshelvesViewController alloc] init] autorelease];
        setupBookshelves.profileSetupDelegate = self;
        [controllers addObject:setupBookshelves];
    }
    
    if (showValidation) {
        if (![[controllers lastObject] isKindOfClass:NSClassFromString(@"SCHAccountValidationViewController")]) {
            SCHAccountValidationViewController *accountValidationViewController = [[[SCHAccountValidationViewController alloc] init] autorelease];
            accountValidationViewController.profileSetupDelegate = self;        
            accountValidationViewController.validatedControllerShouldHideCloseButton = YES;
            accountValidationViewController.title = NSLocalizedString(@"Set Up Your Bookshelves", @"");
            [controllers addObject:accountValidationViewController];
        }
    }
    
    if (!self.modalViewController) {
        [self.modalNavigationController setViewControllers:controllers];
        [self presentModalViewController:self.modalNavigationController animated:animated];
    } else if (self.modalViewController != self.modalNavigationController) {
        [self dismissModalViewControllerAnimated:YES withCompletionHandler:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.modalNavigationController setViewControllers:controllers];
                [self presentModalViewController:self.modalNavigationController animated:YES];
            });
        }];
    } else {
        [self.modalNavigationController setViewControllers:controllers animated:YES];
    }
}

- (void)pushDictionaryDownloadModalControllerAnimated:(BOOL)animated
{
    
    NSMutableArray *controllers = [NSMutableArray arrayWithArray:[self.modalNavigationController viewControllers]];

    if (![[controllers lastObject] isKindOfClass:NSClassFromString(@"SCHDownloadDictionaryViewController")]) {
        SCHDownloadDictionaryViewController *downloadDictionary = [[[SCHDownloadDictionaryViewController alloc] init] autorelease];
        downloadDictionary.profileSetupDelegate = self;
        downloadDictionary.completion = ^{
            if (self.modalViewController) {
                [self dismissModalViewControllerAnimated:YES];
            }
        };
        [controllers addObject:downloadDictionary];
    }
    
    if (!self.modalViewController) {
        [self.modalNavigationController setViewControllers:controllers];
        [self presentModalViewController:self.modalNavigationController animated:animated];
    } else {
        [self.modalNavigationController setViewControllers:controllers animated:YES];
    }
}

- (void)runSetupProfileSequenceAnimated:(BOOL)animated
{
    [self runSetupProfileSequenceAnimated:animated pushProfile:YES showValidation:NO];
}

- (void)runSetupProfileSequenceAnimated:(BOOL)animated pushProfile:(BOOL)pushProfile showValidation:(BOOL)showValidation
{        
    if (self.view != nil)  { // force the view to load if it hasn't already;
        
        dispatch_block_t continueBlock = ^{
            
            if (pushProfile) {
                [self pushCurrentProfileAnimated:animated];
            }
            
            if ([self bookshelfSetupRequired]) {
                self.profileSyncState = kSCHStartingViewControllerProfileSyncStateWaitingForBookshelves;
                [self pushBookshelfSetupModalControllerAnimated:animated showValidation:showValidation];
            } else if ([self dictionaryDownloadRequired]) {
                self.profileSyncState = kSCHStartingViewControllerProfileSyncStateNone;
                [self pushDictionaryDownloadModalControllerAnimated:animated];
            } else {
                if (self.modalViewController) {
                    [self dismissModalViewControllerAnimated:YES];
                }
            }
        };
        
        if ([self.loginPopoverController isModalSheetVisible]) {
            [self.loginPopoverController dismissSheetAnimated:YES completion:continueBlock];
        } else {
            continueBlock();
        }
        
    }
}

- (void)runLoginSequenceWithUsername:(NSString *)username password:(NSString *)password credentialsSuccessBlock:(void(^)(BOOL success, BOOL retrying, NSError *error))credentialsSuccessBlock
{
    BITOperationWithBlocks *setupSequenceCheckConnectivity = [[BITOperationWithBlocks alloc] init];
    setupSequenceCheckConnectivity.syncMain = ^(BITOperationIsCancelledBlock isCancelled, BITOperationFailedBlock failed) {
        if ([[Reachability reachabilityForInternetConnection] isReachable] == NO) {
            NSError *error = [NSError errorWithDomain:nil  
                                                   code:0  
                                               userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"An Internet connection is required to sign into your account.", @"")  
                                                                                    forKey:NSLocalizedDescriptionKey]];  
            failed(error);
        }
    };
    
    setupSequenceCheckConnectivity.failed = ^(NSError *error){
        
        if (credentialsSuccessBlock) {
            credentialsSuccessBlock(NO, NO, error);
        }
        
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"No Internet Connection", @"")
                              message:NSLocalizedString(@"An Internet connection is required to sign into your account.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
        [alert show];
        [alert release];
    };
    
    BITOperationWithBlocks *setupSequenceAttemptServiceLogin = [[BITOperationWithBlocks alloc] init];
    [setupSequenceAttemptServiceLogin addSuccessDependency:setupSequenceCheckConnectivity];
    setupSequenceAttemptServiceLogin.syncMain = ^(BITOperationIsCancelledBlock isCancelled, BITOperationFailedBlock failed) {
        
        [[SCHSyncManager sharedSyncManager] resetSync]; 
        [self setStandardStore];
        self.profileSyncState = kSCHStartingViewControllerProfileSyncStateWaitingForLoginToComplete;
        
        if ([[username stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0 &&
            [[password stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {      
#if USE_EMAIL_ADDRESS_AS_USERNAME
            NSString *errorMessage = NSLocalizedString(@"There was a problem checking your email and password. Please try again.", @"");
            if ([username isValidEmailAddress] == NO) {
                NSError *anError = [NSError errorWithDomain:kSCHAccountValidationErrorDomain  
                                                       code:kSCHAccountValidationCredentialsError  
                                                   userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Email address is not valid. Please try again.", @"")  
                                                                                        forKey:NSLocalizedDescriptionKey]];
                failed(anError);
                
            } else {
#else 
                NSString *errorMessage = NSLocalizedString(@"There was a problem checking your username and password. Please try again.", @"");
#endif
                [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithUser:username 
                                                                                    password:password
                                                                                successBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode) { 
                                                                                    if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) { 
                                                                                        if (credentialsSuccessBlock) {
                                                                                            credentialsSuccessBlock(YES, NO, nil);
                                                                                        }
                                                                                        [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:NO];
                                                                                    } else { 
                                                                                        NSError *anError = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain  
                                                                                                                               code:kSCHAuthenticationManagerOfflineError  
                                                                                                                           userInfo:[NSDictionary dictionaryWithObject:errorMessage  
                                                                                                                                                                forKey:NSLocalizedDescriptionKey]];        
                                                                                        failed(anError);
                                                                                    } 
                                                                                } 
                                                                                failureBlock:^(NSError * error){
                                                                                    if (error == nil) {
                                                                                        NSError *anError = [NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain  
                                                                                                                               code:kSCHAuthenticationManagerGeneralError  
                                                                                                                           userInfo:[NSDictionary dictionaryWithObject:errorMessage  
                                                                                                                                                                forKey:NSLocalizedDescriptionKey]];  
                                                                                        
                                                                                        failed(anError);
                                                                                    } else {
                                                                                        failed(error);
                                                                                    }
                                                                                }
                                                                 waitUntilVersionCheckIsDone:YES];    
#if USE_EMAIL_ADDRESS_AS_USERNAME
            }
#endif
        } else {
            NSError *anError = [NSError errorWithDomain:kSCHAccountValidationErrorDomain  
                                                   code:kSCHAccountValidationCredentialsError  
                                               userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"Username and password must not be blank. Please try again.", @"")  
                                                                                    forKey:NSLocalizedDescriptionKey]];
            failed(anError);
        }
    };
    
    setupSequenceAttemptServiceLogin.failed = ^(NSError *error){
        
        if ([error code] != kSCHAccountValidationCredentialsError) {
            NSString *localizedMessage = [[SCHAuthenticationManager sharedAuthenticationManager] localizedMessageForAuthenticationError:error];
            
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Login Error", @"Login Error") 
                                  message:localizedMessage];
            [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") block:^{
                if (credentialsSuccessBlock) {
                    credentialsSuccessBlock(NO, NO, error);
                }
            }];
            if (([[error domain] isEqualToString:@"kSCHDrmErrorDomain"]) && ([error code] == kSCHDrmInitializationError)) {
                [alert addButtonWithTitle:NSLocalizedString(@"Reset", @"Reset") block:^{
                    if (credentialsSuccessBlock) {
                        credentialsSuccessBlock(NO, YES, error);
                    }
                    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
                    [appDelegate recoverFromUnintializedDRM];
                    [self runLoginSequenceWithUsername:username password:password credentialsSuccessBlock:credentialsSuccessBlock];
                }];
            } else {
                [alert addButtonWithTitle:NSLocalizedString(@"Retry", @"Retry") block:^{
                    if (credentialsSuccessBlock) {
                        credentialsSuccessBlock(NO, YES, error);
                    }
                    [self runLoginSequenceWithUsername:username password:password credentialsSuccessBlock:credentialsSuccessBlock];
                }];
            }
            [alert show];
            [alert release];
        } else {
            if (credentialsSuccessBlock) {
                credentialsSuccessBlock(NO, NO, error);
            }
        }
    };
    
    [self.setupSequenceQueue addOperations:[NSArray arrayWithObjects:setupSequenceCheckConnectivity, setupSequenceAttemptServiceLogin, nil] waitUntilFinished:NO];
    
    [setupSequenceCheckConnectivity release];
    [setupSequenceAttemptServiceLogin release];   
    
}

- (void)pushSamplesAnimated:(BOOL)animated showWelcome:(BOOL)welcome
{       
    if (self.view != nil) { // force the view to load if it hasn't already;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            if (self.modalViewController) {
                [self dismissModalViewControllerAnimated:YES];
            }
        }
        
        // SyncManager should not be suspended
        if ([[SCHSyncManager sharedSyncManager] isSuspended]) {
            NSLog(@"Warning Sync Manager suspended when opening samples");
            [[SCHSyncManager sharedSyncManager] setSuspended:NO];
        }
        
        SCHProfileViewController_Shared *profile = [self profileViewController];
        SCHProfileItem *profileItem = [[profile profileItems] lastObject]; // Only one sample bookshelf so any result will do
        
        if (profileItem) {
            NSMutableArray *viewControllers = [NSMutableArray arrayWithObjects:self, profile, nil];
            [viewControllers addObjectsFromArray:[profile viewControllersForProfileItem:profileItem showWelcome:welcome]];
            [self.navigationController setViewControllers:viewControllers animated:animated];
        } else {
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Unable To Open the Sample Bookshelf", @"")
                                  message:NSLocalizedString(@"There was a problem while opening the sample bookshelf. Please try again.", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            }];
            
            [alert show]; 
            [alert release]; 
        }
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            if (self.modalViewController) {
                [self dismissModalViewControllerAnimated:YES];
            }
        }
        
    }
}

- (void)setStandardStore
{
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
    [appDelegate setStoreType:kSCHStoreTypeStandardStore];
}

- (void)versionDownloadManagerCompleted:(NSNotification *)note
{    
    NSNumber *appStateNumber = [[note userInfo] valueForKey:SCHVersionDownloadManagerCompletionAppVersionState];
    
    if (appStateNumber) {
        SCHVersionDownloadManagerAppVersionState appVersionState = [appStateNumber intValue];
        
        if (appVersionState == SCHVersionDownloadManagerAppVersionStateOutdatedRequiresForcedUpdate) {
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Update Required", @"")
                                  message:NSLocalizedString(@"Please visit the App Store to update Storia. Until you do, you will still be able to read your eBooks, but will not be able to download any new eBooks or synchronize your app.", @"")];
            __block LambdaAlert *weakAlert = alert;
            
            [alert addButtonWithTitle:NSLocalizedString(@"App Store", @"") block:^{
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://itunes.apple.com/app/scholastic-ereading-app-the/id491014756?mt=8"]];
                [weakAlert dismissAnimated:NO]; 
            }];
            
            [alert addButtonWithTitle:NSLocalizedString(@"Not Yet", @"") block:^{}];
            [alert show];
            [alert release];   
        }
    }
}

@end
