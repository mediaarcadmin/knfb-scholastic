//
//  SCHSettingsViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSettingsViewController.h"

#import "SCHAboutViewController.h"
#import "SCHPrivacyPolicyViewController.h"
#import "SCHDictionaryDownloadManager.h"
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
#import "SCHAccountValidationViewController.h"
#import "SCHVersionDownloadManager.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;
extern NSString * const kSCHUserDefaultsSpaceSaverModeSetOffNotification;

@interface SCHSettingsViewController()

@property (nonatomic, retain) SCHBookUpdates *bookUpdates;
@property (nonatomic, retain) SCHUpdateBooksViewController *updateBooksViewController;
@property (nonatomic, retain) LambdaAlert *checkBooksAlert;
@property (nonatomic, retain) Reachability *syncReachability;

- (void)updateSpaceSaverButton;
- (void)updateDictionaryButton;
- (void)releaseViewObjects;
- (void)replaceCheckBooksAlertWithAlert:(LambdaAlert *)alert;
- (void)registerForSyncNotifications;
- (void)deregisterForSyncNotifications;
- (BOOL)connectionIsReachable;
- (BOOL)connectionIsReachableViaWiFi;
- (BOOL)isAppVersionOutdated;
- (void)showAppVersionOutdatedAlert;
- (void)showNoInternetConnectionAlert;
- (void)showAlertForSyncFailure;

@end

@implementation SCHSettingsViewController

@synthesize scrollView;
@synthesize manageBooksGroupView;
@synthesize checkBooksButton;
@synthesize manageBooksButton;
@synthesize deregisterDeviceButton;
@synthesize downloadDictionaryButton;
@synthesize spaceSaverButton;
@synthesize bookUpdates;
@synthesize updateBooksViewController;
@synthesize managedObjectContext;
@synthesize checkBooksAlert;
@synthesize syncReachability;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    [scrollView release], scrollView = nil;
    [manageBooksGroupView release], manageBooksGroupView = nil;
    [checkBooksButton release], checkBooksButton = nil;
    [manageBooksButton release], manageBooksButton = nil;
    [deregisterDeviceButton release], deregisterDeviceButton = nil;
    [downloadDictionaryButton release], downloadDictionaryButton = nil;
    [spaceSaverButton release], spaceSaverButton = nil;
    [updateBooksViewController release], updateBooksViewController = nil;
    [checkBooksAlert release], checkBooksAlert = nil;
    
    [super releaseViewObjects];
}

- (void)dealloc 
{    
    [bookUpdates release], bookUpdates = nil;
	[managedObjectContext release], managedObjectContext = nil;
    [syncReachability release], syncReachability = nil;
    
    [self releaseViewObjects];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    [self.scrollView setContentSize:CGSizeMake(320, 416)];
    [self.manageBooksGroupView.layer setBorderColor:[UIColor SCHGray2Color].CGColor];
    [self.manageBooksGroupView.layer setBorderWidth:2];
    [self.manageBooksGroupView.layer setCornerRadius:15];
    [self.manageBooksGroupView.layer setOpacity:0.66f];
    
    [self setButtonBackground:self.checkBooksButton];
    [self setButtonBackground:self.manageBooksButton];
    [self setButtonBackground:self.spaceSaverButton];
    [self setButtonBackground:self.downloadDictionaryButton];
    [self setButtonBackground:self.deregisterDeviceButton];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationItem.title = NSLocalizedString(@"Back", @"");
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
        CGRect logoFrame = logoImageView.bounds;
        logoFrame.size.height = self.navigationController.navigationBar.frame.size.height;
        logoImageView.frame = logoFrame;
        logoImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin
                                          | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight
                                          | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin);
        logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationItem.titleView = logoImageView;
        [logoImageView release];
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

- (NSArray *)currentSettingsViewControllers
{
    NSArray *viewControllers = nil;
    
    if ([self.bookUpdates areBookUpdatesAvailable] &&
        [[Reachability reachabilityForInternetConnection] isReachable]) {
        viewControllers = [NSArray arrayWithObjects:self, self.updateBooksViewController, nil];
    } else {
        viewControllers = [NSArray arrayWithObject:self];
    }
    
    return viewControllers;
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

- (SCHUpdateBooksViewController *)updateBooksViewController
{
    if (!updateBooksViewController) {
        updateBooksViewController = [[SCHUpdateBooksViewController alloc] init];
        updateBooksViewController.bookUpdates = self.bookUpdates;
    }
    
    return updateBooksViewController;
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];    
    [self updateSpaceSaverButton];
    [self updateDictionaryButton];
    
    if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] == NO) {
        [self.manageBooksButton setEnabled:NO];
        [self.checkBooksButton setEnabled:NO];
    } else {
        [self.manageBooksButton setEnabled:YES];
        [self.checkBooksButton setEnabled:YES];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (self.checkBooksAlert) {
        [self.checkBooksAlert dismissAnimated:NO];
    }
}

#pragma mark - Button states

- (void)updateSpaceSaverButton
{
    NSNumber *spaceSaver = [[NSUserDefaults standardUserDefaults] objectForKey:kSCHUserDefaultsSpaceSaverMode];
    
    if ([spaceSaver boolValue] == YES) {
        [self.spaceSaverButton setTitle:NSLocalizedString(@"Turn Off Space Saver", @"Turn Off Space Saver") forState:UIControlStateNormal];
    } else {
        [self.spaceSaverButton setTitle:NSLocalizedString(@"Turn On Space Saver", @"Turn On Space Saver") forState:UIControlStateNormal];        
    }
}

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
    
    self.downloadDictionaryButton.enabled = enabled;
    self.downloadDictionaryButton.titleLabel.textAlignment = UITextAlignmentCenter;

    BOOL doubleLine = NO;

    switch (state) {
        case SCHDictionaryProcessingStateReady:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Remove Dictionary", @"remove dictionary button title")
                                           forState:UIControlStateNormal];

            break;
        case SCHDictionaryProcessingStateNeedsManifest:
        case SCHDictionaryProcessingStateManifestVersionCheck:
        case SCHDictionaryProcessingStateNeedsDownload:
        {
            if ([[SCHDictionaryDownloadManager sharedDownloadManager] wifiAvailable]) {
                NSUInteger progress = roundf([[SCHDictionaryDownloadManager sharedDownloadManager] currentDictionaryDownloadPercentage] * 100.0f);
                [self.downloadDictionaryButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Downloading Dictionary %d%%", @"Downloading dictionary button title"), 
                                                         progress]
                                               forState:UIControlStateNormal];
            } else {
                [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Download Paused.\nWaiting for WiFi...", @"Waiting for WiFi dictionary button title")
                                               forState:UIControlStateNormal];
                doubleLine = YES;
            }
            break;
        }
        case SCHDictionaryProcessingStateNeedsUnzip:
        case SCHDictionaryProcessingStateNeedsParse:
        {
            NSUInteger progress = roundf([[SCHDictionaryDownloadManager sharedDownloadManager] currentDictionaryProcessingPercentage] * 100.0f);
            [self.downloadDictionaryButton setTitle:[NSString stringWithFormat:NSLocalizedString(@"Processing Dictionary %d%%", @"Processing dictionary button title"), 
                                                     progress]
                                           forState:UIControlStateNormal];
            break;
        }
        case SCHDictionaryProcessingStateDeleting:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Deleting Dictionary...", @"Deleting dictionary button title")
                                           forState:UIControlStateNormal];
            break;   
        case SCHDictionaryProcessingStateError:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Error. Try Again.\nUnknown Error", @"Dictionary error button title for unknown error")
                                           forState:UIControlStateNormal];
            doubleLine = YES;
            break; 
        case SCHDictionaryProcessingStateUnexpectedConnectivityFailureError:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Error. Try Again.\nDownload Interrupted.", @"Dictionary error button title for connection interrupted")
                                           forState:UIControlStateNormal];
            doubleLine = YES;
            break; 
        case SCHDictionaryProcessingStateNotEnoughFreeSpaceError:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Error. Try Again.\nNot Enough Free Space.", @"Dictionary error button title for not enough free space")
                                           forState:UIControlStateNormal];
            doubleLine = YES;
            break; 
        case SCHDictionaryProcessingStateDownloadError:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Error. Try Again.\nDownload Failed.", @"Dictionary error button title for download failed")
                                           forState:UIControlStateNormal];
            doubleLine = YES;
            break; 
        case SCHDictionaryProcessingStateUnableToOpenZipError:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Error. Try Again.\nCouldn't Open Zip.", @"Dictionary error button title for Couldn't open zip")
                                           forState:UIControlStateNormal];
            doubleLine = YES;
            break; 
        case SCHDictionaryProcessingStateUnZipFailureError:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Error. Try Again.\nUnzip Failed. Check Disk Space.", @"Dictionary error button title for unzip failed")
                                           forState:UIControlStateNormal];
            doubleLine = YES;
            break; 
        case SCHDictionaryProcessingStateParseError:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Dictionary Error. Try Again.\nParse Failed.", @"Dictionary error button title for parser error")
                                           forState:UIControlStateNormal];
            doubleLine = YES;
            break;  
        case SCHDictionaryProcessingStateUserSetup:
        case SCHDictionaryProcessingStateUserDeclined:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Download Dictionary", @"download dictionary button title")
                                           forState:UIControlStateNormal];

            break;
    }
    
    if (doubleLine) {
        self.downloadDictionaryButton.titleLabel.lineBreakMode = UILineBreakModeWordWrap;

        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.downloadDictionaryButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:15.0f];
        } else {
            self.downloadDictionaryButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:14.0f];
        }
    } else {
        self.downloadDictionaryButton.titleLabel.lineBreakMode = UILineBreakModeTailTruncation; 
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.downloadDictionaryButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:18.0f];
        } else {
            self.downloadDictionaryButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:17.0f];
        }
    }
}

#pragma mark - Dismissal

- (IBAction)dismissModalSettingsController:(id)sender
{
    [self close];
}

#pragma mark - Actions

- (IBAction)deregisterDevice:(id)sender 
{
    if ([self isAppVersionOutdated] == YES) {
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
        [mfViewController setToRecipients:[NSArray arrayWithObject:@"ebooks@scholastic.com"]];
        [mfViewController setSubject:[NSString stringWithFormat:@"Scholastic v%@ Support Request", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]]];
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

#define MFMailComposeViewControllerDelegate

- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Scholastic Support Email", @"Support Email Alert title")
                                                    message:@""
                                                   delegate:nil 
                                          cancelButtonTitle:@"ok" 
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

- (BOOL)isAppVersionOutdated
{
    SCHVersionDownloadManagerAppVersionState appVersionState = [[SCHVersionDownloadManager sharedVersionManager] appVersionState];
    
    return (appVersionState == SCHVersionDownloadManagerAppVersionStateOutdated) || 
    (appVersionState == SCHVersionDownloadManagerAppVersionStateOutdatedRequiresForcedUpdate);
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

- (IBAction)manageBooks:(id)sender
{
    if ([self isAppVersionOutdated] == YES) {
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
    if ([self isAppVersionOutdated] == YES) {
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
        
        [self registerForSyncNotifications];
        
        [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:YES];      
    } else {
        [self showNoInternetConnectionAlert];
    }    
}

- (IBAction)toggleSpaceSaverMode:(id)sender
{
    NSNumber *spaceSaver = [[NSUserDefaults standardUserDefaults] objectForKey:kSCHUserDefaultsSpaceSaverMode];
    BOOL toggledSpaceSaver = ![spaceSaver boolValue];
        
    [[NSUserDefaults standardUserDefaults] setBool:toggledSpaceSaver forKey:kSCHUserDefaultsSpaceSaverMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (toggledSpaceSaver) {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Space Saver is On", @"")
                              message:NSLocalizedString(@"New eBooks will not be downloaded until someone chooses to read them. This can save storage space on your device and data transfer if using a mobile data plan.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            [self updateSpaceSaverButton];
        }];
        [alert show];
        [alert release];         
    } else {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Space Saver is Off", @"")
                              message:NSLocalizedString(@"New eBooks will be downloaded immediately when they are assigned to a bookshelf.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            [self updateSpaceSaverButton];
        }];
        [alert show];
        [alert release]; 
        
        [[NSNotificationCenter defaultCenter] postNotificationName:kSCHUserDefaultsSpaceSaverModeSetOffNotification object:nil userInfo:nil];
    }
}

- (IBAction)downloadDictionary:(id)sender
{
    if ([self isAppVersionOutdated] == YES) {
        [self showAppVersionOutdatedAlert];
    } else if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] == SCHDictionaryProcessingStateReady) {
        SCHRemoveDictionaryViewController *vc = [[SCHRemoveDictionaryViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else {
        if ([self connectionIsReachableViaWiFi] == YES) {
            [[SCHDictionaryDownloadManager sharedDownloadManager] beginDictionaryDownload];
        } else {
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"No WiFi", @"")
                                  message:NSLocalizedString(@"Downloading the dictionary requires a Wi-Fi connection. Please connect to Wi-Fi and then try again.", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
            [alert show];
            [alert release];
        }
    }
}

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
                [self.checkBooksButton setEnabled:YES];
            }
        }];
        
        [self replaceCheckBooksAlertWithAlert:alert];
        [alert release];  
    } else {
        if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] != NO) {
            [self.checkBooksButton setEnabled:YES];
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
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Sync Complete", @"")
                              message:NSLocalizedString(@"You have new eBooks! Go to your bookshelves to download and read the new eBooks.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] != NO) {
                [self.checkBooksButton setEnabled:YES];
            }
        }];
        
        [self replaceCheckBooksAlertWithAlert:alert];
        [alert release];  
    } else {
        if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] != NO) {
            [self.checkBooksButton setEnabled:YES];
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
                [self.checkBooksButton setEnabled:YES];
            }
        }];
        
        [self replaceCheckBooksAlertWithAlert:alert];
        [alert release];   
        
    } else {
        if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] != NO) {
            [self.checkBooksButton setEnabled:YES];
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

@end

