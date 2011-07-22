//
//  SCHProfileViewController_iPad.m
//  Scholastic
//
//  Created by Gordon Christie on 13/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewController_iPad.h"
#import "SCHBookshelfViewController_iPad.h"
#import "SCHBookshelfViewController.h"
#import "SCHProfileItem.h"
#import "SCHLoginPasswordViewController.h"
#import "SCHThemeManager.h"
#import "SCHURLManager.h"
#import "SCHSyncManager.h"
#import "SCHBookManager.h"
#import "SCHCustomNavigationBar.h"
#import "SCHAppProfile.h"
#import "SCHBookIdentifier.h"
#import "SCHAuthenticationManager.h"
#import "SCHSettingsViewController.h"

static const CGFloat kProfilePadTableOffsetPortrait = 280.0f;
static const CGFloat kProfilePadTableOffsetLandscape = 220.0f;

#pragma mark - Class Extension

@interface SCHProfileViewController_iPad () 

- (void)releaseViewObjects;
- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (void)showProfilePasswordControllerWithAnimation:(BOOL)animated;
- (void)pushSettingsController;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;

@property (nonatomic, retain) UIButton *settingsButton;
@property (nonatomic, retain) SCHLoginPasswordViewController *parentPasswordController; // Lazily instantiated

@end

@implementation SCHProfileViewController_iPad

@synthesize tableView;
@synthesize bookshelfViewController;
@synthesize headerView;
@synthesize containerView;
@synthesize backgroundView;
@synthesize profilePasswordController;
@synthesize settingsViewController;
@synthesize settingsButton;
@synthesize parentPasswordController;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [super releaseViewObjects];
    [tableView release], tableView = nil;
    [bookshelfViewController release], bookshelfViewController = nil;
    [headerView release], headerView = nil;
    [containerView release], containerView = nil;
    [backgroundView release], backgroundView = nil;
    [profilePasswordController release], profilePasswordController = nil;
    [settingsButton release], settingsButton = nil;
    [settingsViewController release], settingsViewController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc 
{    
    [parentPasswordController release], parentPasswordController = nil;
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    self.title = @"";
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = logoImageView;
    [logoImageView release];
        
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingsButton addTarget:self action:@selector(pushSettingsController) 
             forControlEvents:UIControlEventTouchUpInside]; 
    [self.settingsButton setImage:[UIImage imageNamed:@"settings-portrait.png"] 
                         forState:UIControlStateNormal];
    [self.settingsButton sizeToFit];
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.settingsButton] autorelease];
    
    self.loginPasswordController.controllerType = kSCHControllerLoginView;
    self.loginPasswordController.actionBlock = ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerSuccess object:nil];			
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerFailure object:nil];					

        [self.loginPasswordController startShowingProgress];
        [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithUserName:[self.loginPasswordController username] withPassword:[self.loginPasswordController password]];
    };
    
    self.profilePasswordController.controllerType = kSCHControllerPasswordOnlyView;
    self.profilePasswordController.cancelBlock = ^{
        [self endLoginSequence];
    };
    
    self.settingsViewController.settingsDelegate = self;
    
    self.tableView.tableHeaderView = self.headerView;
    [self.containerView addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

- (void)viewDidUnload 
{
    [self releaseViewObjects];
    [super viewDidUnload];
}

#pragma mark - Orientation methods

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self.backgroundView setImage:[UIImage imageNamed:@"admin-background-ipad-landscape.png"]];
        [self.tableView setContentInset:UIEdgeInsetsMake(kProfilePadTableOffsetLandscape, 0, 0, 0)];
    } else {
        [self.backgroundView setImage:[UIImage imageNamed:@"admin-background-ipad-portrait.png"]];
        [self.tableView setContentInset:UIEdgeInsetsMake(kProfilePadTableOffsetPortrait, 0, 0, 0)];
    }
    
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
}    
- (void)showProfilePasswordControllerWithAnimation:(BOOL)animated
{
    [self.profilePasswordController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.profilePasswordController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentModalViewController:self.profilePasswordController animated:YES];

}

- (SCHLoginPasswordViewController *)parentPasswordController
{
    if (!parentPasswordController) {
        parentPasswordController = [[[SCHLoginPasswordViewController alloc] initWithNibName:@"SCHParentToolsViewController_iPad" bundle:nil] retain];
        parentPasswordController.controllerType = kSCHControllerParentToolsView;
    }
    
    return parentPasswordController;
}

- (void)dismissKeyboard
{
    if ([[[UIDevice currentDevice] systemVersion] compare:@"4.3"] == NSOrderedAscending) {
        // pre-4.3 only - we have to dismiss the modal form and represent it to get the
        // keyboard to disappear; from 4.3-on the UINavigationController subclass takes
        // care of this.
        [CATransaction begin];
        [self dismissModalViewControllerAnimated:NO];
        [self presentModalViewController:self.modalNavigationController animated:NO];
        [CATransaction commit];
    }
}

#pragma mark - settings

- (void)dismissSettingsForm
{
    [super dismissModalViewControllerAnimated:YES];

    // allow the previous modal dialog to close before re-opening the login screen
    [self performSelector:@selector(advanceToNextLoginStep) withObject:nil afterDelay:1.0];
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
            [self dismissKeyboard];
            [self.modalNavigationController pushViewController:self.settingsViewController animated:YES];
        }
        
        [self.parentPasswordController clearFields]; 
    };
    
    [self.modalNavigationController setViewControllers:[NSArray arrayWithObject:self.parentPasswordController]];
    [self.modalNavigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.modalNavigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self.modalNavigationController.navigationBar setTintColor:[UIColor SCHRed2Color]];
    [self presentModalViewController:self.modalNavigationController animated:YES];
}

#pragma mark - SCHProfileViewCellDelegate
    
- (void)profileViewCell:(SCHProfileViewCell *)cell didSelectAnimated:(BOOL)animated
{
    NSIndexPath *indexPath = cell.indexPath;
    
    switch (indexPath.section) {
		case 0: {
            SCHProfileItem *profileItem = [[self fetchedResultsController] objectAtIndexPath:indexPath];
#if LOCALDEBUG
            // controller to view book shelf with books filtered to profile
            [SCHThemeManager sharedThemeManager].appProfile = profileItem.AppProfile;                                    
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
                        [self.profilePasswordController clearFields]; 
                        [self pushBookshelvesControllerWithProfileItem:profileItem];            
                        [self dismissModalViewControllerAnimated:YES];
                    }	
                };
                
                [self showProfilePasswordControllerWithAnimation:YES];
                [self.profilePasswordController.profileLabel setText:[profileItem bookshelfName:YES]];

            }
#endif	
		}	break;
	}	
}

- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem
{
	SCHBookShelfViewController_iPad *bookShelfViewController = nil;
    
    bookShelfViewController = [[SCHBookShelfViewController_iPad alloc] initWithNibName:NSStringFromClass([SCHBookShelfViewController class]) bundle:nil];
    bookShelfViewController.profileItem = profileItem;
    bookShelfViewController.managedObjectContext = self.managedObjectContext;
    
    SCHBookIdentifier *bookIdentifier = nil;
    if (profileItem.AppProfile.AutomaticallyLaunchBook != nil) {
        bookIdentifier = [[SCHBookIdentifier alloc] initWithEncodedString:profileItem.AppProfile.AutomaticallyLaunchBook];
    }
    if (bookIdentifier) {
        NSError *error;
        SCHReadingViewController *readingViewController = [bookShelfViewController openBook:bookIdentifier error:&error];
        [bookIdentifier release];
        
        if (readingViewController) {
            NSArray *viewControllers = [self.navigationController.viewControllers arrayByAddingObjectsFromArray:
                                        [NSArray arrayWithObjects:bookShelfViewController, readingViewController, nil]];
            [self.navigationController setViewControllers:(NSArray *)viewControllers animated:YES];
        } else {
            UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"This Book Could Not Be Opened", @"Could not open book") 
                                                                 message:[error localizedDescription]
                                                                delegate:nil 
                                                       cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
                                                       otherButtonTitles:nil]; 
            [errorAlert show]; 
            [errorAlert release];
        }
        profileItem.AppProfile.AutomaticallyLaunchBook = nil;        
    } else {
        [self.navigationController pushViewController:bookShelfViewController animated:YES];
    }
	[bookShelfViewController release], bookShelfViewController = nil;
}

#pragma mark - Authentication Manager

- (void)authenticationManager:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHAuthenticationManagerSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHAuthenticationManagerFailure object:nil];
	
	if ([notification.name compare:kSCHAuthenticationManagerSuccess] == NSOrderedSame) {
		[[SCHURLManager sharedURLManager] clear];
		[[SCHSyncManager sharedSyncManager] clear];
		[[SCHSyncManager sharedSyncManager] firstSync];
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
        [self.loginPasswordController stopShowingProgress];
	}
}

#pragma mark - Fetched results controller delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}

@end
