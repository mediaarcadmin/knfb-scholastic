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
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)setupContentSizeForOrientation:(UIInterfaceOrientation)orientation;
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
@synthesize topBar;
@synthesize barSpacer;
@synthesize closeButton;
@synthesize profileLabel;
@synthesize containerView;
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
    [topBar release], topBar = nil;
    [barSpacer release], barSpacer = nil;
    [closeButton release], closeButton = nil;
    [profileLabel release], profileLabel = nil;
    [containerView release], containerView = nil;
    [scrollView release], scrollView = nil;
    [forgotUsernamePasswordURL release], forgotUsernamePasswordURL = nil;
    [accountURL release], accountURL = nil;
    [loginButton release], loginButton = nil;
    [activeTextField release], activeTextField = nil;
    [promptLabel release], promptLabel = nil;
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
    
    [self.scrollView setAlwaysBounceVertical:NO];
    
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
    
    UIView *fillerView = nil;
    UIImage *bgImage;
    
    if (self.controllerType == kSCHControllerParentToolsView) {
        bgImage = [UIImage imageNamed:@"button-field-red"];
    } else {
        bgImage = [UIImage imageNamed:@"button-field"];
    }
    
    UIImage *cellBGImage = [bgImage stretchableImageWithLeftCapWidth:15 topCapHeight:0];
    
    if (self.topField) {
        self.topField.background = cellBGImage;
        self.topField.leftViewMode = UITextFieldViewModeAlways;
        fillerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 8)];
        self.topField.leftView = fillerView;
        [fillerView release];
    }
    
    if (self.bottomField) {
        self.bottomField.background = cellBGImage;
        self.bottomField.leftViewMode = UITextFieldViewModeAlways;
        fillerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 10, 8)];
        self.bottomField.leftView = fillerView;
        [fillerView release];
    }
    
    if (self.loginButton) {
        if (self.controllerType == kSCHControllerParentToolsView) {
             bgImage = [UIImage imageNamed:@"button-login-red"];
        } else {
            bgImage = [UIImage imageNamed:@"button-login"];
        }
        cellBGImage = [bgImage stretchableImageWithLeftCapWidth:11 topCapHeight:0];
        [self.loginButton setBackgroundImage:cellBGImage forState:UIControlStateNormal];
    }
    
    [self setupAccessibility];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    [self stopShowingProgress];
    [self setupAssetsForOrientation:self.interfaceOrientation];
    [self setupContentSizeForOrientation:self.interfaceOrientation];
    [self clearFields];
    [self setDisplayIncorrectCredentialsWarning:NO];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIColor *borderColor;
        if (self.controllerType == kSCHControllerParentToolsView) {
            borderColor = [UIColor SCHRed2Color];
        } else {
            borderColor = [UIColor SCHBlue3Color];
        }
        [self.navigationController.view.layer setBorderColor:borderColor.CGColor];
        [self.navigationController.view.layer setBorderWidth:2.0f];
    }
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.topField ?: self.bottomField becomeFirstResponder];
    }
}

#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.view endEditing:YES];
    [self setupContentSizeForOrientation:self.interfaceOrientation];
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

- (void)setupContentSizeForOrientation:(UIInterfaceOrientation)orientation;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            self.scrollView.contentSize = CGSizeZero;
        } else {
            self.scrollView.contentSize = CGSizeMake(self.containerView.bounds.size.width, kContentHeightLandscape);
        }
    } else {
        self.scrollView.contentSize = CGSizeZero;
    }    
}

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    CGRect barFrame       = self.topBar.frame;
    UIImage *toolbarImage = nil;
    UIColor *borderColor  = nil;
    
    barFrame.origin = CGPointZero;
    barFrame.size.width = CGRectGetWidth(self.view.bounds);
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        barFrame.size.height = 44;
        
        switch (self.controllerType) {
            case kSCHControllerPasswordOnlyView:
            case kSCHControllerDoublePasswordView:
            case kSCHControllerLoginView:
                toolbarImage = [UIImage imageNamed:@"login-ipad-top-toolbar.png"];
                borderColor  = [UIColor SCHBlue1Color];
                break;
            default:
                toolbarImage = [UIImage imageNamed:@"settings-ipad-top-toolbar.png"];
                borderColor  = [UIColor SCHRed3Color];
                break;
        }
        
        [self.view.layer setBorderColor:borderColor.CGColor];
        [self.view.layer setBorderWidth:2.0f];
    } else {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            toolbarImage = [UIImage imageNamed:@"admin-iphone-portrait-top-toolbar.png"];
            barFrame.size.height = 44;
            [self.barSpacer setWidth:0];
        } else {
            toolbarImage = [UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"];
            barFrame.size.height = 32;
            switch (self.controllerType) {
                case kSCHControllerLoginView:
                case kSCHControllerPasswordOnlyView:
                case kSCHControllerDoublePasswordView:
                case kSCHControllerParentToolsView:
                    [self.barSpacer setWidth:38];
                    break;
                default:
                    [self.barSpacer setWidth:0];
                    break;
            }
        }
    }

    [self.topBar setBackgroundImage:toolbarImage];
    
    CGRect containerFrame = self.containerView.frame;
    CGFloat containerMaxY = CGRectGetMaxY(containerFrame);
    containerFrame.origin.y = CGRectGetMaxY(barFrame);
    containerFrame.size.height = containerMaxY - containerFrame.origin.y;
    self.topBar.frame = barFrame;
    self.containerView.frame = containerFrame;    
    
    self.scrollView.contentSize = containerFrame.size;
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

- (void)setDisplayIncorrectCredentialsWarning:(BOOL)showWarning
{
    if (showWarning) {
        self.promptLabel.text = NSLocalizedString(@"Your User Name or Password was not recognized. Please try again.", @"");
    } else {
        self.promptLabel.text = NSLocalizedString(@"To start reading your eBooks, enter your Scholastic User Name and Password.", @"");
    }
}

#pragma mark - Button Actions

- (IBAction)actionButtonAction:(id)sender
{
    NSAssert(self.actionBlock != nil || self.retainLoopSafeActionBlock != nil, @"Action block must be set!");
    
    if (self.actionBlock) {
        [self.view endEditing:YES];
        self.actionBlock();
    } else if (self.retainLoopSafeActionBlock) {
        BOOL good = self.retainLoopSafeActionBlock(self.topField ? [NSString stringWithString:self.topField.text] : nil,
                                                    self.bottomField ? [NSString stringWithString:self.bottomField.text] : nil);
        if (good) {
            [self.view endEditing:YES];
            [self startShowingProgress];
        } else {
            [self clearFields];
            [self.topField ?: self.bottomField becomeFirstResponder];
        }
    }
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

@end
