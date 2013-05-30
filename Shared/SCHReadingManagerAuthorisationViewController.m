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
@synthesize showNoBookShelvesText;
@synthesize accountVerifier;
@synthesize promptLabel;
@synthesize info1Label;
@synthesize info2Label;
@synthesize textFieldContainer;
//@synthesize usernameField;
@synthesize passwordField;
@synthesize validateButton;
@synthesize spinner;

- (void)releaseViewObjects
{    
    [promptLabel release], promptLabel = nil;
    [info1Label release], info1Label = nil;
    [info2Label release], info2Label = nil;
    [textFieldContainer release], textFieldContainer = nil;
    //[usernameField release], usernameField = nil;
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

- (id)initWithNoBookShelves:(BOOL)noBookShelves;
{
    if ((self = [super init])) {
        if (noBookShelves)
            self.showNoBookShelvesText = YES;  // currently unused.
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *stretchedFieldImage = [[UIImage imageNamed:@"textfield_wht_3part"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
//    [self.usernameField setBackground:stretchedFieldImage];
    [self.passwordField setBackground:stretchedFieldImage];
    
    UIImage *stretchedButtonImage = [[UIImage imageNamed:@"lg_bttn_gray_UNselected_3part"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    [self.validateButton setBackgroundImage:stretchedButtonImage forState:UIControlStateNormal];
    
    [self setAlert:SCHReadingManagerAlertNone];
    
    /*NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kSCHAuthenticationManagerUsername];
    
    if (username) {
        self.usernameField.text = username;
    }
     */
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
    
    switch (alert) {
        case SCHReadingManagerAlertMalformedEmail:
            self.promptLabel.text = NSLocalizedString(@"Please enter a valid e-mail address.", nil);
            break;
        case SCHReadingManagerAlertAuthenticationFailure:
            self.promptLabel.text = [NSString stringWithFormat:@"The password you entered is not correct for account %@. Please try again or contact Scholastic customer service at storia@scholastic.com.",[[NSUserDefaults standardUserDefaults] objectForKey:kSCHAuthenticationManagerUsername]];
            break;
        case SCHReadingManagerAlertWrongUser:
            self.promptLabel.text = NSLocalizedString(@"This e-mail address does not match your account. Please try again, or contact Scholastic customer service at storia@scholastic.com.", nil);
            break;
        case SCHReadingManagerAlertAuthenticationUnavailable:
            self.promptLabel.text = NSLocalizedString(@"Password authentication is currently unavailable. Please try again.", nil);
            break;
        default:
            break;
    }
    
    if (alert == SCHReadingManagerAlertNone) {
        self.promptLabel.alpha = 0;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.info1Label.alpha = 1;
            self.info2Label.transform = CGAffineTransformIdentity;
        } else {
            self.info1Label.transform = CGAffineTransformIdentity;
            self.info2Label.transform = CGAffineTransformIdentity;
            self.textFieldContainer.transform = CGAffineTransformIdentity;
        }
    } else {
        self.promptLabel.alpha = 1;
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            self.info1Label.alpha = 0;
            self.info2Label.transform = CGAffineTransformMakeTranslation(0, -48);
        } else {
            if (alert == SCHReadingManagerAlertMalformedEmail) {
                self.textFieldContainer.transform = CGAffineTransformMakeTranslation(0, 10);
            } else {
                self.info1Label.transform = CGAffineTransformMakeTranslation(0, -14);
                self.info2Label.transform = CGAffineTransformMakeTranslation(0, -14);
                self.textFieldContainer.transform = CGAffineTransformMakeTranslation(0, 30);
            }
        }
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
        /*
        if ([[self.usernameField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
            [self setAlert:SCHReadingManagerAlertMalformedEmail];
            self.passwordField.text = @"";
        } else if ([self.usernameField.text isValidEmailAddress] == NO) {
            [self setAlert:SCHReadingManagerAlertMalformedEmail];
            self.passwordField.text = @"";
        } else */
        if ([[self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
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
            
            //NSString *username = self.usernameField.text;
            NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kSCHAuthenticationManagerUsername];
            
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self setAlert:SCHReadingManagerAlertNone];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self validate:nil];
    return NO;
}

#pragma mark - Touch Handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
