//
//  SCHBookShelfMenuController.m
//  Scholastic
//
//  Created by Gordon Christie on 26/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookShelfMenuController.h"

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
    
    self.navigationController.navigationBarHidden = YES;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (CGSize)contentSizeForViewInPopover
{
    CGFloat height = ([self tableView:self.tableView numberOfRowsInSection:0] * 44) + 20;
    return CGSizeMake(200, height);
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
    if (self.userIsAuthenticated) {
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

- (void)sortPopoverPickedSortType: (SCHBookSortType) newType
{
    NSLog(@"Picked a sort type!");
    [self.delegate bookShelfMenu:self changedSortType:newType];
    
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

@end
