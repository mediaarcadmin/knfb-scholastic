//
//  SCHStoriaLoginViewController.m
//  Scholastic
//
//  Created by Matt Farrugia on 04/01/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHStoriaLoginViewController.h"

#import "SCHVersionDownloadManager.h"
#import "LambdaAlert.h"

static const CGFloat kSCHStoriaLoginContentHeightLandscape = 420;

@interface SCHStoriaLoginViewController() <UITextFieldDelegate>

- (void)releaseViewObjects;
- (void)showAppVersionOutdatedAlert;
- (void)setupContentSizeForOrientation:(UIInterfaceOrientation)orientation;

@property (nonatomic, retain) UITextField *activeTextField;

@end

@implementation SCHStoriaLoginViewController

@synthesize loginBlock;
@synthesize previewBlock;
@synthesize topFieldLabel;
@synthesize topField;
@synthesize bottomField;
@synthesize loginButton;
@synthesize previewButton;
@synthesize spinner;
@synthesize promptLabel;
@synthesize activeTextField;
@synthesize scrollView;
@synthesize backgroundView;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)releaseViewObjects
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] removeObserver:self];
    }
    
    [topFieldLabel release], topFieldLabel = nil;
    [topField release], topField = nil;
    [bottomField release], bottomField = nil;
    [loginButton release], loginButton = nil;
    [previewButton release], previewButton = nil;
    [spinner release], spinner = nil;
    [promptLabel release], promptLabel = nil;
    [activeTextField release], activeTextField = nil;
    [scrollView release], scrollView = nil;
    [backgroundView release], backgroundView = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    [previewBlock release], previewBlock = nil;
    [loginBlock release], loginBlock = nil;
    
    [super dealloc];
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.promptLabel.dataDetectorTypes = UIDataDetectorTypeAll;
    self.promptLabel.delegate = self;
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [mutableLinkAttributes setValue:(id)[[UIColor colorWithRed:0.056 green:0.367 blue:0.577 alpha:1] CGColor] forKey:(NSString*)kCTForegroundColorAttributeName];
    } else {
        [mutableLinkAttributes setValue:(id)[[UIColor colorWithRed:0.256 green:0.667 blue:0.877 alpha:1] CGColor] forKey:(NSString*)kCTForegroundColorAttributeName];
    }
    
    [mutableLinkAttributes setValue:[NSNumber numberWithBool:YES] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    self.promptLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];


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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self releaseViewObjects];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    [self stopShowingProgress];
    [self setupContentSizeForOrientation:self.interfaceOrientation];
    [self clearFields];
    
    [self setDisplayIncorrectCredentialsWarning:kSCHLoginHandlerCredentialsWarningNone];    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [CATransaction begin];
        [CATransaction setAnimationDuration:duration];
        [self setupContentSizeForOrientation:toInterfaceOrientation];
        [CATransaction commit];
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.view endEditing:YES];
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self setupContentSizeForOrientation:self.interfaceOrientation];
    }
}

- (void)setupContentSizeForOrientation:(UIInterfaceOrientation)orientation;
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            self.scrollView.contentSize = CGSizeZero;
            self.backgroundView.transform = CGAffineTransformIdentity;
        } else {
            self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, kSCHStoriaLoginContentHeightLandscape);
            self.backgroundView.transform = CGAffineTransformTranslate(CGAffineTransformMakeScale(1.5f, 1.5f), 0, -76);
        }
    }   
}

#pragma mark - Actions

- (IBAction)loginButtonAction:(id)sender
{
    NSAssert(self.loginBlock != nil, @"Login block must be set!");
    
    if ([[SCHVersionDownloadManager sharedVersionManager] isAppVersionOutdated] == YES) {
        [self showAppVersionOutdatedAlert];
    } else if (self.loginBlock) {
        self.loginBlock(self.topField ? [NSString stringWithString:self.topField.text] : nil,
                        self.bottomField ? [NSString stringWithString:self.bottomField.text] : nil);
    }
}

- (IBAction)previewButtonAction:(id)sender
{
    [self.view endEditing:YES];
    [self clearFields];
    
    if (self.previewBlock) {
        self.previewBlock();
    }
}

#pragma mark - SCHLoginHandlerDelegate

- (void)startShowingProgress
{
 	[self.topField resignFirstResponder];
    [self.topField setEnabled:NO];
	[self.bottomField resignFirstResponder];
    [self.bottomField setEnabled:NO];
    [self.spinner startAnimating];
    [self.loginButton setEnabled:NO];
    [self setDisplayIncorrectCredentialsWarning:kSCHLoginHandlerCredentialsWarningNone];
    [self.previewButton setEnabled:NO];
}

- (void)stopShowingProgress
{
    [self.topField setEnabled:YES];
    [self.bottomField setEnabled:YES];
    [self.spinner stopAnimating];
    [self.loginButton setEnabled:YES];
    [self.previewButton setEnabled:YES];
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
    [self.loginButton setEnabled:YES];
}

- (void)setDisplayIncorrectCredentialsWarning:(SCHLoginHandlerCredentialsWarning)credentialsWarning
{
        NSString *promptText = nil;
        
        switch (credentialsWarning) {
            case kSCHLoginHandlerCredentialsWarningNone:
                promptText = NSLocalizedString(@"You must have a Scholastic account to sign in.", @"");
                break;
            case kSCHLoginHandlerCredentialsWarningMalformedEmail:
                promptText = NSLocalizedString(@"Please enter a valid E-mail Address.", @"");
                break;
            case kSCHLoginHandlerCredentialsWarningAuthenticationFailure:  
                promptText = NSLocalizedString(@"Your E-mail Address or Password was not recognized. Please try again or contact Scholastic customer service at storia@scholastic.com.", @"");
                break;
        }
    
        self.promptLabel.text = promptText;

}

#pragma mark - UITextFieldDelegate

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

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.topField) {
        [self.bottomField becomeFirstResponder];
    }
    
    if (textField == self.bottomField && [self.topField.text length] > 0 && [self.bottomField.text length] > 0) {
        [self.bottomField resignFirstResponder];
        [self loginButtonAction:nil];
    }
    
    return YES;
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

#pragma mark - UIKeyboard Notifications

- (void)keyboardDidShow:(NSNotification *) notification
{
    if (self.activeTextField) {
        [self makeVisibleTextField:self.activeTextField];
    }
}

- (void)keyboardWillShow:(NSNotification *) notification
{
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, MAX(self.view.frame.size.height, self.scrollView.contentSize.height) * 1.5f)];
    } else {
        [self.scrollView setContentSize:CGSizeMake(self.scrollView.contentSize.width, kSCHStoriaLoginContentHeightLandscape * 1.4)];
    }
}

- (void)keyboardWillHide:(NSNotification *) notification
{
    self.activeTextField = nil;
    [self setupContentSizeForOrientation:self.interfaceOrientation];
}

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if (url) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

@end
