//
//  SCHBookShelfWishListController.m
//  Scholastic
//
//  Created by Gordon Christie on 19/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookShelfWishListController.h"
#import "SCHThemeManager.h"

#import "SCHSyncManager.h"
#import "SCHWishListSyncComponent.h"
#import "SCHRecommendationURLRequestOperation.h"

@interface SCHBookShelfWishListController ()

- (void)releaseViewObjects;
- (void)commitWishListDeletions;


@property (nonatomic, retain) NSArray *localWishListItems;
@property (nonatomic, retain) NSMutableArray *wishListItemsToRemove;
@property (nonatomic, retain) UINib *recommendationViewNib;

@end

@implementation SCHBookShelfWishListController

@synthesize delegate;
@synthesize appProfile;
@synthesize mainTableView;
@synthesize titleLabel;
@synthesize topToolbar;
@synthesize bottomToolbar;
@synthesize closeButton;
@synthesize bottomSegment;
@synthesize closeBlock;
@synthesize localWishListItems;
@synthesize wishListItemsToRemove;
@synthesize recommendationViewNib;

#pragma mark - Memory Management 

- (void)dealloc
{
    // release any non-view objects
    delegate = nil;
    [appProfile release], appProfile = nil;
    [closeBlock release], closeBlock = nil;
    [localWishListItems release], localWishListItems = nil;
    [wishListItemsToRemove release], wishListItemsToRemove = nil;
    [recommendationViewNib release], recommendationViewNib = nil;

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SCHWishListSyncComponentDidCompleteNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kSCHRecommendationStateUpdateNotification
                                                  object:nil];

    // release view objects
    [self releaseViewObjects];
    [super dealloc];
}

- (void)releaseViewObjects
{
    // release any view objects here
    [mainTableView release], mainTableView = nil;
    [topToolbar release], topToolbar = nil;
    [bottomToolbar release], bottomToolbar = nil;
    [titleLabel release], titleLabel = nil;
    [closeButton release], closeButton = nil;
    [bottomSegment release], bottomSegment = nil;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.wishListItemsToRemove = [NSMutableArray array];
        self.recommendationViewNib = [UINib nibWithNibName:@"SCHRecommendationListView" bundle:nil];

        [[SCHSyncManager sharedSyncManager] wishListSyncForced:NO];

        // watch for new wishlist items coming in
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadWishlist)
                                                     name:SCHWishListSyncComponentDidCompleteNotification
                                                   object:nil];
        // watch for new info becoming available from the recommendation manager
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(recommendationDidUpdate:)
                                                     name:kSCHRecommendationStateUpdateNotification
                                                   object:nil];
    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    // fetch a local list of wish list items
    // we need to maintain this local copy, so that items can 
    // be unticked but remain in the list
    self.localWishListItems = [self.appProfile wishListItemDictionaries];
    

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        UIColor *viewBackgroundColor = [UIColor colorWithRed:0.863 green:0.875 blue:0.894 alpha:1.0];
        
        self.mainTableView.backgroundColor = viewBackgroundColor;
        
        [self.view.layer setCornerRadius:6];
        [self.view.layer setMasksToBounds:YES];
        [self.view.layer setBorderColor:[[SCHThemeManager sharedThemeManager] colorForModalSheetBorder].CGColor];
        [self.view.layer setBorderWidth:2.0f];
        
        [self.topToolbar setTintColor:[[SCHThemeManager sharedThemeManager] colorForModalSheetBorder]];
        [self.bottomToolbar setTintColor:[[SCHThemeManager sharedThemeManager] colorForModalSheetBorder]];
        
        [self.topToolbar setBackgroundImage:[[SCHThemeManager sharedThemeManager] imageForNavigationBar:UIInterfaceOrientationPortrait]];
        [self.bottomToolbar setBackgroundImage:[[SCHThemeManager sharedThemeManager] imageForNavigationBar:UIInterfaceOrientationPortrait]];
        
        self.titleLabel.text = NSLocalizedString(@"Here are eBooks on your wish list", @"Here are eBooks on your wish list");

        self.mainTableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;

    } else {
        self.title = NSLocalizedString(@"Wish List", @"Wish List");
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(close:)] autorelease];
        self.mainTableView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    }
    
}

- (void)viewDidUnload
{
    // release view objects
    [self releaseViewObjects];
    [super viewDidUnload];
}

- (void)viewWillDisappear:(BOOL)animated
{
    // commit wish list deletion on close - iPhone only
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self commitWishListDeletions];
    }
    
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [self.mainTableView flashScrollIndicators];
    [super viewWillAppear:animated];
}

#pragma mark - View Actions

- (IBAction)close:(id)sender
{
    // commit wish list deletion on close - iPad only
    [self commitWishListDeletions];

    [[SCHSyncManager sharedSyncManager] wishListSyncForced:NO];

    if (closeBlock) {
        closeBlock();
    }
}

- (IBAction)bottomSegmentChanged:(UISegmentedControl *)sender 
{
    if (sender.selectedSegmentIndex == 0) {
        [self commitWishListDeletions];
        
        if (self.delegate) {
            [self.delegate switchToRecommendationsFromWishListController:self];
        }
    }
}

#pragma mark - View Rotation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return YES;
}

#pragma mark - SCHRecommendationListViewDelegate methods

- (void)recommendationListView:(SCHRecommendationListView *)listView addedISBNToWishList:(NSString *)ISBN
{
    // remove the item from the list to be deleted
    NSUInteger index = [self.wishListItemsToRemove indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        return [[(NSDictionary *)obj objectForKey:kSCHWishListISBN] isEqualToString:ISBN];
    }];
    
    if (index != NSNotFound) {
        [self.wishListItemsToRemove removeObjectAtIndex:index];
    }

    [self.mainTableView reloadData];
}

- (void)reloadWishlist
{
    // reload table data
    self.localWishListItems = [self.appProfile wishListItemDictionaries];
    [self.mainTableView reloadData];
}

- (void)recommendationListView:(SCHRecommendationListView *)listView removedISBNFromWishList:(NSString *)ISBN
{
    NSUInteger index = [self.localWishListItems indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        return [[(NSDictionary *)obj objectForKey:kSCHWishListISBN] isEqualToString:ISBN];
    }];
    
    if (index != NSNotFound) {
        [self.wishListItemsToRemove addObject:[self.localWishListItems objectAtIndex:index]];
    }
         
    [self.mainTableView reloadData];
}

#pragma mark - Wish List Deletion

- (void)commitWishListDeletions
{
    for (NSDictionary *dict in self.wishListItemsToRemove) {
        [self.appProfile removeFromWishList:dict];
    }
    
    // remove items that have been removed, so this can be called multiple times safely
    [self.wishListItemsToRemove removeAllObjects];
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
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.localWishListItems && self.localWishListItems.count > 0) {

        static NSString *CellIdentifier = @"WishListControllerCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            
            SCHRecommendationListView *recommendationView = [[[self.recommendationViewNib instantiateWithOwner:self options:nil] objectAtIndex:0] retain];
            recommendationView.frame = cell.frame;
            cell.selectionStyle = UITableViewCellSelectionStyleNone;

            recommendationView.tag = 999;
            recommendationView.delegate = self;
            
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                recommendationView.recommendationBackgroundColor = [UIColor colorWithRed:0.863 green:0.875 blue:0.894 alpha:1.0];
            } else {
                recommendationView.recommendationBackgroundColor = [UIColor clearColor];
                cell.backgroundColor = [UIColor colorWithRed:0.863 green:0.875 blue:0.902 alpha:1.0];
            }
            
            if (indexPath.row >= ([self tableView:self.mainTableView numberOfRowsInSection:0] - 1)) {
                recommendationView.showsBottomRule = NO;
            } else {
                recommendationView.showsBottomRule = YES;
            }
            
            [recommendationView acceptUpdatesFromRecommendationManager];
            
            [cell addSubview:recommendationView];
            [recommendationView release];
        }
        
        SCHRecommendationListView *recommendationView = (SCHRecommendationListView *)[cell viewWithTag:999];
        
        if (recommendationView) {
            [recommendationView updateWithWishListItem:[self.localWishListItems objectAtIndex:indexPath.row]];
            
            NSString *ISBN = [[self.localWishListItems objectAtIndex:indexPath.row] objectForKey:kSCHWishListISBN];

            NSUInteger index = [self.wishListItemsToRemove indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                return [[(NSDictionary *)obj objectForKey:kSCHWishListISBN] isEqualToString:ISBN];
            }];
            
            if (index == NSNotFound) {
                [recommendationView setIsOnWishList:YES];
            } else {
                [recommendationView setIsOnWishList:NO];
            }

        }
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"WishListEmptyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.backgroundColor = [UIColor colorWithRed:0.863 green:0.875 blue:0.902 alpha:1.0];
            UILabel *label = [[UILabel alloc] initWithFrame:cell.contentView.frame];
            label.text = NSLocalizedString(@"No Wish List Items.", @"No Wish List Items.");
            label.font = [UIFont fontWithName:@"Arial-BoldMT" size:17.0f];
            label.textColor = [UIColor colorWithRed:0.004 green:0.192 blue:0.373 alpha:1.0];
            label.textAlignment = UITextAlignmentCenter;
            label.backgroundColor = [UIColor clearColor];
            label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            [cell.contentView addSubview:label];
            [label release];
        }
        
        
        return cell;
    }
}

- (float)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.localWishListItems || self.localWishListItems.count == 0) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            return 120;
        } else {
            return 44;
        }
    }
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        if (indexPath.row == 0) {
            return 199;
        }
        
        return 185;
    } else {
        if (indexPath.row == 0) {
            return 157;
        }
        
        return 150;
    }
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

#pragma mark - RecommendationManager update notifications

- (void)recommendationDidUpdate:(NSNotification *)notification
{
    NSDictionary *recommendationItemDictionary = notification.userInfo;
    NSString *updatedRecommendationISBN = [recommendationItemDictionary objectForKey:kSCHAppRecommendationItemISBN];

    if (updatedRecommendationISBN != nil) {
        for (NSDictionary *wishlistDict in self.localWishListItems) {
            NSString *recommendationISBN = [wishlistDict objectForKey:kSCHAppRecommendationItemISBN];

            if (recommendationISBN != nil && [updatedRecommendationISBN isEqualToString:recommendationISBN] == YES) {
                [self reloadWishlist];
                break;
            }
        }
    }
}

@end
