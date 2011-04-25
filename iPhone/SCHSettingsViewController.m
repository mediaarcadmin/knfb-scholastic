//
//  SCHSettingsViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 13/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSettingsViewController.h"

#import "SCHLoginViewController.h"
#import "SCHAuthenticationManager.h"
#import "SCHDrmRegistrationSession.h"
#import "SCHCustomNavigationBar.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

@interface SCHSettingsViewController()

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)releaseViewObjects;
- (void)deregistration;

@end

@implementation SCHSettingsViewController
@synthesize tableView;
@synthesize backgroundView;

@synthesize loginController, managedObjectContext, drmRegistrationSession;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [loginController release], loginController = nil;
    [tableView release], tableView = nil;
    [backgroundView release], backgroundView = nil;
}

- (void)dealloc 
{
	[managedObjectContext release], managedObjectContext = nil;
    [drmRegistrationSession release], drmRegistrationSession = nil;
    
    [self releaseViewObjects];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    [self.navigationController.navigationBar setTintColor:[UIColor colorWithRed:0.832 green:0.000 blue:0.007 alpha:1.000]];
}

- (void)viewDidUnload 
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

#pragma mark - Orientation methods

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

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation 
{
    return(YES);
}

#pragma mark - Login

- (void)login 
{
	[self presentModalViewController:self.loginController animated:YES];		
}

#pragma mark - Switch Changes

- (void)spaceSwitchChanged:(UISwitch *)sender
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

#pragma mark - Deregistration

- (void)deregistration 
{
    // TODO alert warning user what will happen
    SCHDrmRegistrationSession* registrationSession = [[SCHDrmRegistrationSession alloc] init];
    registrationSession.delegate = self;	
    self.drmRegistrationSession = registrationSession;
    [self.drmRegistrationSession deregisterDevice:[[SCHAuthenticationManager sharedAuthenticationManager] aToken]];
    [registrationSession release];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return(2);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return(1);
}

- (UIView *)tableView:(UITableView *)aTableView viewForFooterInSection:(NSInteger)section
{
    if (section != 1) {
        return nil;
    }
    
    CGRect footerFrame = CGRectMake(0, 0, CGRectGetWidth(aTableView.bounds), 82);
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
    [footerLabel release], footerLabel = nil;
    
    return([containerView autorelease]);
}

- (CGFloat)tableView:(UITableView *)aTableView heightForFooterInSection:(NSInteger)section
{
    if (section != 1) {
        return(aTableView.sectionFooterHeight);
    }
    
    return(82);
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell =  (UITableViewCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    
    switch ([indexPath section]) {
        case 0: {
            cell.accessoryView = nil;
            cell.textLabel.textAlignment = UITextAlignmentCenter;
            cell.textLabel.text = NSLocalizedString(@"De-register This Device", @"");
            cell.selectionStyle = UITableViewCellSelectionStyleBlue;
        } break;
        case 1: {
            UISwitch *switchview = [[UISwitch alloc] initWithFrame:CGRectZero];
            BOOL currentValue = [[NSUserDefaults standardUserDefaults] boolForKey:@"kSCHSpaceSaverMode"];
            [switchview setOn:currentValue];
            [switchview addTarget:self action:@selector(spaceSwitchChanged:) forControlEvents:UIControlEventValueChanged];
            cell.accessoryView = switchview;
            [switchview release], switchview = nil;
            
            cell.textLabel.textAlignment = UITextAlignmentLeft;
            cell.textLabel.text = NSLocalizedString(@"Space Saver Mode", @"");
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
        } break;  
        default:
            break;
    }

    return(cell);
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch ([indexPath section]) {
        case 0: {
            [self deregistration];
        } break;
        default:
            break;
    }
    
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - DRM Registration Session Delegate methods

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
    self.drmRegistrationSession = nil;
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
    self.drmRegistrationSession = nil;
}

@end

