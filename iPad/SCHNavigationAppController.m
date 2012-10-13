//
//  SCHNavigationAppController.m
//  Scholastic
//
//  Created by Matt Farrugia on 14/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHNavigationAppController.h"

#import "SCHStoriaLoginViewController.h"
#import "BITOperationWithBlocks.h"
#import "SCHDictionaryDownloadManager.h"
#import "AppDelegate_iPhone.h"
#import "SCHSampleBooksImporter.h"
#import "LambdaAlert.h"
#import "SCHDownloadDictionaryViewController.h"
#import "Reachability.h"
#import "SCHProfileViewController.h"
#import "SCHCoreDataHelper.h"
#import "SCHProfileSetupDelegate.h"
#import "SCHAccountValidation.h"
#import "BITAPIError.h"
#import "NSString+EmailValidation.h"
#import "SCHAuthenticationManager.h"
#import "SCHSyncManager.h"
#import "SCHDrmSession.h"
#import "SCHAppModel.h"
#import "SCHScholasticAuthenticationWebService.h"
#import "SCHReadingManagerAuthorisationViewController.h"
#import "SCHTourStartViewController.h"
#import "SCHReadingManagerViewController.h"
#import "SCHSettingsViewController.h"
#import "SCHReadingViewController.h"
#import "SCHBookIdentifier.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"
#import "SCHProfileItem.h"
#import <QuartzCore/QuartzCore.h>
#import "SCHDeregisterDeviceViewController.h"
#import "SCHSupportViewController.h"
#import "SCHBookShelfViewController.h"
#import "SCHReadingViewController.h"

@interface SCHNavigationAppController () <UINavigationControllerDelegate>

@property (nonatomic, retain) LambdaAlert *undismissableAlert;

// Cached View Controllers
@property (nonatomic, retain) SCHStoriaLoginViewController *loginViewController;
@property (nonatomic, retain) SCHProfileViewController *profileViewController;
@property (nonatomic, retain) SCHProfileViewController *samplesViewController;
@property (nonatomic, retain) SCHTourStartViewController *tourViewController;
@property (nonatomic, retain) SCHSettingsViewController *settingsViewController;
@property (nonatomic, retain) UIViewController *readingManagerViewController;
@property (nonatomic, assign) NSUInteger dynamicInterfaceOrientations;

- (void)pushSamplesAnimated:(BOOL)animated;
- (void)pushProfileAnimated:(BOOL)animated;
- (void)pushBookshelfAnimated:(BOOL)animated forProfileItem:(SCHProfileItem *)profileItem;
- (void)pushReadingManagerAnimated:(BOOL)animated;
- (void)pushBookWithIdentifier:(SCHBookIdentifier *)identifier profileItem:(SCHProfileItem *)profileItem viewControllers:(NSArray *)viewControllers animated:(BOOL)animated;
- (BOOL)isCurrentlyModal;
- (SCHReadingViewController *)readingViewControllerForBookWithIdentifier:(SCHBookIdentifier *)identifier profileItem:(SCHProfileItem *)profileItem error:(NSError **)error;
- (void)failedOpenBookWithError:(NSError *)error;
- (BOOL)dynamicInterfaceOrientationsSupportInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end

@implementation SCHNavigationAppController

@synthesize undismissableAlert;
@synthesize loginViewController;
@synthesize profileViewController;
@synthesize samplesViewController;
@synthesize tourViewController;
@synthesize settingsViewController;
@synthesize readingManagerViewController;
@synthesize dynamicInterfaceOrientations;

- (void)dealloc
{
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationWillEnterForegroundNotification
                                                  object:nil];
    
    [undismissableAlert release], undismissableAlert = nil;
    [loginViewController release], loginViewController = nil;
    [profileViewController release], profileViewController = nil;
    [samplesViewController release], samplesViewController = nil;
    [tourViewController release], tourViewController = nil;
    [settingsViewController release], settingsViewController = nil;
    [readingManagerViewController release], readingManagerViewController = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        [self registerForNotifications];
        self.delegate = self;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            dynamicInterfaceOrientations = UIInterfaceOrientationMaskLandscape;
        } else {
            dynamicInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
        }
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    if ((self = [super initWithCoder:aDecoder])) {
        [self registerForNotifications];
        self.delegate = self;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            dynamicInterfaceOrientations = UIInterfaceOrientationMaskLandscape;
        } else {
            dynamicInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
        }
    }
    
    return self;
}

- (void)registerForNotifications
{
    // register for going into the background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willEnterForeground:)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];
}

#pragma mark - Presentation Methods

- (void)presentProfiles
{
    if (self.undismissableAlert) {
        [self.undismissableAlert dismissAnimated:YES];
        self.undismissableAlert = nil;
    }
    
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    [self pushProfileAnimated:shouldAnimate];
}

- (void)presentProfilesSetup
{
    [self presentReadingManager];
}

- (void)presentSettings
{
    if (self.undismissableAlert) {
        [self.undismissableAlert dismissAnimated:YES];
        self.undismissableAlert = nil;
    }
    
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    [self pushSettingsAnimated:shouldAnimate];
}

- (void)presentReadingManager
{
    if (self.undismissableAlert) {
        [self.undismissableAlert dismissAnimated:YES];
        self.undismissableAlert = nil;
    }
    
    self.readingManagerViewController = nil; // Reading Manager should not be cached in between invocations
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    [self pushReadingManagerAnimated:shouldAnimate];
}

- (void)presentTour
{
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    [self pushTourAnimated:shouldAnimate];
}

- (void)presentSamples
{
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    [self pushSamplesAnimated:shouldAnimate];
}

- (void)presentBookshelfForProfile:(SCHProfileItem *)profileItem
{
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    [self pushBookshelfAnimated:shouldAnimate forProfileItem:profileItem];
}

- (void)presentLogin
{
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    [self setViewControllers:[NSArray arrayWithObject:self.loginViewController] animated:shouldAnimate];
}

- (void)presentDictionaryDownload
{
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    
    SCHDownloadDictionaryViewController *controller = [[[SCHDownloadDictionaryViewController alloc] init] autorelease];
    controller.appController = self;

    [self setViewControllers:[NSArray arrayWithObjects:self.loginViewController, self.profileViewController, self.settingsViewController, controller, nil] animated:shouldAnimate];
}

- (void)presentDictionaryDelete
{
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    
    SCHDownloadDictionaryViewController *controller = [[[SCHDownloadDictionaryViewController alloc] initWithNibName:@"SCHRemoveDictionaryViewController" bundle:nil] autorelease];
    controller.appController = self;
    
    [self setViewControllers:[NSArray arrayWithObjects:self.loginViewController, self.profileViewController, self.settingsViewController, controller, nil] animated:shouldAnimate];
}

- (void)presentDeregisterDevice
{
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    
    SCHDeregisterDeviceViewController *controller = [[[SCHDeregisterDeviceViewController alloc] init] autorelease];
    controller.appController = self;
    
    [self setViewControllers:[NSArray arrayWithObjects:self.loginViewController, self.profileViewController, self.settingsViewController, controller, nil] animated:shouldAnimate];
}

- (void)presentSupport
{
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    
    SCHSupportViewController *controller = [[[SCHSupportViewController alloc] init] autorelease];
    controller.appController = self;
    
    [self setViewControllers:[NSArray arrayWithObjects:self.loginViewController, self.profileViewController, self.settingsViewController, controller, nil] animated:shouldAnimate];
}

- (void)presentEbookUpdates
{
    
}

#pragma mark - Book Presentation Methods

- (void)presentTourBookWithIdentifier:(SCHBookIdentifier *)identifier
{
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    
    // TODO, this reliance on using a profile view controller to get at a bookshelf should be refactored
    if ([[self.samplesViewController profileItems] count]) {
        SCHProfileItem *profileItem = [[self.samplesViewController profileItems] lastObject]; // Only one sample bookshelf so any result will do
        NSArray *stack = [NSArray arrayWithObjects:self.loginViewController, self.tourViewController, nil];
        [self pushBookWithIdentifier:identifier profileItem:profileItem viewControllers:stack animated:shouldAnimate];
    } else {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Unable To Open the Sample Bookshelf", @"")
                              message:NSLocalizedString(@"There was a problem while opening the sample bookshelf. Please try again.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            [self presentLogin];
        }];
        
        [alert show];
        [alert release];
    }
}

- (void)presentSampleBookWithIdentifier:(SCHBookIdentifier *)identifier
{
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    
    // TODO, this reliance on using a profile view controller to get at a bookshelf should be refactored
    if ([[self.samplesViewController profileItems] count]) {
        SCHProfileItem *profileItem = [[self.samplesViewController profileItems] lastObject]; // Only one sample bookshelf so any result will do
        UIViewController *bookshelfViewController = [[self.samplesViewController viewControllersForProfileItem:profileItem showWelcome:NO] lastObject];
        NSArray *stack = [NSArray arrayWithObjects:self.loginViewController, bookshelfViewController, nil];
        [self pushBookWithIdentifier:identifier profileItem:profileItem viewControllers:stack animated:shouldAnimate];
    } else {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Unable To Open the Sample Bookshelf", @"")
                              message:NSLocalizedString(@"There was a problem while opening the sample bookshelf. Please try again.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            [self presentLogin];
        }];
        
        [alert show];
        [alert release];
    }
}

- (void)presentAccountBookWithIdentifier:(SCHBookIdentifier *)identifier
{
    return; // TODO implement this
}

#pragma mark - Exit Methods

- (void)exitBookshelf
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self.dynamicInterfaceOrientations = UIInterfaceOrientationMaskLandscape;
    } else {
        self.dynamicInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
    }
    
    [self popViewControllerAnimated:YES];
}

- (void)exitReadingManager
{
    dispatch_async(dispatch_get_main_queue(), ^{
        self.undismissableAlert = [[[LambdaAlert alloc]
                                    initWithTitle:NSLocalizedString(@"Syncing with Your Account", @"")
                                    message:@"\n"] autorelease];
        [self.undismissableAlert setSpinnerHidden:NO];
        [self.undismissableAlert show];
    });
    
    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    SCHAppModel *appModel = [appDelegate appModel];
    [appModel waitForSettings];
}

- (void)exitBook
{
    if (tourViewController && [self.viewControllers containsObject:tourViewController]) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.dynamicInterfaceOrientations = UIInterfaceOrientationMaskLandscape;
        } else {
            self.dynamicInterfaceOrientations = UIInterfaceOrientationMaskPortrait;
        }
    }
    
    [self popViewControllerAnimated:YES];
}

#pragma mark - Errors

- (void)failedSamplesWithError:(NSError *)error
{
    LambdaAlert *alert = [[LambdaAlert alloc]
                          initWithTitle:NSLocalizedString(@"Unable To Update Sample eBooks", @"")
                          message:[NSString stringWithFormat:NSLocalizedString(@"There was a problem while updating the sample eBooks. %@. Please try again.", @""), [[error userInfo] valueForKey:@"failureReason"]]];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
    
    [alert show];
    [alert release];
}

- (void)failedLoginWithError:(NSError *)error
{
    SCHStoriaLoginViewController *login = self.loginViewController;
    
    if (error && [[error domain] isEqualToString:kSCHAccountValidationErrorDomain] && ([error code] == kSCHAccountValidationMalformedEmailError)) {
        [login setDisplayIncorrectCredentialsWarning:kSCHLoginHandlerCredentialsWarningMalformedEmail];
        [login stopShowingProgress];
        [login clearBottomField];
    } else if (error && [[error domain] isEqualToString:kBITAPIErrorDomain] && ([error code] == kSCHScholasticAuthenticationWebServiceErrorCodeInvalidUsernamePassword)){
        [login setDisplayIncorrectCredentialsWarning:kSCHLoginHandlerCredentialsWarningAuthenticationFailure];
        [login stopShowingProgress];
        [login clearBottomField];
    } else {
        [login setDisplayIncorrectCredentialsWarning:kSCHLoginHandlerCredentialsWarningNone];
        
        if (error && [[error domain] isEqualToString:kSCHLoginErrorDomain] && ([error code] == kSCHLoginReachabilityError)) {
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"No Internet Connection", @"")
                                  message:NSLocalizedString(@"An Internet connection is required to sign into your account.", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
                [login stopShowingProgress];
                [login clearBottomField];
            }];
            [alert show];
            [alert release];
            
        } else {
            NSString *localizedMessage = [error localizedDescription];
            
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Login Error", @"Login Error")
                                  message:localizedMessage];
            [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") block:^{
                [login stopShowingProgress];
                [login clearBottomField];
            }];
            
            if (([[error domain] isEqualToString:@"kSCHDrmErrorDomain"]) && ([error code] == kSCHDrmInitializationError)) {
                [alert addButtonWithTitle:NSLocalizedString(@"Reset", @"Reset") block:^{
                    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
                    [appDelegate recoverFromUnintializedDRM];
                    [login loginButtonAction:nil];
                }];
            } else {
                [alert addButtonWithTitle:NSLocalizedString(@"Retry", @"Retry") block:^{
                    [login loginButtonAction:nil];
                }];
            }
            
            [alert show];
            [alert release];
            
        }
    }
}

- (void)failedOpenBookWithError:(NSError *)error
{
    NSString *message;
    NSString *errorReason = [[error userInfo] valueForKey:@"failureReason"];
    
    if (errorReason) {
        message = [NSString stringWithFormat:NSLocalizedString(@"There was a problem while opening this eBook. %@. Please try again.", @""), errorReason];
    } else {
        message = [NSString stringWithFormat:NSLocalizedString(@"There was a problem while opening this eBook. Please try again.", @"")];
    }
    
    LambdaAlert *alert = [[LambdaAlert alloc]
                          initWithTitle:NSLocalizedString(@"Unable To Open eBook", @"")
                          message:message];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
    
    [alert show];
    [alert release];
}

- (void)failedSyncWithError:(NSError *)error
{
    
}

#pragma mark - Push Methods


- (void)pushSettingsAnimated:(BOOL)animated
{
    if ([[self.profileViewController profileItems] count]) {
        [self.settingsViewController setBackButtonHidden:NO];
    } else {
        [self.settingsViewController setBackButtonHidden:YES];
    }
    
    [self.settingsViewController displaySettingsPanel:kSCHSettingsPanelReadingManager];
    [self setViewControllers:[NSArray arrayWithObjects:self.loginViewController, self.profileViewController, self.settingsViewController, nil] animated:animated];
}

- (void)pushReadingManagerAnimated:(BOOL)animated
{
    // TODO: this pToken logic should be elsewhere
    NSString *currentToken = [[SCHAuthenticationManager sharedAuthenticationManager] pToken];
    
    if (currentToken != nil) {
        [(SCHReadingManagerViewController *)self.readingManagerViewController setPToken:[[SCHAuthenticationManager sharedAuthenticationManager] pToken]];
        [self setViewControllers:[NSArray arrayWithObjects:self.loginViewController, self.profileViewController, self.settingsViewController, self.readingManagerViewController, nil] animated:animated];
    } else {
        [self pushSettingsAnimated:animated];
        [self.settingsViewController setBackButtonHidden:YES];
        [self.settingsViewController displaySettingsPanel:kSCHSettingsPanelReadingManager];
        [self setViewControllers:[NSArray arrayWithObjects:self.loginViewController, self.profileViewController, self.settingsViewController, nil] animated:animated];
    }
}

- (void)pushProfileAnimated:(BOOL)animated
{
    if ([[self.profileViewController profileItems] count]) {
        [self setViewControllers:[NSArray arrayWithObjects:self.loginViewController, self.profileViewController, nil] animated:animated];
    } else {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Setup Bookshelves", @"")
                              message:NSLocalizedString(@"Please set up some bookshelves.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            [self pushSettingsAnimated:animated];
        }];
        
        [alert show];
        [alert release];
    }
}

- (void)pushSamplesAnimated:(BOOL)animated
{
    // TODO, this reliance on using a profile view controller to get at a bookshelf should be refactored
    if ([[self.samplesViewController profileItems] count]) {
        SCHProfileItem *profileItem = [[self.samplesViewController profileItems] lastObject]; // Only one sample bookshelf so any result will do
        UIViewController *bookshelfViewController = [[self.samplesViewController viewControllersForProfileItem:profileItem showWelcome:NO] lastObject];
        [self setViewControllers:[NSArray arrayWithObjects:self.loginViewController, bookshelfViewController, nil] animated:animated];
    } else {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Unable To Open the Sample Bookshelf", @"")
                              message:NSLocalizedString(@"There was a problem while opening the sample bookshelf. Please try again.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            [self presentLogin];
        }];
        
        [alert show];
        [alert release];
    }
    
}

- (void)pushBookshelfAnimated:(BOOL)animated forProfileItem:(SCHProfileItem *)profileItem
{
    self.dynamicInterfaceOrientations = UIInterfaceOrientationMaskAll;
    
    // TODO, this reliance on using a profile view controller to get at a bookshelf should be refactored
    UIViewController *bookshelfViewController = [[self.profileViewController viewControllersForProfileItem:profileItem showWelcome:NO] lastObject];
    [self setViewControllers:[NSArray arrayWithObjects:self.loginViewController, self.profileViewController, bookshelfViewController, nil] animated:animated];
}

- (void)pushTourAnimated:(BOOL)animated
{
    [self setViewControllers:[NSArray arrayWithObjects:self.loginViewController, self.tourViewController, nil] animated:animated];
}

- (void)pushBookWithIdentifier:(SCHBookIdentifier *)identifier profileItem:(SCHProfileItem *)profileItem viewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
    self.dynamicInterfaceOrientations = UIInterfaceOrientationMaskAll;
    
    NSError *error = nil;
    SCHReadingViewController *readingViewController = [self readingViewControllerForBookWithIdentifier:identifier profileItem:profileItem error:&error];
    
    if (readingViewController) {
        NSMutableArray *allViewControllers = [[viewControllers mutableCopy] autorelease];
        [allViewControllers addObject:readingViewController];
        [self setViewControllers:allViewControllers animated:animated];
    } else {
        [self failedOpenBookWithError:error];
    }
}

#pragma mark - SCHProfileSetupDelegate


- (void)popToAuthenticatedProfileAnimated:(BOOL)animated
{
    [self setViewControllers:[NSArray arrayWithObjects:self.loginViewController, self.profileViewController, nil] animated:animated];
}

- (void)pushCurrentProfileAnimated:(BOOL)animated
{
    [self pushProfileAnimated:animated];
}

- (void)waitingForPassword
{
    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    SCHAppModel *appModel = [appDelegate appModel];
    [appModel waitForPassword];
}

- (void)waitingForBookshelves
{
    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    SCHAppModel *appModel = [appDelegate appModel];
    [appModel waitForBookshelves];
}

- (void)dismissModalViewControllerAnimated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion
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
    [CATransaction setCompletionBlock:^{
        if (completion) {
            completion();
        }
    }];
    
    [self setViewControllers:[NSArray arrayWithObject:self.loginViewController] animated:animated];
       
    [CATransaction commit];
}

- (void)presentWebParentToolsModallyWithToken:(NSString *)token
                                        title:(NSString *)title
                                   modalStyle:(UIModalPresentationStyle)style
                        shouldHideCloseButton:(BOOL)shouldHide
{
//    SCHParentalToolsWebViewController *parentalToolsWebViewController = [[[SCHParentalToolsWebViewController alloc] init] autorelease];
//    parentalToolsWebViewController.title = title;
//    parentalToolsWebViewController.modalPresenterDelegate = self;
//    parentalToolsWebViewController.pToken = token;
//    parentalToolsWebViewController.shouldHideCloseButton = shouldHide;
//    
//    UIViewController *login = [self loginViewController];
//    NSMutableArray *controllers = [NSMutableArray arrayWithObjects:login, parentalToolsWebViewController, nil];
//    
//    if ([self isCurrentlyModal]) {
//        [self.modalContainerView setViewControllers:controllers animated:YES];
//    } else {
//        self.modalContainerView = [[[UINavigationController alloc] init] autorelease];
//        [self.modalContainerView setViewControllers:controllers animated:NO];
//        [self presentModalViewController:self.modalContainerView animated:YES];
//    }
}

- (void)popModalWebParentToolsToValidationAnimated:(BOOL)animated
{
//    SCHSetupBookshelvesViewController *setupBookshelves = [[[SCHSetupBookshelvesViewController alloc] init] autorelease];
//    setupBookshelves.profileSetupDelegate = self;
//    
//    SCHAccountValidationViewController *accountValidationViewController = [[[SCHAccountValidationViewController alloc] init] autorelease];
//    accountValidationViewController.profileSetupDelegate = self;
//    accountValidationViewController.validatedControllerShouldHideCloseButton = YES;
//    accountValidationViewController.title = NSLocalizedString(@"Set Up Your Bookshelves", @"");
//    
//    UIViewController *login = [self loginViewController];
//    NSMutableArray *controllers = [NSMutableArray arrayWithObjects:login, setupBookshelves, accountValidationViewController, nil];
//    
//    if ([self isCurrentlyModal]) {
//        [self.modalContainerView setViewControllers:controllers animated:animated];
//    } else {
//        self.modalContainerView = [[[UINavigationController alloc] init] autorelease];
//        [self.modalContainerView setViewControllers:controllers animated:NO];
//        [self presentModalViewController:self.modalContainerView animated:animated];
//    }
//    
//    [self waitingForPassword];
}

- (void)dismissModalWebParentToolsAnimated:(BOOL)animated
{
    [self waitingForBookshelves];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.undismissableAlert = [[[LambdaAlert alloc]
                                    initWithTitle:NSLocalizedString(@"Syncing with Your Account", @"")
                                    message:@"\n"] autorelease];
        [self.undismissableAlert setSpinnerHidden:NO];
        [self.undismissableAlert show];
    });
}

- (void)waitForWebParentToolsToComplete
{
    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    SCHAppModel *appModel = [appDelegate appModel];
    [appModel waitForWebParentToolsToComplete];
}

#pragma mark - View Controllers

- (SCHStoriaLoginViewController *)loginViewController
{
    if (!loginViewController) {
        loginViewController = [[SCHStoriaLoginViewController alloc] initWithNibName:@"SCHStoriaLoginViewController" bundle:nil];
        AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
        SCHAppModel *appModel = [appDelegate appModel];
   
        loginViewController.previewBlock = ^{
            [appModel setupTour];
        };
        
        loginViewController.samplesBlock = ^{
            [appModel setupSamples];
        };
    
        __block SCHStoriaLoginViewController *weakLoginRef = loginViewController;
    
        loginViewController.loginBlock = ^(NSString *username, NSString *password) {
            [weakLoginRef startShowingProgress];
            [appModel loginWithUsername:username password:password];
        };
    }
    
    return loginViewController;
}

- (SCHProfileViewController *)profileViewController
{
    if (!profileViewController) {
        
        profileViewController = [[SCHProfileViewController alloc] init];
    
        // access to the AppDelegate's managedObjectContext is deferred until we know we don't
        // want to use the same database any more
        AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
        profileViewController.managedObjectContext = appDelegate.coreDataHelper.managedObjectContext;
        profileViewController.appController = self;
    }
    
    return profileViewController;
}

- (SCHProfileViewController *)samplesViewController
{
    if (!samplesViewController) {
        
        samplesViewController = [[SCHProfileViewController alloc] init];
        
        // access to the AppDelegate's managedObjectContext is deferred until we know we don't
        // want to use the same database any more
        AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
        samplesViewController.managedObjectContext = appDelegate.coreDataHelper.managedObjectContext;
        samplesViewController.appController = self;
    }
    
    return samplesViewController;
}

- (SCHTourStartViewController *)tourViewController
{
    if (!tourViewController) {
        
        tourViewController = [[SCHTourStartViewController alloc] init];
        tourViewController.appController = self;
    }
    
    return tourViewController;
}

- (SCHSettingsViewController *)settingsViewController
{
    if (!settingsViewController) {
        
        settingsViewController = [[SCHSettingsViewController alloc] init];
        settingsViewController.appController = self;
        AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
        settingsViewController.managedObjectContext = appDelegate.coreDataHelper.managedObjectContext;
    }
    
    return settingsViewController;
}

- (UIViewController *)readingManagerViewController
{
    if (!readingManagerViewController) {
#if USE_CODEANDTHEORY
        SCHReadingManagerViewController *aReadingManager = [[SCHReadingManagerViewController alloc] init];
        aReadingManager.appController = self;
        readingManagerViewController = aReadingManager;
#else
//        SCHParentalToolsWebViewController *aParentalToolsWebViewController = [[SCHParentalToolsWebViewController alloc] init];
//        aParentalToolsWebViewController.modalPresenterDelegate = self;
//        aParentalToolsWebViewController.shouldHideCloseButton = NO;
//        readingManagerViewController = aParentalToolsWebViewController;        
#endif
    }
    
    return readingManagerViewController;
}

- (SCHReadingViewController *)readingViewControllerForBookWithIdentifier:(SCHBookIdentifier *)identifier profileItem:(SCHProfileItem *)profileItem error:(NSError **)error
{
    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    SCHAppModel *appModel = [appDelegate appModel];
    
    SCHReadingViewController *ret = nil;
    
    if ([appModel canOpenBookWithIdentifier:identifier error:error]) {
        NSManagedObjectContext *moc = profileItem.managedObjectContext;
        
        ret = [[[SCHReadingViewController alloc] initWithNibName:nil
                                                         bundle:nil
                                                 bookIdentifier:identifier
                                                        profile:profileItem
                                           managedObjectContext:moc
                                                          error:error] autorelease];
        
        SCHBookshelfStyles bookshelfStyle = [appModel bookshelfStyleForBookWithIdentifier:identifier];
        
        if (bookshelfStyle == kSCHBookshelfStyleNone) {
            if ([profileItem.BookshelfStyle intValue] == kSCHBookshelfStyleYoungChild) {
                bookshelfStyle = kSCHBookshelfStyleYoungChild;
            } else {
                bookshelfStyle = kSCHBookshelfStyleOlderChild;
            }
        }
        
        if (bookshelfStyle == kSCHBookshelfStyleYoungChild) {
            ret.youngerMode = YES;
        } else {
            ret.youngerMode = NO;
        }
    }
    
    ret.appController = self;
           
    return ret;
}

#pragma mark - Utilities

- (BOOL)isCurrentlyModal
{
    // This will eventually be deprecated and we will have to add a conditional check
    return (self.modalViewController != nil);
}

#pragma mark - UINavigationControllerDelegate

- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    // On iOS 5.0 this is called in viewWillAppear with a nil viewController prior to the app model being created.
    // To protect against accidental lazy instantiation of teh loginViewController, access it via the ivar rather than the property
    // TODO: refactor out this brittleness so iOS 5.0 doesnt need to be special-cased
    if (viewController != nil) {
        if (viewController == loginViewController) {
            AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
            SCHAppModel *appModel = [appDelegate appModel];
            loginViewController.showSamples = [appModel hasBooksToImport] || [appModel hasExtraSampleBooks];
        }
    }
}

#pragma mark - Notification methods

- (void)willEnterForeground:(NSNotification *)note
{
    if (self.topViewController == self.readingManagerViewController) {
        [self pushSettingsAnimated:NO];
    }
}

#pragma mark - Mixed Rotations

- (void)setDynamicInterfaceOrientations:(NSUInteger)newDynamicInterfaceOrientations
{
    if (dynamicInterfaceOrientations != newDynamicInterfaceOrientations) {
        dynamicInterfaceOrientations = newDynamicInterfaceOrientations;
        
        if (![self dynamicInterfaceOrientationsSupportInterfaceOrientation:self.interfaceOrientation]) {
            UIViewController *aVC = [[UIViewController alloc] init];
            if ([UIViewController instancesRespondToSelector:@selector(presentViewController:animated:completion:)]) {
                [self presentViewController:aVC animated:NO completion:nil];
                [self dismissViewControllerAnimated:NO completion:nil];
            } else {
                [self presentModalViewController:aVC animated:NO];
                [self dismissModalViewControllerAnimated:NO];
            }
            [aVC release];
        }
    }
}

- (BOOL)dynamicInterfaceOrientationsSupportInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    BOOL supportsOrientation = NO;
    
    switch (orientation) {
        case UIInterfaceOrientationLandscapeLeft:
            supportsOrientation = dynamicInterfaceOrientations & UIInterfaceOrientationMaskLandscapeLeft;
            break;
        case UIInterfaceOrientationLandscapeRight:
            supportsOrientation = dynamicInterfaceOrientations & UIInterfaceOrientationMaskLandscapeRight;
            break;
        case UIInterfaceOrientationPortrait:
            supportsOrientation = dynamicInterfaceOrientations & UIInterfaceOrientationMaskPortrait;
            break;
        case UIInterfaceOrientationPortraitUpsideDown:
            supportsOrientation = dynamicInterfaceOrientations & UIInterfaceOrientationMaskPortraitUpsideDown;
            break;
    }
    
    return supportsOrientation;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    if ([self dynamicInterfaceOrientationsSupportInterfaceOrientation:toInterfaceOrientation]) {
        return YES;
    } else {
        return NO;
    }
}

- (NSUInteger)supportedInterfaceOrientations
{
    return self.dynamicInterfaceOrientations;
}

@end
