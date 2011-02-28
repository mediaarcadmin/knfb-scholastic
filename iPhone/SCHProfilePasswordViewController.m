//
//  SCHProfilePasswordViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 16/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfilePasswordViewController.h"

#import "SCHProfileItem+Extensions.h"
#import "SCHSyncManager.h"
#import "USAdditions.h"

@interface SCHProfilePasswordViewController ()

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

- (void)releaseViewObjects 
{
	self.newPasswordMessage = nil;
	self.password = nil;
	self.confirmPassword = nil;	
}

- (void)dealloc 
{
	[self releaseViewObjects];
	
	self.profileItem = nil;
	self.managedObjectContext = nil;
	
    [super dealloc];
}

- (void)viewWillAppear:(BOOL)animated	
{
	[super viewWillAppear:animated];

	self.setPasswordMode = [self.profileItem.ProfilePasswordRequired boolValue] == NO;
	
	self.newPasswordMessage.hidden = !self.setPasswordMode;
	self.password.text = @"";
	self.password.returnKeyType = ( self.setPasswordMode == NO ? UIReturnKeyDone : UIReturnKeyNext);
	self.confirmPassword.text = @"";
	
	self.confirmPassword.hidden = !self.setPasswordMode;
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
	[self.password becomeFirstResponder];
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad 
{
    [super viewDidLoad];
	
	newPasswordMessage.text = NSLocalizedString(@"Please enter a password for this profile", nil);
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self releaseViewObjects];
}

#pragma mark -
#pragma mark Action methods

- (IBAction)OK:(id)sender
{
	if (self.setPasswordMode == YES) {
		[self setPassword];		
	} else {
		[self authenticatePassword];
	}
}

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
		self.profileItem.ProfilePasswordRequired = [NSNumber numberWithBool:YES];
		
		[self.managedObjectContext save:nil];
		
		[[SCHSyncManager sharedSyncManager] changeProfile];
		
		[self dismissModalViewControllerAnimated:YES];
		
		if([(id)self.delegate respondsToSelector:@selector(profilePasswordViewControllerDidComplete:)]) {
			[(id)self.delegate profilePasswordViewControllerDidComplete:self];		
		}
	}
}

- (IBAction)cancel:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];	
}

#pragma mark UITextField Delegate Methods
#pragma mark -

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

- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

@end
