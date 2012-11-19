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
#import <QuartzCore/QuartzCore.h>

static const CGFloat kSCHStoriaLoginContentHeightLandscape = 420;

@interface SCHStoriaLoginViewController() <UITextFieldDelegate>

- (void)releaseViewObjects;
- (void)showAppVersionOutdatedAlert;

@end

@implementation SCHStoriaLoginViewController

@synthesize loginBlock;
@synthesize previewBlock;
@synthesize samplesBlock;
@synthesize topField;
@synthesize bottomField;
@synthesize loginButton;
@synthesize previewButton;
@synthesize spinner;
@synthesize promptLabel;
@synthesize showSamples;
@synthesize samplesButton;
@synthesize containerView;
@synthesize centeringContainerView;

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
    [topField release], topField = nil;
    [bottomField release], bottomField = nil;
    [loginButton release], loginButton = nil;
    [previewButton release], previewButton = nil;
    [spinner release], spinner = nil;
    [promptLabel release], promptLabel = nil;
    [containerView release], containerView = nil;
    [centeringContainerView release], centeringContainerView = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    [previewBlock release], previewBlock = nil;
    [samplesBlock release], samplesBlock = nil;
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
    
    UIColor *promptColor = [UIColor colorWithWhite:0.202 alpha:1.000];
    
    NSMutableDictionary *mutableLinkAttributes = [NSMutableDictionary dictionary];
    [mutableLinkAttributes setValue:[NSNumber numberWithBool:NO] forKey:(NSString *)kCTUnderlineStyleAttributeName];
    [mutableLinkAttributes setValue:(id)[promptColor CGColor] forKey:(NSString*)kCTForegroundColorAttributeName];
    
    self.promptLabel.linkAttributes = [NSDictionary dictionaryWithDictionary:mutableLinkAttributes];
    
    UIImage *stretchedFieldImage = [[UIImage imageNamed:@"textfield_wht_3part"] stretchableImageWithLeftCapWidth:7 topCapHeight:0];
    [self.topField setBackground:stretchedFieldImage];
    [self.bottomField setBackground:stretchedFieldImage];

    UIImage *stretchedRedButtonImage = [[UIImage imageNamed:@"btn-red"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
    [self.loginButton setBackgroundImage:stretchedRedButtonImage forState:UIControlStateNormal];
    
    UIImage *stretchedGreyButtonImage = [[UIImage imageNamed:@"greytourbutton"] stretchableImageWithLeftCapWidth:6 topCapHeight:0];
    [self.samplesButton setBackgroundImage:stretchedGreyButtonImage forState:UIControlStateNormal];
    [self.previewButton setBackgroundImage:stretchedGreyButtonImage forState:UIControlStateNormal];

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
    [self.samplesButton setHidden:!self.showSamples];
    
    [self stopShowingProgress];
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

- (void)setShowSamples:(BOOL)newShowSamples
{
    showSamples = newShowSamples;
    [self.samplesButton setHidden:!showSamples];
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

- (IBAction)samplesButtonAction:(id)sender
{
    [self.view endEditing:YES];
    [self clearFields];
    
    if (self.samplesBlock) {
        self.samplesBlock();
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
    CGFloat promptAlpha = 0;
    CGFloat promptHeight = 20;
    CGFloat phoneContainerHeight = 300;
    
    CGAffineTransform containerTransform = CGAffineTransformIdentity;

    switch (credentialsWarning) {
        case kSCHLoginHandlerCredentialsWarningNone:
            break;
        case kSCHLoginHandlerCredentialsWarningMalformedEmail:
            promptText = NSLocalizedString(@"Please enter a valid E-mail Address.", @"");
            promptAlpha = 1;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                phoneContainerHeight = 288;
                promptHeight = 32;
            }
            break;
        case kSCHLoginHandlerCredentialsWarningAuthenticationFailure:
            promptText = NSLocalizedString(@"Your e-mail address or password was not recognized. Please try again, or contact Scholastic customer service at storia@scholastic.com.", @"");
            promptAlpha = 1;
            promptHeight = 48;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                containerTransform = CGAffineTransformMakeTranslation(0, 36);
            } else {
               phoneContainerHeight = 268;
            }
            break;
        default:
            break;
    }
    
    self.promptLabel.text = promptText;
    self.promptLabel.alpha = promptAlpha;
    
    CGRect promptFrame = self.promptLabel.frame;
    promptFrame.size.height = promptHeight;
    self.promptLabel.frame = promptFrame;
    self.containerView.transform = containerTransform;

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        CGRect containerFrame = self.containerView.frame;
        containerFrame.size.height = phoneContainerHeight;
        containerFrame.origin.y = CGRectGetHeight(self.centeringContainerView.frame) - phoneContainerHeight;
        self.containerView.frame = containerFrame;
    }
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self setDisplayIncorrectCredentialsWarning:kSCHLoginHandlerCredentialsWarningNone];

    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.topField) {
        [self.bottomField becomeFirstResponder];
    } else if (textField == self.bottomField) {
        [self.bottomField resignFirstResponder];
        [self loginButtonAction:nil];
    } else {
        [self.view endEditing:YES];
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

#pragma mark - TTTAttributedLabelDelegate

- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url
{
    if (url) {
        [[UIApplication sharedApplication] openURL:url];
    }
}

#pragma mark - Touch Handling

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self.view endEditing:YES];
}

@end
