//
//  SCHDeregisterDeviceViewController.m
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDeregisterDeviceViewController.h"
#import "SCHAuthenticationManager.h"
#import "SCHSettingsDelegate.h"
#import "LambdaAlert.h"
#import "SCHUnderlinedButton.h"
#import "Reachability.h"
#import "SCHAccountValidation.h"
#import "SCHUserDefaults.h"
#import "SCHDrmSession.h"
#import "SCHVersionDownloadManager.h"
#import "SCHSyncManager.h"
#import "SCHDictionaryDownloadManager.h"

static const CGFloat kDeregisterContentHeightLandscape = 380;

@interface SCHDeregisterDeviceViewController () <UITextFieldDelegate> 

@property (nonatomic, retain) SCHAccountValidation *accountValidation;

- (void)deregisterAfterSuccessfulAuthentication;
- (void)deregisterFailedAuthentication:(NSError *)error 
              offerForceDeregistration:(BOOL)offerForceDeregistration;
- (void)showAppVersionOutdatedAlert;

@end

@implementation SCHDeregisterDeviceViewController

@synthesize messageLabel;
@synthesize usernameField;
@synthesize passwordField;
@synthesize deregisterButton;
@synthesize spinner;
@synthesize accountValidation;
@synthesize appController;

- (void)releaseViewObjects
{
    [messageLabel release], messageLabel = nil;
    [usernameField release], usernameField = nil;
    [passwordField release], passwordField = nil;
    [deregisterButton release], deregisterButton = nil;
    [spinner release], spinner = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    [accountValidation release], accountValidation = nil;
    appController = nil;
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

#pragma mark - Accessor methods

- (SCHAccountValidation *)accountValidation
{
    if (accountValidation == nil) {
        accountValidation = [[SCHAccountValidation alloc] init];
    }
    
    return(accountValidation);
}

#pragma mark - Actions

- (void)deregister:(id)sender
{
    if ([[SCHVersionDownloadManager sharedVersionManager] isAppVersionOutdated] == YES) {
        [self showAppVersionOutdatedAlert];
    } else {
        [self.deregisterButton setEnabled:NO];
        
        NSString *username = [self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        
        if ([[self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Incorrect Password", @"")
                                  message:NSLocalizedString(@"Please enter the password", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
                [self.deregisterButton setEnabled:YES];
            }];
            [alert show];
            [alert release];                
        } else if ([[Reachability reachabilityForInternetConnection] isReachable] == NO) {
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"No Internet Connection", @"")
                                  message:NSLocalizedString(@"This function requires an Internet connection. Please connect to the internet and then try again.", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
                [self.deregisterButton setEnabled:YES];
            }];
            [alert show];
            [alert release];                
        } else {
            __block SCHDeregisterDeviceViewController *weakSelf = self;
            [self.spinner startAnimating];
//            [self setEnablesUI:NO];
            [self.accountValidation validateWithUserName:username
                                            withPassword:self.passwordField.text 
                                          updatePassword:YES
                                           validateBlock:^(NSString *pToken, NSError *error) {
                if (error != nil) {
                    LambdaAlert *alert = [[LambdaAlert alloc]
                                          initWithTitle:NSLocalizedString(@"Error", @"error alert title")
                                          message:[error localizedDescription]];
                    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
                        [weakSelf.deregisterButton setEnabled:YES];
                        [weakSelf.spinner stopAnimating];
//                        [weakSelf setEnablesUI:YES];                                    
                    }];
                    [alert show];
                    [alert release]; 
                } else {
                    if ([[SCHAuthenticationManager sharedAuthenticationManager] isAuthenticated] == YES) {
                        [weakSelf deregisterAfterSuccessfulAuthentication];
                    } else {
                        [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithSuccessBlock:^(SCHAuthenticationManagerConnectivityMode connectivityMode) {
                            if (connectivityMode == SCHAuthenticationManagerConnectivityModeOnline) {
                                [weakSelf deregisterAfterSuccessfulAuthentication];
                            } else {
                                [weakSelf deregisterFailedAuthentication:[NSError errorWithDomain:kSCHAuthenticationManagerErrorDomain 
                                                                                             code:kSCHAuthenticationManagerOfflineError 
                                                                                         userInfo:[NSDictionary dictionaryWithObject:NSLocalizedString(@"You are in offline mode, you must be in online mode to deregister", @"") 
                                                                                                                              forKey:NSLocalizedDescriptionKey]] offerForceDeregistration:NO];
                            }
                        } 
                                                                                                failureBlock:^(NSError *error){
                                                                                                    [weakSelf deregisterFailedAuthentication:error
                                                                                                                    offerForceDeregistration:YES];
                                                                                                }
                                                                                 waitUntilVersionCheckIsDone:YES];
                    }                
                }    
            }];
        }
    }
}

- (void)deregisterAfterSuccessfulAuthentication
{
    [[SCHSyncManager sharedSyncManager] performFlushSaves];
    
    SCHDrmDeregistrationSuccessBlock deregistrationCompletionBlock = ^{
        dispatch_block_t block = ^{
            
            if ([[SCHDictionaryDownloadManager sharedDownloadManager] userRequestState] == SCHDictionaryUserDeclined) {
                NSLog(@"Resetting dictionary question; user will be prompted to download dictionary.");
                [[SCHDictionaryDownloadManager sharedDownloadManager] setUserRequestState:SCHDictionaryUserNotYetAsked];
            }
            
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Device Deregistered", @"Device Deregistered") 
                                  message:NSLocalizedString(@"This device has been deregistered. To read eBooks, please register this device again.", @"") ];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK") block:nil];
            [alert show];
            [alert release];
        };  
        
        block();
        [self.appController presentLogin];
    };
    
    [[SCHAuthenticationManager sharedAuthenticationManager] deregisterWithSuccessBlock:^{
        deregistrationCompletionBlock();
    } failureBlock:^(NSError *error){
        if (([error code] == kSCHDrmDeregistrationError) ||
            ([error code] == kSCHDrmInitializationError)) {
            // We were already de-registered or did not have drm initialized. Force deregistration.
            [[SCHAuthenticationManager sharedAuthenticationManager] forceDeregistrationWithCompletionBlock:deregistrationCompletionBlock];
        } else {
            [self.spinner stopAnimating];
            
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Unable to Deregister Device", @"") 
                                  message:[error localizedDescription]];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK") block:^{
//                [self setEnablesUI:YES];
                [self.deregisterButton setEnabled:YES];
            }];
            [alert show];
            [alert release];
        }
    }];
}

- (void)deregisterFailedAuthentication:(NSError *)error 
              offerForceDeregistration:(BOOL)offerForceDeregistration
{
    NSString *message = nil;
    
    SCHDrmDeregistrationSuccessBlock deregistrationCompletionBlock = ^{
        dispatch_block_t block = ^{
            
            if ([[SCHDictionaryDownloadManager sharedDownloadManager] userRequestState] == SCHDictionaryUserDeclined) {
                NSLog(@"Resetting dictionary question; user will be prompted to download dictionary.");
                [[SCHDictionaryDownloadManager sharedDownloadManager] setUserRequestState:SCHDictionaryUserNotYetAsked];
            }
            
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Device Deregistered", @"Device Deregistered") 
                                  message:NSLocalizedString(@"This device has been deregistered. To read eBooks, please register this device again.", @"") ];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK") block:nil];
            [alert show];
            [alert release];
        };
        
        block();
        [self.appController presentLogin];
        
    };

    if (error == nil) {
        message = NSLocalizedString(@"We are not able to authenticate your account with the server. ", nil);
    } else {
        message = [NSString stringWithFormat:NSLocalizedString(@"We are not able to authenticate your account with the server (%@). ", nil), [error localizedDescription]];        
    }
    if (offerForceDeregistration == YES) {
        message = [NSString stringWithFormat:@"%@%@", message, NSLocalizedString(@"Would you like to Continue or Cancel.", nil)];
    } else {
        message = [NSString stringWithFormat:@"%@%@", message, NSLocalizedString(@"Please try again later.", nil)];
    }
    
    LambdaAlert *alert = [[LambdaAlert alloc]
                          initWithTitle:NSLocalizedString(@"Unable To Authenticate", @"")
                          message:message];
    if (offerForceDeregistration == YES) {
        [alert addButtonWithTitle:NSLocalizedString(@"Continue", @"") block:^{
            [[SCHAuthenticationManager sharedAuthenticationManager] forceDeregistrationWithCompletionBlock:deregistrationCompletionBlock];            
        }];        
    }
    [alert addButtonWithTitle:(offerForceDeregistration == YES ? NSLocalizedString(@"Cancel", @"") : NSLocalizedString(@"OK", @"") ) block:^{
        [self.deregisterButton setEnabled:YES];
        [self.spinner stopAnimating];
//        [self setEnablesUI:YES];                                            
    }];
    [alert show];
    [alert release];    
}

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self deregister:nil];
    return NO;
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

@end
