 //
//  SCHProfileViewController_iPhone.m
//  Scholastic
//
//  Created by Gordon Christie on 13/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewController_iPhone.h"
#import "SCHLoginPasswordViewController.h"
#import "SCHSetupBookshelvesViewController.h"
#import "SCHAuthenticationManager.h"
#import "SCHBookShelfViewController.h"
#import "SCHSettingsViewController.h"
#import "SCHCustomNavigationBar.h"
#import "SCHURLManager.h"
#import "SCHSyncManager.h"
#import "SCHThemeManager.h"
#import "SCHProfileItem.h"
#import "SCHAppProfile.h"
#import "SCHReadingViewController.h"
#import "SCHBookIdentifier.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

static const CGFloat kProfilePhoneTableOffsetPortrait = 70.0f;
static const CGFloat kProfilePhoneTableOffsetLandscape = 20.0f;

@interface SCHProfileViewController_iPhone() <UITableViewDelegate> 

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)releaseViewObjects;

@property (nonatomic, retain) UIButton *settingsButton;
@property (nonatomic, retain) UIBarButtonItem *barSpacer;
@property (nonatomic, retain) UIView *logoContainer;

@end


@implementation SCHProfileViewController_iPhone

@synthesize settingsButton;
@synthesize barSpacer;
@synthesize logoContainer;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [super releaseViewObjects];
    [settingsButton release], settingsButton = nil;
    [barSpacer release], barSpacer = nil;
    [logoContainer release], logoContainer = nil;
}

- (void)dealloc 
{    
    [self releaseViewObjects];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingsButton addTarget:self action:@selector(pushSettingsController) 
                  forControlEvents:UIControlEventTouchUpInside]; 
    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.settingsButton] autorelease];
    
    UIImageView *logoImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]] autorelease];
    logoImageView.frame = CGRectZero;
    logoImageView.autoresizingMask = (UIViewAutoresizingFlexibleWidth
                                      | UIViewAutoresizingFlexibleLeftMargin
                                      | UIViewAutoresizingFlexibleRightMargin
                                      | UIViewAutoresizingFlexibleHeight
                                      | UIViewAutoresizingFlexibleBottomMargin
                                      | UIViewAutoresizingFlexibleTopMargin);
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    UIView *container = [[[UIView alloc] initWithFrame:CGRectZero] autorelease];
    [container addSubview:logoImageView];    
    self.logoContainer = container;
    self.navigationItem.titleView = container;
    
    UIBarButtonItem *item = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil] autorelease];
    self.barSpacer = item;
    
    // FIXME: When we are compiling against iOS 5 this should be cleaned up 
    if ([self.navigationItem respondsToSelector:@selector(setLeftBarButtonItems:)]) {
        [self.navigationItem performSelector:@selector(setLeftBarButtonItems:) withObject:[NSArray arrayWithObject:self.barSpacer]];
    } else {
        self.navigationItem.leftBarButtonItem = self.barSpacer;
    }
    
    self.tableView.tableHeaderView = self.headerView;
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
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
         [UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-landscape.jpg"]];
        [self.settingsButton setImage:[UIImage imageNamed:@"settings-landscape.png"] 
                             forState:UIControlStateNormal];
        [self.settingsButton sizeToFit];
        self.settingsButton.accessibilityLabel = @"Settings Button";
        [self.barSpacer setWidth:CGRectGetWidth(self.settingsButton.frame) + 7];
        [self.tableView setContentInset:UIEdgeInsetsMake(kProfilePhoneTableOffsetLandscape, 0, 0, 0)];
        [self.logoContainer setFrame:CGRectMake(0, 0, 260, 32)];
    } else {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
         [UIImage imageNamed:@"admin-iphone-portrait-top-toolbar.png"]];
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.jpg"]];
        [self.settingsButton setImage:[UIImage imageNamed:@"settings-portrait.png"] 
                             forState:UIControlStateNormal];
        [self.settingsButton sizeToFit];
        [self.barSpacer setWidth:0];
        [self.tableView setContentInset:UIEdgeInsetsMake(kProfilePhoneTableOffsetPortrait, 0, 0, 0)];
        [self.logoContainer setFrame:CGRectMake(0, 0, 260, 44)];
    }
    
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (YES);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
}

#pragma mark - Bookshelves view controllers

- (SCHBookShelfViewController *)newBookShelfViewController
{
    return [[SCHBookShelfViewController alloc] initWithNibName:NSStringFromClass([SCHBookShelfViewController class]) bundle:nil];
}

@end
