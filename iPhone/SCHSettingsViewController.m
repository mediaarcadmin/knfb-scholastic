//
//  SCHSettingsViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SCHSettingsViewController.h"

#import "SCHSettingsViewController.h"
#import "SCHDictionaryDownloadManager.h"
#import "SCHDownloadDictionaryViewController.h"
#import "SCHRemoveDictionaryViewController.h"
#import "SCHDeregisterDeviceViewController.h"
#import "SCHCheckbox.h"
#import "SCHBookUpdates.h"
#import "SCHUpdateBooksViewController.h"
#import "SCHProfileSyncComponent.h"
#import "SCHBookshelfSyncComponent.h"
#import "SCHContentSyncComponent.h"
#import "SCHAnnotationSyncComponent.h"
#import "SCHSettingsSyncComponent.h"
#import "SCHReadingStatsSyncComponent.h"
#import "SCHCoreDataHelper.h"
#import "SCHUserDefaults.h"
#import "SCHAppStateManager.h"
#import "SCHSyncManager.h"
#import "Reachability.h"
#import "LambdaAlert.h"
#import "SCHReadingManagerAuthorisationViewController.h"
#import "SCHVersionDownloadManager.h"
#import "SCHSupportViewController.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

@interface SCHSettingsViewController()

@property (nonatomic, retain) SCHBookUpdates *bookUpdates;
@property (nonatomic, retain) LambdaAlert *checkBooksAlert;
@property (nonatomic, retain) Reachability *syncReachability;
@property (nonatomic, retain) UIViewController *contentViewController;
@property (nonatomic, assign) SCHSettingsPanel selectedPanel;
@property (nonatomic, assign) BOOL additionalSettingsVisible;

- (void)updateDictionaryButton;
- (void)releaseViewObjects;
- (void)replaceCheckBooksAlertWithAlert:(LambdaAlert *)alert;
- (void)registerForSyncNotifications;
- (void)deregisterForSyncNotifications;
- (BOOL)connectionIsReachable;
- (BOOL)connectionIsReachableViaWiFi;
- (void)showAppVersionOutdatedAlert;
- (void)showNoInternetConnectionAlert;
- (void)showWifiRequiredAlert;
- (void)showAlertForSyncFailure;
- (UIView *)backgroundViewForCellAtIndexPath:(NSIndexPath *)indexPath withSelection:(NSIndexPath *)selectedIndexPath;
- (void)setAdditionalSettingsVisible:(BOOL)visible completionBlock:(dispatch_block_t)completion;
- (SCHSettingsPanel)panelForIndexPath:(NSIndexPath *)indexPath;

@end

@implementation SCHSettingsViewController

@synthesize bookUpdates;
@synthesize managedObjectContext;
@synthesize checkBooksAlert;
@synthesize syncReachability;
@synthesize containerView;
@synthesize transformableView;
@synthesize shadowView;
@synthesize tableView;
@synthesize contentView;
@synthesize contentViewController;
@synthesize appController;
@synthesize settingsDisplayMask;
@synthesize backButton;
@synthesize backButtonHidden;
@synthesize backgroundImageView;
@synthesize selectedPanel;
@synthesize additionalSettingsVisible;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [checkBooksAlert release], checkBooksAlert = nil;
    [contentView release], contentView = nil;
    [containerView release], containerView = nil;
    [transformableView release], transformableView = nil;
    [shadowView release], shadowView = nil;
    [tableView release], tableView = nil;
    [backButton release], backButton = nil;
    [backgroundImageView release], backgroundImageView = nil;
    
}

- (void)dealloc 
{    
    [bookUpdates release], bookUpdates = nil;
	[managedObjectContext release], managedObjectContext = nil;
    [syncReachability release], syncReachability = nil;
    [contentViewController release], contentViewController = nil;
    appController = nil;
    
    [self releaseViewObjects];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [self addContentSubview:self.contentViewController.view];
    
    UIImage *backButtonImage = [[UIImage imageNamed:@"bookshelf_arrow_bttn_UNselected_3part"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
    [self.backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
    [self.backButton setHidden:self.backButtonHidden];
    [self.backgroundImageView setImage:[UIImage imageNamed:@"storia-tourstepsviewcontroller-static-landscape~ipad.jpg"]];
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIView *whiteView = [[[UIView alloc] initWithFrame:self.tableView.bounds] autorelease];
        whiteView.backgroundColor = [UIColor whiteColor];
        self.tableView.backgroundView = whiteView;
        self.shadowView.layer.shadowOpacity = 0.5f;
        self.shadowView.layer.shadowOffset = CGSizeMake(0, 0);
        self.shadowView.layer.shadowRadius = 4.0f;
        self.shadowView.layer.backgroundColor = [UIColor clearColor].CGColor;
        self.containerView.layer.masksToBounds = YES;
        self.containerView.layer.cornerRadius = 10.0f;
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dictionaryStateChanged:)
                                                 name:kSCHDictionaryStateChange
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dictionaryStateChanged:)
                                                 name:kSCHDictionaryDownloadPercentageUpdate
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dictionaryStateChanged:)
                                                 name:kSCHDictionaryProcessingPercentageUpdate
                                               object:nil];
}

- (void)setSelectedPanel:(SCHSettingsPanel)panel
{
    selectedPanel = panel;
    [self.tableView reloadData];
}

- (void)setSettingsDisplayMask:(NSUInteger)newMask
{
    settingsDisplayMask = newMask;
    [self.tableView reloadData];
}

- (void)setBackButtonHidden:(BOOL)hidden
{
    backButtonHidden = hidden;

    if ([self.backButton isHidden] != backButtonHidden) {
        [self.backButton setHidden:backButtonHidden];
    }
}

- (SCHBookUpdates *)bookUpdates
{
    if (bookUpdates == nil) {
        NSAssert(self.managedObjectContext != nil, @"must set managedObjectContext before accessing bookUpdates");
        bookUpdates = [[SCHBookUpdates alloc] init];
        bookUpdates.managedObjectContext = self.managedObjectContext;
    }
    
    return bookUpdates;
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];    
     
    [self.navigationController setNavigationBarHidden:YES];
    
    [self registerForKeyboardNotifications];
//    if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] == NO) {
//        [self.manageBooksButton setEnabled:NO];
//        [self.checkBooksButton setEnabled:NO];
//    } else {
//        [self.manageBooksButton setEnabled:YES];
//        [self.checkBooksButton setEnabled:YES];
//    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.checkBooksAlert) {
        [self.checkBooksAlert dismissAnimated:NO];
    }
    
    [self.view endEditing:YES];
    [self deregisterForKeyboardNotifications];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return UIInterfaceOrientationIsLandscape(toInterfaceOrientation);
}

#pragma mark - Button states

- (void)updateDictionaryButton
{
    SCHDictionaryProcessingState state = [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState];
    
    BOOL enabled = NO;
    
    // Specifically enumerating without a default so we catch any new cases at compile time
    switch (state) {
        case SCHDictionaryProcessingStateReady:
        case SCHDictionaryProcessingStateUserSetup:
        case SCHDictionaryProcessingStateUserDeclined:
        case SCHDictionaryProcessingStateError:
        case SCHDictionaryProcessingStateNotEnoughFreeSpaceError:
        case SCHDictionaryProcessingStateUnexpectedConnectivityFailureError:
        case SCHDictionaryProcessingStateDownloadError:
        case SCHDictionaryProcessingStateUnableToOpenZipError:
        case SCHDictionaryProcessingStateUnZipFailureError:
        case SCHDictionaryProcessingStateParseError:
            enabled = YES;
            break;
        case SCHDictionaryProcessingStateNeedsManifest:
        case SCHDictionaryProcessingStateManifestVersionCheck:
        case SCHDictionaryProcessingStateNeedsDownload:
        case SCHDictionaryProcessingStateNeedsUnzip:
        case SCHDictionaryProcessingStateNeedsParse:
        case SCHDictionaryProcessingStateDeleting:
            enabled = NO;
            break;
    }
    
   // self.downloadDictionaryButton.enabled = enabled;
    //self.downloadDictionaryButton.titleLabel.textAlignment = UITextAlignmentCenter;

    BOOL doubleLine = NO;

    switch (state) {
        case SCHDictionaryProcessingStateReady:
          //  [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Remove Dictionary", @"remove dictionary button title")
              //                             forState:UIControlStateNormal];

            break;
        case SCHDictionaryProcessingStateNeedsManifest:
        case SCHDictionaryProcessingStateManifestVersionCheck:
        case SCHDictionaryProcessingStateNeedsDownload:
        {
            if ([[SCHDictionaryDownloadManager sharedDownloadManager] wifiAvailable]) {
                //NSUInteger progress = roundf([[SCHDictionaryDownloadManager sharedDownloadManager] currentDictionaryDownloadPercentage] * 100.0f);
             //   [self.downloadDictionaryButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Downloading Dictionary %d%%", @"Downloading dictionary button title"),
                                             //            progress]
                                             //  forState:UIControlStateNormal];
            } else {
               // [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Download Paused.\nWaiting for Wi-Fi.", @"Waiting for Wi-Fi dictionary button title")
                                             //  forState:UIControlStateNormal];
                doubleLine = YES;
            }
            break;
        }
        case SCHDictionaryProcessingStateNeedsUnzip:
        case SCHDictionaryProcessingStateNeedsParse:
        {
           // NSUInteger progress = roundf([[SCHDictionaryDownloadManager sharedDownloadManager] currentDictionaryProcessingPercentage] * 100.0f);
            //[self.downloadDictionaryButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Installing Dictionary %d%%", @"Installing dictionary button title"),
                                             //        progress]
                                          // forState:UIControlStateNormal];
            break;
        }
        case SCHDictionaryProcessingStateDeleting:
            //[self.downloadDictionaryButton setTitle:NSLocalizedString(@"Deleting Dictionary...", @"Deleting dictionary button title")
               //                            forState:UIControlStateNormal];
            break;   
        case SCHDictionaryProcessingStateError:
           // [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Error. Try Again.\nUnknown Error", @"Dictionary error button title for unknown error")
            //                               forState:UIControlStateNormal];
            doubleLine = YES;
            break; 
        case SCHDictionaryProcessingStateUnexpectedConnectivityFailureError:
          //  [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Error. Try Again.\nDownload Interrupted.", @"Dictionary error button title for connection interrupted")
             //                              forState:UIControlStateNormal];
            doubleLine = YES;
            break; 
        case SCHDictionaryProcessingStateNotEnoughFreeSpaceError:
           // [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Error. Try Again.\nNot Enough Free Space.", @"Dictionary error button title for not enough free space")
             //                              forState:UIControlStateNormal];
            doubleLine = YES;
            break; 
        case SCHDictionaryProcessingStateDownloadError:
           // [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Error. Try Again.\nDownload Failed.", @"Dictionary error button title for download failed")
           //                                forState:UIControlStateNormal];
            doubleLine = YES;
            break; 
        case SCHDictionaryProcessingStateUnableToOpenZipError:
           // [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Error. Try Again.\nCouldn't Open Zip.", @"Dictionary error button title for Couldn't open zip")
            //                               forState:UIControlStateNormal];
            doubleLine = YES;
            break; 
        case SCHDictionaryProcessingStateUnZipFailureError:
           // [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Error. Try Again.\nUnzip Failed. Check Disk Space.", @"Dictionary error button title for unzip failed")
            //                               forState:UIControlStateNormal];
            doubleLine = YES;
            break; 
        case SCHDictionaryProcessingStateParseError:
           // [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Error. Try Again.\nParse Failed.", @"Dictionary error button title for parser error")
             //                              forState:UIControlStateNormal];
            doubleLine = YES;
            break;  
        case SCHDictionaryProcessingStateUserSetup:
        case SCHDictionaryProcessingStateUserDeclined:
           // [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Download Dictionary", @"download dictionary button title")
            //                               forState:UIControlStateNormal];

            break;
    }
    
//    if (doubleLine) {
//        self.downloadDictionaryButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;
//
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//            self.downloadDictionaryButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
//        } else {
//            self.downloadDictionaryButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14.0f];
//        }
//    } else {
//        self.downloadDictionaryButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation; 
//        
//        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
//            self.downloadDictionaryButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:18.0f];
//        } else {
//            self.downloadDictionaryButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:17.0f];
//        }
//    }
}

#pragma mark - Actions
#if 0

- (IBAction)deregisterDevice:(id)sender 
{
    if ([[SCHVersionDownloadManager sharedVersionManager] isAppVersionOutdated] == YES) {
        [self showAppVersionOutdatedAlert];
    } else if ([self connectionIsReachable]) {
        SCHDeregisterDeviceViewController *vc = [[SCHDeregisterDeviceViewController alloc] init];
        vc.settingsDelegate = self.settingsDelegate;
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else {
        [self showNoInternetConnectionAlert];
    }
}

- (IBAction)showPrivacyPolicy:(id)sender
{
    SCHPrivacyPolicyViewController *privacyController = [[SCHPrivacyPolicyViewController alloc] init];
    [self.navigationController pushViewController:privacyController animated:YES];
    [privacyController release];
}

- (IBAction)showAboutView:(id)sender
{
    SCHAboutViewController *aboutController = [[SCHAboutViewController alloc] init];
    [self.navigationController pushViewController:aboutController animated:YES];
    [aboutController release];
}

- (IBAction)contactCustomerSupport:(id)sender
{
    if ([MFMailComposeViewController canSendMail]) {
        MFMailComposeViewController *mfViewController = [[MFMailComposeViewController alloc] init];
        mfViewController.mailComposeDelegate = self;
        [mfViewController setToRecipients:[NSArray arrayWithObject:@"storia@scholastic.com"]];
        [mfViewController setSubject:[NSString stringWithFormat:@"Storia v%@ Support Request", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
        [self presentModalViewController:mfViewController animated:YES];
        [mfViewController release];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Unable to Send Email", @"Email error title")
                                                        message:NSLocalizedString(@"This device is not set up to send email. Please configure an email account in Settings and try again", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

#endif

#define MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Storia Support Email", @"Support Email Alert title")
                                                    message:@""
                                                   delegate:nil 
                                          cancelButtonTitle:@"OK" 
                                          otherButtonTitles:nil];
    
    switch (result) {
        case MFMailComposeResultCancelled:
            [alert release];
            [self dismissModalViewControllerAnimated:YES];
            return;
            break;
        case MFMailComposeResultSaved:
            alert.message = NSLocalizedString(@"Draft Saved", @"Draft Saved");
            break;
        case MFMailComposeResultSent:
            alert.message = NSLocalizedString(@"Support Request Sent", @"Support Request Sent");
            break;
        case MFMailComposeResultFailed:
            alert.message = NSLocalizedString(@"Support Request Failed", @"Support Request Failed");
            break;
        default:
            alert.message = NSLocalizedString(@"Support Request Not Sent", @"Support Request Not Sent");
            break;
    }
    
    [self dismissModalViewControllerAnimated:YES];
    
    [alert show];
    [alert release];
}

- (BOOL)connectionIsReachable
{
    return [[Reachability reachabilityForInternetConnection] isReachable];
}

- (BOOL)connectionIsReachableViaWiFi
{
    return [[Reachability reachabilityForLocalWiFi] isReachable];
}

- (void)showAppVersionOutdatedAlert
{
    LambdaAlert *alert = [[LambdaAlert alloc]
                          initWithTitle:NSLocalizedString(@"Update Required", @"")
                          message:NSLocalizedString(@"This function requires that you update Storia. Please visit the App Store to update your app.", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
    [alert show];
    [alert release];         
}

- (void)showNoInternetConnectionAlert
{
    LambdaAlert *alert = [[LambdaAlert alloc]
                          initWithTitle:NSLocalizedString(@"No Internet Connection", @"")
                          message:NSLocalizedString(@"This function requires an Internet connection. Please connect to the internet and then try again.", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
    [alert show];
    [alert release];
}

- (void)showWifiRequiredAlert
{
    LambdaAlert *alert = [[LambdaAlert alloc]
                          initWithTitle:NSLocalizedString(@"No Wi-Fi Connection", @"")
                          message:NSLocalizedString(@"Downloading the dictionary requires a Wi-Fi connection. Please connect to Wi-Fi and then try again.", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
    [alert show];
    [alert release];
}

#if 0
- (IBAction)manageBooks:(id)sender
{
    if ([[SCHVersionDownloadManager sharedVersionManager] isAppVersionOutdated] == YES) {
        [self showAppVersionOutdatedAlert];
    } else if ([self connectionIsReachable]) {
        // we always ask for the password before showing parent tools from settings
        SCHAccountValidationViewController *accountValidationViewController = [[[SCHAccountValidationViewController alloc] init] autorelease];
        accountValidationViewController.title = NSLocalizedString(@"Manage eBooks", @"Manage eBooks");
        accountValidationViewController.settingsDelegate = self.settingsDelegate;
        [self.navigationController pushViewController:accountValidationViewController animated:YES];   
    } else {
        [self showNoInternetConnectionAlert];
    }
}

- (IBAction)checkBooks:(id)sender
{
    if ([[SCHVersionDownloadManager sharedVersionManager] isAppVersionOutdated] == YES) {
        [self showAppVersionOutdatedAlert];
    } else if ([self connectionIsReachable]) {
        [self.checkBooksButton setEnabled:NO];
    
        checkBooksAlert = [[LambdaAlert alloc]
                           initWithTitle:NSLocalizedString(@"Syncing with Your Account", @"")
                           message:@"\n\n\n"];   
        
        SCHSettingsViewController *weakSelf = self;
        LambdaAlert *weakAlert = checkBooksAlert;
        [checkBooksAlert addButtonWithTitle:@"Cancel" block:^{
            [weakSelf deregisterForSyncNotifications];
            [weakAlert dismissAnimated:YES];
            if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] != NO) {
                [weakSelf.checkBooksButton setEnabled:YES];
            }
        }];
        
        [checkBooksAlert setSpinnerHidden:NO];
        [checkBooksAlert show];
        
        if ([[SCHSyncManager sharedSyncManager] isSuspended]) {
            double delayInSeconds = 2.0;
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
                [self showAlertForSyncFailure];
            });
        } else {
            [self registerForSyncNotifications];
            [[SCHSyncManager sharedSyncManager] flushSyncQueue];
            [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:YES];
        }
        
    } else {
        [self showNoInternetConnectionAlert];
    }    
}

- (IBAction)downloadDictionary:(id)sender
{
    SCHDictionaryProcessingState dictionaryState = [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState];
    
    if ([[SCHVersionDownloadManager sharedVersionManager] isAppVersionOutdated] == YES) {
        [self showAppVersionOutdatedAlert];
    } else if (dictionaryState == SCHDictionaryProcessingStateReady) {
        SCHRemoveDictionaryViewController *vc = [[SCHRemoveDictionaryViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else if (dictionaryState == SCHDictionaryProcessingStateError ||
               dictionaryState == SCHDictionaryProcessingStateUnexpectedConnectivityFailureError) {

        [[SCHDictionaryDownloadManager sharedDownloadManager] beginDictionaryDownload];
    } else {
        if ([[SCHDictionaryDownloadManager sharedDownloadManager] wifiAvailable]) {
        
            SCHDownloadDictionaryFromSettingsViewController *downloadController = [[SCHDownloadDictionaryFromSettingsViewController alloc] initWithNibName:nil bundle:nil];
            
            __block SCHSettingsViewController *weakSelf = self;
            
            downloadController.completion = ^{
                [weakSelf back:nil];
            };

            [self.navigationController pushViewController:downloadController animated:YES];
            [downloadController release];
            
        } else {
            [self showWifiRequiredAlert];
        }
    }
}

#endif

- (void)replaceCheckBooksAlertWithAlert:(LambdaAlert *)alert
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    
    [self.checkBooksAlert setSpinnerHidden:YES];
    [self.checkBooksAlert dismissAnimated:NO];
    self.checkBooksAlert = nil;
    
    [alert show];
    
    [CATransaction commit];

}

- (void)showAlertForSyncFailure
{
    if (self.checkBooksAlert) {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Sync Failed", @"")
                              message:NSLocalizedString(@"There was a problem while checking for new eBooks. Please try again.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] != NO) {
                //[self.checkBooksButton setEnabled:YES];
            }
        }];
        
        [self replaceCheckBooksAlertWithAlert:alert];
        [alert release];  
    } else {
        if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] != NO) {
           // [self.checkBooksButton setEnabled:YES];
        }
    }
}

#pragma mark - notifications

- (void)registerForSyncNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didCompleteSync:)
                                                 name:SCHBookshelfSyncComponentDidCompleteNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateAccountDuringSync:)
                                                 name:SCHContentSyncComponentDidAddBookToProfileNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailSync:)
                                                 name:SCHProfileSyncComponentDidFailNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailSync:)
                                                 name:SCHBookshelfSyncComponentDidFailNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailSync:)
                                                 name:SCHContentSyncComponentDidFailNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailSync:)
                                                 name:SCHAnnotationSyncComponentDidFailNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailSync:)
                                                 name:SCHReadingStatsSyncComponentDidFailNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailSync:)
                                                 name:SCHSettingsSyncComponentDidFailNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailSync:)
                                                 name:SCHSyncComponentDidFailAuthenticationNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didEnterBackground:) 
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    self.syncReachability = [Reachability reachabilityForInternetConnection];
    [self.syncReachability startNotifier];
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                                  selector:@selector(syncReachabilityChanged:) 
                                                      name:kReachabilityChangedNotification 
                                                    object:nil];
    
}

- (void)deregisterForSyncNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:SCHBookshelfSyncComponentDidCompleteNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:SCHContentSyncComponentDidAddBookToProfileNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:SCHProfileSyncComponentDidFailNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SCHBookshelfSyncComponentDidFailNotification
                                                  object:nil]; 
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SCHContentSyncComponentDidFailNotification
                                                  object:nil]; 
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SCHAnnotationSyncComponentDidFailNotification
                                                  object:nil]; 
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SCHReadingStatsSyncComponentDidFailNotification
                                                  object:nil]; 
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SCHSettingsSyncComponentDidFailNotification
                                                  object:nil]; 
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SCHSyncComponentDidFailAuthenticationNotification
                                                  object:nil]; 
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                 name:UIApplicationDidEnterBackgroundNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                 name:kReachabilityChangedNotification 
                                               object:nil];
    
    [self.syncReachability stopNotifier];
    self.syncReachability = nil;

}

- (void)didEnterBackground:(NSNotification *)note
{
    if (self.checkBooksAlert) {
        [self.checkBooksAlert dismissAnimated:NO];
    }
}

- (void)dictionaryStateChanged:(NSNotification *)note
{
    [self updateDictionaryButton];
}

- (void)didUpdateAccountDuringSync:(NSNotification *)note
{
    [self deregisterForSyncNotifications];
    
    if (self.checkBooksAlert) {
        NSString *message = NSLocalizedString(@"You have new eBooks! Go to your bookshelves to download and read the new eBooks.", @"");
        
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Sync Complete", @"")
                              message:message];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] != NO) {
               // [self.checkBooksButton setEnabled:YES];
            }
        }];
        
        [self replaceCheckBooksAlertWithAlert:alert];
        [alert release];  
    } else {
        if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] != NO) {
          //  [self.checkBooksButton setEnabled:YES];
        }
    }
    
    [self deregisterForSyncNotifications];
}

- (void)didFailSync:(NSNotification *)note
{
    [self deregisterForSyncNotifications];
    [self showAlertForSyncFailure];
}

- (void)didCompleteSync:(NSNotification *)note
{
    [self deregisterForSyncNotifications];
        
    if (self.checkBooksAlert) {
                
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Sync Complete", @"")
                              message:NSLocalizedString(@"No new eBooks have been assigned to any of your bookshelves.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] != NO) {
                //[self.checkBooksButton setEnabled:YES];
            }
        }];
        
        [self replaceCheckBooksAlertWithAlert:alert];
        [alert release];   
        
    } else {
        if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] != NO) {
           // [self.checkBooksButton setEnabled:YES];
        }
    }
}

- (void)syncReachabilityChanged:(NSNotification *)note
{
    if (![self.syncReachability isReachableViaWWAN]) {
        [self deregisterForSyncNotifications];
        [self showAlertForSyncFailure];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
    if ([self.bookUpdates areBookUpdatesAvailable]) {
        return 3;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return 1;
            break;
        case 1:
            return self.additionalSettingsVisible ? 4 : 1;
            break;
        case 2:
            return 1;
            break;
        default:
            return 0;
            break;
    }
}


- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const CellIdentifier = @"Cell";
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    cell.indentationLevel = 0;
    cell.imageView.image = nil;
    
    UIColor *blueText  = [UIColor colorWithRed:0.059 green:0.392 blue:0.596 alpha:1.000];
    UIColor *darkText  = [UIColor colorWithWhite:0.353 alpha:1.000];
    UIColor *lightText = [UIColor colorWithWhite:1 alpha:1.000];
    UIColor *redText   = [UIColor colorWithRed:0.792 green:0.071 blue:0.208 alpha:1.000];
    UIImage *selectedImage = [UIImage imageNamed:@"cloud_icon_menu_wht"];
    
    SCHSettingsPanel panel = [self panelForIndexPath:indexPath];
    BOOL isSelected = (panel == self.selectedPanel);
    
    switch (panel) {
        case kSCHSettingsPanelReadingManager:
            cell.textLabel.text = @"SIGN IN TO\nREADING MANAGER";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
            cell.textLabel.textColor = blueText;
            cell.textLabel.numberOfLines = 2;
            break;
        case kSCHSettingsPanelAdditionalSettings:
            cell.textLabel.text = @"ADDITIONAL SETTINGS";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
            cell.textLabel.textColor = blueText;
            break;
        case kSCHSettingsPanelDictionaryDownload:
            cell.textLabel.text = @"Download Dictionary";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
            if (isSelected) {
                cell.textLabel.textColor = lightText;
                cell.imageView.image = selectedImage;
                cell.indentationLevel = 0;
            } else {
                cell.textLabel.textColor = darkText;
                cell.imageView.image = nil;
                cell.indentationLevel = 1;
            }
            break;
        case kSCHSettingsPanelDeregisterDevice:
            cell.textLabel.text = @"Deregister Device";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
            if (isSelected) {
                cell.textLabel.textColor = lightText;
                cell.imageView.image = selectedImage;
                cell.indentationLevel = 0;
            } else {
                cell.textLabel.textColor = darkText;
                cell.imageView.image = nil;
                cell.indentationLevel = 1;
            }
            break;
        case kSCHSettingsPanelSupport:
            cell.textLabel.text = @"Support";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:12];
            if (isSelected) {
                cell.textLabel.textColor = lightText;
                cell.imageView.image = selectedImage;
                cell.indentationLevel = 0;
            } else {
                cell.textLabel.textColor = darkText;
                cell.imageView.image = nil;
                cell.indentationLevel = 1;
            }
            break;
        case kSCHSettingsPanelEbookUpdates:
            cell.textLabel.text = @"EBOOK UPDATES";
            cell.textLabel.font = [UIFont boldSystemFontOfSize:13];
            cell.textLabel.textColor = redText;
            break;
        default:
            break;
    }
    
    cell.backgroundView = [self backgroundViewForCellAtIndexPath:indexPath withSelection:[self indexPathForPanel:self.selectedPanel]];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat ret = 0;
    
    SCHSettingsPanel panel = [self panelForIndexPath:indexPath];
    switch (panel) {
        case kSCHSettingsPanelReadingManager:
            ret = 61;
            break;
        case kSCHSettingsPanelAdditionalSettings:
        case kSCHSettingsPanelDictionaryDelete:
        case kSCHSettingsPanelDeregisterDevice:
        case kSCHSettingsPanelDictionaryDownload:
            ret = 42;
            break;
        case kSCHSettingsPanelSupport:
            ret = 44;
            break;
        case kSCHSettingsPanelEbookUpdates:
            ret = 43;
            break;
        default:
            break;
    }
    
    return ret;
}

- (UIView *)backgroundViewForCellAtIndexPath:(NSIndexPath *)indexPath withSelection:(NSIndexPath *)selectedIndexPath
{
    SCHSettingsPanel panel = [self panelForIndexPath:indexPath];
    BOOL sectionIsSelected = ([indexPath section] == [selectedIndexPath section]);
    BOOL panelIsSelected   = [indexPath isEqual:selectedIndexPath];
        
    UIImage *stretchableImage = nil;
    
    if (panelIsSelected) {
        switch (panel) {
            case kSCHSettingsPanelReadingManager:
                stretchableImage = [UIImage imageNamed:@"lg_menu_selector_box_wht_3part"];
                break;
            case kSCHSettingsPanelAdditionalSettings:
                if (self.additionalSettingsVisible) {
                    stretchableImage = [UIImage imageNamed:@"top_menu_selector_box_wht_3part"];
                } else {
                    stretchableImage = [UIImage imageNamed:@"sm_menu_selector_box_wht_3part"];
                }
                break;
            case kSCHSettingsPanelDictionaryDelete:
            case kSCHSettingsPanelDictionaryDownload:
            case kSCHSettingsPanelDeregisterDevice:
                stretchableImage = [UIImage imageNamed:@"mid_menu_selector_box_selected_3part"];
                break;
            case kSCHSettingsPanelSupport:
                stretchableImage = [UIImage imageNamed:@"bottom_menu_selector_box_selected_3part"];
                break;
            case kSCHSettingsPanelEbookUpdates:
                stretchableImage = [UIImage imageNamed:@"sm_menu_selector_box_wht_3part"];
                break;
            default:
                break;
        }
    } else if (sectionIsSelected) {
        switch (panel) {
            case kSCHSettingsPanelAdditionalSettings:
                if (self.additionalSettingsVisible) {
                    stretchableImage = [UIImage imageNamed:@"top_menu_selector_box_wht_3part"];
                } else {
                    stretchableImage = [UIImage imageNamed:@"sm_menu_selector_box_wht_3part"];
                }
                break;
            case kSCHSettingsPanelDictionaryDelete:
            case kSCHSettingsPanelDictionaryDownload:
                stretchableImage = [UIImage imageNamed:@"mid_menu_selector_box_gry_3part"];
                break;
            case kSCHSettingsPanelDeregisterDevice:
                if (sectionIsSelected && ([selectedIndexPath row] == [indexPath row] - 1)) {
                    stretchableImage = [UIImage imageNamed:@"mid_menu_selector_box_gry_3part"];
                } else {
                    stretchableImage = [UIImage imageNamed:@"mid_menu_selector_box_wht_3part"];
                }
                break;
            case kSCHSettingsPanelSupport:
                stretchableImage = [UIImage imageNamed:@"bottom_menu_selector_box_gry_3part"];
                break;
            default:
                break;
        }
    }
        
    if (stretchableImage) {
         UIImage *backgroundImage = [stretchableImage stretchableImageWithLeftCapWidth:13 topCapHeight:0];
         return [[[UIImageView alloc] initWithImage:backgroundImage] autorelease];
    } else {
        UIView *plain = [[UIView alloc] init];
        plain.backgroundColor = [UIColor whiteColor];
        return [plain autorelease];
    }
}

- (void)setAdditionalSettingsVisible:(BOOL)visible
{
    [self setAdditionalSettingsVisible:visible completionBlock:nil];
}

- (void)setAdditionalSettingsVisible:(BOOL)visible completionBlock:(dispatch_block_t)completion
{
    if (additionalSettingsVisible != visible) {
        additionalSettingsVisible = visible;
        [CATransaction begin];
        [CATransaction setCompletionBlock:^{
            if (completion) {
                completion();
            }
        }];
        if (additionalSettingsVisible) {
            [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:1],
                                                    [NSIndexPath indexPathForRow:2 inSection:1],
                                                    [NSIndexPath indexPathForRow:3 inSection:1], nil]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
            
        } else {
            [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObjects:[NSIndexPath indexPathForRow:1 inSection:1],
                                                    [NSIndexPath indexPathForRow:2 inSection:1],
                                                    [NSIndexPath indexPathForRow:3 inSection:1], nil]
                                  withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [CATransaction commit];
    }
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:NO];
    SCHSettingsPanel panel = [self panelForIndexPath:indexPath];
    
    if (panel == kSCHSettingsPanelAdditionalSettings) {
        if (!self.additionalSettingsVisible) {
            [self setSelectedPanel:kSCHSettingsPanelAdditionalSettings];
            [self setAdditionalSettingsVisible:YES completionBlock:^{
                [self displaySettingsPanel:panel];
            }];
        }
    } else if ([indexPath section] != [[self indexPathForPanel:kSCHSettingsPanelAdditionalSettings] section]) {
        [self displaySettingsPanel:panel];
        [self setAdditionalSettingsVisible:NO];
    } else {
        [self displaySettingsPanel:panel];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.settingsDisplayMask == kSCHSettingsPanelAll) {
        cell.alpha = 1;
    } else {
        SCHSettingsPanel panel = [self panelForIndexPath:indexPath];
        if (self.settingsDisplayMask & panel) {
            cell.alpha = 1;
        } else {
            cell.alpha = 0;
        }
    }
}

- (SCHSettingsPanel)panelForIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0:
            return kSCHSettingsPanelReadingManager;
            break;
        case 1: {
            switch ([indexPath row]) {
                case 0:
                    return kSCHSettingsPanelAdditionalSettings;
                    break;
                case 1:
                    if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] == SCHDictionaryProcessingStateReady) {
                        return kSCHSettingsPanelDictionaryDelete;
                    } else {
                        return kSCHSettingsPanelDictionaryDownload;
                    }
                    break;
                case 2:
                    return kSCHSettingsPanelDeregisterDevice;
                    break;
                case 3:
                    return kSCHSettingsPanelSupport;
                    break;
                default:
                    break;
            }
            break;
        }
        case 2:
            return kSCHSettingsPanelEbookUpdates;
            break;
        default:
            break;
    }
    
    return -1;
}
    
- (NSIndexPath *)indexPathForPanel:(SCHSettingsPanel)panel
{
    switch (panel) {
        case kSCHSettingsPanelReadingManager:
            return [NSIndexPath indexPathForRow:0 inSection:0];
            break;
        case kSCHSettingsPanelAdditionalSettings:
            return [NSIndexPath indexPathForRow:0 inSection:1];
            break;
        case kSCHSettingsPanelDictionaryDelete:
        case kSCHSettingsPanelDictionaryDownload:
            return [NSIndexPath indexPathForRow:1 inSection:1];
            break;
        case kSCHSettingsPanelDeregisterDevice:
            return [NSIndexPath indexPathForRow:2 inSection:1];
            break;
        case kSCHSettingsPanelSupport:
            return [NSIndexPath indexPathForRow:3 inSection:1];
            break;
        case kSCHSettingsPanelEbookUpdates:
            return [NSIndexPath indexPathForRow:0 inSection:2];
            break;
        default:
            break;
    }
    
    return nil;
}

- (void)displaySettingsPanel:(SCHSettingsPanel)panel
{
    [self.view endEditing:YES];
        
    switch (panel) {
        case kSCHSettingsPanelReadingManager: {
            SCHReadingManagerAuthorisationViewController *controller = [[[SCHReadingManagerAuthorisationViewController alloc] init] autorelease];
            controller.appController = self.appController;
            self.contentViewController = controller;
        } break;
        case kSCHSettingsPanelDictionaryDownload: {
            SCHDownloadDictionaryViewController *controller = [[[SCHDownloadDictionaryViewController alloc] init] autorelease];
            self.contentViewController = controller;
        } break;
        case kSCHSettingsPanelDictionaryDelete: {
            SCHRemoveDictionaryViewController *controller = [[[SCHRemoveDictionaryViewController alloc] init] autorelease];
            self.contentViewController = controller;
        } break;
        case kSCHSettingsPanelDeregisterDevice: {
            SCHDeregisterDeviceViewController *controller = [[[SCHDeregisterDeviceViewController alloc] init] autorelease];
            controller.appController = self.appController;
            self.contentViewController = controller;
        } break;
        case kSCHSettingsPanelSupport: {
            SCHSupportViewController *controller = [[[SCHSupportViewController alloc] init] autorelease];
            self.contentViewController = controller;
        } break;
        case kSCHSettingsPanelEbookUpdates: {
            SCHUpdateBooksViewController *controller = [[[SCHUpdateBooksViewController alloc] init] autorelease];
            self.contentViewController = controller;
        } break;
        default:
            break;
    }
    
    [self addContentSubview:self.contentViewController.view];
    [self setSelectedPanel:panel];
}

- (IBAction)close:(id)sender
{
    [self.appController presentProfiles];
}

- (void)addContentSubview:(UIView *)newContentView
{
    for (UIView *view in [self.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    if (newContentView && self.contentView) {
        newContentView.frame = self.contentView.bounds;
        [self.contentView addSubview:newContentView];
    }
}

#pragma mark - Keyboard

- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)deregisterForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{    
    NSDictionary *info = [notification userInfo];
    NSNumber *duration = [info valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [info valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    self.transformableView.transform = CGAffineTransformMakeTranslation(0, -(self.transformableView.frame.origin.y));
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{

    NSDictionary *info = [notification userInfo];
    NSNumber *duration = [info valueForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSNumber *curve = [info valueForKey:UIKeyboardAnimationCurveUserInfoKey];
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:[duration doubleValue]];
    [UIView setAnimationCurve:[curve intValue]];
    self.transformableView.transform = CGAffineTransformIdentity;
    [UIView commitAnimations];
}

@end

