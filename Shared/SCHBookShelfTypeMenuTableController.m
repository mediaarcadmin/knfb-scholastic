//
//  SCHBookShelfTypeMenuTableController.m
//  Scholastic
//
//  Created by Gordon Christie on 26/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookShelfTypeMenuTableController.h"

@interface SCHBookShelfTypeMenuTableController ()

@end

@implementation SCHBookShelfTypeMenuTableController

@synthesize delegate;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"BookShelfTypeCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell...
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"Bookshelf";
            break;
        }   
        case 1:
        {
            cell.textLabel.text = @"Detail";
            break;
        }   
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case 0:
        {
            [self.delegate bookShelfTypeControllerSelectedGridView:self];
            break;
        }   
        case 1:
        {
            [self.delegate bookShelfTypeControllerSelectedListView:self];
            break;
        }   
    }
    
}

#pragma mark - Popover Size

- (CGSize)contentSizeForViewInPopover
{
    CGFloat height = ([self tableView:self.tableView numberOfRowsInSection:0] * 44) + 20;
    return CGSizeMake(200, height);
}


@end
