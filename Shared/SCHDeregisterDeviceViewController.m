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

static const CGFloat kDeregisterContentHeightLandscape = 380;

@interface SCHDeregisterDeviceViewController ()

@property (nonatomic, retain) UITextField *activeTextField;
@property (nonatomic, retain) SCHAccountValidation *accountValidation;

- (void)setEnablesUI:(BOOL)enablesUI;
- (void)setupContentSizeForOrientation:(UIInterfaceOrientation)orientation;
- (void)makeVisibleTextField:(UITextField *)textField;
- (void)deregisterAfterSuccessfulAuthentication;
- (void)deregisterFailedAuthentication:(NSError *)error;
- (void)showAppVersionOutdatedAlert;

@end

@implementation SCHDeregisterDeviceViewController

@synthesize promptLabel;
@synthesize passwordField;
@synthesize deregisterButton;
@synthesize spinner;
@synthesize scrollView;
@synthesize activeTextField;
@synthesize accountValidation;
@synthesize passwordHintLabel;

- (void)releaseViewObjects
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    [promptLabel release], promptLabel = nil;
    [passwordField release], passwordField = nil;
    [deregisterButton release], deregisterButton = nil;
    [scrollView release], scrollView = nil;
    [spinner release], spinner = nil;
    [activeTextField release], activeTextField = nil;
    [passwordHintLabel release], passwordHintLabel = nil;
    
    [super releaseViewObjects];
}

- (void)dealloc
{
    [self releaseViewObjects];
    [accountValidation release], accountValidation = nil;
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
    
    if (username) {
        self.promptLabel.text = [NSString stringWithFormat:self.promptLabel.text, username];
    } else {
        // Something has gone wrong - we don't know the username. We should hide the authentication controls and allow a forced deregister
        self.promptLabel.hidden = YES;
        self.passwordField.hidden = YES;
        self.passwordHintLabel.hidden = YES;
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardWillShow:) 
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardDidShow:) 
                                                     name:UIKeyboardDidShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    [self setupContentSizeForOrientation:self.interfaceOrientation];
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

- (void)setEnablesUI:(BOOL)enablesUI
{
    [self setEnablesBackButton:enablesUI];
    
    self.passwordField.enabled = enablesUI;
}

#pragma mark - Actions

- (void)deregister:(id)sender
{
    if ([[SCHVersionDownloadManager sharedVersionManager] isAppVersionOutdated] == YES) {
        [self showAppVersionOutdatedAlert];
    } else {
        [self.deregisterButton setEnabled:NO];
        
        NSString *username = [[NSUserDefaults standardUserDefaults] objectForKey:kSCHAuthenticationManagerUsername];
        
        if (!username) {
            // Something has gone wrong - we don't know the username. Perform a non-authenticated deregister
            [self deregisterAfterSuccessfulAuthentication];
        } else if ([[self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Incorrect Password", @"")
                                  message:NSLocalizedString(@"Incorrect password for deregistration", @"")];
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
            NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
            [self.spinner startAnimating];
            [self setEnablesUI:NO];
            [self.accountValidation validateWithUserName:storedUsername withPassword:self.passwordField.text validateBlock:^(NSString *pToken, NSError *error) {
                if (error != nil) {
                    LambdaAlert *alert = [[LambdaAlert alloc]
                                          initWithTitle:NSLocalizedString(@"Error", @"error alert title")
                                          message:[error localizedDescription]];
                    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
                        [weakSelf.deregisterButton setEnabled:YES];
                        [weakSelf.spinner stopAnimating];
                        [weakSelf setEnablesUI:YES];                                    
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
                                                                                                                              forKey:NSLocalizedDescriptionKey]]];
                            }
                        } 
                                                                                                failureBlock:^(NSError *error){
                                                                                                    [weakSelf deregisterFailedAuthentication:error];
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
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Device Deregistered", @"Device Deregistered") 
                                  message:NSLocalizedString(@"This device has been deregistered. To read eBooks, please register this device again.", @"") ];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK") block:nil];
            [alert show];
            [alert release];
        };  
        
        if (self.settingsDelegate != nil) {
            [self.settingsDelegate popToRootViewControllerAnimated:YES withCompletionHandler:block];
        } else if (self.profileSetupDelegate != nil) {
            [self.profileSetupDelegate popToRootViewControllerAnimated:YES withCompletionHandler:block];            
        }
    };
    
    [[SCHAuthenticationManager sharedAuthenticationManager] deregisterWithSuccessBlock:^{
        deregistrationCompletionBlock();
    } failureBlock:^(NSError *error){
        if (([error code] == kSCHDrmDeregistrationError) ||
            ([error code] == kSCHDrmInitializationError)) {
            // We were already de-registered or did not have drm initialized. Force deregistration.
            [[SCHAuthenticationManager sharedAuthenticationManager]  forceDeregistrationWithCompletionBlock:deregistrationCompletionBlock];
        } else {
            [self.spinner stopAnimating];
            
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Unable to Deregister Device", @"") 
                                  message:[error localizedDescription]];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK") block:^{
                [self setEnablesUI:YES];
                [self.deregisterButton setEnabled:YES];        
            }];
            [alert show];
            [alert release];
        }
    }];
}

- (void)deregisterFailedAuthentication:(NSError *)error
{
    NSString *message = nil;
    
    if (error == nil) {
        message = NSLocalizedString(@"We are not able to authenticate your account with the server. Please try again later.", nil);
    } else {
        message = [NSString stringWithFormat:NSLocalizedString(@"We are not able to authenticate your account with the server (%@). Please try again later.", nil), [error localizedDescription]];        
    }
    
    LambdaAlert *alert = [[LambdaAlert alloc]
                          initWithTitle:NSLocalizedString(@"Unable To Authenticate", @"")
                          message:message];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
        [self.deregisterButton setEnabled:YES];
        [self.spinner stopAnimating];
        [self setEnablesUI:YES];                                            
    }];
    [alert show];
    [alert release];    
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self.view endEditing:YES];
    [self setupContentSizeForOrientation:self.interfaceOrientation];
}

#pragma mark - Text field delegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (self.activeTextField && (self.activeTextField != textField)) {
            // We have swapped textFields with the keyboard showing
            [self makeVisibleTextField:textField];
        }
        
        self.activeTextField = textField;
    }
}

- (void)makeVisibleTextField:(UITextField *)textField
{
    CGFloat textFieldCenterY    = CGRectGetMidY(textField.frame);
    CGFloat scrollViewQuadrantY = CGRectGetMidY(self.scrollView.frame)/2.0f;
    
    if (textFieldCenterY > scrollViewQuadrantY) {
        [self.scrollView setContentOffset:CGPointMake(0, textFieldCenterY - scrollViewQuadrantY) animated:YES];
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [self deregister:nil];
    return NO;
}

- (void)setupContentSizeForOrientation:(UIInterfaceOrientation)orientation;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            self.scrollView.contentSize = CGSizeZero;
        } else {
            self.scrollView.contentSize = CGSizeMake(self.containerView.bounds.size.width, kDeregisterContentHeightLandscape);
        }
    } else {
        self.scrollView.contentSize = CGSizeZero;
    }    
}

#pragma mark - UIKeyboard Notifications

- (void)keyboardDidShow:(NSNotification *) notification
{
    if (self.activeTextField) {
        [self makeVisibleTextField:self.activeTextField];
    }
}

- (void)keyboardWillShow:(NSNotification *) notification
{
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, MAX(self.containerView.frame.size.height, self.scrollView.contentSize.height) * 1.5f)];
}

- (void)keyboardWillHide:(NSNotification *) notification
{
    self.activeTextField = nil;
    [self setupContentSizeForOrientation:self.interfaceOrientation];
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
