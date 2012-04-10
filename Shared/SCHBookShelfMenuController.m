//
//  SCHBookShelfMenuController.m
//  Scholastic
//
//  Created by Gordon Christie on 26/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookShelfMenuController.h"
#import "SCHThemeManager.h"
#import "SCHBookshelfPopoverController.h"
#import "SCHBookShelfWishListController.h"
#import "SCHBookShelfRecommendationListController.h"
#import "SCHSettingItem.h"
#import "SCHAppStateManager.h"
#import "SCHCustomNavigationBar.h"

@interface SCHBookShelfMenuController ()

@property (nonatomic, retain) NSNumber *cachedRecommendationsActive;

- (BOOL)recommendationsActive;

@end

@implementation SCHBookShelfMenuController

@synthesize delegate;
@synthesize userIsAuthenticated;
@synthesize managedObjectContext;
@synthesize cachedRecommendationsActive;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil 
 managedObjectContext:(NSManagedObjectContext *)setManagedObjectContext
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        userIsAuthenticated = NO;
        managedObjectContext = [setManagedObjectContext retain];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [managedObjectContext release], managedObjectContext = nil;
    [cachedRecommendationsActive release], cachedRecommendationsActive = nil;
    
    [super dealloc];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"Options";
    self.navigationItem.backBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:nil action:nil] autorelease];
    
    // button tint colour for iPhone
    self.navigationController.navigationBar.tintColor = [[SCHThemeManager sharedThemeManager] colorForModalSheetBorder];
    
    // iOS 5 and above - set the tint colour inside a popover
    // simply setting the tint colour on the navigation bar isn't enough - 
    // popover overrides the style. This uses SCHBookShelfPopoverController 
    // to allow the appearance to be set only on this popover
    if ([[UIBarButtonItem class] respondsToSelector:@selector(appearanceWhenContainedIn:)]) {
        [[UIBarButtonItem appearanceWhenContainedIn:[SCHBookshelfPopoverController class], nil] 
         setTintColor:[[SCHThemeManager sharedThemeManager] colorForModalSheetBorder]];
    }
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)] autorelease];
        self.view.backgroundColor = [UIColor clearColor];
    }
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receivedRotate:) 
                                                 name:UIDeviceOrientationDidChangeNotification
                                               object:nil];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}


#pragma mark - Orientation methods

- (void)receivedRotate:(NSNotification *)notification
{
    UIDeviceOrientation toDeviceOrientation = [[UIDevice currentDevice] orientation];
    
    if (UIDeviceOrientationIsValidInterfaceOrientation(toDeviceOrientation)) {
        [self setupAssetsForOrientation:toDeviceOrientation];
    }
}

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        if (UIInterfaceOrientationIsLandscape(orientation)) {
            
            CGRect barFrame = self.navigationController.navigationBar.frame;
            if (barFrame.size.height == 44) {
                barFrame.size.height = 32;
                self.navigationController.navigationBar.frame = barFrame;
                [self.navigationController.navigationBar sizeToFit];
                
                CGRect tableFrame = self.tableView.frame;
                tableFrame.size.height += 12;
                tableFrame.origin.y -= 12;
                self.tableView.frame = tableFrame;

                [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
                 [[SCHThemeManager sharedThemeManager] imageForNavigationBar:UIInterfaceOrientationLandscapeLeft]];
            }
            
        } else {
            
            CGRect barFrame = self.navigationController.navigationBar.frame;
            if (barFrame.size.height == 32) {
                barFrame.size.height = 44;
                self.navigationController.navigationBar.frame = barFrame;
                [self.navigationController.navigationBar sizeToFit];
                
                CGRect tableFrame = self.tableView.frame;
                tableFrame.size.height -= 12;
                tableFrame.origin.y += 12;
                self.tableView.frame = tableFrame;

                [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
                 [[SCHThemeManager sharedThemeManager] imageForNavigationBar:UIInterfaceOrientationPortrait]];
            }
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)cancel
{
    [self.delegate bookShelfMenuCancelled:self];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (BOOL)recommendationsActive
{
    if (self.cachedRecommendationsActive == nil) {
        NSString *settingValue = [[SCHAppStateManager sharedAppStateManager] settingNamed:kSCHSettingItemRECOMMENDATIONS_ON];
        
        if (settingValue != nil) {
            self.cachedRecommendationsActive = [NSNumber numberWithBool:[settingValue boolValue]];
        }
    }
    
    return [self.cachedRecommendationsActive boolValue];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.userIsAuthenticated && [self recommendationsActive] == YES) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return 4;
        } else {
            // disable wishlists if the last authentication failed
            if ([[SCHAppStateManager sharedAppStateManager] lastScholasticAuthenticationFailed]) {
                return 4;
            } else {
                return 5;
            }
        }
    } else {
        return 3;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookShelfMenuCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    // Configure the cell...
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = NSLocalizedString(@"View", @"View");
            break;
        }   
        case 1:
        {
            cell.textLabel.text = NSLocalizedString(@"Theme", @"Theme");
            break;
        }   
        case 2:
        {
            cell.textLabel.text = NSLocalizedString(@"Sort", @"Sort");
            break;
        }   
        case 3:
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                cell.textLabel.text = NSLocalizedString(@"More eBooks", @"More eBooks");
            } else {
                cell.textLabel.text = NSLocalizedString(@"Kids' Top Rated eBooks", @"Kids' Top Rated eBooks");
            }
            break;
        }
        case 4:
        {
            cell.textLabel.text = NSLocalizedString(@"Wish List", @"Wish List");
            break;
        }
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    switch (indexPath.row) {
        case 0:
        {
            SCHBookShelfTypeMenuTableController *typeMenuController = [[SCHBookShelfTypeMenuTableController alloc] initWithNibName:@"SCHBookShelfTypeMenuTableController" bundle:nil];
            typeMenuController.delegate = self;
            
            [self.navigationController pushViewController:typeMenuController animated:YES];
            [typeMenuController release];

            break;
        }
        // themes
        case 1:
        {
            SCHThemePickerViewController *themePicker = [[SCHThemePickerViewController alloc] initWithNibName:nil bundle:nil];
            themePicker.delegate = self;
            
            [self.navigationController pushViewController:themePicker animated:YES];
            [themePicker release];
            
            break;
        }
        // sort
        case 2:
        {
            SCHBookShelfSortTableView *sortTable = [[SCHBookShelfSortTableView alloc] initWithNibName:nil bundle:nil];
            sortTable.sortType = [self.delegate sortTypeForBookShelfMenu:self];
            sortTable.delegate = self;

            [self.navigationController pushViewController:sortTable animated:YES];
            [sortTable release];
            
            break;
        }
        // recommendations / list view
        // also iPhone - Kids Top Rated eBooks
        case 3:
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                [self.delegate bookShelfMenuSelectedRecommendations:self];
            } else {
                SCHBookShelfRecommendationListController *recommendationList = [[SCHBookShelfRecommendationListController alloc] initWithNibName:@"SCHBookShelfRecommendationListController" bundle:nil];
                recommendationList.appProfile = [self.delegate appProfileForBookShelfMenu];
                recommendationList.lastAuthenticationFailed = [[SCHAppStateManager sharedAppStateManager] lastScholasticAuthenticationFailed];
                recommendationList.closeBlock = ^{
                    [self.delegate bookShelfMenuCancelled:self];
                };
                [self.navigationController pushViewController:recommendationList animated:YES];
                [recommendationList release];
            }
            break;
        }
        // iPhone only - Wish List
        case 4:
        {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                SCHBookShelfWishListController *wishList = [[SCHBookShelfWishListController alloc] initWithNibName:@"SCHBookShelfWishListController" bundle:nil];
                wishList.appProfile = [self.delegate appProfileForBookShelfMenu];
                wishList.closeBlock = ^{
                    [self.delegate bookShelfMenuCancelled:self];
                };
                [self.navigationController pushViewController:wishList animated:YES];
                [wishList release];
            }
            
            break;
        }
    }
}

#pragma mark - Sort Table View Delegate

- (void)sortPopover: (SCHBookShelfSortTableView *) sortTableView pickedSortType: (SCHBookSortType) newType
{
    NSLog(@"Picked a sort type!");
    [self.delegate bookShelfMenu:self changedSortType:newType];
    
}

- (void)sortPopoverCancelled: (SCHBookShelfSortTableView *) sortTableView
{
    [self.delegate bookShelfMenuCancelled:self];
}

#pragma mark - Bookshelf Type Delegate

- (SCHAppProfile *)appProfileForbookShelfTypeController
{
    return [self.delegate appProfileForBookShelfMenu];
}

- (void)bookShelfTypeControllerSelectedGridView:(SCHBookShelfTypeMenuTableController *)typeController
{
    [self.delegate bookShelfMenuSwitchedToGridView:self];
}

- (void)bookShelfTypeControllerSelectedListView:(SCHBookShelfTypeMenuTableController *)typeController
{
    [self.delegate bookShelfMenuSwitchedToListView:self];
}

- (void)bookShelfTypeControllerSelectedCancel:(SCHBookShelfTypeMenuTableController *)typeController
{
    [self.delegate bookShelfMenuCancelled:self];
}

#pragma mark - SCHThemePickerViewController Delegate

- (void)themePickerControllerSelectedClose:(SCHThemePickerViewController *)controller
{
    [self.delegate bookShelfMenuCancelled:self];
}

#pragma mark - Popover Size

- (CGSize)contentSizeForViewInPopover
{
    CGFloat height = ([self tableView:self.tableView numberOfRowsInSection:0] * 44) + 20;
    return CGSizeMake(240, height);
}


@end
