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
#import "SCHThemeManager.h"
#import "SCHThemeButton.h"
#import "SCHThemeImageView.h"
#import "SCHCustomNavigationBar.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

@interface SCHSettingsViewController()

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)releaseViewObjects;

@end

@implementation SCHSettingsViewController
@synthesize tableView;
@synthesize backgroundView;

@synthesize loginController, managedObjectContext, drmRegistrationSession;

#pragma mark -
#pragma mark View lifecycle

- (void)releaseViewObjects
{
    [loginController release], loginController = nil;
    [tableView release], tableView = nil;
    [backgroundView release], backgroundView = nil;
}

- (void)dealloc {
	[managedObjectContext release], managedObjectContext = nil;
    [drmRegistrationSession release], drmRegistrationSession = nil;
    
    [self releaseViewObjects];
    [super dealloc];
}

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
         [UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-landscape.png"]];
        
    } else {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
         [UIImage imageNamed:@"admin-iphone-portrait-top-toolbar.png"]];
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.png"]];        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
//    SCHThemeButton *deregisterButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
//    [deregisterButton setFrame:CGRectMake(0, 0, 82, 30)];
//    [deregisterButton setTitle:NSLocalizedString(@"Deregister", @"") forState:UIControlStateNormal];
//    [deregisterButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
//    [deregisterButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5f] forState:UIControlStateHighlighted];
//    [deregisterButton setReversesTitleShadowWhenHighlighted:YES];
    
//    deregisterButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
//    deregisterButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
//    [deregisterButton setThemeButton:kSCHThemeManagerButtonImage leftCapWidth:5 topCapHeight:0];
//    [deregisterButton addTarget:self action:@selector(deregistrationButtonPushed:) forControlEvents:UIControlEventTouchUpInside];    
//    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:deregisterButton] autorelease];
    
    SCHThemeButton *button = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [button setThemeIcon:kSCHThemeManagerHomeIcon];
    [button sizeToFit];    
    [button addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:button] autorelease];
}

- (void)back
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
}

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
    headerLabel.textColor = [UIColor colorWithRed:0.063 green:0.337 blue:0.510 alpha:1.0];
    headerLabel.shadowColor = [UIColor whiteColor];
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

- (UIView *)tableView:(UITableView *)aTableView viewForFooterInSection:(NSInteger)section
{
    CGRect footerFrame = CGRectMake(0, 0, CGRectGetWidth(aTableView.bounds), 60);
    UIView *containerView = [[UIView alloc] initWithFrame:footerFrame];
    UILabel *footerLabel = [[UILabel alloc] initWithFrame:CGRectInset(footerFrame, 10, 8)];
    
    footerLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight;
    footerLabel.text =  NSLocalizedString(@"Space Saver Mode allows you to download individual books - turn it off to automatically download all books.", @"");
    footerLabel.minimumFontSize = 11;
    footerLabel.numberOfLines = 3;
    footerLabel.adjustsFontSizeToFitWidth = YES;
    footerLabel.backgroundColor = [UIColor clearColor];
    footerLabel.textColor = [UIColor colorWithRed:0.063 green:0.337 blue:0.510 alpha:1.0];
    footerLabel.shadowColor = [UIColor whiteColor];
    footerLabel.shadowOffset = CGSizeMake(0, -1);
    footerLabel.textAlignment = UITextAlignmentCenter;
    [containerView addSubview:footerLabel];
    [footerLabel release];
    
    return([containerView autorelease]);
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section
{
    return 76;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell =  (UITableViewCell*) [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
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
    return 44;
}

- (void)viewDidUnload {
    [self releaseViewObjects];
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

