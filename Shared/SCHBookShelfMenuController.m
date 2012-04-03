//
//  SCHBookShelfMenuController.m
//  Scholastic
//
//  Created by Gordon Christie on 26/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookShelfMenuController.h"
#import "SCHAppStateManager.h"
#import "SCHThemeManager.h"
#import "SCHBookshelfPopoverController.h"

@interface SCHBookShelfMenuController ()

@end

@implementation SCHBookShelfMenuController

@synthesize delegate;
@synthesize userIsAuthenticated;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.userIsAuthenticated = NO;
    }
    return self;
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
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.userIsAuthenticated &&
        [[SCHAppStateManager sharedAppStateManager] isCOPPACompliant] == YES) {
        return 4;
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
            cell.textLabel.text = NSLocalizedString(@"Sort", @"Sort");
            break;
        }   
        case 2:
        {
            cell.textLabel.text = NSLocalizedString(@"Wallpaper", @"Wallpaper");
            break;
        }   
        case 3:
        {
            cell.textLabel.text = NSLocalizedString(@"More eBooks", @"More eBooks");
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
        // sort
        case 1:
        {
            SCHBookShelfSortTableView *sortTable = [[SCHBookShelfSortTableView alloc] initWithNibName:nil bundle:nil];
            sortTable.sortType = [self.delegate sortTypeForBookShelfMenu:self];
            sortTable.delegate = self;

            [self.navigationController pushViewController:sortTable animated:YES];
            [sortTable release];
            
            break;
        }
        // themes
        case 2:
        {
            SCHThemePickerViewController *themePicker = [[SCHThemePickerViewController alloc] initWithNibName:nil bundle:nil];
            themePicker.delegate = self;
            
            [self.navigationController pushViewController:themePicker animated:YES];
            [themePicker release];
            
            break;
        }
        // recommendations / list view
        case 3:
        {
            [self.delegate bookShelfMenuSelectedRecommendations:self];
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
