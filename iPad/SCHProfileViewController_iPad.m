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
#import "SCHCustomNavigationBar.h"
#import "SCHAppProfile.h"
#import "SCHBookIdentifier.h"

static const CGFloat kProfilePadTableOffsetPortrait = 280.0f;
static const CGFloat kProfilePadTableOffsetLandscape = 220.0f;

#pragma mark - Class Extension

@interface SCHProfileViewController_iPad () 

- (void)releaseViewObjects;
- (void)pushBookshelvesControllerWithProfileItem:(SCHProfileItem *)profileItem;
- (void)showProfilePasswordControllerWithAnimation:(BOOL)animated;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;

@property (nonatomic, retain) UIButton *settingsButton;

@end

@implementation SCHProfileViewController_iPad

@synthesize tableView;
@synthesize bookshelfViewController;
@synthesize headerView;
@synthesize containerView;
@synthesize backgroundView;
@synthesize settingsButton;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [super releaseViewObjects];
    [tableView release], tableView = nil;
    [bookshelfViewController release], bookshelfViewController = nil;
    [headerView release], headerView = nil;
    [containerView release], containerView = nil;
    [backgroundView release], backgroundView = nil;
    [settingsButton release], settingsButton = nil;
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc 
{    
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

#pragma mark - Fetched results controller delegate

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller 
{
    // In the simplest, most efficient, case, reload the table view.
    [self.tableView reloadData];
}

@end
