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

@interface SCHDeregisterDeviceViewController ()
@property (nonatomic, retain) SCHDrmRegistrationSession* drmRegistrationSession;
@end

@implementation SCHDeregisterDeviceViewController

@synthesize settingsDelegate;
@synthesize deregisterButton;
@synthesize drmRegistrationSession;

- (void)releaseViewObjects
{
    self.deregisterButton = nil;
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
    SCHDrmRegistrationSession* registrationSession = [[SCHDrmRegistrationSession alloc] init];
    registrationSession.delegate = self;	
    self.drmRegistrationSession = registrationSession;
    [self.drmRegistrationSession deregisterDevice:[[SCHAuthenticationManager sharedAuthenticationManager] aToken]];
    [registrationSession release]; 
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
