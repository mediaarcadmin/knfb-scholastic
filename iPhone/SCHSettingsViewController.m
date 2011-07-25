//
//  SCHSettingsViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSettingsViewController.h"
#import "SCHSettingsViewControllerDelegate.h"
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
#import "SCHUpdateBooksViewController.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

@interface SCHSettingsViewController()

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)updateDictionaryButton;
- (void)releaseViewObjects;
- (void)resetLocalSettings;

@end

@implementation SCHSettingsViewController

@synthesize topBar;
@synthesize manageBooksButton;
@synthesize updateBooksButton;
@synthesize deregisterDeviceButton;
@synthesize downloadDictionaryButton;
@synthesize spaceSaverSwitch;
@synthesize backgroundView;
@synthesize managedObjectContext;
@synthesize settingsDelegate;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [topBar release], topBar = nil;
    [manageBooksButton release], manageBooksButton = nil;
    [updateBooksButton release], updateBooksButton = nil;
    [deregisterDeviceButton release], deregisterDeviceButton = nil;
    [downloadDictionaryButton release], downloadDictionaryButton = nil;
    [spaceSaverSwitch release], spaceSaverSwitch = nil;
    [backgroundView release], backgroundView = nil;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[managedObjectContext release], managedObjectContext = nil;
    
    [self releaseViewObjects];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
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
                                             selector:@selector(dictionaryStateChanged:)
                                                 name:kSCHDictionaryStateChange
                                               object:nil];
    
#if LOCALDEBUG
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
    [self setupAssetsForOrientation:self.interfaceOrientation];
    
    NSNumber *spaceSaver = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSCHSpaceSaverMode"];
    self.spaceSaverSwitch.selected = [spaceSaver boolValue];
    
    [self updateDictionaryButton];
}

- (void)updateDictionaryButton
{
    SCHDictionaryProcessingState state = [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState];
    self.downloadDictionaryButton.enabled = (state == SCHDictionaryProcessingStateUserSetup
                                             || state == SCHDictionaryProcessingStateUserDeclined
                                             || state == SCHDictionaryProcessingStateReady);
    if (state == SCHDictionaryProcessingStateReady) {
        [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Remove Dictionary", @"remove dictionary button title")
                                       forState:UIControlStateNormal];
    } else {
        [self.downloadDictionaryButton setTitle:NSLocalizedString(@"Download Dictionary", @"download dictionary button title")
                                       forState:UIControlStateNormal];
    }
}

#pragma mark - Orientation methods

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.topBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.png"]];   
        [self.navigationController.view.layer setBorderColor:[UIColor SCHRed3Color].CGColor];
        [self.navigationController.view.layer setBorderWidth:2.0f];
    } else {
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
             [UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
            [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-landscape.png"]];
        } else {
            [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
             [UIImage imageNamed:@"admin-iphone-portrait-top-toolbar.png"]];
            [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.png"]];   
        }
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return(YES);
}

#pragma mark - Dismissal

- (IBAction)dismissModalSettingsController:(id)sender
{
    [[NSUserDefaults standardUserDefaults] setBool:self.spaceSaverSwitch.selected forKey:@"kSCHSpaceSaverMode"];
    [[NSUserDefaults standardUserDefaults] synchronize];

    [self.settingsDelegate dismissSettingsForm];
}

#pragma mark - Actions

- (IBAction)deregisterDevice:(id)sender 
{
#if LOCALDEBUG
    [self resetLocalSettings];
    [self.settingsDelegate dismissSettingsForm];
#else
    SCHDeregisterDeviceViewController *vc = [[SCHDeregisterDeviceViewController alloc] init];
    vc.settingsDelegate = self.settingsDelegate;
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
}

- (IBAction)manageBooks:(id)sender
{
    // TODO correct URL
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.scholastic.com"]];
}

- (IBAction)updateBooks:(id)sender
{
    SCHUpdateBooksViewController *updateBooks = [[SCHUpdateBooksViewController alloc] init];
    updateBooks.managedObjectContext = self.managedObjectContext;
    [self.navigationController pushViewController:updateBooks animated:YES];
    [updateBooks release];
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
    [appDelegate clearDatabase];
#endif
}

#pragma mark - notifications

- (void)dictionaryStateChanged:(NSNotification *)note
{
    [self updateDictionaryButton];
}

@end

