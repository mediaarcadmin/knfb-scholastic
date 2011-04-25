//
//  SCHLoginViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 19/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHLoginViewController.h"

#import "SCHAuthenticationManager.h"
#import "SCHSyncManager.h"
#import "SCHURLManager.h"
#import "SCHCustomToolbar.h"

@interface SCHLoginViewController ()

- (void)releaseViewObjects;

@end

@implementation SCHLoginViewController

@synthesize userName;
@synthesize password;
@synthesize loginButton;
@synthesize cancelButton;
@synthesize spinner;
@synthesize topBar;

- (void)releaseViewObjects
{
	self.userName = nil;
	self.password = nil;
	self.loginButton = nil;
	self.cancelButton = nil;
	self.spinner = nil;
    self.topBar = nil;
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [self releaseViewObjects];    
    [super dealloc];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (YES);
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    topBar.items = [NSArray arrayWithObjects:
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], 
                    [[UIBarButtonItem alloc] initWithCustomView:headerImage],
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], nil];
    [headerImage release];
    
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        [topBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
    } else {
        [topBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-portrait-top-toolbar.png"]];
    }
	self.userName.text = @"";
	self.password.text = @"";
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.userName becomeFirstResponder];
}


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (UIInterfaceOrientationIsLandscape(toInterfaceOrientation)) {
        [topBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
    } else {
        [topBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-portrait-top-toolbar.png"]];
    }
}

- (void)authenticationManager:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[spinner stopAnimating];
	self.loginButton.enabled = YES;
	self.cancelButton.enabled = YES;

	if ([notification.name compare:kSCHAuthenticationManagerSuccess] == NSOrderedSame) {
		[[SCHURLManager sharedURLManager] clear];
		[[SCHSyncManager sharedSyncManager] clear];
		[[SCHSyncManager sharedSyncManager] firstSync];
		[self dismissModalViewControllerAnimated:YES];	
	} else {
		NSError *error = [notification.userInfo objectForKey:kSCHAuthenticationManagerNSError];
		if (error!= nil) {
			UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
																 message:[error localizedDescription]
																delegate:nil 
													   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
													   otherButtonTitles:nil]; 
			[errorAlert show]; 
			[errorAlert release];
		}		
	}
}

- (IBAction)login:(id)sender
{
	[self.userName resignFirstResponder];
	[self.password resignFirstResponder];
				
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerSuccess object:nil];			
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerFailure object:nil];					
	
	[[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithUserName:[self.userName text] withPassword:[self.password text]];
    [spinner startAnimating];
    self.loginButton.enabled = NO;
    self.cancelButton.enabled = NO;
}

- (IBAction)cancel:(id)sender
{
	[self.userName resignFirstResponder];
	[self.password resignFirstResponder];
	
	[self dismissModalViewControllerAnimated:YES];	
}

- (void)removeCancelButton
{
	CGPoint center = self.loginButton.center;
	center.x = self.view.superview.center.x;
	self.loginButton.center = center;
	
	self.cancelButton.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == userName) {
        [password becomeFirstResponder];
        return YES;
    }
    
    if (textField == password && [userName.text length] > 0 && [password.text length] > 0) {
        [password resignFirstResponder];
        [self login:nil];
    }
    
    return YES;
}

// The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
/*
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization.
    }
    return self;
}
*/

/*
// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [self releaseViewObjects];    
}

@end
