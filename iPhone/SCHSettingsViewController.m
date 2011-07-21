//
//  SCHSettingsViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSettingsViewController.h"

#import "SCHLoginPasswordViewController.h"
#import "SCHAuthenticationManager.h"
#import "SCHDrmSession.h"
#import "SCHCustomNavigationBar.h"
#import "SCHCustomToolbar.h"
#import "SCHURLManager.h"
#import "SCHSyncManager.h"
#import "SCHAboutViewController.h"
#import "SCHPrivacyPolicyViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SCHProcessingManager.h"
#import "SCHDictionaryDownloadManager.h"
#import "AppDelegate_Shared.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

@interface SCHSettingsViewController()

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)releaseViewObjects;
- (void)deregistration;
- (void)resetLocalSettings;

@end

@implementation SCHSettingsViewController

@synthesize topBar;
@synthesize tableView;
@synthesize backgroundView;

@synthesize managedObjectContext;
@synthesize drmRegistrationSession;
@synthesize settingsDelegate;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [topBar release], topBar = nil;
    [tableView release], tableView = nil;
    [backgroundView release], backgroundView = nil;
}

- (void)dealloc 
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
	[managedObjectContext release], managedObjectContext = nil;
    [drmRegistrationSession release], drmRegistrationSession = nil;
    
    [self releaseViewObjects];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.tableView.backgroundView = nil;
    self.tableView.backgroundColor = [UIColor clearColor]; // Needed to avoid black corners
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationItem.title = NSLocalizedString(@"Back", @"");
        UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
        CGRect logoFrame = logoImageView.bounds;
        logoFrame.size.height = self.navigationController.navigationBar.frame.size.height;
        logoImageView.frame = logoFrame;
        logoImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
        logoImageView.contentMode = UIViewContentModeScaleAspectFit;
        self.navigationItem.titleView = logoImageView;
        [logoImageView release];
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
    [self setupAssetsForOrientation:self.interfaceOrientation];
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
    [self.settingsDelegate dismissSettingsForm];
}

#pragma mark - Switch Changes

- (void)spaceSwitchChanged:(UISwitch *)sender
{
	NSNumber *currentValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSCHSpaceSaverMode"];
	
	if (!currentValue) {
		BOOL newValue = [sender isOn];
		[[NSUserDefaults standardUserDefaults] setBool:newValue forKey:@"kSCHSpaceSaverMode"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		return;
	}
	
	BOOL newValue = !([currentValue boolValue]);
	[[NSUserDefaults standardUserDefaults] setBool:newValue forKey:@"kSCHSpaceSaverMode"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark - Deregistration

- (void)deregistration 
{
    UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Confirmation", @"Confirmation") 
                                                         message:NSLocalizedString(@"This will remove all books and settings.", nil)
                                                        delegate:self 
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                               otherButtonTitles:NSLocalizedString(@"Continue", @""), nil]; 
    [errorAlert show]; 
    [errorAlert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
#if !LOCALDEBUG
        SCHDrmRegistrationSession* registrationSession = [[SCHDrmRegistrationSession alloc] init];
        registrationSession.delegate = self;	
        self.drmRegistrationSession = registrationSession;
        [self.drmRegistrationSession deregisterDevice:[[SCHAuthenticationManager sharedAuthenticationManager] aToken]];
        [registrationSession release]; 
#endif
        [self resetLocalSettings];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return(4);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return(1);
}

- (UIView *)tableView:(UITableView *)aTableView viewForFooterInSection:(NSInteger)section
{
    if (section != 1) {
        return nil;
    }
    
    CGRect footerFrame = CGRectMake(0, 0, CGRectGetWidth(aTableView.bounds), 82);
    UIView *containerView = [[UIView alloc] initWithFrame:footerFrame];
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectInset(footerFrame, 10, 8)];
    
    footerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    footerLabel.text =  NSLocalizedString(@"Space Saver Mode allows you to download individual books - turn it off to automatically download all books.", @"");
    footerLabel.minimumFontSize = 11;
    footerLabel.numberOfLines = 3;
    footerLabel.adjustsFontSizeToFitWidth = YES;
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.textColor = [UIColor SCHDarkBlue1Color];
    footerLabel.shadowColor = [UIColor whiteColor];
    footerLabel.shadowOffset = CGSizeMake(0, -1);
    footerLabel.textAlignment = UITextAlignmentCenter;
    [containerView addSubview:footerLabel];
    [footerLabel release], footerLabel = nil;
    
    return([containerView autorelease]);
}

- (CGFloat)tableView:(UITableView *)aTableView heightForFooterInSection:(NSInteger)section
{
    if (section != 1) {
        return(aTableView.sectionFooterHeight);
    }
    
    return(82);
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell =  (UITableViewCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch ([indexPath section]) {
        case 0: {
            cell.accessoryView = nil;
            cell.textLabel.textAlignment = UITextAlignmentLeft;
            if (LOCALDEBUG) {
                cell.textLabel.text = NSLocalizedString(@"Reset Content and Settings", @"");
            } else {
                cell.textLabel.text = NSLocalizedString(@"Deregister This Device", @"");
            }
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        } break;
        case 1: {
            UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
            BOOL currentValue = [[NSUserDefaults standardUserDefaults] boolForKey:@"kSCHSpaceSaverMode"];
            [switchview setOn:currentValue];
            [switchview addTarget:self action:@selector(spaceSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchview;
            [switchview release], switchview = nil;
            
            cell.textLabel.textAlignment = UITextAlignmentLeft;
            cell.textLabel.text = NSLocalizedString(@"Space Saver Mode", @"");
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } break;  
        case 2: {
            cell.accessoryView = nil;
            cell.textLabel.textAlignment = UITextAlignmentLeft;
            cell.textLabel.text = NSLocalizedString(@"Privacy Policy", @"");
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        } break;
        case 3: {
            cell.accessoryView = nil;
            cell.textLabel.textAlignment = UITextAlignmentLeft;
            cell.textLabel.text = NSLocalizedString(@"About", @"");
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        } break;  
        default:
            break;
    }

    return(cell);
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0: {
            [self deregistration];
        } break;
        case 2: {
			SCHPrivacyPolicyViewController *privacyController = [[SCHPrivacyPolicyViewController alloc] init];
			[self.navigationController pushViewController:privacyController animated:YES];
			[privacyController release];
        } break;
        case 3: {
			SCHAboutViewController *aboutController = [[SCHAboutViewController alloc] init];
			[self.navigationController pushViewController:aboutController animated:YES];
			[aboutController release];
        } break;
        default:
            break;
    }
    
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - DRM Registration Session Delegate methods

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession didComplete:(NSString *)deviceKey
{
    if (deviceKey == nil) {
        [[SCHAuthenticationManager sharedAuthenticationManager] clearAppProcessing];
        [self.settingsDelegate dismissSettingsForm];
    } else {
        NSLog(@"Unknown DRM error: device key value returned from successful deregistration.");
    }
    self.drmRegistrationSession = nil;
}

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession didFailWithError:(NSError *)error
{
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                         message:[error localizedDescription]
                                                        delegate:nil 
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                               otherButtonTitles:nil]; 
    [errorAlert show]; 
    [errorAlert release]; 
    self.drmRegistrationSession = nil;
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

@end

