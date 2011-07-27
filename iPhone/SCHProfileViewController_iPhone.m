 //
//  SCHProfileViewController_iPhone.m
//  Scholastic
//
//  Created by Gordon Christie on 13/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewController_iPhone.h"
#import "SCHLoginPasswordViewController.h"
#import "SCHSetupBookshelvesViewController.h"
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
#import "SCHBookIdentifier.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

static const CGFloat kProfilePhoneTableOffsetPortrait = 70.0f;
static const CGFloat kProfilePhoneTableOffsetLandscape = 20.0f;

@interface SCHProfileViewController_iPhone() <UITableViewDelegate> 

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)releaseViewObjects;

@property (nonatomic, retain) UIButton *settingsButton;

@end


@implementation SCHProfileViewController_iPhone

@synthesize tableView;
@synthesize backgroundView;
@synthesize headerView;
@synthesize settingsButton;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [tableView release], tableView = nil;
    [backgroundView release], backgroundView = nil;
    [headerView release], headerView = nil;
    [settingsButton release], settingsButton = nil;
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
    bookShelfViewController.managedObjectContext = self.managedObjectContext;
    
    if (profileItem.AppProfile.AutomaticallyLaunchBook != nil) {
        SCHBookIdentifier *bookIdentifier = [[SCHBookIdentifier alloc] initWithEncodedString:profileItem.AppProfile.AutomaticallyLaunchBook];
        
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
                        [self.profilePasswordController dismissModalViewControllerAnimated:YES];	
                        [self.profilePasswordController clearFields]; 
                        [self pushBookshelvesControllerWithProfileItem:profileItem];            
                    }	
                };
                
                [self presentModalViewController:self.profilePasswordController animated:YES];
            }
#endif	
		}	break;
	}
}

#pragma mark - Fetched results controller delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}




@end
