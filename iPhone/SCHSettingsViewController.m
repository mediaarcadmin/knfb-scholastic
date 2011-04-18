//
//  SCHSettingsViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSettingsViewController.h"
#import "SCHLoginViewController.h"
#import "AppDelegate_Shared.h"
#import "SCHUserSettingsItem.h"
#import "SCHAuthenticationManager.h"
#import "SCHDrmRegistrationSession.h"
#import "SCHProfileViewCell.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

@implementation SCHSettingsViewController
@synthesize tableView;

@synthesize loginController, managedObjectContext, drmRegistrationSession;

#pragma mark -
#pragma mark View lifecycle


- (void)viewDidLoad {
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    UIButton *deregisterButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [deregisterButton setFrame:CGRectMake(0, 0, 82, 30)];
    [deregisterButton setTitle:NSLocalizedString(@"Deregister", @"") forState:UIControlStateNormal];
    [deregisterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [deregisterButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5f] forState:UIControlStateHighlighted];
    [deregisterButton setReversesTitleShadowWhenHighlighted:YES];
    
    deregisterButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    deregisterButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    [deregisterButton setBackgroundImage:[[UIImage imageNamed:@"button-cancel"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
    [deregisterButton addTarget:self action:@selector(deregistrationButtonPushed:) forControlEvents:UIControlEventTouchUpInside];    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:deregisterButton] autorelease];
    
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setImage:[UIImage imageNamed:@"icon-home"] forState:UIControlStateNormal];
    [button sizeToFit];    
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
}
*/


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Override to allow orientations other than the default portrait orientation.
    return YES;
}


#pragma mark -
#pragma mark Login

- (void)login {
	[self presentModalViewController:self.loginController animated:YES];		
}

#pragma mark -
#pragma mark Switch Changes

- (void) spaceSwitchChanged: (UISwitch *) sender
{
	NSNumber *currentValue = [[NSUserDefaults standardUserDefaults] objectForKey:@"kSCHSpaceSaverMode"];
	
	if (!currentValue) {
		BOOL newValue = [sender isOn];
		[[NSUserDefaults standardUserDefaults] setBool:newValue forKey:@"kSCHSpaceSaverMode"];
		[[NSUserDefaults standardUserDefaults] synchronize];
		return;
	}
	
	BOOL newValue = !([currentValue boolValue]);
	[[NSUserDefaults standardUserDefaults] setBool:newValue forKey:@"kSCHSpaceSaverMode"];
	[[NSUserDefaults standardUserDefaults] synchronize];
}

#pragma mark -
#pragma mark Deregistration Button

- (void) deregistrationButtonPushed: (UISwitch *) sender {
    // TODO alert warning user what will happen
    SCHDrmRegistrationSession* registrationSession = [[SCHDrmRegistrationSession alloc] init];
    registrationSession.delegate = self;	
    self.drmRegistrationSession = registrationSession;
    [self.drmRegistrationSession deregisterDevice:[[SCHAuthenticationManager sharedAuthenticationManager] aToken]];
    [registrationSession release];
}


#pragma mark -
#pragma mark Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return 1;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 12, self.view.frame.size.width - 40, 40)];
    headerLabel.text = NSLocalizedString(@"Device Options", @"");
    headerLabel.font = [UIFont boldSystemFontOfSize:18.0f];
    headerLabel.minimumFontSize = 11;
    headerLabel.numberOfLines = 1;
    headerLabel.adjustsFontSizeToFitWidth = YES;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowColor = [UIColor blackColor];
    headerLabel.shadowOffset = CGSizeMake(0, -1);
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    [containerView addSubview:headerLabel];
    [headerLabel release];
    
    return [containerView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 54;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
{
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 8, self.view.frame.size.width - 20, 60)];
    footerLabel.text =  NSLocalizedString(@"Space Saver Mode allows you to download individual books - turn it off to automatically download all books.", @"");
    footerLabel.minimumFontSize = 11;
    footerLabel.numberOfLines = 3;
    footerLabel.adjustsFontSizeToFitWidth = YES;
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.textColor = [UIColor whiteColor];
    footerLabel.shadowColor = [UIColor blackColor];
    footerLabel.shadowOffset = CGSizeMake(0, -1);
    footerLabel.textAlignment = UITextAlignmentCenter;
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    [containerView addSubview:footerLabel];
    [footerLabel release];
    
    return [containerView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 76;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    SCHProfileViewCell *cell =  (SCHProfileViewCell*) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[SCHProfileViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
		UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
		
		BOOL currentValue = [[NSUserDefaults standardUserDefaults] boolForKey:@"kSCHSpaceSaverMode"];
		[switchview setOn:currentValue];
		
		[switchview addTarget:self action:@selector(spaceSwitchChanged:) forControlEvents:UIControlEventValueChanged];
		cell.accessoryView = switchview;
		[switchview release];
        
        cell.textLabel.textAlignment = UITextAlignmentLeft;
    }

    // Configure the cell...
	cell.textLabel.text = NSLocalizedString(@"Space Saver Mode", @"");

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 66;
}



/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/


/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source.
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view.
    }   
}
*/


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/


/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark -
#pragma mark Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    // Navigation logic may go here. Create and push another view controller.
    /*
    <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
    // ...
    // Pass the selected object to the new view controller.
    [self.navigationController pushViewController:detailViewController animated:YES];
    [detailViewController release];
    */
}


#pragma mark -
#pragma mark Memory management

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc. that aren't in use.
}

- (void)viewDidUnload {
    [self setTableView:nil];
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
	self.managedObjectContext = nil;
	
}


- (void)dealloc {
	self.managedObjectContext = nil;
    [tableView release];
    [super dealloc];
}


#pragma mark -
#pragma mark DRM Registration Session Delegate methods

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession didComplete:(NSString *)deviceKey
{
    if ( deviceKey == nil ) {
        // removeObjectForKey does not change the value...
        [[NSUserDefaults standardUserDefaults] setObject:nil forKey:kSCHAuthenticationManagerDeviceKey];
        [self login];
        [self.navigationController popViewControllerAnimated:NO];
    }
    else
        NSLog(@"Unknown DRM error:  device key value returned from successful deregistration.");
    [self.drmRegistrationSession release];
}

- (void)registrationSession:(SCHDrmRegistrationSession *)registrationSession didFailWithError:(NSError *)error
{
	UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                         message:[error localizedDescription]
                                                        delegate:nil 
                                               cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                               otherButtonTitles:nil]; 
    [errorAlert show]; 
    [errorAlert release]; 
    [self.drmRegistrationSession release];
}


@end

