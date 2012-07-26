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
#import "SCHParentalToolsWebViewController.h"
#import "SCHScholasticAuthenticationWebService.h"

@interface SCHPhoneAppController () <SCHProfileSetupDelegate>

@property (nonatomic, retain) NSOperationQueue *setupSequenceQueue;
@property (nonatomic, retain) UINavigationController *modalContainerView;
@property (nonatomic, retain) LambdaAlert *checkProfilesAlert;

- (BOOL)dictionaryDownloadRequired;
- (void)pushSamplesAnimated:(BOOL)animated showWelcome:(BOOL)welcome;
- (void)pushProfileAnimated:(BOOL)animated;

- (UIViewController *)loginViewController;

@end

@implementation SCHPhoneAppController

@synthesize setupSequenceQueue;
@synthesize modalContainerView;
@synthesize checkProfilesAlert;

- (void)dealloc
{
    [setupSequenceQueue release], setupSequenceQueue = nil;
    [modalContainerView release], modalContainerView = nil;
    [checkProfilesAlert release], checkProfilesAlert = nil;
    
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

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

- (void)presentProfiles
{
    BOOL presentFromLogin = ([self.modalContainerView.viewControllers count] > 0);
    
    if (presentFromLogin) {
        // Check if dictionary needs set up
        if ([self dictionaryDownloadRequired]) {
            SCHDownloadDictionaryViewController *downloadDictionary = [[SCHDownloadDictionaryViewController alloc] init];
            downloadDictionary.completion = ^{
                [self pushProfileAnimated:NO];
                [self dismissModalViewControllerAnimated:YES];
                
                self.modalContainerView = nil;
            };
            
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
    
}

- (void)presentSamplesWithWelcome:(BOOL)welcome
{
    BOOL presentFromLogin = ([self.modalContainerView.viewControllers count] > 0);
    
    if (presentFromLogin) {
        // Check if dictionary needs set up
        if ([self dictionaryDownloadRequired]) {
            SCHDownloadDictionaryViewController *downloadDictionary = [[SCHDownloadDictionaryViewController alloc] init];
            downloadDictionary.completion = ^{
                [self pushSamplesAnimated:NO showWelcome:welcome];
                [self dismissModalViewControllerAnimated:YES];
            
                self.modalContainerView = nil;
            };
        
            [self.modalContainerView pushViewController:downloadDictionary animated:YES];        
            [downloadDictionary release];
        } else {
            [self pushSamplesAnimated:NO showWelcome:welcome];
            [self dismissModalViewControllerAnimated:YES];
        }
    } else {
        [self pushSamplesAnimated:NO showWelcome:welcome];
    }
}

- (void)presentLogin
{   
    UIViewController *login = [self loginViewController];
    self.modalContainerView = [[[UINavigationController alloc] initWithRootViewController:login] autorelease];
    
    [self presentModalViewController:self.modalContainerView animated:NO];
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
    [appModel waitingForPassword];
}

- (void)waitingForBookshelves
{
    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    SCHAppModel *appModel = [appDelegate appModel];
    [appModel waitingForBookshelves];
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
 
    
    UIViewController *login = [self loginViewController];
    self.modalContainerView = [[[UINavigationController alloc] initWithRootViewController:login] autorelease];
    [self presentModalViewController:self.modalContainerView animated:animated];
    [self popToRootViewControllerAnimated:animated];
    
    [CATransaction commit];
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
    
    [self presentModalViewController:parentalToolsWebViewController animated:YES];        
    
    [CATransaction commit];
}

- (void)dismissModalWebParentToolsAnimated:(BOOL)animated withSync:(BOOL)shouldSync showValidation:(BOOL)showValidation
{
    if (self.modalViewController) {
        [self dismissModalViewControllerAnimated:NO];
    }
   #if 0 
    SCHStartingViewController *weakSelf = self;
    
    dispatch_block_t completion = ^{
        
        if (showValidation) {
            [self waitingForPassword];
        } else {
            [self waitingForBookshelves];
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
#endif

}

- (void)waitingForWebParentToolsToComplete
{
    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    SCHAppModel *appModel = [appDelegate appModel];
    [appModel waitingForWebParentToolsToComplete];
}

#pragma mark - View Controllers

- (UIViewController *)loginViewController
{
    SCHStoriaLoginViewController *login = [[[SCHStoriaLoginViewController alloc] initWithNibName:@"SCHStoriaLoginViewController" bundle:nil] autorelease];

    AppDelegate_iPhone *appDelegate = (AppDelegate_iPhone *)[[UIApplication sharedApplication] delegate];
    SCHAppModel *appModel = [appDelegate appModel];

    login.previewBlock = ^{
        [appModel setupPreview];
    };
    
    __block SCHStoriaLoginViewController *weakLoginRef = login;
    
    login.loginBlock = ^(NSString *username, NSString *password) {
        [weakLoginRef startShowingProgress];
        [appModel loginWithUsername:username password:password];
    };
    
    return login;
}

@end
