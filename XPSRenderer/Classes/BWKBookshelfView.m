//
//  BWKBookshelfView.m
//  XPSRenderer
//
//  Created by Gordon Christie on 31/12/2010.
//  Copyright 2010 Chillypea. All rights reserved.
//

#import "BWKBookshelfView.h"
#import "BWKTestPageViewController.h"

@implementation BWKBookshelfView
@synthesize xpsFiles;

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


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
    [super viewDidLoad];
	
	NSError *error = nil;
	
	NSString *bundleRoot = [[NSBundle mainBundle] bundlePath];
	NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:bundleRoot error:&error];

	if (error) {
		NSLog(@"Error: %@", [error localizedDescription]);
	}

	NSArray *xpsContents = [dirContents filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"self ENDSWITH '.xps'"]];

	NSMutableArray *trimmedXpsContents = [[NSMutableArray alloc] init];
	for (NSString *item in xpsContents) {
		[trimmedXpsContents addObject:[item stringByDeletingPathExtension]];
	}
	
	self.xpsFiles = [NSArray arrayWithArray:trimmedXpsContents];
	[trimmedXpsContents release];
}

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations.
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

#pragma mark -
#pragma mark TableView

#pragma mark UITableViewDataSource methods

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	return [self.xpsFiles count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	static NSString *cellID = @"bookShelfViewCell";
	
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
	
	if (!cell) {
		cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID] autorelease];
		
	}
	
	cell.textLabel.text = [self.xpsFiles objectAtIndex:indexPath.row];
	cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
	
	NSString *xpsPath = [[NSBundle mainBundle] pathForResource:[self.xpsFiles objectAtIndex:indexPath.row] ofType:@"xps"];
	BWKXPSProvider *provider = [[BWKXPSProvider alloc] initWithPath:xpsPath];
	provider.title = [self.xpsFiles objectAtIndex:indexPath.row];
	cell.image = [provider coverThumbForList];
	[provider release];
	
	return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
	return 88.0f;
}

#pragma mark UITableViewDelegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{

	BWKTestPageViewController *pageView = [[BWKTestPageViewController alloc] initWithNibName:nil bundle:nil];
	pageView.xpsPath = [[NSBundle mainBundle] pathForResource:[self.xpsFiles objectAtIndex:indexPath.row] ofType:@"xps"];
	[self.navigationController pushViewController:pageView animated:YES];
	[pageView release];
	
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
	self.xpsFiles = nil;
}


- (void)dealloc {
	self.xpsFiles = nil;
    [super dealloc];
}


@end
