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
#import "SCHParentalToolsWebViewController.h"
#import "SCHUserDefaults.h"

static const CGFloat kDeregisterContentHeightLandscape = 380;

@interface SCHAccountValidationViewController ()

@property (nonatomic, retain) SCHAccountValidation *accountValidation;
@property (nonatomic, retain) UITextField *activeTextField;

- (void)setupContentSizeForOrientation:(UIInterfaceOrientation)orientation;
- (void)makeVisibleTextField:(UITextField *)textField;

@end

@implementation SCHAccountValidationViewController

@synthesize accountValidation;
@synthesize promptLabel;
@synthesize passwordField;
@synthesize validateButton;
@synthesize spinner;
@synthesize scrollView;
@synthesize activeTextField;

- (void)releaseViewObjects
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    [promptLabel release], promptLabel = nil;
    [passwordField release], passwordField = nil;
    [validateButton release], validateButton = nil;
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
    [self setButtonBackground:self.validateButton];
    
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
    
    [self.profileSetupDelegate waitingForPassword];
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

- (void)validate:(id)sender
{
    if ([[passwordField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1) {
        LambdaAlert *alert = [[LambdaAlert alloc]
                              initWithTitle:NSLocalizedString(@"Error", @"error alert title")
                              message:NSLocalizedString(@"Incorrect password", @"error alert title")];
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
        
        __block SCHAccountValidationViewController *weakSelf = self;
        NSString *storedUsername = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerUsername];
        if ([self.accountValidation validateWithUserName:storedUsername withPassword:passwordField.text validateBlock:^(NSString *pToken, NSError *error) {
            if (error != nil) {
                LambdaAlert *alert = [[LambdaAlert alloc]
                                      initWithTitle:NSLocalizedString(@"Error", @"error alert title")
                                      message:[error localizedDescription]];
                [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
                [alert show];
                [alert release];        
            } else {
                weakSelf.passwordField.text = @"";
                SCHParentalToolsWebViewController *parentalToolsWebViewController = [[[SCHParentalToolsWebViewController alloc] init] autorelease];
                parentalToolsWebViewController.profileSetupDelegate = weakSelf.profileSetupDelegate;
                parentalToolsWebViewController.pToken = pToken;
                [weakSelf.navigationController pushViewController:parentalToolsWebViewController animated:YES];                
                // remove us from the view hiearachy - now we're no longer needed
                NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:weakSelf.navigationController.viewControllers];
                [viewControllers removeObject:weakSelf];     
                self.navigationController.viewControllers = [NSArray arrayWithArray:viewControllers];
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

@end
