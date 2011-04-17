//
//  SCHThemePickerViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThemePickerViewController.h"

#import "SCHThemeManager.h"
#import <QuartzCore/QuartzCore.h>

@implementation SCHThemePickerViewController

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bookshelf-back"]];
    self.tableView.backgroundColor = [UIColor clearColor];

    UIButton *cancelButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cancelButton setFrame:CGRectMake(0, 0, 60, 30)];
    [cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [cancelButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5f] forState:UIControlStateHighlighted];
    [cancelButton setReversesTitleShadowWhenHighlighted:YES];

    cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    cancelButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    [cancelButton setBackgroundImage:[[UIImage imageNamed:@"button-cancel"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
    [cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:cancelButton] autorelease];
    
    UIButton *doneButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [doneButton setFrame:CGRectMake(0, 0, 60, 30)];
    [doneButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [doneButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5f] forState:UIControlStateHighlighted];
    [doneButton setReversesTitleShadowWhenHighlighted:YES];
    
    doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    doneButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    [doneButton setBackgroundImage:[[UIImage imageNamed:@"button-done"] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
    [doneButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:doneButton] autorelease];
    
    self.tableView.rowHeight = 58;
    self.tableView.separatorColor = [UIColor colorWithRed:0.000 green:0.365 blue:0.616 alpha:1.000];
}

- (void)cancel
{
    [self dismissModalViewControllerAnimated:YES];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width - 32, 50)];
    headerLabel.text = NSLocalizedString(@"Themes", @"");
    headerLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    headerLabel.numberOfLines = 1;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowOffset = CGSizeMake(0, -1);
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    [containerView addSubview:headerLabel];
    [headerLabel release];
    
    return [containerView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return(1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[SCHThemeManager sharedThemeManager] themeNames] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:22.0f];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
        cell.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
    }
    
    // Configure the cell...
    cell.textLabel.text = [[[SCHThemeManager sharedThemeManager] themeNames] objectAtIndex:indexPath.row];
    NSString *backgroundPath = [[NSBundle mainBundle] pathForResource:cell.textLabel.text ofType:@"png" inDirectory:@"Themes"];
    UIImage *backgroundImage = [UIImage imageWithContentsOfFile:backgroundPath];
    cell.backgroundColor = [UIColor colorWithPatternImage:backgroundImage];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     [detailViewController release];
     */
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
