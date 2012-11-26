//
//  SCHLoginPasswordViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 19/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHLoginPasswordViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "SCHCustomToolbar.h"
#import "SCHUnderlinedButton.h"

static const CGFloat kContentHeightLandscape = 380;

#pragma mark - Class Extension

@interface SCHLoginPasswordViewController ()

@property (nonatomic, retain) UITextField *activeTextField;

- (void)releaseViewObjects;
- (void)setupAccessibility;
- (void)makeVisibleTextField:(UITextField *)textField;

@end

#pragma mark -

@implementation SCHLoginPasswordViewController

@synthesize controllerType;
@synthesize actionBlock;
@synthesize cancelBlock;
@synthesize retainLoopSafeActionBlock;

@synthesize topField;
@synthesize bottomField;
@synthesize spinner;
@synthesize closeButton;
@synthesize backButton;
@synthesize profileLabel;
@synthesize containerView;
@synthesize shadowView;
@synthesize scrollView;
@synthesize forgotUsernamePasswordURL;
@synthesize accountURL;
@synthesize loginButton;
@synthesize activeTextField;
@synthesize promptLabel;

#pragma mark - Object Lifecycle

- (void)releaseViewObjects
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
	[topField release], topField = nil;
	[bottomField release], bottomField = nil;
	[spinner release], spinner = nil;
    [closeButton release], closeButton = nil;
    [profileLabel release], profileLabel = nil;
    [containerView release], containerView = nil;
    [shadowView release], shadowView = nil;
    [scrollView release], scrollView = nil;
    [forgotUsernamePasswordURL release], forgotUsernamePasswordURL = nil;
    [accountURL release], accountURL = nil;
    [loginButton release], loginButton = nil;
    [activeTextField release], activeTextField = nil;
    [promptLabel release], promptLabel = nil;
    [backButton release], backButton = nil;
}

- (void)dealloc 
{
    [actionBlock release], actionBlock = nil;
    [cancelBlock release], cancelBlock = nil;
    [retainLoopSafeActionBlock release], retainLoopSafeActionBlock = nil;
	
    [self releaseViewObjects];    
    [super dealloc];
}


- (void)viewDidUnload 
{
    [super viewDidUnload];
    [self releaseViewObjects];    
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
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
    
    UIImage *stretchedFieldImage = [[UIImage imageNamed:@"textfield_wht_3part"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    [self.topField setBackground:stretchedFieldImage];
    [self.bottomField setBackground:stretchedFieldImage];
    
    UIImage *stretchedButtonImage = [[UIImage imageNamed:@"lg_bttn_gray_UNselected_3part"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    [self.loginButton setBackgroundImage:stretchedButtonImage forState:UIControlStateNormal];
    [self.closeButton setBackgroundImage:stretchedButtonImage forState:UIControlStateNormal];
    
    UIImage *backButtonImage = [[UIImage imageNamed:@"bookshelf_arrow_bttn_UNselected_3part"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
    [self.backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
    
    self.shadowView.layer.shadowOpacity = 0.5f;
    self.shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    self.shadowView.layer.shadowRadius = 4.0f;
    self.shadowView.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.cornerRadius = 10.0f;
    
//    UIView *fillerView = nil;

    
//    UIImage *cellBGImage = [bgImage stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    
//    if (self.topField) {
//        self.topField.background = cellBGImage;
//        self.topField.leftViewMode = UITextFieldViewModeAlways;
//        fillerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 8)];
//        self.topField.leftView = fillerView;
//        [fillerView release];
//    }
//    
//    if (self.bottomField) {
//        self.bottomField.background = cellBGImage;
//        self.bottomField.leftViewMode = UITextFieldViewModeAlways;
//        fillerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 8)];
//        self.bottomField.leftView = fillerView;
//        [fillerView release];
//    }
    
    
    [self setupAccessibility];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    [self stopShowingProgress];
    [self clearFields];
    [self setDisplayIncorrectCredentialsWarning:kSCHLoginHandlerCredentialsWarningNone];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.view.layer setCornerRadius:10];
        [self.view setClipsToBounds:YES];
    }
}

#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
    } else {
        return (UIInterfaceOrientationIsPortrait(interfaceOrientation));
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
//    [self.view endEditing:YES];
}

- (void)setupAccessibility
{
    switch (self.controllerType) {
        case kSCHControllerParentToolsView:
            self.scrollView.accessibilityLabel = @"ParentTools View";
            break;
        case kSCHControllerLoginView:
            self.scrollView.accessibilityLabel = @"Login View";
            self.loginButton.accessibilityLabel = @"Login View Sign In Button";
            break;
        default:
            self.scrollView.accessibilityLabel = nil;
            break;
    }
}

#pragma mark - Username and Password accessors

- (NSString *)username
{
    return self.topField.text;
}

- (NSString *)password
{
    return self.bottomField.text;
}

#pragma mark - External Behaviour Changing

- (void)startShowingProgress
{
 	[self.topField resignFirstResponder];
    self.topField.enabled = NO;
	[self.bottomField resignFirstResponder];
    self.bottomField.enabled = NO;
    [spinner startAnimating];
    self.forgotUsernamePasswordURL.enabled = NO;
    self.accountURL.enabled = NO;
    self.loginButton.enabled = NO;
    self.closeButton.enabled = NO;
}

- (void)stopShowingProgress
{
    self.topField.enabled = YES;
    self.bottomField.enabled = YES;
    [spinner stopAnimating];
    self.forgotUsernamePasswordURL.enabled = YES;
    self.accountURL.enabled = YES;    
    self.loginButton.enabled = YES;
    self.closeButton.enabled = YES;
}

- (void)clearFields
{
    self.topField.text = @"";
    self.bottomField.text = @"";
    [self.loginButton setEnabled:YES];
}

- (void)clearBottomField
{
    self.bottomField.text = @"";
}

- (void)setDisplayIncorrectCredentialsWarning:(SCHLoginHandlerCredentialsWarning)credentialsWarning
{
    self.promptLabel.alpha = 1;
    switch (credentialsWarning) {
        case kSCHLoginHandlerCredentialsWarningNone:
            self.promptLabel.alpha = 0;
            self.promptLabel.text = NSLocalizedString(@"To start reading your eBooks, enter your Scholastic User Name and Password.", @"");
            break;
        case kSCHLoginHandlerCredentialsWarningMalformedEmail:
            self.promptLabel.text = NSLocalizedString(@"Please enter a valid e-mail address.", @"");
            break;
        case kSCHLoginHandlerCredentialsWarningAuthenticationFailure:
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                self.promptLabel.text = NSLocalizedString(@"The password you entered is not correct. If you have forgotten your password, you can ask your parent to reset it using the Reading Manager.", @"");
            } else {
                self.promptLabel.text = NSLocalizedString(@"Your password was incorrect. Ask your parent or teacher to reset your password.", @"");
            }
            break;
        case kSCHLoginHandlerCredentialsWarningPasswordLeadingSpaces:
            self.promptLabel.text = NSLocalizedString(@"You cannot use spaces at the beginning of your password.", @"");
            break;
        case kSCHLoginHandlerCredentialsWarningPasswordMismatch:
            self.promptLabel.text = NSLocalizedString(@"Your password does not match. Try again.", @"");
            break;
        case kSCHLoginHandlerCredentialsWarningPasswordBlank:
            self.promptLabel.text = NSLocalizedString(@"The password cannot be blank.", @"");
            break;
    }
}

#pragma mark - Button Actions

- (IBAction)actionButtonAction:(id)sender
{
    NSAssert(self.actionBlock != nil || self.retainLoopSafeActionBlock != nil, @"Action block must be set!");
    
    
    
    [CATransaction begin];
    [CATransaction setCompletionBlock:^{
    
    if (self.actionBlock) {
        
        self.actionBlock();
    } else if (self.retainLoopSafeActionBlock) {
        
        BOOL good = self.retainLoopSafeActionBlock(self.topField ? [NSString stringWithString:self.topField.text] : nil,
                                                    self.bottomField ? [NSString stringWithString:self.bottomField.text] : nil);
        if (good) {
            [self startShowingProgress];
        } else {
            [self clearFields];
        }
    }
    }];
    
    [self.view endEditing:YES];
    [CATransaction commit];
}

- (IBAction)cancelButtonAction:(id)sender
{
    [self.view endEditing:YES];
    [self clearFields];
    
    if (self.cancelBlock) {
        self.cancelBlock();
    } else {
        [self dismissModalViewControllerAnimated:YES];	
    }
}

- (IBAction)openScholasticUsernamePasswordURLInSafari:(id)sender
{
    if (((SCHUnderlinedButton *)sender).enabled == YES) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://my.scholastic.com/sps_my_account/pwmgmt/ForgotPassword.jsp?AppType=COOL"]];
    }
}

- (IBAction)openScholasticAccountURLInSafari:(id)sender
{
    if (((SCHUnderlinedButton *)sender).enabled == YES) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://my.scholastic.com/sps_my_account/accmgmt/GenericSignin.jsp?AppType=COOL"]];
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self.shadowView setTransform:CGAffineTransformIdentity];
    }

    switch (self.controllerType) {
        case kSCHControllerLoginView:
        case kSCHControllerDoublePasswordView:
        {
            if (textField == self.topField) {
                [self.bottomField becomeFirstResponder];
                return YES;
            }
            
            if (textField == self.bottomField && [self.topField.text length] > 0 && [self.bottomField.text length] > 0) {
                [self.bottomField resignFirstResponder];
                [self actionButtonAction:nil];
            }
            
            return YES;
            break;
        }  
        case kSCHControllerPasswordOnlyView:
        {
            if (textField == self.bottomField && [self.bottomField.text length] > 0) {
                [self actionButtonAction:nil];
            }
            return YES;
            break;
        }
        case kSCHControllerParentToolsView:
        {
            if (textField == self.bottomField && [self.bottomField.text length] > 0) {
                [self actionButtonAction:nil];
            }
            return YES;
            break;
        }            
        default:
            NSLog(@"Unknown controller mode!");
            return NO;
            break;
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (self.activeTextField && (self.activeTextField != textField)) {
            // We have swapped textFields with the keyboard showing
            [self makeVisibleTextField:textField];
        }
        
        self.activeTextField = textField;

        if (self.controllerType == kSCHControllerPasswordOnlyView) {
            [self.shadowView setTransform:CGAffineTransformMakeTranslation(0, -132)];
        } else if (self.controllerType == kSCHControllerDoublePasswordView) {
            [self.shadowView setTransform:CGAffineTransformMakeTranslation(0, -123)];
        }
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
}

#pragma mark - Touch Handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
