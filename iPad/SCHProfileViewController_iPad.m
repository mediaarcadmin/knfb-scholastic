//
//  SCHProfileViewController_iPad.m
//  Scholastic
//
//  Created by Gordon Christie on 13/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewController_iPad.h"
#import <QuartzCore/QuartzCore.h>
#import "SCHBookshelfViewController_iPad.h"
#import "SCHBookshelfViewController.h"
#import "SCHProfileItem.h"
#import "SCHLoginPasswordViewController.h"
#import "SCHAuthenticationManager.h"
#import "SCHSetupBookshelvesViewController.h"
#import "SCHThemeManager.h"
#import "SCHURLManager.h"
#import "SCHSyncManager.h"
#import "SCHBookManager.h"
#import "SCHSettingsViewController.h"
#import "SCHCustomNavigationBar.h"
#import "SCHAppProfile.h"
#import "SCHBookIdentifier.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

static const CGFloat kProfilePadTableOffsetPortrait = 280.0f;
static const CGFloat kProfilePadTableOffsetLandscape = 220.0f;

enum LoginScreens {
    kLoginScreenNone,
    kLoginScreenPassword,
    kLoginScreenSetupBookshelves,
    kLoginScreenDownloadDictionary
};

#pragma mark - Class Extension

@interface SCHProfileViewController_iPad () 

@property (nonatomic, assign) enum LoginScreens loginScreen;

- (void)releaseViewObjects;
- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (void)showLoginControllerWithAnimation:(BOOL)animated;
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
@synthesize loginPasswordController;
@synthesize profilePasswordController;
@synthesize settingsViewController;
@synthesize settingsButton;
@synthesize parentPasswordController;
@synthesize setupBookshelvesViewController;
@synthesize modalNavigationController;
@synthesize loginScreen;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [tableView release], tableView = nil;
    [bookshelfViewController release], bookshelfViewController = nil;
    [headerView release], headerView = nil;
    [containerView release], containerView = nil;
    [backgroundView release], backgroundView = nil;
    [loginPasswordController release], loginPasswordController = nil;
    [profilePasswordController release], profilePasswordController = nil;
    [settingsButton release], settingsButton = nil;
    [settingsViewController release], settingsViewController = nil;
    [setupBookshelvesViewController release], setupBookshelvesViewController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc 
{    
    [self releaseViewObjects];
    [parentPasswordController release], parentPasswordController = nil;
    [modalNavigationController release], modalNavigationController = nil;

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
        [self dismissModalViewControllerAnimated:YES];
    };
    
    self.tableView.tableHeaderView = self.headerView;
    [self.containerView addSubview:self.tableView];
    
    self.loginScreen = kLoginScreenNone;
    
    // check for authentication
#if !LOCALDEBUG	
#if NONDRMAUTHENTICATION
	SCHAuthenticationManager *authenticationManager = [SCHAuthenticationManager sharedAuthenticationManager];
	if ([authenticationManager isAuthenticated] == NO) {
        self.loginScreen = kLoginScreenPassword;
    }
#else 
    NSString *deviceKey = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];
    if (!deviceKey) {
        self.loginScreen = kLoginScreenPassword;
	}
#endif
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showLoginControllerWithAnimation:YES];
    });
#endif
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

- (void)viewDidUnload {
    [self releaseViewObjects];
    [super viewDidUnload];
}

#pragma mark - Orientation methods

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
//        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
//         [UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
        [self.backgroundView setImage:[UIImage imageNamed:@"admin-background-ipad-landscape.png"]];
        [self.tableView setContentInset:UIEdgeInsetsMake(kProfilePadTableOffsetLandscape, 0, 0, 0)];
    } else {
//        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
//         [UIImage imageNamed:@"admin-iphone-portrait-top-toolbar.png"]];
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

#pragma mark - View Shuffling

- (void)showNextLoginScreen
{
    if (/*FIXME: remove hack*/ self.loginScreen == kLoginScreenPassword
        || [[self.fetchedResultsController sections] count] == 0 
        || [[[self.fetchedResultsController sections] objectAtIndex:0] numberOfObjects] == 0) {
        self.loginScreen = kLoginScreenSetupBookshelves;
    }
    else if (/* FIXME: detect if dictionary downloaded */ YES) {
        self.loginScreen = kLoginScreenDownloadDictionary;
    }
    
    [self showLoginControllerWithAnimation:YES];
}

- (void)showLoginControllerWithAnimation:(BOOL)animated
{
    switch (self.loginScreen) {
        case kLoginScreenNone:
            break;
            
        case kLoginScreenPassword:
            [self.modalNavigationController setViewControllers:[NSArray arrayWithObject:self.loginPasswordController]];
            [self.modalNavigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
            [self.modalNavigationController setModalPresentationStyle:UIModalPresentationFormSheet];
            [self.modalNavigationController setNavigationBarHidden:YES];
            [self presentModalViewController:self.modalNavigationController animated:animated];
            break;
            
        case kLoginScreenSetupBookshelves:
            [self.modalNavigationController pushViewController:self.setupBookshelvesViewController animated:animated];
            break;
            
        case kLoginScreenDownloadDictionary:
            // TODO
            break;
    }
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
            [self.modalNavigationController setNavigationBarHidden:NO animated:YES];
            [self.modalNavigationController pushViewController:self.settingsViewController animated:YES];
        }
        
        [self.parentPasswordController clearFields]; 
    };
    
    [self.modalNavigationController setViewControllers:[NSArray arrayWithObject:self.parentPasswordController]];
    [self.modalNavigationController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.modalNavigationController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self.modalNavigationController setNavigationBarHidden:YES animated:NO];
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
        [self showNextLoginScreen];
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
