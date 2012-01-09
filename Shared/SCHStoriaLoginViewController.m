//
//  SCHStoriaLoginViewController.m
//  Scholastic
//
//  Created by Matt Farrugia on 04/01/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHStoriaLoginViewController.h"

@interface SCHStoriaLoginViewController() <UITextFieldDelegate>

- (void)releaseViewObjects;

@end

@implementation SCHStoriaLoginViewController

@synthesize loginBlock;
@synthesize previewBlock;
@synthesize topField;
@synthesize bottomField;
@synthesize loginButton;
@synthesize spinner;

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
    [spinner release], spinner = nil;
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    [self releaseViewObjects];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

#pragma mark - Actions

- (IBAction)loginButtonAction:(id)sender
{
    NSAssert(self.loginBlock != nil, @"Login block must be set!");
    
    if (self.loginBlock) {
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
}

- (void)stopShowingProgress
{
    [self.topField setEnabled:YES];
    [self.bottomField setEnabled:YES];
    [self.spinner stopAnimating];
    [self.loginButton setEnabled:YES];
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

- (void)setDisplayIncorrectCredentialsWarning:(BOOL)showWarning
{
    
}

#pragma mark - UITextFieldDelegate

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

@end
