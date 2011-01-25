//
//  SCHLoginViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 19/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHLoginViewController.h"

#import "SCHAuthenticationManager.h"
#import "SFHFKeychainUtils.h"

@implementation SCHLoginViewController

@synthesize userName;
@synthesize password;
@synthesize cancel;
@synthesize spinner;

- (void)awakeFromNib
{
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerSuccess object:nil];			
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerFailure object:nil];					
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
    [super dealloc];
}

- (void)authenticationManager:(NSNotification *)notification
{
	[spinner stopAnimating];
	
	if ([notification.name compare:kSCHAuthenticationManagerSuccess] == NSOrderedSame) {
		[self dismissModalViewControllerAnimated:YES];	
	} else {
		// oh bummer!
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
	[userName resignFirstResponder];
	[password resignFirstResponder];
					   
	[[SCHAuthenticationManager sharedAuthenticationManager] authenticateUserName:[userName text] withPassword:[password text]];
	[spinner startAnimating];
}

- (IBAction)cancel:(id)sender
{
	[userName resignFirstResponder];
	[password resignFirstResponder];
	
	[spinner startAnimating];
}

- (void)canCancel:(BOOL)canCancel
{
	cancel.hidden = canCancel;
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

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}


@end
