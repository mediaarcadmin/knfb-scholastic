//
//  SCHProfilePasswordViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 16/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfilePasswordViewController.h"

#import "SCHProfileItem.h"

@implementation SCHProfilePasswordViewController

@synthesize password;
@synthesize profileItem;
@synthesize delegate;

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

- (IBAction)OK:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];	
	
	if([(id)self.delegate respondsToSelector:@selector(profilePasswordViewControllerDidComplete:)]) {
		[(id)self.delegate profilePasswordViewControllerDidComplete:self];									
	}	
}

- (IBAction)cancel:(id)sender
{
	[self dismissModalViewControllerAnimated:YES];
	
	if([(id)self.delegate respondsToSelector:@selector(profilePasswordViewControllerDidCancel:)]) {
		[(id)self.delegate profilePasswordViewControllerDidCancel:self];									
	}
}

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


- (void)dealloc {
    [super dealloc];
}


@end
