//
//  SCHBookShelfTypeMenuTableController.m
//  Scholastic
//
//  Created by Gordon Christie on 26/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookShelfTypeMenuTableController.h"
#import "SCHThemeManager.h"

@interface SCHBookShelfTypeMenuTableController ()

@property (nonatomic, assign) BOOL showingListView;

@end

@implementation SCHBookShelfTypeMenuTableController

@synthesize delegate;
@synthesize showingListView;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.showingListView = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"View";

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(cancel)] autorelease];
        
        self.tableView.backgroundColor = [UIColor clearColor];
    }

    self.showingListView = [[self.delegate appProfileForbookShelfTypeController].ShowListView boolValue];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)cancel
{
    [self.delegate bookShelfTypeControllerSelectedCancel:self];
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
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    // Configure the cell...
    
    switch (indexPath.row) {
        case 0:
        {
            cell.textLabel.text = @"Bookshelf";
            if (self.showingListView) {
                cell.textLabel.textColor = [UIColor darkTextColor];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            } else {
                cell.textLabel.textColor = [UIColor grayColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            }

            break;
        }   
        case 1:
        {
            cell.textLabel.text = @"Details";
            if (self.showingListView) {
                cell.textLabel.textColor = [UIColor grayColor];
                cell.selectionStyle = UITableViewCellSelectionStyleNone;
            } else {
                cell.textLabel.textColor = [UIColor darkTextColor];
                cell.selectionStyle = UITableViewCellSelectionStyleBlue;
            }

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
            if (self.showingListView) {
                [self.delegate bookShelfTypeControllerSelectedGridView:self];
            }
            break;
        }   
        case 1:
        {
            if (!self.showingListView) {
                [self.delegate bookShelfTypeControllerSelectedListView:self];
            }
            break;
        }   
    }
    
}

#pragma mark - Popover Size

- (CGSize)contentSizeForViewInPopover
{
    CGFloat height = (2 * 44) + 20;
    return CGSizeMake(240, height);
}


@end
