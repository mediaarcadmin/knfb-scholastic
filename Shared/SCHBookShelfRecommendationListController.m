//
//  SCHBookShelfRecommendationListController.m
//  Scholastic
//
//  Created by Gordon Christie on 15/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookShelfRecommendationListController.h"

@interface SCHBookShelfRecommendationListController ()

- (void)releaseViewObjects;
- (void)commitWishListChanges;

@property (nonatomic, retain) NSArray *localRecommendationItems;
@property (nonatomic, retain) NSArray *localWishListItems;
@property (nonatomic, retain) NSMutableArray *modifiedWishListItems;

@end

@implementation SCHBookShelfRecommendationListController

@synthesize delegate;
@synthesize appProfile;
@synthesize mainTableView;
@synthesize closeBlock;
@synthesize localRecommendationItems;
@synthesize localWishListItems;
@synthesize modifiedWishListItems;

#pragma mark - Memory Management

- (void)dealloc
{
    // release any non-view objects
    delegate = nil;
    [localWishListItems release], localWishListItems = nil;
    [localRecommendationItems release], localRecommendationItems = nil;
    [modifiedWishListItems release], modifiedWishListItems = nil;
    [appProfile release], appProfile = nil;
    [closeBlock release], closeBlock = nil;
    
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
        self.title = @"Kids' Top Rated eBooks";
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *viewBackgroundColor = [UIColor colorWithRed:0.996 green:0.937 blue:0.718 alpha:1.0];
    self.mainTableView.backgroundColor = viewBackgroundColor;
    
    self.localRecommendationItems = [self.appProfile recommendationDictionaries];
    self.localWishListItems = [self.appProfile wishListItemDictionaries];

    // take a copy of the original state of the wish list and modify that instead
    self.modifiedWishListItems = [NSMutableArray arrayWithArray:self.localWishListItems];

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
    [self commitWishListChanges];

    if (closeBlock) {
        closeBlock();
    }
}

- (IBAction)switchToWishList:(id)sender
{
    [self commitWishListChanges];
    
    if (self.delegate) {
        [self.delegate switchToWishListFromRecommendationListController:self];
    }
}

#pragma mark - View Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - SCHRecommendationListView delegate

- (void)recommendationListView:(SCHRecommendationListView *)listView addedISBNToWishList:(NSString *)ISBN
{
    // find the recommendation item
    NSUInteger index = [self.localRecommendationItems indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        return [[(NSDictionary *)obj objectForKey:kSCHAppProfileISBN] isEqualToString:ISBN];
    }];
    
    if (index != NSNotFound) {
        NSDictionary *item = [self.localRecommendationItems objectAtIndex:index];

        // create the wishlist dictionary
        // add it to the profile
        NSMutableDictionary *wishListItem = [NSMutableDictionary dictionary];
        
        [wishListItem setValue:([item objectForKey:kSCHAppProfileAuthor] == nil ? (id)[NSNull null] : [item objectForKey:kSCHAppProfileAuthor]) 
                        forKey:kSCHAppProfileAuthor];
        [wishListItem setValue:([item objectForKey:kSCHAppProfileISBN] == nil ? (id)[NSNull null] : [item objectForKey:kSCHAppProfileISBN]) 
                        forKey:kSCHAppProfileISBN];
        [wishListItem setValue:([item objectForKey:kSCHAppProfileTitle] == nil ? (id)[NSNull null] : [item objectForKey:kSCHAppProfileTitle]) 
                        forKey:kSCHAppProfileTitle];
        
//        [self.appProfile addToWishList:wishListItem];
        
        [self.modifiedWishListItems addObject:wishListItem];
    }

    
    // reload table data
    self.localRecommendationItems = [self.appProfile recommendationDictionaries];
//    self.localWishListItems = [self.appProfile wishListItemDictionaries];
    [self.mainTableView reloadData];
}

- (void)recommendationListView:(SCHRecommendationListView *)listView removedISBNFromWishList:(NSString *)ISBN
{
    // get the wishlist from the app profile
//    NSArray *wishListItems = [self.appProfile wishListItemDictionaries];
    
    NSUInteger index = [self.localWishListItems indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        return [[(NSDictionary *)obj objectForKey:kSCHAppProfileISBN] isEqualToString:ISBN];
    }];
    
    if (index != NSNotFound) {
//        NSDictionary *item = [self.localWishListItems objectAtIndex:index];
//        [self.appProfile removeFromWishList:item];
        [self.modifiedWishListItems removeObjectAtIndex:index];
    }
    
    // reload table data
    self.localRecommendationItems = [self.appProfile recommendationDictionaries];
//    self.localWishListItems = [self.appProfile wishListItemDictionaries];
    [self.mainTableView reloadData];
}

#pragma mark - Wish List Changes

- (void)commitWishListChanges
{
    for (NSDictionary *item in self.modifiedWishListItems) {
        if (![self.localWishListItems containsObject:item]) {
            [self.appProfile addToWishList:item];
        }
    }
    
    // look for items that are in the original but not in the new list
    // those need to be deleted
    for (NSDictionary *item in self.localWishListItems) {
        if (![self.modifiedWishListItems containsObject:item]) {
            [self.appProfile removeFromWishList:item];
        }
    }
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
    NSLog(@"Number of rows.");
    
    if (self.localRecommendationItems && self.localRecommendationItems.count > 0) {
        return self.localRecommendationItems.count;
    } else {
        return 0;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"RecommendationListController";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];

        SCHRecommendationListView *recommendationView = [[SCHRecommendationListView alloc] initWithFrame:cell.frame];
        recommendationView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        recommendationView.tag = 999;
        recommendationView.delegate = self;
        
        [cell addSubview:recommendationView];
        [recommendationView release];
    }
    
    if (self.localRecommendationItems && self.localRecommendationItems.count > 0) {
        SCHRecommendationListView *recommendationView = (SCHRecommendationListView *)[cell viewWithTag:999];
        NSString *ISBN = [[self.localRecommendationItems objectAtIndex:indexPath.row] objectForKey:kSCHAppProfileISBN];
        
        if (recommendationView) {
            
            [recommendationView updateWithRecommendationItem:[self.localRecommendationItems objectAtIndex:indexPath.row]];
            
            NSUInteger index = [self.modifiedWishListItems indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                return [[(NSDictionary *)obj objectForKey:kSCHAppProfileISBN] isEqualToString:ISBN];
            }];
            
            if (index != NSNotFound) {
                [recommendationView setIsOnWishList:YES];
            } else {
                [recommendationView setIsOnWishList:NO];
            }
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
