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

static const CGFloat kDeregisterContentHeightLandscape = 380;

@interface SCHDeregisterDeviceViewController ()

@property (nonatomic, retain) UITextField *activeTextField;
@property (nonatomic, retain) SCHAccountValidation *accountValidation;

- (void)setupContentSizeForOrientation:(UIInterfaceOrientation)orientation;
- (void)makeVisibleTextField:(UITextField *)textField;

@end

@implementation SCHDeregisterDeviceViewController

@synthesize promptLabel;
@synthesize passwordField;
@synthesize deregisterButton;
@synthesize spinner;
@synthesize scrollView;
@synthesize activeTextField;
@synthesize accountValidation;

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
    self.promptLabel.text = [NSString stringWithFormat:self.promptLabel.text, username];
    
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
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(authenticationManagerDidFailDeregistration:)
                                                 name:SCHAuthenticationManagerDidFailDeregistrationNotification
                                               object:nil];
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

#pragma mark - Actions

- (void)deregister:(id)sender
{
    [self.deregisterButton setEnabled:NO];
    
    if ([[self.passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Error", @"error alert title")
                              message:NSLocalizedString(@"Incorrect password", @"error alert title")];
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
        [self setEnablesBackButton:NO];
        if ([self.accountValidation validateWithUserName:storedUsername withPassword:self.passwordField.text validateBlock:^(NSString *pToken, NSError *error) {
            if (error != nil) {
                LambdaAlert *alert = [[LambdaAlert alloc]
                                      initWithTitle:NSLocalizedString(@"Error", @"error alert title")
                                      message:[error localizedDescription]];
                [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
                    [weakSelf.deregisterButton setEnabled:YES];
                    [weakSelf.spinner stopAnimating];
                    [weakSelf setEnablesBackButton:YES];                                    
                }];
                [alert show];
                [alert release]; 
            } else {
                if ([[SCHAuthenticationManager sharedAuthenticationManager] isAuthenticated] == YES) {
                    [[SCHAuthenticationManager sharedAuthenticationManager] deregister];            
                } else {
                    [[SCHAuthenticationManager sharedAuthenticationManager] authenticate];
                    LambdaAlert *alert = [[LambdaAlert alloc]
                                          initWithTitle:NSLocalizedString(@"Error", @"error alert title")
                                          message:NSLocalizedString(@"Waiting for the server, please try again in a moment. If this problem persists please contact support.", nil)];
                    [alert addButtonWithTitle:NSLocalizedString(@"Try Again", @"try again button after no authentication") block:^{
                        [weakSelf.deregisterButton setEnabled:YES];
                        [weakSelf.spinner stopAnimating];
                        [weakSelf setEnablesBackButton:YES];                                            
                    }];
                    [alert show];
                    [alert release];        
                }                
            }    
        }] == NO) {
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Password authentication unavailable", @"")
                                  message:NSLocalizedString(@"Please try again in a moment.", @"")];
            [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
                [self.deregisterButton setEnabled:YES];
                [self.spinner stopAnimating];
                [self setEnablesBackButton:YES];                                
            }];
            [alert show];
            [alert release];                
        };
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

#pragma mark - Deregistration Notification methods

- (void)authenticationManagerDidFailDeregistration:(NSNotification *)notification
{
    [self.spinner stopAnimating];
    NSError *error = [[notification userInfo] objectForKey:kSCHAuthenticationManagerNSError];
    LambdaAlert *alert = [[LambdaAlert alloc]
                          initWithTitle:NSLocalizedString(@"Error", @"Error") 
                          message:[error localizedDescription]];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"OK") block:^{
        [self setEnablesBackButton:YES];
        [self.deregisterButton setEnabled:YES];        
    }];
    [alert show];
    [alert release];
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

@end
