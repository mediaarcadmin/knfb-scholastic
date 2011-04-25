//
//  SCHProfilePasswordViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 16/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfilePasswordViewController.h"

#import "SCHProfileItem.h"
#import "SCHSyncManager.h"
#import "SCHCustomToolbar.h"

@interface SCHProfilePasswordViewController ()

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)authenticatePassword;
- (void)setPassword;
- (void)releaseViewObjects;

@end

@implementation SCHProfilePasswordViewController

@synthesize newPasswordMessage;
@synthesize password;
@synthesize confirmPassword;
@synthesize profileItem;
@synthesize setPasswordMode;
@synthesize managedObjectContext;
@synthesize delegate;
@synthesize topBar;

#pragma mark - Object lifecycle

- (void)releaseViewObjects 
{
	[newPasswordMessage release], newPasswordMessage = nil;
	[password release], password = nil;
	[confirmPassword release], confirmPassword = nil;	
    [topBar release], topBar = nil;
}

- (void)dealloc 
{
	[self releaseViewObjects];
	
	[profileItem release], profileItem = nil;
	[managedObjectContext release], managedObjectContext = nil;
	
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewWillAppear:(BOOL)animated	
{
	[super viewWillAppear:animated];

	self.setPasswordMode = [self.profileItem hasPassword] == NO;
	
	self.newPasswordMessage.hidden = !self.setPasswordMode;
	self.password.text = @"";
	self.password.returnKeyType = ( self.setPasswordMode == NO ? UIReturnKeyDone : UIReturnKeyNext);
	self.confirmPassword.text = @"";
	
	self.confirmPassword.hidden = !self.setPasswordMode;
    
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	[self.password becomeFirstResponder];
}

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	newPasswordMessage.text = NSLocalizedString(@"Please enter a password for this profile", nil);
    UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    topBar.items = [NSArray arrayWithObjects:
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], 
                    [[UIBarButtonItem alloc] initWithCustomView:headerImage],
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], nil];
    [headerImage release];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self releaseViewObjects];
}

#pragma mark - Orientation methods

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape([[UIApplication sharedApplication] statusBarOrientation])) {
        [topBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
    } else {
        [topBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-portrait-top-toolbar.png"]];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (YES);
}

#pragma mark - Action methods

- (IBAction)OK:(id)sender
{
	if (self.setPasswordMode == YES) {
		[self setPassword];		
	} else {
		[self authenticatePassword];
	}
}

- (IBAction)cancel:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];	
}

#pragma mark - Private methods

- (void)authenticatePassword
{
	if ([self.profileItem validatePasswordWith:password.text] == NO) {
		UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
															 message:NSLocalizedString(@"Incorrect password", nil)
															delegate:nil 
												   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												   otherButtonTitles:nil]; 
		[errorAlert show]; 
		[errorAlert release];
	} else {
		[self dismissModalViewControllerAnimated:YES];	
		
		if([(id)self.delegate respondsToSelector:@selector(profilePasswordViewControllerDidComplete:)]) {
			[(id)self.delegate profilePasswordViewControllerDidComplete:self];									
		}	
	}	
}

- (void)setPassword
{
	if ([[self.password.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] < 1 ||
		[self.password.text compare:self.confirmPassword.text] != NSOrderedSame) {
		UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
															 message:NSLocalizedString(@"Incorrect password", nil)
															delegate:nil 
												   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
												   otherButtonTitles:nil]; 
		[errorAlert show]; 
		[errorAlert release];
	} else {	
		[self.profileItem setRawPassword:self.password.text];
		
		[self.managedObjectContext save:nil];
		
		[[SCHSyncManager sharedSyncManager] changeProfile];
		
		[self dismissModalViewControllerAnimated:YES];
		
		if([(id)self.delegate respondsToSelector:@selector(profilePasswordViewControllerDidComplete:)]) {
			[(id)self.delegate profilePasswordViewControllerDidComplete:self];		
		}
	}
}

#pragma mark - UITextField Delegate Methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField 
{
	BOOL ret = NO;
	
	if(textField == self.password) {
		ret = YES;
		[self.confirmPassword becomeFirstResponder];
	} else if(textField == self.confirmPassword) {
		ret = YES;
		[self OK:textField];
	}
	
	return(ret); 
} 

@end
