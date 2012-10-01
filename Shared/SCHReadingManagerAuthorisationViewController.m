//
//  SCHAccountValidationViewController.m
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "SCHReadingManagerAuthorisationViewController.h"
#import "SCHAuthenticationManager.h"
#import "LambdaAlert.h"
#import "Reachability.h"
#import "SCHAccountVerifier.h"
#import "SCHUserDefaults.h"
#import "SCHSyncManager.h"
#import "SCHVersionDownloadManager.h"
#import "NSString+EmailValidation.h"
#import "SFHFKeychainUtils.h"
#import "SCHAuthenticationManager.h"

typedef enum  {
    SCHReadingManagerAlertNone,
    SCHReadingManagerAlertMalformedEmail,
    SCHReadingManagerAlertAuthenticationFailure,
    SCHReadingManagerAlertWrongUser,
    SCHReadingManagerAlertAuthenticationUnavailable
} SCHReadingManagerAlert;

@interface SCHReadingManagerAuthorisationViewController () <UITextFieldDelegate>

@property (nonatomic, retain) SCHAccountVerifier *accountVerifier;

- (void)showAppVersionOutdatedAlert;
- (void)setAlert:(SCHReadingManagerAlert)alert;

@end

@implementation SCHReadingManagerAuthorisationViewController

@synthesize appController;
@synthesize accountVerifier;
@synthesize promptLabel;
@synthesize info1Label;
@synthesize info2Label;
@synthesize usernameField;
@synthesize passwordField;
@synthesize validateButton;
@synthesize spinner;

- (void)releaseViewObjects
{    
    [promptLabel release], promptLabel = nil;
    [info1Label release], info1Label = nil;
    [info2Label release], info2Label = nil;
    [usernameField release], usernameField = nil;
    [passwordField release], passwordField = nil;
    [validateButton release], validateButton = nil;
    [spinner release], spinner = nil;    
}

- (void)dealloc
{
    [self releaseViewObjects];
    appController = nil;
    [accountVerifier release], accountVerifier = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *stretchedFieldImage = [[UIImage imageNamed:@"textfield_wht_3part"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    [self.usernameField setBackground:stretchedFieldImage];
    [self.passwordField setBackground:stretchedFieldImage];
    
    UIImage *stretchedButtonImage = [[UIImage imageNamed:@"lg_bttn_gray_UNselected_3part"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    [self.validateButton setBackgroundImage:stretchedButtonImage forState:UIControlStateNormal];
    
    [self setAlert:SCHReadingManagerAlertNone];
}
- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

#pragma mark - Accessor methods

- (SCHAccountVerifier *)accountVerifier
{
    if (accountVerifier == nil) {
        accountVerifier = [[SCHAccountVerifier alloc] init];
    }
    
    return(accountVerifier);    
}

- (void)setAlert:(SCHReadingManagerAlert)alert
{
    [CATransaction begin];
    [CATransaction setDisableActions:YES];

    self.promptLabel.alpha = 0;
    self.info1Label.alpha = 1;
    self.info2Label.alpha = 1;
    self.info2Label.transform = CGAffineTransformIdentity;
    
    switch (alert) {
        case SCHReadingManagerAlertNone:
            break;
        case SCHReadingManagerAlertMalformedEmail:
            self.promptLabel.text = NSLocalizedString(@"Please enter a valid e-mail address.", nil);
            self.promptLabel.alpha = 1;
            self.info1Label.alpha = 0;
            self.info2Label.transform = CGAffineTransformMakeTranslation(0, -48);
            break;
        case SCHReadingManagerAlertAuthenticationFailure:
            self.promptLabel.text = NSLocalizedString(@"Your e-mail address or password was not recognized. Please try again, or contact Scholastic customer service at storia@scholastic.com.", nil);
            self.promptLabel.alpha = 1;
            self.info1Label.alpha = 0;
            self.info2Label.transform = CGAffineTransformMakeTranslation(0, -48);
            break;
        case SCHReadingManagerAlertWrongUser:
            self.promptLabel.text = NSLocalizedString(@"This e-mail address does not match your account. Please try again, or contact Scholastic customer service at storia@scholastic.com.", nil);
            self.promptLabel.alpha = 1;
            self.info1Label.alpha = 0;
            self.info2Label.transform = CGAffineTransformMakeTranslation(0, -48);
            break;
        case SCHReadingManagerAlertAuthenticationUnavailable:
            self.promptLabel.text = NSLocalizedString(@"Password authentication is currently unavailable. Please try again.", nil);
            self.promptLabel.alpha = 1;
            self.info1Label.alpha = 0;
            self.info2Label.transform = CGAffineTransformMakeTranslation(0, -48);
            break;
        default:
            break;
    }
    
    [CATransaction commit];
}

#pragma mark - Actions

- (IBAction)validate:(id)sender
{
    [self setAlert:SCHReadingManagerAlertNone];
    [self.view endEditing:YES];

    if ([[SCHVersionDownloadManager sharedVersionManager] isAppVersionOutdated] == YES) {
        [self showAppVersionOutdatedAlert];
    } else {
        if ([[self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
            [self setAlert:SCHReadingManagerAlertMalformedEmail];
            self.passwordField.text = @"";
        } else if ([self.usernameField.text isValidEmailAddress] == NO) {
            [self setAlert:SCHReadingManagerAlertMalformedEmail];
            self.passwordField.text = @"";
        } else if ([[self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
            [self setAlert:SCHReadingManagerAlertAuthenticationFailure];
            self.passwordField.text = @"";
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
            
            NSString *username = self.usernameField.text;
            
            BOOL canValidate = [[SCHAuthenticationManager sharedAuthenticationManager] validateWithUserName:username
                                                withPassword:passwordField.text
                                              updatePassword:NO
                                               validateBlock:^(NSString *pToken, NSError *error) {
                                                   if (error != nil) {
                                                       self.passwordField.text = @"";
                                                       [self setAlert:SCHReadingManagerAlertAuthenticationFailure];
                                                       [self.spinner stopAnimating];
                                                       [self.validateButton setEnabled:YES];
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
                                                                              [self setAlert:SCHReadingManagerAlertWrongUser];
                                                                          }
                                                                          
                                                                          [self.spinner stopAnimating];
                                                                          [self.validateButton setEnabled:YES];
                                                                      }];
                                                   }
                                               }];
            
            if (!canValidate) {
                [self setAlert:SCHReadingManagerAlertAuthenticationUnavailable];
                [self.spinner stopAnimating];
                self.passwordField.text = @"";
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
