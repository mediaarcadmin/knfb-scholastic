 //
//  SCHProfileViewController_iPhone.m
//  Scholastic
//
//  Created by Gordon Christie on 13/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewController_iPhone.h"
#import "SCHLoginPasswordViewController.h"
#import "SCHAuthenticationManager.h"
#import "SCHBookShelfViewController.h"
#import "SCHSettingsViewController.h"
#import "SCHCustomNavigationBar.h"
#import "SCHURLManager.h"
#import "SCHSyncManager.h"
#import "SCHThemeManager.h"
#import "SCHProfileItem.h"
#import "SCHAppProfile.h"
#import "SCHReadingViewController.h"

static const CGFloat kProfilePhoneTableOffsetPortrait = 70.0f;
static const CGFloat kProfilePhoneTableOffsetLandscape = 20.0f;

@interface SCHProfileViewController_iPhone() <UITableViewDelegate> 

- (void)pushSettingsController;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)releaseViewObjects;

@property (nonatomic, retain) UIButton *settingsButton;
@property (nonatomic, retain) SCHLoginPasswordViewController *parentPasswordController; // Lazily instantiated

@end


@implementation SCHProfileViewController_iPhone

@synthesize profilePasswordController;
@synthesize tableView;
@synthesize backgroundView;
@synthesize headerView;
@synthesize settingsButton;
@synthesize settingsController;
@synthesize loginController;
@synthesize parentPasswordController;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [tableView release], tableView = nil;
    [backgroundView release], backgroundView = nil;
    [headerView release], headerView = nil;
    [settingsButton release], settingsButton = nil;
    
    [profilePasswordController release], profilePasswordController = nil;
    [settingsController release], settingsController = nil;
    [loginController release], loginController = nil;    
}

- (void)dealloc 
{    
    [self releaseViewObjects];
    [parentPasswordController release], parentPasswordController = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingsButton addTarget:self action:@selector(pushSettingsController) 
             forControlEvents:UIControlEventTouchUpInside]; 
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.settingsButton] autorelease];
    
    self.navigationItem.title = NSLocalizedString(@"Back", @"");
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]];
    logoImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin;
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = logoImageView;
    [logoImageView release];
    
    self.tableView.tableHeaderView = self.headerView;
    
    self.loginController.controllerType = kSCHControllerLoginView;
    self.loginController.actionBlock = ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerSuccess object:nil];			
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerFailure object:nil];					
        
        [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithUserName:[self.loginController username] withPassword:[self.loginController password]];
    };
    
    // block gets set when a row is selected
    self.profilePasswordController.controllerType = kSCHControllerPasswordOnlyView;
}  

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    
#if !LOCALDEBUG	
	SCHAuthenticationManager *authenticationManager = [SCHAuthenticationManager sharedAuthenticationManager];
	
	if ([authenticationManager hasUsernameAndPassword] == NO) {
		[self presentModalViewController:self.loginController animated:NO];	
	}
#endif
}

#pragma mark - Orientation methods

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
         [UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-landscape.png"]];
        [self.settingsButton setImage:[UIImage imageNamed:@"settings-landscape.png"] 
                             forState:UIControlStateNormal];
        [self.settingsButton sizeToFit];
        [self.tableView setContentInset:UIEdgeInsetsMake(kProfilePhoneTableOffsetLandscape, 0, 0, 0)];
    } else {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
         [UIImage imageNamed:@"admin-iphone-portrait-top-toolbar.png"]];
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.png"]];
        [self.settingsButton setImage:[UIImage imageNamed:@"settings-portrait.png"] 
                             forState:UIControlStateNormal];
        [self.settingsButton sizeToFit];
        [self.tableView setContentInset:UIEdgeInsetsMake(kProfilePhoneTableOffsetPortrait, 0, 0, 0)];
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (YES);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
}

 
- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem
{
	SCHBookShelfViewController *bookShelfViewController = nil;

    bookShelfViewController = [[SCHBookShelfViewController alloc] initWithNibName:NSStringFromClass([SCHBookShelfViewController class]) bundle:nil];
    bookShelfViewController.profileItem = profileItem;
    
    if (profileItem.AppProfile.AutomaticallyLaunchBook != nil) {
        SCHReadingViewController *readingViewController = [bookShelfViewController openBook:profileItem.AppProfile.AutomaticallyLaunchBook];
        NSArray *viewControllers = [self.navigationController.viewControllers arrayByAddingObjectsFromArray:
                                    [NSArray arrayWithObjects:bookShelfViewController, readingViewController, nil]];
        [self.navigationController setViewControllers:(NSArray *)viewControllers animated:YES];
        profileItem.AppProfile.AutomaticallyLaunchBook = nil;        
    } else {
        [self.navigationController pushViewController:bookShelfViewController animated:YES];
    }
    [bookShelfViewController release], bookShelfViewController = nil;        
}


- (SCHLoginPasswordViewController *)parentPasswordController
{
    if (!parentPasswordController) {
        parentPasswordController = [[[SCHLoginPasswordViewController alloc] initWithNibName:@"SCHParentToolsViewController_iPhone" bundle:nil] retain];
        parentPasswordController.controllerType = kSCHControllerParentToolsView;
    }
    
    return parentPasswordController;
}

- (void)pushSettingsController
{
    self.parentPasswordController.actionBlock = ^{
        
        if ([[SCHAuthenticationManager sharedAuthenticationManager] validatePassword:[self.parentPasswordController password]] == NO) {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                                 message:NSLocalizedString(@"Incorrect password", nil)
                                                                delegate:nil 
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                       otherButtonTitles:nil]; 
            [errorAlert show]; 
            [errorAlert release];
        } else {
            [self.parentPasswordController dismissModalViewControllerAnimated:YES];	
            settingsController.managedObjectContext = self.managedObjectContext;
            [self.navigationController pushViewController:self.settingsController animated:YES];
        }
        
        [self.parentPasswordController clearFields]; 
    };   
    [self presentModalViewController:self.parentPasswordController animated:YES];
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	
    switch (indexPath.section) {
		case 0: {
            
            SCHProfileItem *profileItem = [[self fetchedResultsController] objectAtIndexPath:indexPath];
#if LOCALDEBUG
            // controller to view book shelf with books filtered to profile
            [self pushBookshelvesControllerWithProfileItem:profileItem];	
#else
            if ([profileItem.ProfilePasswordRequired boolValue] == NO) {
                [self pushBookshelvesControllerWithProfileItem:profileItem];            
            } else {
                self.profilePasswordController.actionBlock = ^{
                    
                    if ([profileItem validatePasswordWith:[self.profilePasswordController password]] == NO) {
                        UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
                                                                             message:NSLocalizedString(@"Incorrect password", nil)
                                                                            delegate:nil 
                                                                   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                                   otherButtonTitles:nil]; 
                        [errorAlert show]; 
                        [errorAlert release];
                    } else {
                        [SCHThemeManager sharedThemeManager].appProfile = profileItem.AppProfile;
                        [self.profilePasswordController dismissModalViewControllerAnimated:YES];	
                        [self.profilePasswordController clearFields]; 
                        [self pushBookshelvesControllerWithProfileItem:profileItem];            
                    }	
                };
                
                [self presentModalViewController:self.profilePasswordController animated:YES];
                [self.profilePasswordController.profileLabel setText:[profileItem bookshelfName:YES]];
            }
#endif	
		}	break;
	}
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Authentication Manager

- (void)authenticationManager:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	if ([notification.name compare:kSCHAuthenticationManagerSuccess] == NSOrderedSame) {
		[[SCHURLManager sharedURLManager] clear];
		[[SCHSyncManager sharedSyncManager] clear];
		[[SCHSyncManager sharedSyncManager] firstSync];
		[self.loginController dismissModalViewControllerAnimated:YES];	
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
        [self.loginController stopShowingProgress];
	}
}

#pragma mark - Fetched results controller delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}




@end
