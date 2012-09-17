//
//  SCHPadAppController.m
//  Scholastic
//
//  Created by Matt Farrugia on 14/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHPadAppController.h"

#import "SCHPhoneAppController.h"
#import "SCHStoriaLoginViewController.h"
#import "BITOperationWithBlocks.h"
#import "SCHDictionaryDownloadManager.h"
#import "AppDelegate_iPhone.h"
#import "SCHSampleBooksImporter.h"
#import "LambdaAlert.h"
#import "SCHDownloadDictionaryViewController.h"
#import "Reachability.h"
#import "SCHProfileViewController_iPad.h"
#import "SCHCoreDataHelper.h"
#import "SCHProfileSetupDelegate.h"
#import "SCHAccountValidation.h"
#import "BITAPIError.h"
#import "NSString+EmailValidation.h"
#import "SCHAuthenticationManager.h"
#import "SCHSyncManager.h"
#import "SCHDrmSession.h"
#import "SCHAppModel.h"
#import "SCHParentalToolsWebViewController.h"
#import "SCHScholasticAuthenticationWebService.h"
#import "SCHAccountValidationViewController.h"
#import "SCHSetupBookshelvesViewController.h"
#import "SCHTourViewController.h"

@interface SCHPadAppController () <SCHProfileSetupDelegate>

@property (nonatomic, retain) UINavigationController *modalContainerView;
@property (nonatomic, retain) LambdaAlert *undismissableAlert;

// Cached View Controllers
@property (nonatomic, retain) SCHStoriaLoginViewController *loginViewController;
@property (nonatomic, retain) SCHProfileViewController_iPad *profileViewController;
@property (nonatomic, retain) SCHProfileViewController_iPad *samplesViewController;
@property (nonatomic, retain) SCHTourViewController *tourViewController;

- (void)pushSamplesAnimated:(BOOL)animated showWelcome:(BOOL)welcome;
- (void)pushProfileAnimated:(BOOL)animated;
- (void)pushProfileSetupAnimated:(BOOL)animated;

- (BOOL)isCurrentlyModal;

@end

@implementation SCHPadAppController

@synthesize modalContainerView;
@synthesize undismissableAlert;
@synthesize loginViewController;
@synthesize profileViewController;
@synthesize samplesViewController;
@synthesize tourViewController;

- (void)dealloc
{
    [modalContainerView release], modalContainerView = nil;
    [undismissableAlert release], undismissableAlert = nil;
    [loginViewController release], loginViewController = nil;
    [profileViewController release], profileViewController = nil;
    [samplesViewController release], samplesViewController = nil;
    [tourViewController release], tourViewController = nil;
    
    [super dealloc];
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
    
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    [self pushProfileAnimated:shouldAnimate];
}

- (void)presentProfilesSetup
{
    if ([self isCurrentlyModal]) {
        [self pushProfileSetupAnimated:YES];
    } else {
        BOOL shouldAnimate = ([self.viewControllers count] > 0);
        [self pushProfileSetupAnimated:shouldAnimate];
    }
}

- (void)presentSamplesWithWelcome:(BOOL)welcome
{
    BOOL shouldAnimate = ([self.viewControllers count] > 0);
    [self pushTourAnimated:shouldAnimate];
}

- (void)presentLogin
{
    [self setViewControllers:[NSArray arrayWithObject:self.loginViewController] animated:NO];
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

- (void)failedSyncWithError:(NSError *)error
{
    
}

- (void)pushProfileSetupAnimated:(BOOL)animated
{
    SCHSetupBookshelvesViewController *setupBookshelves = [[[SCHSetupBookshelvesViewController alloc] init] autorelease];
    setupBookshelves.profileSetupDelegate = self;
    
    NSMutableArray *controllers = [NSMutableArray arrayWithObjects:self.loginViewController, setupBookshelves, nil];
    
    if ([self isCurrentlyModal]) {
        [self.modalContainerView setViewControllers:controllers animated:animated];
    } else {
        self.modalContainerView = [[[UINavigationController alloc] init] autorelease];
        [self.modalContainerView setViewControllers:controllers animated:NO];
        [self presentModalViewController:self.modalContainerView animated:animated];
    }
}

- (void)pushProfileAnimated:(BOOL)animated
{
    if ([[self.profileViewController profileItems] count]) {
        [self setViewControllers:[NSArray arrayWithObjects:self.loginViewController, self.profileViewController, nil] animated:animated];
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
    if ([[self.samplesViewController profileItems] count]) {
        SCHProfileItem *profileItem = [[self.samplesViewController profileItems] lastObject]; // Only one sample bookshelf so any result will do

        NSMutableArray *viewControllers = [NSMutableArray arrayWithObjects:self.loginViewController, self.samplesViewController, nil];
        [viewControllers addObjectsFromArray:[self.samplesViewController viewControllersForProfileItem:profileItem showWelcome:welcome]];
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

- (void)pushTourAnimated:(BOOL)animated
{
    [self setViewControllers:[NSArray arrayWithObjects:self.loginViewController, self.tourViewController, nil] animated:animated];
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
    
    [self popToRootViewControllerAnimated:YES];
       
    [CATransaction commit];
}

- (void)presentWebParentToolsModallyWithToken:(NSString *)token
                                        title:(NSString *)title
                                   modalStyle:(UIModalPresentationStyle)style
                        shouldHideCloseButton:(BOOL)shouldHide
{
    SCHParentalToolsWebViewController *parentalToolsWebViewController = [[[SCHParentalToolsWebViewController alloc] init] autorelease];
    parentalToolsWebViewController.title = title;
    parentalToolsWebViewController.modalPresenterDelegate = self;
    parentalToolsWebViewController.pToken = token;
    parentalToolsWebViewController.shouldHideCloseButton = shouldHide;
    
    UIViewController *login = [self loginViewController];
    NSMutableArray *controllers = [NSMutableArray arrayWithObjects:login, parentalToolsWebViewController, nil];
    
    if ([self isCurrentlyModal]) {
        [self.modalContainerView setViewControllers:controllers animated:YES];
    } else {
        self.modalContainerView = [[[UINavigationController alloc] init] autorelease];
        [self.modalContainerView setViewControllers:controllers animated:NO];
        [self presentModalViewController:self.modalContainerView animated:YES];
    }
}

- (void)popModalWebParentToolsToValidationAnimated:(BOOL)animated
{
    SCHSetupBookshelvesViewController *setupBookshelves = [[[SCHSetupBookshelvesViewController alloc] init] autorelease];
    setupBookshelves.profileSetupDelegate = self;
    
    SCHAccountValidationViewController *accountValidationViewController = [[[SCHAccountValidationViewController alloc] init] autorelease];
    accountValidationViewController.profileSetupDelegate = self;
    accountValidationViewController.validatedControllerShouldHideCloseButton = YES;
    accountValidationViewController.title = NSLocalizedString(@"Set Up Your Bookshelves", @"");
    
    UIViewController *login = [self loginViewController];
    NSMutableArray *controllers = [NSMutableArray arrayWithObjects:login, setupBookshelves, accountValidationViewController, nil];
    
    if ([self isCurrentlyModal]) {
        [self.modalContainerView setViewControllers:controllers animated:animated];
    } else {
        self.modalContainerView = [[[UINavigationController alloc] init] autorelease];
        [self.modalContainerView setViewControllers:controllers animated:NO];
        [self presentModalViewController:self.modalContainerView animated:animated];
    }
    
    [self waitingForPassword];
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
            [appModel setupPreview];
        };
    
        __block SCHStoriaLoginViewController *weakLoginRef = loginViewController;
    
        loginViewController.loginBlock = ^(NSString *username, NSString *password) {
            [weakLoginRef startShowingProgress];
            [appModel loginWithUsername:username password:password];
        };
    }
    
    return loginViewController;
}

- (SCHProfileViewController_iPad *)profileViewController
{
    if (!profileViewController) {
        
        profileViewController = [[SCHProfileViewController_iPad alloc] init];
    
        // access to the AppDelegate's managedObjectContext is deferred until we know we don't
        // want to use the same database any more
        AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
        profileViewController.managedObjectContext = appDelegate.coreDataHelper.managedObjectContext;
        profileViewController.profileSetupDelegate = self;
    }
    
    return profileViewController;
}

- (SCHProfileViewController_iPad *)samplesViewController
{
    if (!samplesViewController) {
        
        samplesViewController = [[SCHProfileViewController_iPad alloc] init];
        
        // access to the AppDelegate's managedObjectContext is deferred until we know we don't
        // want to use the same database any more
        AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
        samplesViewController.managedObjectContext = appDelegate.coreDataHelper.managedObjectContext;
        samplesViewController.profileSetupDelegate = self;
    }
    
    return samplesViewController;
}

- (SCHTourViewController *)tourViewController
{
    if (!tourViewController) {
        
        tourViewController = [[SCHTourViewController alloc] init];
        
        // access to the AppDelegate's managedObjectContext is deferred until we know we don't
        // want to use the same database any more
        AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
        tourViewController.managedObjectContext = appDelegate.coreDataHelper.managedObjectContext;
    }
    
    return tourViewController;
}

#pragma mark - Utilities

- (BOOL)isCurrentlyModal
{
    // This will eventually be deprecated and we will have to add a conditional check
    return (self.modalViewController != nil);
}

@end
