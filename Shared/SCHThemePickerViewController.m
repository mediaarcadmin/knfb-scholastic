//
//  SCHThemePickerViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThemePickerViewController.h"

#import "SCHThemeManager.h"
#import "SCHThemeButton.h"
#import "SCHThemeImageView.h"
#import "SCHCustomNavigationBar.h"
#import "SCHBookShelfShadowsView.h"

static NSTimeInterval const kSCHThemePickerViewControllerThemeTransitionDuration = 0.3;

@interface SCHThemePickerViewController ()

@property (nonatomic, retain) SCHThemeButton *cancelButton;
@property (nonatomic, retain) SCHThemeButton *doneButton;
@property (nonatomic, copy) NSString *lastTappedTheme;

- (void)previewTheme:(NSString *)themeName;
- (void)setThemeWithName:(NSString *)themeName forInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (void)setThemeForInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end

@implementation SCHThemePickerViewController

@synthesize tableView;
@synthesize cancelButton;
@synthesize doneButton;
@synthesize lastTappedTheme;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [tableView release], tableView = nil;
    [cancelButton release], cancelButton = nil;
    [doneButton release], doneButton = nil;
}

- (void)dealloc 
{    
    [lastTappedTheme release], lastTappedTheme = nil;
    [self releaseViewObjects];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)setThemeWithName:(NSString *)themeName forInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        SCHThemeManager *themeManager = [SCHThemeManager sharedThemeManager];
        
        [self.cancelButton setBackgroundImage:[[themeManager imageForTheme:themeName 
                                                                       key:kSCHThemeManagerDoneButtonImage 
                                                               orientation:orientation] stretchableImageWithLeftCapWidth:7 topCapHeight:0] 
                                     forState:UIControlStateNormal];
        
        [self.doneButton setBackgroundImage:[[themeManager imageForTheme:themeName 
                                                                     key:kSCHThemeManagerButtonImage 
                                                             orientation:orientation] stretchableImageWithLeftCapWidth:7 topCapHeight:0] 
                                   forState:UIControlStateNormal];
        
        [(SCHThemeImageView *)self.tableView.backgroundView setImage:[themeManager imageForTheme:themeName 
                                                                                   key:kSCHThemeManagerBackgroundImage 
                                                                           orientation:UIInterfaceOrientationPortrait]]; // Always use portrait
        
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[themeManager 
                                                                                               imageForTheme:themeName 
                                                                                               key:kSCHThemeManagerNavigationBarImage 
                                                                                               orientation:orientation]];
    }
}

- (void)setThemeForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    [self.cancelButton updateTheme:orientation];
    [self.doneButton updateTheme:orientation];
    
    NSString *themeName = self.lastTappedTheme ? : [[SCHThemeManager sharedThemeManager] theme];
    [self setThemeWithName:themeName forInterfaceOrientation:orientation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        SCHThemeImageView *themeBackgroundView = [[[SCHThemeImageView alloc] initWithImage:nil] autorelease];
        [themeBackgroundView setContentMode:UIViewContentModeCenter];
        [themeBackgroundView setTheme:kSCHThemeManagerBackgroundImage];
        self.tableView.backgroundView = themeBackgroundView;
        
        SCHBookShelfShadowsView *shadows = [[SCHBookShelfShadowsView alloc] initWithFrame:themeBackgroundView.bounds];
        [shadows setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
        [themeBackgroundView addSubview:shadows];
        [shadows release];
    
        self.cancelButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
        [self.cancelButton setFrame:CGRectMake(0, 0, 60, 30)];
        [self.cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.cancelButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5f] forState:UIControlStateHighlighted];
        [self.cancelButton setReversesTitleShadowWhenHighlighted:YES];
        
        self.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.cancelButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        
        [self.cancelButton setThemeButton:kSCHThemeManagerDoneButtonImage leftCapWidth:7 topCapHeight:0];
        [self.cancelButton addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];    
        self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:cancelButton] autorelease];
        
        self.doneButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
        [self.doneButton setFrame:CGRectMake(0, 0, 60, 30)];
        [self.doneButton setTitle:NSLocalizedString(@"Done", @"") forState:UIControlStateNormal];
        [self.doneButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [self.doneButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5f] forState:UIControlStateHighlighted];
        [self.doneButton setReversesTitleShadowWhenHighlighted:YES];
        
        self.doneButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
        self.doneButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
        
        [self.doneButton setThemeButton:kSCHThemeManagerButtonImage leftCapWidth:7 topCapHeight:0];
        [self.doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];    
        self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:doneButton] autorelease];
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setTheme:kSCHThemeManagerNavigationBarImage];

    } else {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        backgroundView.backgroundColor = [UIColor colorWithRed:0.839 green:0.847 blue:0.871 alpha:1.];
        self.tableView.backgroundView = backgroundView;
        [backgroundView release];
        
        self.tableView.scrollEnabled = NO;
    }
    self.tableView.rowHeight = 50;
//    self.tableView.separatorColor = [UIColor whiteColor];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
	[self releaseViewObjects];
}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    [self setThemeForInterfaceOrientation:self.interfaceOrientation];
}

#pragma mark - Orientation methods

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return(YES);
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation 
                                duration:(NSTimeInterval)duration
{
    [self setThemeForInterfaceOrientation:toInterfaceOrientation];
}

#pragma mark - Private Methods

- (void)previewTheme:(NSString *)themeName
{
    [self setThemeWithName:themeName forInterfaceOrientation:self.interfaceOrientation];
}

#pragma mark - Action Methods

- (IBAction)done
{
    if (self.lastTappedTheme != nil) {
        [SCHThemeManager sharedThemeManager].theme = self.lastTappedTheme;    
        self.lastTappedTheme = nil;
    }
    [self dismissModalViewControllerAnimated:YES];    
    [self.tableView reloadData];    
}

- (IBAction)cancel
{
    self.lastTappedTheme = nil;
    [self dismissModalViewControllerAnimated:YES];
    [self previewTheme:[SCHThemeManager sharedThemeManager].theme];    
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return(1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[SCHThemeManager sharedThemeManager] themeNames:NO] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }

    NSString *theme = [[[SCHThemeManager sharedThemeManager] themeNames:NO] objectAtIndex:indexPath.row];
    
    cell.backgroundColor = [UIColor colorWithPatternImage:
                            [[SCHThemeManager sharedThemeManager] imageForTheme:theme 
                                                                            key:kSCHThemeManagerImage 
                                                                    orientation:self.interfaceOrientation 
                                                                  iPadQualifier:kSCHThemeManagerPadQualifierSuffix]];
    if ([SCHThemeManager sharedThemeManager].theme != nil &&
        [theme isEqualToString:[SCHThemeManager sharedThemeManager].theme] == YES) {
        cell.accessoryView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"popoverTickLight"]] autorelease];
    } else {
        cell.accessoryView = nil;
    }
    
    return(cell);
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *themeName = [[[SCHThemeManager sharedThemeManager] themeNames:NO] 
                           objectAtIndex:indexPath.row];
    if (self.lastTappedTheme == nil ||
        [themeName isEqualToString:self.lastTappedTheme] == NO) {
        self.lastTappedTheme = themeName;
        
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            [self previewTheme:themeName];
        } else {
            if (self.lastTappedTheme != nil) {
                [SCHThemeManager sharedThemeManager].theme = self.lastTappedTheme;    
                self.lastTappedTheme = nil;
                [self.tableView reloadData];    
            }
        }
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width - 32, 50)];
    headerLabel.text = NSLocalizedString(@"Themes", @"");
    headerLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    headerLabel.numberOfLines = 1;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowOffset = CGSizeMake(0, -1);
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    [containerView addSubview:headerLabel];
    [headerLabel release], headerLabel = nil;
    
    return([containerView autorelease]);
    } else {
        UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
        return [containerView autorelease];
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return(50);
    } else {
        return 10;
    }
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

- (CGSize) contentSizeForViewInPopover
{
    CGFloat height = ([[[SCHThemeManager sharedThemeManager] themeNames:NO] count] * 44) + 44 + 18;
    return CGSizeMake(200, height);
}

@end
