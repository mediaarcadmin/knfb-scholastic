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
#import "SCHURLManager.h"
#import "SCHSyncManager.h"
#import "SCHAboutViewController.h"
#import "SCHPrivacyPolicyViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SCHProcessingManager.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

@interface SCHSettingsViewController()

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)releaseViewObjects;
- (void)deregistration;

@end

@implementation SCHSettingsViewController
@synthesize tableView;
@synthesize backgroundView;

@synthesize loginController;
@synthesize managedObjectContext;
@synthesize drmRegistrationSession;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [loginController release], loginController = nil;
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
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.832 green:0.000 blue:0.007 alpha:1.000]];

    self.loginController.controllerType = kSCHControllerLoginView;
    self.loginController.actionBlock = ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerSuccess object:nil];			
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerFailure object:nil];					
        
        [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithUserName:[self.loginController username] withPassword:[self.loginController password]];
    };    
    
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
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
         [UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.png"]];   
        [self.navigationController.view.layer setBorderColor:[UIColor colorWithRed:0.651 green:0.051 blue:0.106 alpha:1.000].CGColor];
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
    [self.parentViewController dismissModalViewControllerAnimated:YES];
}

#pragma mark - Login

- (void)login 
{
    [self.loginController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.loginController setModalPresentationStyle:UIModalPresentationFormSheet];    
	[self presentModalViewController:self.loginController animated:YES];		
}

#pragma mark - Authentication Manager

- (void)authenticationManager:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if ([notification.name compare:kSCHAuthenticationManagerSuccess] == NSOrderedSame) {
		[[SCHSyncManager sharedSyncManager] firstSync];
        if (self.parentViewController.parentViewController != nil) {
            [self.parentViewController.parentViewController dismissModalViewControllerAnimated:YES];
        }
	} else {
		NSError *error = [notification.userInfo objectForKey:kSCHAuthenticationManagerNSError];
		if (error!= nil) {
			UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
																 message:[error localizedDescription]
																delegate:nil 
													   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
													   otherButtonTitles:nil]; 
			[errorAlert show]; 
			[errorAlert release];
		}	
        [self.loginController stopShowingProgress];
	}
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
                                                         message:NSLocalizedString(@"This will remove all books and settings", nil)
                                                        delegate:self 
                                               cancelButtonTitle:NSLocalizedString(@"Cancel", @"")
                                               otherButtonTitles:NSLocalizedString(@"Continue", @""), nil]; 
    [errorAlert show]; 
    [errorAlert release];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        SCHDrmRegistrationSession* registrationSession = [[SCHDrmRegistrationSession alloc] init];
        registrationSession.delegate = self;	
        self.drmRegistrationSession = registrationSession;
        [self.drmRegistrationSession deregisterDevice:[[SCHAuthenticationManager sharedAuthenticationManager] aToken]];
        [registrationSession release];    
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
    footerLabel.textColor = [UIColor colorWithRed:0.063 green:0.337 blue:0.510 alpha:1.0];
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
            cell.textLabel.text = NSLocalizedString(@"Deregister This Device", @"");
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
    if ( deviceKey == nil ) {
        // removeObjectForKey does not change the value...
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSCHAuthenticationManagerDeviceKey];
		[[SCHURLManager sharedURLManager] clear];
        [[SCHProcessingManager sharedProcessingManager] cancelAllOperations];                
		[[SCHSyncManager sharedSyncManager] clear];
        [self login];
        [self.navigationController popViewControllerAnimated:NO];
    }
    else
        NSLog(@"Unknown DRM error:  device key value returned from successful deregistration.");
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

@end

