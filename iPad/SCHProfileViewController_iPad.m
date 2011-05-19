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
#import "SCHThemeManager.h"
#import "SCHURLManager.h"
#import "SCHSyncManager.h"
#import "SCHBookManager.h"
#import "SCHSettingsViewController.h"
#import "SCHCustomNavigationBar.h"
#import "SCHAppProfile.h"

#pragma mark - Class Extension

@interface SCHProfileViewController_iPad () 

- (void)releaseViewObjects;
- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (void)showLoginControllerWithAnimation:(BOOL)animated;
- (void)showProfilePasswordControllerWithAnimation:(BOOL)animated;
- (void)toggleSettingsController;

@property (nonatomic, retain) UIButton *settingsButton;
@property (nonatomic, retain) UIPopoverController *settingsPopover;

@end

@implementation SCHProfileViewController_iPad

@synthesize tableView;
@synthesize bookshelfViewController;
@synthesize headerView;
@synthesize containerView;
@synthesize loginPasswordController;
@synthesize profilePasswordController;
@synthesize settingsNavigationController;
@synthesize settingsButton;
@synthesize settingsPopover;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [tableView release], tableView = nil;
    [bookshelfViewController release], bookshelfViewController = nil;
    [headerView release], headerView = nil;
    [containerView release], containerView = nil;
    [loginPasswordController release], loginPasswordController = nil;
    [profilePasswordController release], profilePasswordController = nil;
    [settingsButton release], settingsButton = nil;
    [settingsPopover release], settingsPopover = nil;
    [settingsNavigationController release], settingsNavigationController = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc 
{    
    [self releaseViewObjects];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    self.managedObjectContext = [[SCHBookManager sharedBookManager] managedObjectContextForCurrentThread];
    self.title = @"";
    
//    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
//    self.navigationItem.titleView = logoImageView;
//    [logoImageView release];
    
    self.containerView.layer.cornerRadius = 5;
    
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingsButton addTarget:self action:@selector(toggleSettingsController) 
             forControlEvents:UIControlEventTouchUpInside]; 
    [self.settingsButton setImage:[UIImage imageNamed:@"settings-portrait.png"] 
                         forState:UIControlStateNormal];
    [self.settingsButton sizeToFit];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.settingsButton] autorelease];


    self.loginPasswordController.controllerType = kSCHControllerLoginView;
    self.loginPasswordController.actionBlock = ^{
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerSuccess object:nil];			
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerFailure object:nil];					
        
        [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithUserName:[self.loginPasswordController username] withPassword:[self.loginPasswordController password]];
        [self.loginPasswordController startShowingProgress];
    };
    
    self.profilePasswordController.controllerType = kSCHControllerPasswordOnlyView;
    self.profilePasswordController.cancelBlock = ^{
        [self.profilePasswordController dismissModalViewControllerAnimated:YES];
    };
    
    self.tableView.tableHeaderView = self.headerView;
    [self.containerView addSubview:self.tableView];

    
    // check for authentication
#if !LOCALDEBUG	
	SCHAuthenticationManager *authenticationManager = [SCHAuthenticationManager sharedAuthenticationManager];
	
	if ([authenticationManager hasUsernameAndPassword] == NO) {
        [self showLoginControllerWithAnimation:YES];
	}
#endif

}  


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	return YES;
}

- (void)viewDidUnload {
    [self releaseViewObjects];
    [super viewDidUnload];
}

#pragma mark - View Shuffling

- (void)showLoginControllerWithAnimation:(BOOL)animated
{
    [self.loginPasswordController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.loginPasswordController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self.navigationController presentModalViewController:self.loginPasswordController animated:YES];
}
- (void)showProfilePasswordControllerWithAnimation:(BOOL)animated
{
    [self.profilePasswordController setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.profilePasswordController setModalPresentationStyle:UIModalPresentationFormSheet];
    [self.navigationController presentModalViewController:self.profilePasswordController animated:YES];

}

- (void)toggleSettingsController
{
    NSLog(@"Toggle settings controller.");
    
    if (self.settingsPopover) {
        [self.settingsPopover dismissPopoverAnimated:YES];
        self.settingsPopover = nil;
    } else {
        [self.settingsNavigationController popToRootViewControllerAnimated:NO];
        self.settingsPopover = [[UIPopoverController alloc] initWithContentViewController:self.settingsNavigationController];
        self.settingsPopover.delegate = self;
        
        [self.settingsPopover presentPopoverFromBarButtonItem:self.navigationItem.rightBarButtonItem permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

#pragma mark - UIPopoverControllerDelegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    if (popoverController == self.settingsPopover) {
        self.settingsPopover = nil;
    }
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
//                [self showBookshelfListWithAnimation:YES];
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
                        //[self showBookshelfListWithAnimation:YES];
                        [self.profilePasswordController clearFields]; 
                        [self pushBookshelvesControllerWithProfileItem:profileItem];            
                        [self.profilePasswordController dismissModalViewControllerAnimated:YES];
                    }	
                };
                
                [self showProfilePasswordControllerWithAnimation:YES];
                
            }
#endif	
		}	break;
	}
	
	[self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem
{
	SCHBookShelfViewController_iPad *bookShelfViewController = nil;
    
    bookShelfViewController = [[SCHBookShelfViewController_iPad alloc] initWithNibName:NSStringFromClass([SCHBookShelfViewController class]) bundle:nil];
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

#pragma mark - Authentication Manager

- (void)authenticationManager:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHAuthenticationManagerSuccess object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHAuthenticationManagerFailure object:nil];
	
	if ([notification.name compare:kSCHAuthenticationManagerSuccess] == NSOrderedSame) {
		[[SCHURLManager sharedURLManager] clear];
		[[SCHSyncManager sharedSyncManager] clear];
		[[SCHSyncManager sharedSyncManager] firstSync];
        [self.loginPasswordController dismissModalViewControllerAnimated:YES];
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
