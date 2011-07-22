//
//  SCHDeregisterDeviceViewController.m
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDeregisterDeviceViewController.h"
#import "SCHAuthenticationManager.h"
#import "SCHDrmSession.h"
#import "SCHSettingsViewControllerDelegate.h"
#import "SCHAuthenticationManagerProtected.h"

@interface SCHDeregisterDeviceViewController ()
@property (nonatomic, retain) SCHDrmRegistrationSession* drmRegistrationSession;
@end

@implementation SCHDeregisterDeviceViewController

@synthesize settingsDelegate;
@synthesize promptLabel;
@synthesize passwordField;
@synthesize deregisterButton;
@synthesize spinner;
@synthesize drmRegistrationSession;

- (void)releaseViewObjects
{
    [promptLabel release], promptLabel = nil;
    [passwordField release], passwordField = nil;
    [deregisterButton release], deregisterButton = nil;
    [spinner release], spinner = nil;
}

- (void)dealloc
{
    [drmRegistrationSession release], drmRegistrationSession = nil;
    [self releaseViewObjects];
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonBackground:self.deregisterButton];
    
    UIView *fillerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 8)];
    UIImage *cellBGImage = [[UIImage imageNamed:@"button-field"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    self.passwordField.background = cellBGImage;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordField.leftView = fillerView;
    [fillerView release];

    NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kSCHAuthenticationManagerUsername];
    self.promptLabel.text = [NSString stringWithFormat:self.promptLabel.text, username];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - Actions

- (void)back:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)deregister:(id)sender
{
    if ([[SCHAuthenticationManager sharedAuthenticationManager] validatePassword:self.passwordField.text]) {
        SCHDrmRegistrationSession* registrationSession = [[SCHDrmRegistrationSession alloc] init];
        registrationSession.delegate = self;	
        self.drmRegistrationSession = registrationSession;
        [self.drmRegistrationSession deregisterDevice:[[SCHAuthenticationManager sharedAuthenticationManager] aToken]];
        [registrationSession release]; 
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"error alert title")
                                                        message:NSLocalizedString(@"The password was incorrect", @"")
                                                       delegate:nil
                                              cancelButtonTitle:NSLocalizedString(@"Try Again", @"try again button after password failure")
                                              otherButtonTitles:nil];
        [alert show];
        [alert release];
    }
}

- (void)forgotPassword:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://my.scholastic.com/sps_my_account/pwmgmt/ForgotPassword.jsp?AppType=COOL"]];
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

@end