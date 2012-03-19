//
//  SCHBookShelfWishListController.m
//  Scholastic
//
//  Created by Gordon Christie on 19/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookShelfWishListController.h"

#import "SCHRecommendationListView.h"

@interface SCHBookShelfWishListController ()

- (void)releaseViewObjects;
- (IBAction)switchToRecommendations:(id)sender;

@property (nonatomic, retain) NSArray *localWishListItems;

@end

@implementation SCHBookShelfWishListController

@synthesize delegate;
@synthesize appProfile;
@synthesize mainTableView;
@synthesize closeBlock;
@synthesize localWishListItems;

#pragma mark - Memory Management

- (void)dealloc
{
    // release any non-view objects
    delegate = nil;
    [appProfile release], appProfile = nil;
    [closeBlock release], closeBlock = nil;
    [localWishListItems release], localWishListItems = nil;
    
    // release view objects
    [self releaseViewObjects];
    [super dealloc];
}

- (void)releaseViewObjects
{
    // release any view objects here
    [mainTableView release], mainTableView = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(close:)] autorelease];
        self.title = @"Your Wish List";
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *viewBackgroundColor = [UIColor colorWithRed:0.996 green:0.937 blue:0.718 alpha:1.0];
    self.mainTableView.backgroundColor = viewBackgroundColor;
    
    // fetch a local list of wish list items
    // we need to maintain this local copy, so that items can 
    // be unticked but remain in the list
    self.localWishListItems = [self.appProfile wishListItems];
}

- (void)viewDidUnload
{
    // release view objects
    [self releaseViewObjects];
    [super viewDidUnload];
}

#pragma mark - View Actions

- (IBAction)close:(id)sender
{
    if (closeBlock) {
        closeBlock();
    }
}

- (IBAction)switchToRecommendations:(id)sender
{
    if (self.delegate) {
        [self.delegate switchToRecommendationsFromWishListController:self];
    }
}

#pragma mark - View Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
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
    if (self.localWishListItems && self.localWishListItems.count > 0) {
        return self.localWishListItems.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"WishListControllerCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        
        SCHRecommendationListView *recommendationView = [[SCHRecommendationListView alloc] initWithFrame:cell.frame];
        recommendationView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        recommendationView.tag = 999;
        
        [cell addSubview:recommendationView];
        [recommendationView release];
    }
    
    if (self.localWishListItems && self.localWishListItems.count > 0) {
        SCHRecommendationListView *recommendationView = (SCHRecommendationListView *)[cell viewWithTag:999];
        
        if (recommendationView) {
            [recommendationView updateWithWishListItem:[self.localWishListItems objectAtIndex:indexPath.row]];
        }
    }
    
    return cell;
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 132;
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
}

@end
