//
//  SCHBookShelfRecommendationListController.m
//  Scholastic
//
//  Created by Gordon Christie on 15/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookShelfRecommendationListController.h"
#import "SCHAppRecommendationItem.h"

@interface SCHBookShelfRecommendationListController ()

- (void)releaseViewObjects;
- (void)commitWishListChanges;

@property (nonatomic, retain) NSArray *localRecommendationItems;
@property (nonatomic, retain) NSArray *localWishListItems;
@property (nonatomic, retain) NSMutableArray *modifiedWishListItems;

@property (nonatomic, retain) UINib *recommendationViewNib;

@end

@implementation SCHBookShelfRecommendationListController

@synthesize delegate;
@synthesize appProfile;
@synthesize mainTableView;
@synthesize closeBlock;
@synthesize localRecommendationItems;
@synthesize localWishListItems;
@synthesize modifiedWishListItems;
@synthesize recommendationViewNib;

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
    [recommendationViewNib release], recommendationViewNib = nil;
    
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
        self.recommendationViewNib = [UINib nibWithNibName:@"SCHRecommendationListView" bundle:nil];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIColor *viewBackgroundColor = [UIColor colorWithRed:0.863 green:0.875 blue:0.894 alpha:1.0];

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
        return [[(NSDictionary *)obj objectForKey:kSCHAppRecommendationISBN] isEqualToString:ISBN];
    }];
    
    if (index != NSNotFound) {
        NSDictionary *recommendationItem = [self.localRecommendationItems objectAtIndex:index];

        // create the wishlist dictionary
        // add it to the profile
        NSMutableDictionary *wishListItem = [NSMutableDictionary dictionary];
        
        
        [wishListItem setValue:([recommendationItem objectForKey:kSCHAppRecommendationAuthor] == nil ? (id)[NSNull null] : [recommendationItem objectForKey:kSCHAppRecommendationAuthor]) 
                        forKey:kSCHWishListAuthor];
        [wishListItem setValue:([recommendationItem objectForKey:kSCHAppRecommendationISBN] == nil ? (id)[NSNull null] : [recommendationItem objectForKey:kSCHAppRecommendationISBN]) 
                        forKey:kSCHWishListISBN];
        [wishListItem setValue:([recommendationItem objectForKey:kSCHAppRecommendationTitle] == nil ? (id)[NSNull null] : [recommendationItem objectForKey:kSCHAppRecommendationTitle]) 
                        forKey:kSCHWishListTitle];
        
        [self.modifiedWishListItems addObject:wishListItem];
    }

    
    // reload table data
    self.localRecommendationItems = [self.appProfile recommendationDictionaries];
    [self.mainTableView reloadData];
}

- (void)recommendationListView:(SCHRecommendationListView *)listView removedISBNFromWishList:(NSString *)ISBN
{
    // find the item in the modified list and remove it
    NSUInteger modifiedItemsIndex = [self.modifiedWishListItems indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        return [[(NSDictionary *)obj objectForKey:kSCHAppRecommendationISBN] isEqualToString:ISBN];
    }];
    
    if (modifiedItemsIndex != NSNotFound) {
        [self.modifiedWishListItems removeObjectAtIndex:modifiedItemsIndex];
        
        // reload table data
        self.localRecommendationItems = [self.appProfile recommendationDictionaries];
        [self.mainTableView reloadData];
    }
}

#pragma mark - Wish List Changes

- (void)commitWishListChanges
{
    // look for items that are in the new list but not in the original list
    // those need to be added
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
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
//        SCHRecommendationListView *recommendationView = [[SCHRecommendationListView alloc] initWithFrame:cell.frame];
//        [self.recommendationViewNib instantiateWithOwner:recommendationView options:nil];
        
        SCHRecommendationListView *recommendationView = [[[self.recommendationViewNib instantiateWithOwner:self options:nil] objectAtIndex:0] retain];
        recommendationView.frame = cell.frame;
        NSLog(@"rec view: %@", recommendationView);
        
//        recommendationView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        recommendationView.tag = 999;
        recommendationView.delegate = self;
        recommendationView.recommendationBackgroundColor = [UIColor colorWithRed:0.863 green:0.875 blue:0.894 alpha:1.0];
        
        [cell addSubview:recommendationView];
        [recommendationView release];
    }
    
    if (self.localRecommendationItems && self.localRecommendationItems.count > 0) {
        SCHRecommendationListView *recommendationView = (SCHRecommendationListView *)[cell viewWithTag:999];
        NSString *ISBN = [[self.localRecommendationItems objectAtIndex:indexPath.row] objectForKey:kSCHAppRecommendationISBN];
        
        if (recommendationView) {
            
            [recommendationView updateWithRecommendationItem:[self.localRecommendationItems objectAtIndex:indexPath.row]];
            
            NSUInteger index = [self.modifiedWishListItems indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                return [[(NSDictionary *)obj objectForKey:kSCHAppRecommendationISBN] isEqualToString:ISBN];
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
    return 180;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // FIXME: could add the ability to toggle the whole row for add/remove from wishlist
//    NSLog(@"Recommendation item selected: %@", [self.localRecommendationItems objectAtIndex:indexPath.row]);
}

@end
