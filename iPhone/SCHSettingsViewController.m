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
#import "SCHBookshelfSyncComponent.h"
#import "SCHContentSyncComponent.h"
#import "SCHCoreDataHelper.h"
#import "SCHUserDefaults.h"
#import "SCHAppStateManager.h"
#import "SCHSyncManager.h"
#import "Reachability.h"
#import "LambdaAlert.h"
#import "SCHParentalToolsWebViewController.h"
#import "SCHAuthenticationManager.h"
#import "SCHAccountValidationViewController.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

@interface SCHSettingsViewController()

@property (nonatomic, retain) SCHBookUpdates *bookUpdates;
@property (nonatomic, retain) SCHUpdateBooksViewController *updateBooksViewController;
@property (nonatomic, retain) LambdaAlert *checkBooksAlert;

- (void)updateSpaceSaverButton;
- (void)updateUpdateBooksButton;
- (void)updateDictionaryButton;
- (void)releaseViewObjects;
- (void)replaceCheckBooksAlertWithAlert:(LambdaAlert *)alert;

@end

@implementation SCHSettingsViewController

@synthesize scrollView;
@synthesize manageBooksGroupView;
@synthesize checkBooksButton;
@synthesize manageBooksButton;
@synthesize updateBooksButton;
@synthesize deregisterDeviceButton;
@synthesize downloadDictionaryButton;
@synthesize spaceSaverButton;
@synthesize bookUpdates;
@synthesize updateBooksViewController;
@synthesize managedObjectContext;
@synthesize checkBooksAlert;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [scrollView release], scrollView = nil;
    [manageBooksGroupView release], manageBooksGroupView = nil;
    [checkBooksButton release], checkBooksButton = nil;
    [manageBooksButton release], manageBooksButton = nil;
    [updateBooksButton release], updateBooksButton = nil;
    [deregisterDeviceButton release], deregisterDeviceButton = nil;
    [downloadDictionaryButton release], downloadDictionaryButton = nil;
    [spaceSaverButton release], spaceSaverButton = nil;
    [updateBooksViewController release], updateBooksViewController = nil;
    [checkBooksAlert release], checkBooksAlert = nil;
    [super releaseViewObjects];
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [bookUpdates release], bookUpdates = nil;
	[managedObjectContext release], managedObjectContext = nil;
    
    [self releaseViewObjects];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    NSAssert(self.managedObjectContext != nil, @"must set managedObjectContext before loading view");
    bookUpdates = [[SCHBookUpdates alloc] init];
    bookUpdates.managedObjectContext = self.managedObjectContext;
    
    updateBooksViewController = [[SCHUpdateBooksViewController alloc] init];
    updateBooksViewController.bookUpdates = bookUpdates;

    [self.scrollView setContentSize:CGSizeMake(320, 416)];
    [self.manageBooksGroupView.layer setBorderColor:[UIColor SCHGray2Color].CGColor];
    [self.manageBooksGroupView.layer setBorderWidth:2];
    [self.manageBooksGroupView.layer setCornerRadius:15];
    [self.manageBooksGroupView.layer setOpacity:0.66f];
    
    [self setButtonBackground:self.checkBooksButton];
    [self setButtonBackground:self.manageBooksButton];
    [self setButtonBackground:self.updateBooksButton];
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
                                             selector:@selector(didCompleteSync:)
                                                 name:SCHBookshelfSyncComponentDidCompleteNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didUpdateAccountDuringSync:)
                                                 name:SCHContentSyncComponentDidAddBookToProfileNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didFailSync:)
                                                 name:SCHBookshelfSyncComponentDidFailNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(dictionaryStateChanged:)
                                                 name:kSCHDictionaryStateChange
                                               object:nil];
    
    if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] == NO) {
        [self.manageBooksButton setEnabled:NO];
        [self.checkBooksButton setEnabled:NO];
    }
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
    [self updateUpdateBooksButton];
    [self updateDictionaryButton];
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

- (void)updateUpdateBooksButton
{
    self.updateBooksButton.enabled = [self.bookUpdates areBookUpdatesAvailable];
    
    if (self.updateBooksButton.enabled == YES) {
        [self.updateBooksButton setTitle:NSLocalizedString(@"Update my Current eBooks", @"Update my Current eBooks") forState:UIControlStateNormal];
        [self.updateBooksButton setImage:[UIImage imageNamed:@"update-icon"] forState:UIControlStateNormal];
    } else {
        [self.updateBooksButton setTitle:NSLocalizedString(@"No eBook Updates Available", @"No eBook Updates Available") forState:UIControlStateNormal];        
        [self.updateBooksButton setImage:nil forState:UIControlStateNormal];        
    }
}

- (void)updateDictionaryButton
{
    SCHDictionaryProcessingState state = [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState];
    self.downloadDictionaryButton.enabled = (state == SCHDictionaryProcessingStateUserSetup
                                             || state == SCHDictionaryProcessingStateUserDeclined
                                             || state == SCHDictionaryProcessingStateReady);
    
    switch (state) {
        case SCHDictionaryProcessingStateReady:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Remove Dictionary", @"remove dictionary button title")
                                           forState:UIControlStateNormal];

            break;
        case SCHDictionaryProcessingStateNeedsManifest:
        case SCHDictionaryProcessingStateManifestVersionCheck:
        case SCHDictionaryProcessingStateNeedsDownload:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Downloading Dictionary...", @"Downloading dictionary button title")
                                           forState:UIControlStateNormal];
            break;
        case SCHDictionaryProcessingStateNeedsUnzip:
        case SCHDictionaryProcessingStateNeedsParse:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Processing Dictionary...", @"Processing dictionary button title")
                                           forState:UIControlStateNormal];
            break;
        case SCHDictionaryProcessingStateDeleting:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Deleting Dictionary...", @"Deleting dictionary button title")
                                           forState:UIControlStateNormal];
            break;            
        default:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Download Dictionary", @"download dictionary button title")
                                           forState:UIControlStateNormal];

            break;
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
    SCHDeregisterDeviceViewController *vc = [[SCHDeregisterDeviceViewController alloc] init];
    vc.settingsDelegate = self.settingsDelegate;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
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
        [mfViewController setToRecipients:[NSArray arrayWithObject:@"support@scholastic.com"]];
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

- (IBAction)manageBooks:(id)sender
{
    if ([[SCHAuthenticationManager sharedAuthenticationManager] hasValidPToken] == YES) {
        SCHParentalToolsWebViewController *parentalToolsWebViewController = [[[SCHParentalToolsWebViewController alloc] init] autorelease];
        [self.navigationController pushViewController:parentalToolsWebViewController animated:YES];
    } else {
        SCHAccountValidationViewController *accountValidationViewController = [[[SCHAccountValidationViewController alloc] init] autorelease];
        [self.navigationController pushViewController:accountValidationViewController animated:YES];        
    }
}

- (IBAction)checkBooks:(id)sender
{
    
    [self.checkBooksButton setEnabled:NO];
    
    if ([[Reachability reachabilityForInternetConnection] isReachable] == NO) {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"No Internet Connection", @"")
                              message:NSLocalizedString(@"This function requires an Internet connection. Please connect to the internet and then try again.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            if ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] != NO) {
                [self.checkBooksButton setEnabled:YES];
            }
        }];
        [alert show];
        [alert release];                
    } else {
        checkBooksAlert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Syncing with Your Account", @"")
                              message:@"\n"];
        [checkBooksAlert setSpinnerHidden:NO];
        [checkBooksAlert show];

        [[SCHSyncManager sharedSyncManager] firstSync:YES];      
    }
    
}

- (IBAction)updateBooks:(id)sender
{
    [self.navigationController pushViewController:updateBooksViewController animated:YES];
}

- (IBAction)toggleSpaceSaverMode:(id)sender
{
    NSNumber *spaceSaver = [[NSUserDefaults standardUserDefaults] objectForKey:kSCHUserDefaultsSpaceSaverMode];
    BOOL toggledSpaceSaver = ![spaceSaver boolValue];
        
    [[NSUserDefaults standardUserDefaults] setBool:toggledSpaceSaver forKey:kSCHUserDefaultsSpaceSaverMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    if (toggledSpaceSaver) {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Space Saver On", @"")
                              message:NSLocalizedString(@"New eBooks will not be downloaded until someone chooses to read them. This can save storage space on your device.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            [self updateSpaceSaverButton];
        }];
        [alert show];
        [alert release]; 
    } else {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Space Saver Off", @"")
                              message:NSLocalizedString(@"New eBooks will be downloaded immediately when they are assigned to a bookshelf.", @"")];
        [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            [self updateSpaceSaverButton];
        }];
        [alert show];
        [alert release]; 
    }
}

- (IBAction)downloadDictionary:(id)sender
{
    if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] == SCHDictionaryProcessingStateReady) {
        SCHRemoveDictionaryViewController *vc = [[SCHRemoveDictionaryViewController alloc] init];
        [self.navigationController pushViewController:vc animated:YES];
        [vc release];
    } else {
        [[SCHDictionaryDownloadManager sharedDownloadManager] beginDictionaryDownload];
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

#pragma mark - notifications

- (void)dictionaryStateChanged:(NSNotification *)note
{
    [self updateDictionaryButton];
}

- (void)didUpdateAccountDuringSync:(NSNotification *)note
{
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
}

- (void)didFailSync:(NSNotification *)note
{
    if (self.checkBooksAlert) {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Sync Failed", @"")
                              message:NSLocalizedString(@"There was a problem whilst checking for new eBooks. Please try again.", @"")];
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

- (void)didCompleteSync:(NSNotification *)note
{
    [self updateUpdateBooksButton];
    
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

@end

