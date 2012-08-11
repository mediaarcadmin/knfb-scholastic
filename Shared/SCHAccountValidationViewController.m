//
//  SCHAccountValidationViewController.m
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAccountValidationViewController.h"
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

static const CGFloat kDeregisterContentHeightLandscape = 380;

@interface SCHAccountValidationViewController ()

@property (nonatomic, retain) SCHAccountValidation *accountValidation;
@property (nonatomic, retain) SCHAccountVerifier *accountVerifier;
@property (nonatomic, retain) UITextField *activeTextField;
//@property (nonatomic, assign) BOOL requestUserNameAndPassword;

//- (void)activateUsernameAndPassword;
- (void)setupContentSizeForOrientation:(UIInterfaceOrientation)orientation;
- (void)makeVisibleTextField:(UITextField *)textField;
- (void)showAppVersionOutdatedAlert;

@end

@implementation SCHAccountValidationViewController

@synthesize accountValidation;
@synthesize accountVerifier;
@synthesize promptLabel;
@synthesize messageLabel;
@synthesize usernameField;
@synthesize passwordField;
@synthesize validateButton;
@synthesize spinner;
@synthesize scrollView;
@synthesize activeTextField;
@synthesize validatedControllerShouldHideCloseButton;
@synthesize titleLabel;
//@synthesize requestUserNameAndPassword;

- (void)releaseViewObjects
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    [promptLabel release], promptLabel = nil;
    [messageLabel release], messageLabel = nil;
    [usernameField release], usernameField = nil;
    [passwordField release], passwordField = nil;
    [validateButton release], validateButton = nil;
    [scrollView release], scrollView = nil;
    [spinner release], spinner = nil;
    [activeTextField release], activeTextField = nil;
    [titleLabel release], titleLabel = nil;
    
    [super releaseViewObjects];
}

- (void)dealloc
{
    [self releaseViewObjects];
    [accountValidation release], accountValidation = nil;
    [accountVerifier release], accountVerifier = nil;
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setButtonBackground:self.validateButton];
    
    UIView *fillerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 8)];
    UIImage *cellBGImage = [[UIImage imageNamed:@"button-field-red"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    self.usernameField.background = cellBGImage;
    self.usernameField.leftViewMode = UITextFieldViewModeAlways;
    self.usernameField.leftView = fillerView;
    [fillerView release];
    self.usernameField.text = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];                                     
    
    fillerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 8)];
    cellBGImage = [[UIImage imageNamed:@"button-field-red"] stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    self.passwordField.background = cellBGImage;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    self.passwordField.leftView = fillerView;
    [fillerView release];
    
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
    
    if (self.profileSetupDelegate) {
        [self.profileSetupDelegate waitingForPassword];
    }
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.navigationController setNavigationBarHidden:YES];
    }
    
    self.titleLabel.text = self.title;
    [self setupContentSizeForOrientation:self.interfaceOrientation];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)back:(id)sender
{
    if (self.profileSetupDelegate) {
        [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:YES];
    }
    [super back:nil];
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

- (void)validate:(id)sender
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
            [self setEnablesBackButton:NO];
            [self.validateButton setEnabled:NO];
            [self.view endEditing:YES];
            
            dispatch_block_t afterEditingEnds = ^{
                __block SCHAccountValidationViewController *weakSelf = self;
                NSString *username = weakSelf.usernameField.text;
                
                if ([self.accountValidation validateWithUserName:username
                                                    withPassword:passwordField.text
                                                  updatePassword:NO
                                                       validateBlock:^(NSString *pToken, NSError *error) {
                    if (error != nil) {
                        weakSelf.passwordField.text = @"";
                        
                        self.promptLabel.text = NSLocalizedString(@"The e-mail address or password you entered does not match your account. Please try again.", nil);
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
                                    
                                    if ([weakSelf.passwordField.text isEqualToString:storedPassword] == NO) {
                                        [SFHFKeychainUtils storeUsername:username 
                                                             andPassword:weakSelf.passwordField.text 
                                                          forServiceName:kSCHAuthenticationManagerServiceName 
                                                          updateExisting:YES 
                                                                   error:nil];
                                    }
                                    
                                    weakSelf.passwordField.text = @"";
                                    id<SCHModalPresenterDelegate> targetDelegate = nil;
                                    if (weakSelf.profileSetupDelegate) {
                                        targetDelegate = weakSelf.profileSetupDelegate;
                                    } else if (weakSelf.settingsDelegate) {
                                        targetDelegate = weakSelf.settingsDelegate;
                                    }
                                    
                                    [targetDelegate presentWebParentToolsModallyWithToken:pToken 
                                                                                    title:weakSelf.title 
                                                                               modalStyle:UIModalPresentationFullScreen 
                                                                    shouldHideCloseButton:weakSelf.validatedControllerShouldHideCloseButton];                                    
                                } else {
                                    weakSelf.passwordField.text = @"";
                                }
                            }];                                                            
                    }
                    
                    [weakSelf.spinner stopAnimating];
                    [weakSelf setEnablesBackButton:YES];
                    [weakSelf.validateButton setEnabled:YES];            
                }] == NO) {
                    LambdaAlert *alert = [[LambdaAlert alloc]
                                          initWithTitle:NSLocalizedString(@"Password authentication unavailable", @"")
                                          message:NSLocalizedString(@"Please try again in a moment.", @"")];
                    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
                    [alert show];
                    [alert release];                
                    [self.spinner stopAnimating];
                    [self setEnablesBackButton:YES];
                    [self.validateButton setEnabled:YES];                        
                };
            };
            
            [self.view endEditing:YES];
            double delayInSeconds = 0.5; // We really need the keyboard to be off screen
            dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
            dispatch_after(popTime, dispatch_get_main_queue(), afterEditingEnds);
        }
    }
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
    [self validate:nil];
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

- (void)keyboardDidShow:(NSNotification *)notification
{
    if (self.activeTextField) {
        [self makeVisibleTextField:self.activeTextField];
    }
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, MAX(self.containerView.frame.size.height, self.scrollView.contentSize.height) * 1.5f)];
}

- (void)keyboardWillHide:(NSNotification *)notification
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
