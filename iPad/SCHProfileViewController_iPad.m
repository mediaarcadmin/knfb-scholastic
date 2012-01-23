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

static const CGFloat kProfilePadTableOffsetPortrait = 80.0f;
static const CGFloat kProfilePadTableOffsetLandscape = 56.0f;

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

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
	NSInteger ret = 0;
	id <NSFetchedResultsSectionInfo> sectionInfo = nil;
	
	switch (section) {
		case 0:
			sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
            NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
			ret = (numberOfObjects > 0 ? numberOfObjects / 2 : numberOfObjects);
            // if we have an odd number of profiles add an extra row
            if (numberOfObjects % 2 > 0) {
                ret++;
            }
			break;
	}
	
	return(ret);
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{    
    static NSString *CellIdentifier = @"Cell";
    NSString *leftTitle = nil;
    NSIndexPath *leftIndexPath = nil;
    NSString *rightTitle = nil;
    NSIndexPath *rightIndexPath = nil;
    SCHProfileItem *profileItem = nil;
    
    SCHProfileViewCell *cell = (SCHProfileViewCell*)[aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[SCHProfileViewCell alloc] initWithStyle:UITableViewCellStyleDefault 
                                          reuseIdentifier:CellIdentifier] autorelease];
        cell.delegate = self;
    }
    
    leftIndexPath = [NSIndexPath indexPathForRow:(indexPath.row == 0 ? 0 : indexPath.row * 2)
                                       inSection:indexPath.section];
    profileItem = [self.fetchedResultsController objectAtIndexPath:leftIndexPath]; 
    leftTitle = [profileItem bookshelfName:NO];
    
    if (leftIndexPath.row + 1 < [[[self.fetchedResultsController sections] objectAtIndex:indexPath.section] numberOfObjects]) {
        rightIndexPath = [NSIndexPath indexPathForRow:leftIndexPath.row + 1 inSection:indexPath.section];
        profileItem = [self.fetchedResultsController objectAtIndexPath:rightIndexPath]; 
        rightTitle = [profileItem bookshelfName:NO];
    }
    
	[cell setLeftButtonTitle:leftTitle
               leftIndexPath:leftIndexPath
            rightButtonTitle:rightTitle
              rightIndexPath:rightIndexPath];
    
    return(cell);
}

#pragma mark - Orientation methods

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    CGRect headerFrame = self.tableView.tableHeaderView.frame;
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-landscape.jpg"]];
        headerFrame.size.height = 354;
        [self.tableView setContentInset:UIEdgeInsetsMake(kProfilePadTableOffsetLandscape, 0, 0, 0)];
    } else {
        [self.backgroundView setImage:[UIImage imageNamed:@"plain-background-portrait.jpg"]];
        headerFrame.size.height = 378;
        [self.tableView setContentInset:UIEdgeInsetsMake(kProfilePadTableOffsetPortrait, 0, 0, 0)];
    }
    
    self.tableView.tableHeaderView.frame = headerFrame;
    
    // yuck - need to re-set the header view in order to get the table to recognise the size change
    self.tableView.tableHeaderView = self.tableView.tableHeaderView;
    
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
