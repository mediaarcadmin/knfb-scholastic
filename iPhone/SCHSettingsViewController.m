//
//  SCHSettingsViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSettingsViewController.h"
#import "SCHSetupDelegate.h"
#import "SCHLoginPasswordViewController.h"
#import "SCHCustomNavigationBar.h"
#import "SCHCustomToolbar.h"
#import "SCHURLManager.h"
#import "SCHSyncManager.h"
#import "SCHAboutViewController.h"
#import "SCHPrivacyPolicyViewController.h"
#import "SCHProcessingManager.h"
#import "SCHDictionaryDownloadManager.h"
#import "SCHRemoveDictionaryViewController.h"
#import "AppDelegate_Shared.h"
#import "SCHDeregisterDeviceViewController.h"
#import "SCHCheckbox.h"
#import "SCHBookUpdates.h"
#import "SCHUpdateBooksViewController.h"
#import "SCHBookshelfSyncComponent.h"
#import "SCHCoreDataHelper.h"
#import "SCHUserDefaults.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

@interface SCHSettingsViewController()

@property (nonatomic, retain) SCHBookUpdates *bookUpdates;
@property (nonatomic, retain) SCHUpdateBooksViewController *updateBooksViewController;

- (void)updateUpdateBooksButton;
- (void)updateDictionaryButton;
- (void)releaseViewObjects;
- (void)resetLocalSettings;

@end

@implementation SCHSettingsViewController

@synthesize scrollView;
@synthesize manageBooksButton;
@synthesize updateBooksButton;
@synthesize deregisterDeviceButton;
@synthesize downloadDictionaryButton;
@synthesize spaceSaverSwitch;
@synthesize bookUpdates;
@synthesize updateBooksViewController;
@synthesize managedObjectContext;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [scrollView release], scrollView = nil;
    [manageBooksButton release], manageBooksButton = nil;
    [updateBooksButton release], updateBooksButton = nil;
    [deregisterDeviceButton release], deregisterDeviceButton = nil;
    [downloadDictionaryButton release], downloadDictionaryButton = nil;
    [spaceSaverSwitch release], spaceSaverSwitch = nil;
    [updateBooksViewController release], updateBooksViewController = nil;
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

    [self setButtonBackground:self.manageBooksButton];
    [self setButtonBackground:self.updateBooksButton];
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
                                             selector:@selector(dictionaryStateChanged:)
                                                 name:kSCHDictionaryStateChange
                                               object:nil];
    
#if LOCALDEBUG
    [self.manageBooksButton setEnabled:NO];
    [self.deregisterDeviceButton setTitle:@"Reset Content and Settings" forState:UIControlStateNormal];
#endif
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    NSNumber *spaceSaver = [[NSUserDefaults standardUserDefaults] objectForKey:kSCHUserDefaultsSpaceSaverMode];
    self.spaceSaverSwitch.selected = [spaceSaver boolValue];
    
    [self updateUpdateBooksButton];
    [self updateDictionaryButton];
}

#pragma mark - Button states

- (void)updateUpdateBooksButton
{
    self.updateBooksButton.enabled = [self.bookUpdates areBookUpdatesAvailable];
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
        default:
            [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Download Dictionary", @"download dictionary button title")
                                           forState:UIControlStateNormal];

            break;
    }
}

#pragma mark - Dismissal

- (IBAction)dismissModalSettingsController:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.spaceSaverSwitch.selected forKey:kSCHUserDefaultsSpaceSaverMode];
    [[NSUserDefaults standardUserDefaults] synchronize];
    [super closeSettings];
}

#pragma mark - Actions

- (IBAction)deregisterDevice:(id)sender 
{
#if LOCALDEBUG
    [self resetLocalSettings];
    [self.setupDelegate dismissSettingsForm];
#else
    SCHDeregisterDeviceViewController *vc = [[SCHDeregisterDeviceViewController alloc] init];
    vc.setupDelegate = self.setupDelegate;
    [self.navigationController pushViewController:vc animated:YES];
    [vc release];
#endif
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
    // TODO correct URL
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.scholastic.com"]];
}

- (IBAction)updateBooks:(id)sender
{
    [self.navigationController pushViewController:updateBooksViewController animated:YES];
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

#pragma mark - Local settings

- (void)resetLocalSettings
{
    [NSUserDefaults resetStandardUserDefaults];
    [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUserSetup];
    
#if LOCALDEBUG
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
    [appDelegate.coreDataHelper clearDatabase];
#endif
}

#pragma mark - notifications

- (void)dictionaryStateChanged:(NSNotification *)note
{
    [self updateDictionaryButton];
}

- (void)didCompleteSync:(NSNotification *)note
{
    [self updateUpdateBooksButton];
}

@end

