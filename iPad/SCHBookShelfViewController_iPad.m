//
//  SCHBookShelfViewController_iPad.m
//  Scholastic
//
//  Created by Gordon Christie on 16/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookShelfViewController_iPad.h"
#import <QuartzCore/QuartzCore.h>
#import "SCHBookShelfGridView.h"
#import "SCHCustomNavigationBar.h"
#import "SCHThemeManager.h"
#import "SCHProfileViewController_iPad.h"
#import "SCHBookManager.h"
#import "SCHThemeButton.h"
#import "SCHBookShelfSortPopoverTableView.h"
#import "SCHBookShelfTopTenPopoverTableView.h"
#import "SCHTopFavoritesComponent.h"
#import "SCHProfileItem.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHAppProfile.h"

static NSInteger const kSCHBookShelfViewControllerGridCellHeightPortrait_iPad = 254;
static NSInteger const kSCHBookShelfViewControllerGridCellHeightLandscape_iPad = 266;
static NSInteger const kSCHBookShelfButtonPadding = 25;
static NSInteger const kSCHBookShelfEdgePadding = 12;
static NSTimeInterval const kSCHBookShelfViewControllerTopTenRefreshTime = -600.0;

@interface SCHBookShelfViewController_iPad ()

@property (nonatomic, retain) SCHTopFavoritesComponent *topFavoritesComponent;
@property (nonatomic, retain) NSArray *topTenBooks;
@property (nonatomic, retain) NSDate *lastTopTenBookRetrieval;

@property (nonatomic, retain) SCHThemeButton *topTenPicksButton;
@property (nonatomic, retain) SCHThemeButton *sortButton;

@property (nonatomic, retain) UIPopoverController *popover;

- (void)updateTheme;
- (void)setupToolbar;

@end

@implementation SCHBookShelfViewController_iPad

@synthesize profileViewController;
@synthesize topFavoritesComponent;
@synthesize topTenBooks;
@synthesize lastTopTenBookRetrieval;
@synthesize topTenPicksButton;
@synthesize sortButton;
@synthesize popover;

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    
    [topFavoritesComponent release], topFavoritesComponent = nil;
    [topTenBooks release], topTenBooks = nil;
    [lastTopTenBookRetrieval release], lastTopTenBookRetrieval = nil;
    [popover release], popover = nil;
    [profileViewController release], profileViewController = nil;
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
    [themeButton setThemeIcon:kSCHThemeManagerThemeIcon iPadSpecific:YES];
    [themeButton sizeToFit];    
    [themeButton addTarget:self action:@selector(themeAction:) forControlEvents:UIControlEventTouchUpInside];
    
    SCHThemeButton *homeButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [homeButton setThemeIcon:kSCHThemeManagerHomeIcon iPadSpecific:YES];
    [homeButton sizeToFit];    
    [homeButton addTarget:self action:@selector(back) forControlEvents:UIControlEventTouchUpInside];    
    
    self.topTenPicksButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [self.topTenPicksButton setFrame:CGRectMake(0, 0, 120, 30)];
    [self.topTenPicksButton setTitle:NSLocalizedString(@"Top 10 Picks", @"") forState:UIControlStateNormal];
    [self.topTenPicksButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.topTenPicksButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5f] forState:UIControlStateHighlighted];
    [self.topTenPicksButton setReversesTitleShadowWhenHighlighted:YES];
    
    self.topTenPicksButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.topTenPicksButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    [self.topTenPicksButton setThemeButton:kSCHThemeManagerButtonImage leftCapWidth:5 topCapHeight:0];
    [self.topTenPicksButton addTarget:self action:@selector(topTenAction:) forControlEvents:UIControlEventTouchUpInside];    
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.topTenPicksButton.frame) + kSCHBookShelfButtonPadding + CGRectGetWidth(themeButton.frame) + kSCHBookShelfEdgePadding, CGRectGetHeight(themeButton.frame))];
    [containerView addSubview:self.topTenPicksButton];
    
    CGRect themeFrame = themeButton.frame;
    themeFrame.origin.x = kSCHBookShelfButtonPadding + CGRectGetWidth(self.topTenPicksButton.frame);
    themeButton.frame = themeFrame;
    
    [containerView addSubview:themeButton];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:containerView];
    [containerView release];
    
    if ([self.profileItem.BookshelfStyle intValue] == kSCHBookshelfStyleYoungChild) {
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(homeButton.frame) + kSCHBookShelfEdgePadding, CGRectGetHeight(homeButton.frame))];
        
        CGRect frame = homeButton.frame;
        frame.origin.x = kSCHBookShelfEdgePadding;
        homeButton.frame = frame;
        
        [containerView addSubview:homeButton];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:containerView];
        [containerView release];
    } else {
        self.sortButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
        [self.sortButton setFrame:CGRectMake(0, 0, 120, 30)];
        [self.sortButton setTitle:NSLocalizedString(@"Sort", @"") forState:UIControlStateNormal];
        [self.sortButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.sortButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5f] forState:UIControlStateHighlighted];
        [self.sortButton setReversesTitleShadowWhenHighlighted:YES];
        
        self.sortButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.sortButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        
        [self.sortButton setThemeButton:kSCHThemeManagerButtonImage leftCapWidth:5 topCapHeight:0];
        [self.sortButton addTarget:self action:@selector(sortAction:) forControlEvents:UIControlEventTouchUpInside];   
        
        containerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(homeButton.frame) + kSCHBookShelfButtonPadding + CGRectGetWidth(self.sortButton.frame) + kSCHBookShelfButtonPadding, CGRectGetHeight(homeButton.frame))];
        
        [containerView addSubview:self.sortButton];
        
        CGRect sortFrame = self.sortButton.frame;
        sortFrame.origin.x = kSCHBookShelfEdgePadding + CGRectGetWidth(homeButton.frame) + kSCHBookShelfButtonPadding;
        self.sortButton.frame = sortFrame;
        
        sortFrame = homeButton.frame;
        sortFrame.origin.x = kSCHBookShelfEdgePadding;
        homeButton.frame = sortFrame;
        
        [containerView addSubview:homeButton];
        
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:containerView];
        [containerView release];
        
    }
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    [super setEditing:editing animated:animated];
    
    if (editing) {
        self.sortButton.hidden = YES;
    } else {
        self.sortButton.hidden = NO;
    }
    
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    [self.gridView setShelfImage:[[SCHThemeManager sharedThemeManager] imageForShelf:interfaceOrientation]];        
    [self.view.layer setContents:(id)[[SCHThemeManager sharedThemeManager] imageForBackground:interfaceOrientation].CGImage];
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar updateTheme:interfaceOrientation];
    
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
    
    [self setupAssetsForOrientation:toInterfaceOrientation];
}

#pragma mark - Grid View Cell Dimensions

- (CGSize)cellSize
{
    return CGSizeMake(147,218);
}

- (CGFloat)cellBorderSize
{
    return 36;
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

    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverTable];
    self.popover.delegate = self;
    
    CGRect senderFrame = sender.superview.frame;
    senderFrame.origin.y -= 44;
    senderFrame.origin.x += 28;

    
    NSLog(@"Sender frame: %@", NSStringFromCGRect(senderFrame));
    
    [self.popover presentPopoverFromRect:senderFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [popoverTable release];

    NSLog(@"Sort!");
}

- (void)topTenAction:(SCHThemeButton *)sender
{
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
 
    if (self.topFavoritesComponent == nil) {
        self.topTenBooks = nil;
        
        self.topFavoritesComponent = [[SCHTopFavoritesComponent alloc] init];
        [self.topFavoritesComponent release];
        self.topFavoritesComponent.delegate = self;
    }

    if (self.lastTopTenBookRetrieval == nil || 
        [self.lastTopTenBookRetrieval timeIntervalSinceNow] <= kSCHBookShelfViewControllerTopTenRefreshTime || 
        [self.topTenBooks count] < 1) {
        if ([self.topFavoritesComponent topFavoritesForAge:self.profileItem.age] == NO) {
            // if we need to authenticate then try again once we are
            [[NSNotificationCenter defaultCenter] addObserver:self 
                                                     selector:@selector(authenticationManager:) 
                                                         name:kSCHAuthenticationManagerSuccess 
                                                       object:nil];					            
        }
    }
    
    SCHBookShelfTopTenPopoverTableView *popoverTable = [[SCHBookShelfTopTenPopoverTableView alloc] initWithNibName:nil bundle:nil];
    popoverTable.books = self.topTenBooks;
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:popoverTable];
    self.popover.delegate = self;
    
    CGRect senderFrame = sender.superview.frame;
    senderFrame.origin.y -= 44;
    senderFrame.origin.x -= 28;

    
    NSLog(@"Sender frame: %@", NSStringFromCGRect(senderFrame));
    
    [self.popover presentPopoverFromRect:senderFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    [popoverTable release];
    NSLog(@"Top ten!");
}

- (void)themeAction:(SCHThemeButton *)sender
{
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
    
    self.popover = [[UIPopoverController alloc] initWithContentViewController:self.themePickerContainer];
    self.popover.delegate = self;
    
    CGRect senderFrame = sender.superview.frame;
    senderFrame.origin.y -= 44;
    senderFrame.origin.x += 58;
    
    
    NSLog(@"Sender frame: %@", NSStringFromCGRect(senderFrame));
    
    [self.popover presentPopoverFromRect:senderFrame inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    NSLog(@"Theme change!");
}

- (void)updateTheme
{
    if (self.popover) {
        [self.popover dismissPopoverAnimated:YES];
        self.popover = nil;
    }
    [self setupAssetsForOrientation:self.interfaceOrientation];
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

    self.books = [self.profileItem allISBNs];
	self.loadingView.hidden = YES;

    [self.popover dismissPopoverAnimated:YES];
}

#pragma mark - Authentication Manager Delegate

- (void)authenticationManager:(NSNotification *)notification
{
	NSDictionary *userInfo = [notification userInfo];
	
	if ([[userInfo valueForKey:kSCHAuthenticationManagerOfflineMode] boolValue] == NO) {
        if ([self.topFavoritesComponent topFavoritesForAge:self.profileItem.age] == YES) {
            [[NSNotificationCenter defaultCenter] removeObserver:self];
        }
	}
}

#pragma mark - SCHComponent Delegate

- (void)component:(SCHComponent *)component didCompleteWithResult:(NSDictionary *)result
{
	NSMutableArray *topBooks = [result objectForKey:kSCHLibreAccessWebServiceContentMetadataList];

    NSLog(@"%@", topBooks);
    
    if (topBooks != (id)[NSNull null] && [topBooks count] > 0) {
        self.lastTopTenBookRetrieval = [NSDate date];
        
        self.topTenBooks = topBooks;
        
        if (self.popover != nil && [self.popover.contentViewController isKindOfClass:[SCHBookShelfTopTenPopoverTableView class]] == YES) {
            ((SCHBookShelfTopTenPopoverTableView *)self.popover.contentViewController).books = self.topTenBooks;
        }
    }
}

- (void)component:(SCHComponent *)component didFailWithError:(NSError *)error
{
    
}

@end