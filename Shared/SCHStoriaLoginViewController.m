//
//  SCHStoriaLoginViewController.m
//  Scholastic
//
//  Created by Matt Farrugia on 04/01/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHStoriaLoginViewController.h"

@interface SCHStoriaLoginViewController()

- (void)releaseViewObjects;

@end

@implementation SCHStoriaLoginViewController

@synthesize loginBlock;
@synthesize previewBlock;
@synthesize topField;
@synthesize bottomField;
@synthesize loginButton;

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
    self.topField.enabled = NO;
	[self.bottomField resignFirstResponder];
    self.bottomField.enabled = NO;
    //[spinner startAnimating];
    //self.forgotUsernamePasswordURL.enabled = NO;
    //self.accountURL.enabled = NO;
    self.loginButton.enabled = NO;
    //self.closeButton.enabled = NO;
}

- (void)stopShowingProgress
{
    self.topField.enabled = YES;
    self.bottomField.enabled = YES;
    //[spinner stopAnimating];
    //self.forgotUsernamePasswordURL.enabled = YES;
    //self.accountURL.enabled = YES;    
    self.loginButton.enabled = YES;
    //self.closeButton.enabled = YES;
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

@end
