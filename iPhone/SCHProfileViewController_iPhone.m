 //
//  SCHProfileViewController_iPhone.m
//  Scholastic
//
//  Created by Gordon Christie on 13/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHProfileViewController_iPhone.h"
#import "SCHLoginPasswordViewController.h"
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

static const CGFloat kSCHProfileViewControllerPhoneLogoWidthPortrait = 260;
static const CGFloat kSCHProfileViewControllerPhoneLogoWidthLandscape = 200;
static const CGFloat kSCHProfileViewControllerPhoneLogoHeightPortrait = 44;
static const CGFloat kSCHProfileViewControllerPhoneLogoHeightLandscape = 32;

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

#pragma mark - View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    
    self.settingsButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.settingsButton addTarget:self action:@selector(pushSettingsController) 
                  forControlEvents:UIControlEventTouchUpInside]; 
        
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:self.settingsButton] autorelease];
    
    UIImageView *logoImageView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo.png"]] autorelease];
    logoImageView.contentMode = UIViewContentModeScaleAspectFit;
    self.navigationItem.titleView = logoImageView;
    
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
    CGRect currentTitleBounds = self.navigationItem.titleView.bounds;
    CGRect newTitleBounds;
    
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
     [UIImage imageNamed:@"red-toolbar.png"]];
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self.backgroundView setImage:[UIImage imageNamed:@"cloud-background-landscape.jpg"]];
        [self.settingsButton setImage:[UIImage imageNamed:@"settings-landscape.png"] 
                             forState:UIControlStateNormal];
        [self.settingsButton sizeToFit];
        
        newTitleBounds = CGRectMake(0, 0, kSCHProfileViewControllerPhoneLogoWidthLandscape, kSCHProfileViewControllerPhoneLogoHeightLandscape);
    } else {
        [self.backgroundView setImage:[UIImage imageNamed:@"cloud-background-portrait.jpg"]];
        [self.settingsButton setImage:[UIImage imageNamed:@"settings-portrait.png"] 
                             forState:UIControlStateNormal];
        [self.settingsButton sizeToFit];
        newTitleBounds = CGRectMake(0, 0, kSCHProfileViewControllerPhoneLogoWidthPortrait, kSCHProfileViewControllerPhoneLogoHeightPortrait);
    }
    
    if (!CGRectEqualToRect(newTitleBounds, currentTitleBounds)) {
        [self.navigationItem.titleView setBounds:newTitleBounds];
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
