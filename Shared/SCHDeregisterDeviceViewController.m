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
#import "SCHSetupDelegate.h"
#import "SCHAuthenticationManagerProtected.h"

@interface SCHDeregisterDeviceViewController ()
@property (nonatomic, retain) SCHDrmRegistrationSession* drmRegistrationSession;
@end

@implementation SCHDeregisterDeviceViewController

@synthesize promptLabel;
@synthesize passwordField;
@synthesize deregisterButton;
@synthesize spinner;
@synthesize scrollView;
@synthesize drmRegistrationSession;

- (void)releaseViewObjects
{
    [promptLabel release], promptLabel = nil;
    [passwordField release], passwordField = nil;
    [deregisterButton release], deregisterButton = nil;
    [scrollView release], scrollView = nil;
    [spinner release], spinner = nil;
    
    [super releaseViewObjects];
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
    UIImage *cellBGImage = [[UIImage imageNamed:@"button-field-red"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
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

#pragma mark - Actions

- (void)deregister:(id)sender
{
    if ([[SCHAuthenticationManager sharedAuthenticationManager] validatePassword:self.passwordField.text]) {
        [self.spinner startAnimating];
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

#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self.scrollView setContentSize:CGSizeMake(CGRectGetWidth(self.view.bounds), 2*CGRectGetHeight(self.view.bounds))];
    [self.scrollView setContentOffset:CGPointMake(0, CGRectGetMinY(self.promptLabel.frame)) animated:YES];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self deregister:nil];
    return NO;
}

#pragma mark - DRM Registration Session Delegate methods

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession didComplete:(NSString *)deviceKey
{
    [self.spinner stopAnimating];
    if (deviceKey == nil) {
        [[SCHAuthenticationManager sharedAuthenticationManager] clear];
        [[SCHAuthenticationManager sharedAuthenticationManager] clearAppProcessing];
        [self.setupDelegate dismissSettingsForm];
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
