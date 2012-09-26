//
//  SCHPhoneAppController.m
//  Scholastic
//
//  Created by Matt Farrugia on 20/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHPhoneAppController.h"
#import "SCHStoriaLoginViewController.h"
#import "BITOperationWithBlocks.h"
#import "SCHDictionaryDownloadManager.h"
#import "AppDelegate_iPhone.h"
#import "SCHSampleBooksImporter.h"
#import "LambdaAlert.h"
#import "SCHDownloadDictionaryViewController.h"
#import "Reachability.h"
#import "SCHProfileViewController_iPhone.h"
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

@interface SCHPhoneAppController () <SCHProfileSetupDelegate>

@property (nonatomic, retain) NSOperationQueue *setupSequenceQueue;
@property (nonatomic, retain) UINavigationController *modalContainerView;
@property (nonatomic, retain) LambdaAlert *undismissableAlert;

- (BOOL)dictionaryDownloadRequired;
- (void)pushSamplesAnimated:(BOOL)animated showWelcome:(BOOL)welcome;
- (void)pushProfileAnimated:(BOOL)animated;
- (void)pushProfileSetupAnimated:(BOOL)animated;

- (UIViewController *)loginViewController;
- (BOOL)isCurrentlyModal;

@end

@implementation SCHPhoneAppController

@synthesize setupSequenceQueue;
@synthesize modalContainerView;
@synthesize undismissableAlert;

- (void)dealloc
{
    [setupSequenceQueue release], setupSequenceQueue = nil;
    [modalContainerView release], modalContainerView = nil;
    [undismissableAlert release], undismissableAlert = nil;
    
    [super dealloc];
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        setupSequenceQueue = [[NSOperationQueue alloc] init];
        setupSequenceQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (void)presentProfiles
{        
    if (self.undismissableAlert) {
        [self.undismissableAlert dismissAnimated:YES];
        self.undismissableAlert = nil;
    }
    
    if ([self isCurrentlyModal]) {
        // Check if dictionary needs set up
        if ([self dictionaryDownloadRequired]) {
            SCHDownloadDictionaryViewController *downloadDictionary = [[SCHDownloadDictionaryViewController alloc] init];
           // downloadDictionary.completion = ^{
            //    [self pushProfileAnimated:NO];
             //   [self dismissModalViewControllerAnimated:YES];
                
             //   self.modalContainerView = nil;
           // };
            
            [self.modalContainerView pushViewController:downloadDictionary animated:YES];
            [downloadDictionary release];
        } else {
            [self pushProfileAnimated:NO];
            [self dismissModalViewControllerAnimated:YES];
        }
        
    } else {
        [self pushProfileAnimated:NO];
    }
}

- (void)presentProfilesSetup
{
    [self presentReadingManager];
}

- (void)presentSettings
{
    [self presentReadingManager];
}

- (void)presentReadingManager
{    
    if ([self isCurrentlyModal]) {
        // Check if dictionary needs set up
        if ([self dictionaryDownloadRequired]) {
            SCHDownloadDictionaryViewController *downloadDictionary = [[SCHDownloadDictionaryViewController alloc] init];
          //  downloadDictionary.completion = ^{
          //      [self pushProfileSetupAnimated:YES];
          //  };
            
            [self.modalContainerView pushViewController:downloadDictionary animated:YES];
            [downloadDictionary release];
        } else {
            [self pushProfileSetupAnimated:YES];
        }
    } else {
        BOOL shouldAnimate = ([self.viewControllers count] > 0);
        [self pushProfileSetupAnimated:shouldAnimate];
    }
}

- (void)presentTour
{    
    if ([self isCurrentlyModal]) {
        // Check if dictionary needs set up
        if ([self dictionaryDownloadRequired]) {
            SCHDownloadDictionaryViewController *downloadDictionary = [[SCHDownloadDictionaryViewController alloc] init];
           // downloadDictionary.completion = ^{
           //     [self pushSamplesAnimated:NO showWelcome:YES];
            //    [self dismissModalViewControllerAnimated:YES];
            
            //    self.modalContainerView = nil;
           // };
        
            [self.modalContainerView pushViewController:downloadDictionary animated:YES];        
            [downloadDictionary release];
        } else {
            [self pushSamplesAnimated:NO showWelcome:YES];
            [self dismissModalViewControllerAnimated:YES];
        }
    } else {
        [self pushSamplesAnimated:NO showWelcome:YES];
    }
}

- (void)presentSamples
{
    [self pushSamplesAnimated:NO showWelcome:YES];
}

- (void)presentLogin
{   
    UIViewController *login = [self loginViewController];
    self.modalContainerView = [[[UINavigationController alloc] initWithRootViewController:login] autorelease];
    
    [self presentModalViewController:self.modalContainerView animated:NO];
}

#pragma mark - Book Presentation Methods

- (void)presentTourBookWithIdentifier:(SCHBookIdentifier *)identifier
{
    
}

- (void)presentSampleBookWithIdentifier:(SCHBookIdentifier *)identifier
{
    
}

- (void)presentAccountBookWithIdentifier:(SCHBookIdentifier *)identifier
{
    
}

#pragma mark - Exit Methods

- (void)exitBookshelf
{
    [self popToRootViewControllerAnimated:YES];
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
    SCHStoriaLoginViewController *login = (SCHStoriaLoginViewController *)[self.modalContainerView topViewController];
    
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

- (void)failedSyncWithError:(NSError *)error
{
    
}

- (BOOL)dictionaryDownloadRequired
{
    BOOL downloadRequired = 
    ([[SCHDictionaryDownloadManager sharedDownloadManager] userRequestState] == SCHDictionaryUserNotYetAsked) 
    || ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] == SCHDictionaryProcessingStateUserSetup);
    
    return (downloadRequired && [[Reachability reachabilityForLocalWiFi] isReachable]);
}
   
- (void)pushProfileSetupAnimated:(BOOL)animated
{    
//    SCHSetupBookshelvesViewController *setupBookshelves = [[[SCHSetupBookshelvesViewController alloc] init] autorelease];
//    setupBookshelves.profileSetupDelegate = self;
//    
//    UIViewController *login = [self loginViewController];
//    NSMutableArray *controllers = [NSMutableArray arrayWithObjects:login, setupBookshelves, nil];
//
//    if ([self isCurrentlyModal]) {
//        [self.modalContainerView setViewControllers:controllers animated:animated];
//    } else {
//        self.modalContainerView = [[[UINavigationController alloc] init] autorelease];
//        [self.modalContainerView setViewControllers:controllers animated:NO];
//        [self presentModalViewController:self.modalContainerView animated:animated];
//    }    
}

- (void)pushProfileAnimated:(BOOL)animated
{
    SCHProfileViewController_Shared *profileViewController = [[SCHProfileViewController_iPhone alloc] init];
    
    // access to the AppDelegate's managedObjectContext is deferred until we know we don't
    // want to use the same database any more
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
    profileViewController.managedObjectContext = appDelegate.coreDataHelper.managedObjectContext;
    profileViewController.profileSetupDelegate = self;
    
    if ([[profileViewController profileItems] count]) {
        NSMutableArray *viewControllers = [NSMutableArray arrayWithObject:profileViewController];
        [self setViewControllers:viewControllers animated:animated];
    } else {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Unable To Open the Profile", @"")
                              message:NSLocalizedString(@"There was a problem while opening the profile. Please try again.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            [self presentLogin];
        }];
        
        [alert show]; 
        [alert release]; 
    }   
}

- (void)pushSamplesAnimated:(BOOL)animated showWelcome:(BOOL)welcome
{         
        
    SCHProfileViewController_Shared *profileViewController = [[SCHProfileViewController_iPhone alloc] init];
    
    // access to the AppDelegate's managedObjectContext is deferred until we know we don't
    // want to use the same database any more
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
    profileViewController.managedObjectContext = appDelegate.coreDataHelper.managedObjectContext;
    profileViewController.profileSetupDelegate = self;
    
    SCHProfileItem *profileItem = [[profileViewController profileItems] lastObject]; // Only one sample bookshelf so any result will do
    
    if (profileItem) {
        NSMutableArray *viewControllers = [NSMutableArray array];
        [viewControllers addObjectsFromArray:[profileViewController viewControllersForProfileItem:profileItem showWelcome:welcome]];
        [self setViewControllers:viewControllers animated:animated];
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

#pragma mark - SCHProfileSetupDelegate


- (void)popToAuthenticatedProfileAnimated:(BOOL)animated
{
    [self popToRootViewControllerAnimated:animated];
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
        [self setViewControllers:nil];
        if (completion) {
            completion();
        }
    }];
    
    if ([self isCurrentlyModal]) {
        [self.modalContainerView popToRootViewControllerAnimated:animated];
    } else {
        UIViewController *login = [self loginViewController];
        self.modalContainerView = [[[UINavigationController alloc] initWithRootViewController:login] autorelease];
        [self presentModalViewController:self.modalContainerView animated:animated];
    }
    
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

- (void)waitingForWebParentToolsToComplete
{
    [self waitForWebParentToolsToComplete];    
}

- (void)waitForWebParentToolsToComplete
{
    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    SCHAppModel *appModel = [appDelegate appModel];
    [appModel waitForWebParentToolsToComplete];
}

#pragma mark - View Controllers

- (UIViewController *)loginViewController
{
    SCHStoriaLoginViewController *login = [[[SCHStoriaLoginViewController alloc] initWithNibName:@"SCHStoriaLoginViewController" bundle:nil] autorelease];

    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    SCHAppModel *appModel = [appDelegate appModel];

    login.previewBlock = ^{
        [appModel setupTour];
    };
    
    __block SCHStoriaLoginViewController *weakLoginRef = login;
    
    login.loginBlock = ^(NSString *username, NSString *password) {
        [weakLoginRef startShowingProgress];
        [appModel loginWithUsername:username password:password];
    };
    
    return login;
}

#pragma mark - Utilities

- (BOOL)isCurrentlyModal
{
    // This will eventually be deprecated and we will have to add a conditional check
    return (self.modalViewController != nil);
}

@end
