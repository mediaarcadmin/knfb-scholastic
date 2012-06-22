//
//  SCHBookShelfViewController_iPad.m
//  Scholastic
//
//  Created by Gordon Christie on 16/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfViewController_iPad.h"
#import "SCHBookShelfViewControllerProtected.h"
#import <QuartzCore/QuartzCore.h>
#import "SCHBookShelfGridView.h"
#import "SCHCustomNavigationBar.h"
#import "SCHThemeManager.h"
#import "SCHBookManager.h"
#import "SCHThemeButton.h"
#import "SCHBookShelfTopTenPopoverTableView.h"
#import "SCHTopFavoritesComponent.h"
#import "SCHProfileItem.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHAppProfile.h"
#import "SCHAppStateManager.h"
#import "LambdaAlert.h"
#import "SCHVersionDownloadManager.h"
#import "SCHLibreAccessConstants.h"
#import "BITModalSheetController.h"
#import "SCHBookShelfMenuPopoverBackgroundView.h"
#import "SCHBookshelfPopoverController.h"
#import "SCHAppStateManager.h"

//static NSInteger const kSCHBookShelfViewControllerGridCellHeightPortrait_iPad = 254;
static NSInteger const kSCHBookShelfViewControllerGridCellHeightPortrait_iPad = 224;
static NSInteger const kSCHBookShelfViewControllerGridCellHeightLandscape_iPad = 225;
static NSInteger const kSCHBookShelfButtonPadding = 25;
static NSInteger const kSCHBookShelfEdgePadding = 12;
//static NSTimeInterval const kSCHBookShelfViewControllerTopTenRefreshTime = -600.0;

@interface SCHBookShelfViewController_iPad ()

@property (nonatomic, retain) SCHTopFavoritesComponent *topFavoritesComponent;
@property (nonatomic, retain) NSArray *topTenBooks;
@property (nonatomic, retain) NSDate *lastTopTenBookRetrieval;

@property (nonatomic, retain) SCHThemeButton *topTenPicksButton;
@property (nonatomic, retain) SCHThemeButton *sortButton;
@property (nonatomic, retain) SCHThemeButton *ratingButton;

@property (nonatomic, retain) UIPopoverController *popover;
@property (nonatomic, retain) BITModalSheetController *recommendationPopover;

- (void)updateTheme;
- (void)setupToolbar;
- (void)showAppVersionOutdatedAlert;

- (void)showRecommendationsListAnimated:(BOOL)animated;
- (void)showWishListAnimated:(BOOL)animated;

@end

@implementation SCHBookShelfViewController_iPad

@synthesize topFavoritesComponent;
@synthesize topTenBooks;
@synthesize lastTopTenBookRetrieval;
@synthesize topTenPicksButton;
@synthesize sortButton;
@synthesize popover;
@synthesize ratingButton;
@synthesize recommendationPopover;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [recommendationPopover release], recommendationPopover = nil;
    [ratingButton release], ratingButton = nil;
    [topFavoritesComponent release], topFavoritesComponent = nil;
    [topTenBooks release], topTenBooks = nil;
    [lastTopTenBookRetrieval release], lastTopTenBookRetrieval = nil;
    [popover release], popover = nil;
    [super dealloc];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self setupToolbar];

}

- (void)setupToolbar
{
    SCHThemeButton *homeButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [homeButton setThemeIcon:kSCHThemeManagerHomeIcon iPadQualifier:kSCHThemeManagerPadQualifierSuffix];
    [homeButton sizeToFit];    
    [homeButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];    
    homeButton.accessibilityLabel = @"Back To Bookshelves Button";
    
    if (![[SCHAppStateManager sharedAppStateManager] isSampleStore]) {
        SCHThemeButton *menuButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
        [menuButton setThemeIcon:kSCHThemeManagerMenuIcon iPadQualifier:kSCHThemeManagerPadQualifierSuffix];
        [menuButton sizeToFit];    
        [menuButton addTarget:self action:@selector(menuAction:) forControlEvents:UIControlEventTouchUpInside];    
        menuButton.accessibilityLabel = @"Menu Button";
        
        UIView *rightContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(menuButton.frame) + kSCHBookShelfEdgePadding + 1, CGRectGetHeight(menuButton.frame))];
        
        [rightContainerView addSubview:menuButton];
        
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightContainerView] autorelease];
        [rightContainerView release];
    }
    
    UIImageView *storiaLogoView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"storiatoolbar"]] autorelease];
    
    UIView *leftContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kSCHBookShelfEdgePadding + CGRectGetWidth(homeButton.frame) + kSCHBookShelfEdgePadding + CGRectGetWidth(storiaLogoView.frame) + kSCHBookShelfButtonPadding, CGRectGetHeight(homeButton.frame))];
    
    CGRect homeFrame = homeButton.frame;
    homeFrame.origin.x = kSCHBookShelfEdgePadding;
    homeButton.frame = homeFrame;
    
    CGRect logoFrame = storiaLogoView.frame;
    logoFrame.origin.x = kSCHBookShelfEdgePadding + CGRectGetWidth(homeFrame) + kSCHBookShelfEdgePadding;
    storiaLogoView.frame = logoFrame;
    
    [leftContainerView addSubview:homeButton];
    [leftContainerView addSubview:storiaLogoView];
    
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:leftContainerView] autorelease];
    [leftContainerView release];
    
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (self.sortButton != nil) {
        if (editing) {
            self.sortButton.hidden = YES;
        } else {
            self.sortButton.hidden = NO;
        }
    }    
}

- (void)toggleRatings
{
    [super toggleRatings];
    
    if (self.showingRatings) {
        [self.ratingButton setThemeIcon:kSCHThemeManagerRatingsSelectedIcon iPadQualifier:kSCHThemeManagerPadQualifierSuffix];
    } else {
        [self.ratingButton setThemeIcon:kSCHThemeManagerRatingsIcon iPadQualifier:kSCHThemeManagerPadQualifierSuffix];
    }

}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];

    [self.popover dismissPopoverAnimated:NO];
    self.popover = nil;
}

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self.gridView setShelfImage:[[SCHThemeManager sharedThemeManager] imageForShelf:interfaceOrientation]];   
    
    [self.backgroundView setImage:[[SCHThemeManager sharedThemeManager] imageForBackground:UIInterfaceOrientationPortrait]]; // Note we re-use portrait
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar updateTheme:interfaceOrientation];
    self.listTableView.backgroundColor = [[SCHThemeManager sharedThemeManager] colorForListBackground];
//    self.listToggleView.backgroundColor = [[SCHThemeManager sharedThemeManager] colorForListBackground]; 
    
    // this removes the toggle view from the iPad version - this is now covered by the menu
    if (self.listToggleView.superview) {
        [self.listToggleView removeFromSuperview];
    }

    CGFloat inset = 86;

    if (UIInterfaceOrientationIsLandscape(interfaceOrientation)) {
        [self.gridView setShelfHeight:kSCHBookShelfViewControllerGridCellHeightLandscape_iPad];
        [self.gridView setShelfInset:CGSizeMake(0, -inset)];
    } else {
        [self.gridView setShelfHeight:kSCHBookShelfViewControllerGridCellHeightPortrait_iPad];
        [self.gridView setShelfInset:CGSizeMake(0, -inset)];
    }
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
    
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];    
}

#pragma mark - Grid View Cell Dimensions

- (CGSize)cellSize
{
    return CGSizeMake(236,209);
}

- (CGFloat)cellBorderSize
{
    return 10;
}

#pragma mark - Actions

- (void)menuAction:(SCHThemeButton *)sender
{
    SCHBookShelfMenuController *menuTableController = [[SCHBookShelfMenuController alloc] initWithNibName:@"SCHBookShelfMenuController" 
                                                                                                   bundle:nil 
                                                                                     managedObjectContext:self.managedObjectContext];

    menuTableController.delegate = self;
    menuTableController.userIsAuthenticated = !TOP_TEN_DISABLED && [[SCHAppStateManager sharedAppStateManager] canAuthenticate];
    
    UINavigationController *navCon = [[UINavigationController alloc] initWithRootViewController:menuTableController];
    
    self.popover = [[[SCHBookshelfPopoverController alloc] initWithContentViewController:navCon] autorelease];
    self.popover.delegate = self;

    // iOS 5 and higher: add a custom popover background
    if ([self.popover respondsToSelector:@selector(setPopoverBackgroundViewClass:)]) {
        [self.popover setPopoverBackgroundViewClass:[SCHBookShelfMenuPopoverBackgroundView class]];
    }
    
    [self.popover presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [menuTableController release];
    [navCon release];

}

- (void)updateTheme
{
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }

    [super updateTheme];
}


#pragma mark - Popover Delegate

- (void)popoverControllerDidDismissPopover:(UIPopoverController *)popoverController
{
    self.popover = nil;
}

#pragma mark - Bookshelf Menu Delegate

- (void)bookShelfMenu:(SCHBookShelfMenuController *)controller changedSortType:(SCHBookSortType)newSortType
{
    [super bookShelfMenu:controller changedSortType:newSortType];
    
    [self.popover dismissPopoverAnimated:YES];
    self.popover = nil;
}

- (void)bookShelfMenuSelectedRecommendations:(SCHBookShelfMenuController *)controller
{
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
    
    if ([[SCHVersionDownloadManager sharedVersionManager] isAppVersionOutdated] == YES) {
        [self showAppVersionOutdatedAlert];
    } else {
        [self showRecommendationsListAnimated:YES];
    }
}

- (void)bookShelfMenuSwitchedToGridView:(SCHBookShelfMenuController *)controller
{
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
    
    [super bookShelfMenuSwitchedToGridView:controller];
}

- (void)bookShelfMenuSwitchedToListView:(SCHBookShelfMenuController *)controller
{
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
    
    [super bookShelfMenuSwitchedToListView:controller];
}

- (void)bookShelfMenuCancelled:(SCHBookShelfMenuController *)controller
{
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
}


#pragma mark - Recommendations and Wish List

- (void)switchToWishListFromRecommendationListController:(SCHBookShelfRecommendationListController *)recommendationController
{
    [self showWishListAnimated:NO];
}

- (void)switchToRecommendationsFromWishListController:(SCHBookShelfWishListController *)wishListController
{
    [self showRecommendationsListAnimated:NO];
}

- (void)showRecommendationsListAnimated:(BOOL)animated
{
    // FIXME: "sticky plaster" preventing animation while switching
    if (!animated) {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    }
    
    if (self.recommendationPopover) {
        [self.recommendationPopover dismissSheetAnimated:NO completion:^{}];
    }

    SCHBookShelfRecommendationListController *recommendationController = 
    [[SCHBookShelfRecommendationListController alloc] initWithNibName:@"SCHBookShelfRecommendationListController" bundle:nil];
    recommendationController.appProfile = self.profileItem.AppProfile;
    recommendationController.delegate = self;
    recommendationController.shouldShowWishList = [[SCHAppStateManager sharedAppStateManager] shouldShowWishList];
        
    self.recommendationPopover = [[[BITModalSheetController alloc] initWithContentViewController:recommendationController] autorelease];
    [self.recommendationPopover setContentSize:CGSizeMake(640, 654)];
    [self.recommendationPopover setContentOffset:CGPointMake(0, 0)];
    
    __block BITModalSheetController *weakPopoverController = self.recommendationPopover;
    __block SCHBookShelfViewController_iPad *weakSelf = self;
    
    recommendationController.closeBlock = ^{
        [weakPopoverController dismissSheetAnimated:YES completion:nil];
        weakSelf.recommendationPopover = nil;
    };
    
    [self.recommendationPopover presentSheetInViewController:self animated:animated completion:nil];
    
    [recommendationController release];

    if (!animated) {
        [CATransaction commit];
    }
}

- (void)showWishListAnimated:(BOOL)animated
{
    // FIXME: "sticky plaster" preventing animation while switching
    if (!animated) {
        [CATransaction begin];
        [CATransaction setValue:(id)kCFBooleanTrue forKey:kCATransactionDisableActions];
    }
    
    if (self.recommendationPopover) {
        [self.recommendationPopover dismissSheetAnimated:NO completion:^{}];
    }
    
    SCHBookShelfWishListController *wishListController = 
    [[SCHBookShelfWishListController alloc] initWithNibName:@"SCHBookShelfWishListController" bundle:nil];
    wishListController.appProfile = self.profileItem.AppProfile;
    wishListController.delegate = self;
    
    self.recommendationPopover = [[[BITModalSheetController alloc] initWithContentViewController:wishListController] autorelease];
    [self.recommendationPopover setContentSize:CGSizeMake(640, 654)];
    [self.recommendationPopover setContentOffset:CGPointMake(0, 0)];
    
    __block BITModalSheetController *weakPopoverController = self.recommendationPopover;
    __block SCHBookShelfViewController_iPad *weakSelf = self;
    
    wishListController.closeBlock = ^{
        [weakPopoverController dismissSheetAnimated:YES completion:nil];
        weakSelf.recommendationPopover = nil;
    };
    
    [self.recommendationPopover presentSheetInViewController:self animated:animated completion:nil];

    [wishListController release];
    
    if (!animated) {
        [CATransaction commit];
    }
}

- (void)authenticationDidSucceed
{
    // Re-call top favorites for age now we have authenticated
    [self.topFavoritesComponent topFavoritesForAge:self.profileItem.age];
}

- (void)showAppVersionOutdatedAlert
{
    LambdaAlert *alert = [[LambdaAlert alloc]
                          initWithTitle:NSLocalizedString(@"Update Required", @"")
                          message:NSLocalizedString(@"This function requires that you update Storia. Please visit the App Store to update your app.", @"")];
    [alert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:nil];
    [alert show];
    [alert release];         
}

@end