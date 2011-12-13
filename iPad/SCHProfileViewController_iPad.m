//
//  SCHProfileViewController_iPad.m
//  Scholastic
//
//  Created by Gordon Christie on 13/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewController_iPad.h"
#import "SCHBookshelfViewController_iPad.h"
#import "SCHBookshelfViewController.h"
#import "SCHProfileItem.h"
#import "SCHThemeManager.h"
#import "SCHCustomNavigationBar.h"

static const CGFloat kProfilePadTableOffsetPortrait = 280.0f;
static const CGFloat kProfilePadTableOffsetLandscape = 220.0f;

#pragma mark - Class Extension

@interface SCHProfileViewController_iPad () 

- (void)releaseViewObjects;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;

@property (nonatomic, retain) UIButton *settingsButton;

@end

@implementation SCHProfileViewController_iPad

@synthesize bookshelfViewController;
@synthesize containerView;
@synthesize settingsButton;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [super releaseViewObjects];
    [bookshelfViewController release], bookshelfViewController = nil;
    [containerView release], containerView = nil;
    [settingsButton release], settingsButton = nil;
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
	
    self.title = @"";
    
    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = logoImageView;
    [logoImageView release];
        
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingsButton addTarget:self action:@selector(pushSettingsController) 
             forControlEvents:UIControlEventTouchUpInside]; 
    [self.settingsButton setImage:[UIImage imageNamed:@"settings-portrait.png"] 
                         forState:UIControlStateNormal];
    [self.settingsButton sizeToFit];
    self.settingsButton.accessibilityLabel = @"Settings Button";
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.settingsButton] autorelease];
    
    self.tableView.tableHeaderView = self.headerView;
    [self.containerView addSubview:self.tableView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

#pragma mark - Orientation methods

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-landscape.jpg"]];
        [self.tableView setContentInset:UIEdgeInsetsMake(kProfilePadTableOffsetLandscape, 0, 0, 0)];
    } else {
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.jpg"]];
        [self.tableView setContentInset:UIEdgeInsetsMake(kProfilePadTableOffsetPortrait, 0, 0, 0)];
    }
    
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];

}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation
{
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
}    

#pragma mark - Bookshelf view controller

- (SCHBookShelfViewController *)newBookShelfViewController
{
    return [[SCHBookShelfViewController_iPad alloc] initWithNibName:NSStringFromClass([SCHBookShelfViewController class]) bundle:nil];
}


@end
