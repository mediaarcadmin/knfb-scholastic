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
#import "SCHBookShelfSortPopoverTableView.h"
#import "SCHBookShelfTopTenPopoverTableView.h"
#import "SCHTopFavoritesComponent.h"
#import "SCHProfileItem.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHAppProfile.h"
#import "SCHAppStateManager.h"
#import "LambdaAlert.h"
#import "SCHVersionDownloadManager.h"
#import "SCHLibreAccessConstants.h"
#import "SCHBookShelfRecommendationListController.h"

//static NSInteger const kSCHBookShelfViewControllerGridCellHeightPortrait_iPad = 254;
static NSInteger const kSCHBookShelfViewControllerGridCellHeightPortrait_iPad = 224;
static NSInteger const kSCHBookShelfViewControllerGridCellHeightLandscape_iPad = 225;
static NSInteger const kSCHBookShelfButtonPadding = 25;
static NSInteger const kSCHBookShelfEdgePadding = 12;
static NSTimeInterval const kSCHBookShelfViewControllerTopTenRefreshTime = -600.0;

@interface SCHBookShelfViewController_iPad ()

@property (nonatomic, retain) SCHTopFavoritesComponent *topFavoritesComponent;
@property (nonatomic, retain) NSArray *topTenBooks;
@property (nonatomic, retain) NSDate *lastTopTenBookRetrieval;

@property (nonatomic, retain) SCHThemeButton *topTenPicksButton;
@property (nonatomic, retain) SCHThemeButton *sortButton;
@property (nonatomic, retain) SCHThemeButton *ratingButton;

@property (nonatomic, retain) UIPopoverController *popover;

- (void)updateTheme;
- (void)setupToolbar;
- (void)updateTopTenWithBooks:(NSArray *)topBooks;
- (void)showAppVersionOutdatedAlert;

@end

@implementation SCHBookShelfViewController_iPad

@synthesize topFavoritesComponent;
@synthesize topTenBooks;
@synthesize lastTopTenBookRetrieval;
@synthesize topTenPicksButton;
@synthesize sortButton;
@synthesize popover;
@synthesize ratingButton;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
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
    SCHThemeButton *themeButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [themeButton setThemeIcon:kSCHThemeManagerThemeIcon iPadQualifier:kSCHThemeManagerPadQualifierSuffix];
    [themeButton sizeToFit];    
    [themeButton addTarget:self action:@selector(themeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    SCHThemeButton *homeButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [homeButton setThemeIcon:kSCHThemeManagerHomeIcon iPadQualifier:kSCHThemeManagerPadQualifierSuffix];
    [homeButton sizeToFit];    
    [homeButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];    
    homeButton.accessibilityLabel = @"Back To Bookshelves Button";
    
    CGRect sortFrame = CGRectZero;
    CGRect topTenFrame = CGRectZero;

    self.ratingButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [self.ratingButton setThemeIcon:kSCHThemeManagerRatingsIcon iPadQualifier:kSCHThemeManagerPadQualifierSuffix];
    [self.ratingButton sizeToFit];    
    [self.ratingButton addTarget:self action:@selector(toggleRatings) forControlEvents:UIControlEventTouchUpInside];    
    self.ratingButton.accessibilityLabel = @"Rating Button";

    // no sort or top ten buttons for the sample bookshelf
    if ([[SCHAppStateManager sharedAppStateManager] isSampleStore] == NO) {
        self.sortButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
        sortFrame = CGRectMake(0, 3, 82, 30);
        [self.sortButton setFrame:sortFrame];
        [self.sortButton setTitle:NSLocalizedString(@"Sort", @"") forState:UIControlStateNormal];
        [self.sortButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.sortButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5f] forState:UIControlStateHighlighted];
        [self.sortButton setReversesTitleShadowWhenHighlighted:YES];
        
        self.sortButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.sortButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        
        [self.sortButton setThemeButton:kSCHThemeManagerButtonImage leftCapWidth:7 topCapHeight:0];
        [self.sortButton addTarget:self action:@selector(sortAction:) forControlEvents:UIControlEventTouchUpInside];   
        
        CGRect sortFrame = self.sortButton.frame;
        sortFrame.origin.x = kSCHBookShelfEdgePadding;
        self.sortButton.frame = sortFrame;
        
        if (!TOP_TEN_DISABLED && ([[SCHAppStateManager sharedAppStateManager] canAuthenticate] == YES)) {
            topTenFrame = CGRectMake(kSCHBookShelfButtonPadding + CGRectGetWidth(sortFrame), 3, 120, 30);
            self.topTenPicksButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
            [self.topTenPicksButton setFrame:topTenFrame];
            [self.topTenPicksButton setTitle:NSLocalizedString(@"More eBooks", @"") forState:UIControlStateNormal];
            [self.topTenPicksButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.topTenPicksButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5f] forState:UIControlStateHighlighted];
            [self.topTenPicksButton setReversesTitleShadowWhenHighlighted:YES];
            
            self.topTenPicksButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
            self.topTenPicksButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
            
            [self.topTenPicksButton setThemeButton:kSCHThemeManagerButtonImage leftCapWidth:7 topCapHeight:0];
            [self.topTenPicksButton addTarget:self action:@selector(topTenAction:) forControlEvents:UIControlEventTouchUpInside];    
        }
    }
    
    // right toolbar items code
    // order: Sort, Ratings, More eBooks (top 10), Themes

    CGFloat topTenWidth = topTenFrame.size.width;
    
    if (topTenWidth > 0) {
        topTenWidth += kSCHBookShelfEdgePadding;
    }

    UIView *rightContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(sortFrame) + kSCHBookShelfButtonPadding + topTenWidth + CGRectGetWidth(themeButton.frame) + kSCHBookShelfButtonPadding + CGRectGetWidth(themeButton.frame) + kSCHBookShelfEdgePadding, CGRectGetHeight(themeButton.frame))];

    if (self.sortButton) {
        [rightContainerView addSubview:self.sortButton];
    }
    if (self.topTenPicksButton) {
        [rightContainerView addSubview:self.topTenPicksButton];
    }
    if (self.ratingButton) {
        [rightContainerView addSubview:self.ratingButton];
    }
    
    CGRect themeFrame = themeButton.frame;
    themeFrame.origin.x = topTenWidth + kSCHBookShelfButtonPadding + CGRectGetWidth(sortFrame) + kSCHBookShelfButtonPadding + CGRectGetWidth(self.ratingButton.frame);
    themeButton.frame = themeFrame;

    CGRect ratingFrame = self.ratingButton.frame;
    ratingFrame.origin.x = topTenWidth + kSCHBookShelfButtonPadding + CGRectGetWidth(sortFrame);
    self.ratingButton.frame = ratingFrame;

    [rightContainerView addSubview:themeButton];

    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:rightContainerView] autorelease];
    [rightContainerView release];
    
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
    self.listToggleView.backgroundColor = [[SCHThemeManager sharedThemeManager] colorForListBackground]; 

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

#pragma mark - Sort and Top Ten actions

- (void)sortAction:(SCHThemeButton *)sender
{
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
    
    SCHBookShelfSortPopoverTableView *popoverTable = [[SCHBookShelfSortPopoverTableView alloc] initWithNibName:nil bundle:nil];
    popoverTable.sortType = self.sortType;
    popoverTable.delegate = self;
    
    self.popover = [[[UIPopoverController alloc] initWithContentViewController:popoverTable] autorelease];
    self.popover.delegate = self;
    
    [self.popover presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [popoverTable release];
}

- (void)topTenAction:(SCHThemeButton *)sender
{
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
    
    if ([[SCHVersionDownloadManager sharedVersionManager] isAppVersionOutdated] == YES) {
        [self showAppVersionOutdatedAlert];
    } else {
//        if (self.topFavoritesComponent == nil) {
//            self.topTenBooks = nil;
//            
//            self.topFavoritesComponent = [[[SCHTopFavoritesComponent alloc] init] autorelease];
//            self.topFavoritesComponent.delegate = self;
//        }
//        
//        if (self.lastTopTenBookRetrieval == nil || 
//            [self.lastTopTenBookRetrieval timeIntervalSinceNow] <= kSCHBookShelfViewControllerTopTenRefreshTime || 
//            [self.topTenBooks count] < 1) {
//            
//            [self.topFavoritesComponent topFavoritesForAge:self.profileItem.age];
//            
//        }
//        
//        SCHBookShelfTopTenPopoverTableView *popoverTable = [[SCHBookShelfTopTenPopoverTableView alloc] initWithNibName:nil bundle:nil];
//        popoverTable.books = self.topTenBooks;
        
        SCHBookShelfRecommendationListController *recommendationController = 
        [[SCHBookShelfRecommendationListController alloc] initWithNibName:@"SCHBookShelfRecommendationListController" bundle:nil];
        recommendationController.appProfile = self.profileItem.AppProfile;
        
        self.popover = [[[UIPopoverController alloc] initWithContentViewController:recommendationController] autorelease];
        self.popover.delegate = self;
        
        [self.popover presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
        [recommendationController release];
    }
}

- (void)themeAction:(SCHThemeButton *)sender
{
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
    
    self.popover = [[[UIPopoverController alloc] initWithContentViewController:self.themePickerContainer] autorelease];
    self.popover.delegate = self;
    
    [self.popover presentPopoverFromRect:sender.frame inView:sender.superview permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
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

#pragma mark - Sort Popover Delegate

- (void)sortPopoverPickedSortType: (SCHBookSortType) newType
{
    self.sortType = newType;
    [[self.profileItem AppProfile] setSortType:[NSNumber numberWithInt:newType]];

    self.books = [self.profileItem allBookIdentifiers];
    [self dismissLoadingView];

    [self.popover dismissPopoverAnimated:YES];
    self.popover = nil;
}

#pragma mark - SCHComponent Delegate

- (void)updateTopTenWithBooks:(NSArray *)topBooks
{    
    if (topBooks) {
        self.topTenBooks = topBooks;
    } else {
        self.topTenBooks = [NSArray array];
    }
    
    if (self.popover != nil) {
        id bookShelfTopTenPopoverTableView = self.popover.contentViewController;
        if ([bookShelfTopTenPopoverTableView isKindOfClass:[SCHBookShelfTopTenPopoverTableView class]] == YES) {
            ((SCHBookShelfTopTenPopoverTableView *)bookShelfTopTenPopoverTableView).books = self.topTenBooks;
        }
    }
}

- (void)component:(SCHComponent *)component didCompleteWithResult:(NSDictionary *)result
{
	NSMutableArray *topBooks = [result objectForKey:kSCHLibreAccessWebServiceContentMetadataList];

    NSLog(@"%@", topBooks);
    
    if (topBooks != (id)[NSNull null] && [topBooks count] > 0) {
        self.lastTopTenBookRetrieval = [NSDate date];
        [self updateTopTenWithBooks:topBooks];
    } else {
        [self updateTopTenWithBooks:nil];
    }
}

- (void)component:(SCHComponent *)component didFailWithError:(NSError *)error
{
    [self updateTopTenWithBooks:nil];
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