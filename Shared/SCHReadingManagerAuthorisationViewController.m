//
//  SCHAccountValidationViewController.m
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingManagerAuthorisationViewController.h"
#import "SCHAuthenticationManager.h"
#import "SCHSettingsDelegate.h"
#import "LambdaAlert.h"
#import "Reachability.h"
#import "SCHAccountValidation.h"
#import "SCHAccountVerifier.h"
#import "SCHParentalToolsWebViewController.h"
#import "SCHUserDefaults.h"
#import "SCHSyncManager.h"
#import "SCHVersionDownloadManager.h"
#import "NSString+EmailValidation.h"
#import "SFHFKeychainUtils.h"

@interface SCHReadingManagerAuthorisationViewController () <UITextFieldDelegate>

@property (nonatomic, retain) SCHAccountValidation *accountValidation;
@property (nonatomic, retain) SCHAccountVerifier *accountVerifier;

- (void)showAppVersionOutdatedAlert;

@end

@implementation SCHReadingManagerAuthorisationViewController

@synthesize appController;
@synthesize accountValidation;
@synthesize accountVerifier;
@synthesize messageLabel;
@synthesize usernameField;
@synthesize passwordField;
@synthesize validateButton;
@synthesize spinner;

- (void)releaseViewObjects
{    
    [messageLabel release], messageLabel = nil;
    [usernameField release], usernameField = nil;
    [passwordField release], passwordField = nil;
    [validateButton release], validateButton = nil;
    [spinner release], spinner = nil;    
}

- (void)dealloc
{
    [self releaseViewObjects];
    appController = nil;
    [accountValidation release], accountValidation = nil;
    [accountVerifier release], accountVerifier = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.messageLabel.alpha = 0;
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

- (SCHAccountVerifier *)accountVerifier
{
    if (accountVerifier == nil) {
        accountVerifier = [[SCHAccountVerifier alloc] init];
    }
    
    return(accountVerifier);    
}

#pragma mark - Actions

- (IBAction)validate:(id)sender
{
    if ([[SCHVersionDownloadManager sharedVersionManager] isAppVersionOutdated] == YES) {
        [self showAppVersionOutdatedAlert];
    } else {
        if ([[usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Incorrect E-mail Address", @"error alert title")
                                  message:NSLocalizedString(@"Please enter a valid e-mail address.", @"error alert title")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
            [alert show];
            [alert release];                
        } else if ([usernameField.text isValidEmailAddress] == NO) {
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Incorrect E-mail Address", @"error alert title")
                                  message:NSLocalizedString(@"E-mail address is not valid. Please try again.", @"error alert title")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
            [alert show];
            [alert release];
        } else if ([[passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Incorrect Password", @"error alert title")
                                  message:NSLocalizedString(@"Please enter the password", @"error alert title")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
            [alert show];
            [alert release];                
        } else if ([[Reachability reachabilityForInternetConnection] isReachable] == NO) {
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"No Internet Connection", @"")
                                  message:NSLocalizedString(@"This function requires an Internet connection. Please connect to the internet and then try again.", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
            [alert show];
            [alert release];                
        } else {
            [self.spinner startAnimating];
            [self.validateButton setEnabled:NO];
            [self.view endEditing:YES];
            self.messageLabel.alpha = 0;
            
            NSString *username = self.usernameField.text;
            
            BOOL canValidate = [self.accountValidation validateWithUserName:username
                                                withPassword:passwordField.text
                                              updatePassword:NO
                                               validateBlock:^(NSString *pToken, NSError *error) {
                                                   if (error != nil) {
                                                       self.passwordField.text = @"";
                                                       self.messageLabel.text = NSLocalizedString(@"The e-mail address or password you entered does not match your account. Please try again.", nil);
                                                       self.messageLabel.alpha = 1;
                                                   } else {
                                                       // check this username isnt for a different user
                                                       [self.accountVerifier verifyAccount:pToken
                                                                      accountVerifiedBlock:^(BOOL usernameIsValid, NSError *error) {
                                                                          if (usernameIsValid == YES) {
                                                                              // update username/password
                                                                              [[NSUserDefaults standardUserDefaults] setObject:username forKey:kSCHAuthenticationManagerUsername];
                                                                              [[NSUserDefaults standardUserDefaults] synchronize];
                                                                              
                                                                              NSString *storedPassword = [SFHFKeychainUtils getPasswordForUsername:username
                                                                                                                                    andServiceName:kSCHAuthenticationManagerServiceName
                                                                                                                                             error:nil];
                                                                              
                                                                              if ([self.passwordField.text isEqualToString:storedPassword] == NO) {
                                                                                  [SFHFKeychainUtils storeUsername:username
                                                                                                       andPassword:self.passwordField.text
                                                                                                    forServiceName:kSCHAuthenticationManagerServiceName
                                                                                                    updateExisting:YES
                                                                                                             error:nil];
                                                                              }
                                                                              
                                                                              self.passwordField.text = @"";
                                                                              [self.appController presentReadingManager];
                                                                          } else {
                                                                              self.passwordField.text = @"";
                                                                          }
                                                                      }];                                                            
                                                   }
                                                   
                                                   [self.spinner stopAnimating];
                                                   [self.validateButton setEnabled:YES];
                                               }];
            
            if (!canValidate) {
                LambdaAlert *alert = [[LambdaAlert alloc]
                                      initWithTitle:NSLocalizedString(@"Password authentication unavailable", @"")
                                      message:NSLocalizedString(@"Please try again in a moment.", @"")];
                [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
                [alert show];
                [alert release];
                [self.spinner stopAnimating];
                self.messageLabel.alpha = 0;
                [self.validateButton setEnabled:YES];
            }
        }            
    }
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

#pragma mark - Text field delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self validate:nil];
    return NO;
}

@end
