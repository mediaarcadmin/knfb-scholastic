//
//  SCHStartingViewController.m
//  Scholastic
//
//  Created by Neil Gall on 29/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStartingViewController.h"
#import "SCHLoginPasswordViewController.h"
#import "SCHProfileViewController_iPad.h"
#import "SCHProfileViewController_iPhone.h"
#import "SCHStartingViewCell.h"
#import "SCHCustomNavigationBar.h"
#import "SCHAuthenticationManager.h"
#import "SCHSyncManager.h"
#import "SCHURLManager.h"
#import "LambdaAlert.h"
#import "AppDelegate_Shared.h"

enum {
    kTableSectionSamples = 0,
    kTableSectionSignIn,
    kNumberOfTableSections,
};

enum {
    kNumberOfSampleBookshelves = 2,
    
    kTableOffsetPortrait_iPad = 240,
    kTableOffsetLandscape_iPad = 120,
    kTableOffsetPortrait_iPhone = 0,
    kTableOffsetLandscape_iPhone = 0
};

@interface SCHStartingViewController ()

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (NSString *)sampleBookshelfTitleAtIndex:(NSInteger)index;
- (void)openSampleBookshelfAtIndex:(NSInteger)index;
- (void)showSignInForm;
- (void)pushProfileView;

@end

@implementation SCHStartingViewController

@synthesize starterTableView;
@synthesize backgroundView;
@synthesize samplesHeaderView;
@synthesize signInHeaderView;

- (void)releaseViewObjects
{
    [starterTableView release], starterTableView = nil;
    [backgroundView release], backgroundView = nil;
    [samplesHeaderView release], samplesHeaderView = nil;
    [signInHeaderView release], signInHeaderView = nil;
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

    UIImageView *logoImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    self.navigationItem.titleView = logoImageView;
    [logoImageView release];
}

- (void)viewDidUnload
{
    [self releaseViewObjects];
    [super viewDidUnload];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self setupAssetsForOrientation:self.interfaceOrientation];
}

#pragma mark - Orientation methods

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    const BOOL iPad = (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad);
    
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        CGFloat offset = iPad ? kTableOffsetLandscape_iPad : kTableOffsetLandscape_iPhone;
        [self.backgroundView setImage:[UIImage imageNamed:@"admin-background-ipad-landscape.png"]];
        [self.starterTableView setContentInset:UIEdgeInsetsMake(offset, 0, 0, 0)];
    } else {
        CGFloat offset = iPad ? kTableOffsetPortrait_iPad : kTableOffsetPortrait_iPhone;
        [self.backgroundView setImage:[UIImage imageNamed:@"admin-background-ipad-portrait.png"]];
        [self.starterTableView setContentInset:UIEdgeInsetsMake(offset, 0, 0, 0)];
    }
    
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
	return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
    [self setupAssetsForOrientation:toInterfaceOrientation];
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return kNumberOfTableSections;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case kTableSectionSamples:
            return kNumberOfSampleBookshelves;
        case kTableSectionSignIn:
            return 1;
    }
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kTableSectionSamples:
            return CGRectGetHeight(self.samplesHeaderView.bounds);
        case kTableSectionSignIn:
            return CGRectGetHeight(self.signInHeaderView.bounds);
    }
    return 0;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case kTableSectionSamples:
            return self.samplesHeaderView;
        case kTableSectionSignIn:
            return self.signInHeaderView;
    }
    return nil;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * const CellIdentifier = @"Cell";
    
    SCHStartingViewCell *cell = (SCHStartingViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[[SCHStartingViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.delegate = self;
    }
    
    switch (indexPath.section) {
        case kTableSectionSamples:
            [cell setTitle:[self sampleBookshelfTitleAtIndex:indexPath.row]];
            break;
        case kTableSectionSignIn:
            [cell setTitle:NSLocalizedString(@"Sign In", @"starter view sign in button title")];
            break;
    }

    cell.indexPath = indexPath;
    return cell;
}

- (void)cellButtonTapped:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case kTableSectionSamples:
            [self openSampleBookshelfAtIndex:indexPath.row];
            break;
            
        case kTableSectionSignIn:
            [self showSignInForm];
            break;
    }
}

#pragma mark - Sample bookshelves

- (NSString *)sampleBookshelfTitleAtIndex:(NSInteger)index
{
    switch (index) {
        case 0: return NSLocalizedString(@"Younger kids' bookshelf (3-6)", @"younger kids sample bookshelf name");
        case 1: return NSLocalizedString(@"Older kids' bookshelf (7+)", @"older kids sample bookshelf name");
    }
    return nil;
}

- (void)openSampleBookshelfAtIndex:(NSInteger)index
{
    
}


#pragma mark - Sign In

- (void)showSignInForm
{
    SCHLoginPasswordViewController *login = [[SCHLoginPasswordViewController alloc] initWithNibName:@"SCHLoginViewController" bundle:nil];
    login.controllerType = kSCHControllerLoginView;
    
    login.cancelBlock = ^{
        [self dismissModalViewControllerAnimated:YES];
    };
    
    login.retainLoopSafeActionBlock = ^BOOL(NSString *username, NSString *password) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerDidSucceedNotification object:nil];			
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerDidFailNotification object:nil];					
        [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithUserName:username withPassword:password];
        return YES;
    };
    
    [login setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [login setModalPresentationStyle:UIModalPresentationFormSheet];
    [self presentModalViewController:login animated:YES];
}

- (void)authenticationManager:(NSNotification *)notification
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHAuthenticationManagerDidSucceedNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:kSCHAuthenticationManagerDidFailNotification object:nil];
	
	if ([notification.name isEqualToString:kSCHAuthenticationManagerDidSucceedNotification]) {
        [self dismissModalViewControllerAnimated:YES];
        [self pushProfileView];
	} else {
		NSError *error = [notification.userInfo objectForKey:kSCHAuthenticationManagerNSError];
		if (error != nil) {
            NSString *localizedMessage = [NSString stringWithFormat:
                                          NSLocalizedString(@"A problem occured. If this problem persists please contact support.\n\n '%@'", nil), 
                                          [error localizedDescription]];                      
            LambdaAlert *alert = [[LambdaAlert alloc]
                                  initWithTitle:NSLocalizedString(@"Login Error", @"Login Error") 
                                  message:localizedMessage];
            [alert addButtonWithTitle:NSLocalizedString(@"Cancel", @"Cancel") block:^{
                [self dismissModalViewControllerAnimated:YES];
            }];
            [alert addButtonWithTitle:NSLocalizedString(@"Retry", @"Retry") block:^{}];
            [alert show];
            [alert release];
        }	
        
        SCHLoginPasswordViewController *login = (SCHLoginPasswordViewController *)self.modalViewController;
        [login stopShowingProgress];
	}
}

- (void)pushProfileView
{
    [[SCHURLManager sharedURLManager] clear];
    [[SCHSyncManager sharedSyncManager] clear];
    [[SCHSyncManager sharedSyncManager] firstSync:YES];

    SCHProfileViewController_Shared *profile;
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        profile = [[SCHProfileViewController_iPad alloc] init];
    } else {
        profile = [[SCHProfileViewController_iPhone alloc] init];
    }
    
    AppDelegate_Shared *appDelegate = (AppDelegate_Shared *)[[UIApplication sharedApplication] delegate];
    profile.managedObjectContext = appDelegate.managedObjectContext;
    [self.navigationController pushViewController:profile animated:NO];
}

@end
