//
//  SCHBookShelfRecommendationListController.m
//  Scholastic
//
//  Created by Gordon Christie on 15/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBookShelfRecommendationListController.h"
#import "SCHAppRecommendationItem.h"
#import "SCHThemeManager.h"
#import "SCHAppStateManager.h"
#import "SCHSyncManager.h"
#import "SCHTopRatingsSyncComponent.h"
#import "SCHRecommendationURLRequestOperation.h"

@interface SCHBookShelfRecommendationListController ()

- (void)releaseViewObjects;
- (void)commitWishListChanges;
- (void)refreshFromAppProfile;
- (void)reloadRecommendations;

@property (nonatomic, retain) NSArray *localRecommendationItems;
@property (nonatomic, retain) NSArray *localWishListItems;
@property (nonatomic, retain) NSMutableArray *modifiedWishListItems;

@property (nonatomic, retain) UINib *recommendationViewNib;

@end

@implementation SCHBookShelfRecommendationListController

@synthesize delegate;
@synthesize appProfile;
@synthesize mainTableView;
@synthesize titleLabel;
@synthesize topToolbar;
@synthesize bottomToolbar;
@synthesize closeButton;
@synthesize bottomSegment;
@synthesize closeBlock;
@synthesize localRecommendationItems;
@synthesize localWishListItems;
@synthesize modifiedWishListItems;
@synthesize recommendationViewNib;
@synthesize shouldShowWishList;

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

    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SCHTopRatingsSyncComponentDidCompleteNotification
                                                  object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:SCHRecommendationURLRequestOperationDidUpdateNotification
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
        self.recommendationViewNib = [UINib nibWithNibName:@"SCHRecommendationListView" bundle:nil];
        self.shouldShowWishList = YES;

        [[SCHSyncManager sharedSyncManager] topRatingsSync];

        // watch for new recommendations coming in
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(reloadRecommendations)
                                                     name:SCHTopRatingsSyncComponentDidCompleteNotification
                                                   object:nil];
        // watch for new info becoming available from the recommendation manager
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(recommendationDidUpdate:)
                                                     name:SCHRecommendationURLRequestOperationDidUpdateNotification
                                                   object:nil];

    }
    return self;
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self refreshFromAppProfile];
    
    // iPad specific setup
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
        
        self.titleLabel.text = NSLocalizedString(@"Here are kids' top-rated eBooks", @"Here are kids' top-rated eBooks");
        
        if (self.shouldShowWishList) {
            self.bottomSegment.hidden = NO;
        } else {
            self.bottomSegment.hidden = YES;
        }
        
        self.mainTableView.indicatorStyle = UIScrollViewIndicatorStyleBlack;
    } else {
        self.title = NSLocalizedString(@"Top-Rated eBooks", @"Top-Rated eBooks");
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
    // commit wish list changes on close - iPhone only
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [self commitWishListChanges];
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
    // commit wish list changes on close - iPad only
    [self commitWishListChanges];
    
    if (closeBlock) {
        closeBlock();
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
        return [[(NSDictionary *)obj objectForKey:kSCHAppRecommendationItemISBN] isEqualToString:ISBN];
    }];
    
    if (index != NSNotFound) {
        NSDictionary *recommendationItem = [self.localRecommendationItems objectAtIndex:index];

        // create the wishlist dictionary
        // add it to the profile
        NSMutableDictionary *wishListItem = [NSMutableDictionary dictionary];
        
        
        [wishListItem setValue:([recommendationItem objectForKey:kSCHAppRecommendationItemAuthor] == nil ? (id)[NSNull null] : [recommendationItem objectForKey:kSCHAppRecommendationItemAuthor]) 
                        forKey:kSCHWishListAuthor];
        [wishListItem setValue:([recommendationItem objectForKey:kSCHAppRecommendationItemISBN] == nil ? (id)[NSNull null] : [recommendationItem objectForKey:kSCHAppRecommendationItemISBN]) 
                        forKey:kSCHWishListISBN];
        [wishListItem setValue:([recommendationItem objectForKey:kSCHAppRecommendationItemTitle] == nil ? (id)[NSNull null] : [recommendationItem objectForKey:kSCHAppRecommendationItemTitle]) 
                        forKey:kSCHWishListTitle];
        
        [self.modifiedWishListItems addObject:wishListItem];
    }


    [self reloadRecommendations];
}

- (void)reloadRecommendations
{
    // reload table data
    self.localRecommendationItems = [self.appProfile recommendationDictionaries];
    [self.mainTableView reloadData];
}

- (void)recommendationListView:(SCHRecommendationListView *)listView removedISBNFromWishList:(NSString *)ISBN
{
    // find the item in the modified list and remove it
    NSUInteger modifiedItemsIndex = [self.modifiedWishListItems indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        return [[(NSDictionary *)obj objectForKey:kSCHAppRecommendationItemISBN] isEqualToString:ISBN];
    }];
    
    if (modifiedItemsIndex != NSNotFound) {
        [self.modifiedWishListItems removeObjectAtIndex:modifiedItemsIndex];
        
        // reload table data
        self.localRecommendationItems = [self.appProfile recommendationDictionaries];
        [self.mainTableView reloadData];
    }
}

#pragma mark - Wish List Changes

- (void)refreshFromAppProfile
{
    self.localRecommendationItems = [self.appProfile recommendationDictionaries];
    self.localWishListItems = [self.appProfile wishListItemDictionaries];
    
    // take a copy of the original state of the wish list and modify that instead
    self.modifiedWishListItems = [NSMutableArray arrayWithArray:self.localWishListItems];
}

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
    
    // sync with the new changes we've just made - this makes multiple calls
    // to commitWishListChanges safe
    [self refreshFromAppProfile];
}

#pragma mark - Segmented Control

- (IBAction)segmentChanged:(UISegmentedControl *)sender 
{
    if (sender.selectedSegmentIndex == 1) {
        // commit wish list changes on segment change - iPad only
        [self commitWishListChanges];
        
        if (self.delegate) {
            [self.delegate switchToWishListFromRecommendationListController:self];
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
    if (self.localRecommendationItems && self.localRecommendationItems.count > 0) {
        return self.localRecommendationItems.count;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.localRecommendationItems && self.localRecommendationItems.count > 0) {
        
        static NSString *CellIdentifier = @"RecommendationListController";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            SCHRecommendationListView *recommendationView = [[[self.recommendationViewNib instantiateWithOwner:self options:nil] objectAtIndex:0] retain];
            recommendationView.frame = cell.frame;
            recommendationView.showsWishListButton = self.shouldShowWishList;
            
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
        
        if (self.localRecommendationItems && self.localRecommendationItems.count > 0) {
            SCHRecommendationListView *recommendationView = (SCHRecommendationListView *)[cell viewWithTag:999];
            NSString *ISBN = [[self.localRecommendationItems objectAtIndex:indexPath.row] objectForKey:kSCHAppRecommendationItemISBN];
            
            if (recommendationView) {
                
                [recommendationView updateWithRecommendationItem:[self.localRecommendationItems objectAtIndex:indexPath.row]];
                
                NSUInteger index = [self.modifiedWishListItems indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
                    return [[(NSDictionary *)obj objectForKey:kSCHAppRecommendationItemISBN] isEqualToString:ISBN];
                }];
                
                if (index != NSNotFound) {
                    [recommendationView setIsOnWishList:YES];
                } else {
                    [recommendationView setIsOnWishList:NO];
                }
            }
        }
        
        return cell;
    } else {
        static NSString *CellIdentifier = @"RecommendationEmptyCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        
        if (!cell) {
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
            cell.backgroundColor = [UIColor colorWithRed:0.863 green:0.875 blue:0.902 alpha:1.0];
            UILabel *label = [[UILabel alloc] initWithFrame:cell.contentView.frame];
            label.text = NSLocalizedString(@"No Top-Rated eBooks.", @"No Top-Rated eBooks.");
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
    if (!self.localRecommendationItems || self.localRecommendationItems.count == 0) {
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
    // FIXME: could add the ability to toggle the whole row for add/remove from wishlist
//    NSLog(@"Recommendation item selected: %@", [self.localRecommendationItems objectAtIndex:indexPath.row]);
}

#pragma mark - RecommendationManager update notifications

- (void)recommendationDidUpdate:(NSNotification *)notification
{
    NSDictionary *recommendationItemDictionary = notification.userInfo;
    NSString *updatedRecommendationISBN = [recommendationItemDictionary objectForKey:kSCHAppRecommendationItemISBN];

    if (updatedRecommendationISBN != nil) {
        for (NSDictionary *recommendationDict in self.localRecommendationItems) {
            NSString *recommendationISBN = [recommendationDict objectForKey:kSCHAppRecommendationItemISBN];

            if (recommendationISBN != nil && [updatedRecommendationISBN isEqualToString:recommendationISBN] == YES) {
                self.localRecommendationItems = [self.appProfile recommendationDictionaries];
                break;
            }
        }
    }
}

@end
