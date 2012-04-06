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

@property (nonatomic, copy) NSString *originalTheme;
@property (nonatomic, assign) BOOL keepSelectedTheme;

- (void)previewTheme:(NSString *)themeName;
- (void)setThemeWithName:(NSString *)themeName forInterfaceOrientation:(UIInterfaceOrientation)orientation;
- (void)setThemeForInterfaceOrientation:(UIInterfaceOrientation)orientation;

@end

@implementation SCHThemePickerViewController

@synthesize tableView;
@synthesize originalTheme;
@synthesize keepSelectedTheme;
@synthesize delegate;

#pragma mark - Object lifecycle

- (void)releaseViewObjects
{
    [tableView release], tableView = nil;
}

- (void)dealloc 
{    
    [originalTheme release], originalTheme = nil;
    [self releaseViewObjects];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)setThemeWithName:(NSString *)themeName forInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        
        SCHThemeManager *themeManager = [SCHThemeManager sharedThemeManager];
        
        self.view.backgroundColor = [UIColor clearColor];
        self.tableView.backgroundColor = [UIColor clearColor];
        
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[themeManager 
                                                                                               imageForTheme:themeName 
                                                                                               key:kSCHThemeManagerNavigationBarImage 
                                                                                               orientation:orientation]];
    }
}

- (void)setThemeForInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    NSString *themeName = [[SCHThemeManager sharedThemeManager] theme];
    [self setThemeWithName:themeName forInterfaceOrientation:orientation];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        self.originalTheme = [SCHThemeManager sharedThemeManager].theme;
        self.keepSelectedTheme = NO;
        
        UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(done)];
        
        self.navigationItem.rightBarButtonItem = doneButton;
        [doneButton release];
        
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setTheme:kSCHThemeManagerNavigationBarImage];

    } else {
        UIView *backgroundView = [[UIView alloc] initWithFrame:CGRectZero];
        backgroundView.backgroundColor = [UIColor colorWithRed:0.839 green:0.847 blue:0.871 alpha:1.];
        self.tableView.backgroundView = backgroundView;
        [backgroundView release];
        
        self.tableView.scrollEnabled = NO;
    }
    self.tableView.rowHeight = 50;
    self.tableView.separatorColor = [UIColor whiteColor];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLineEtched;
    
    self.title = NSLocalizedString(@"Theme", @"Theme");
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

- (void)viewWillDisappear:(BOOL)animated
{
    if (!self.keepSelectedTheme) {
        [SCHThemeManager sharedThemeManager].theme = self.originalTheme;
        self.navigationController.navigationBar.tintColor = [[SCHThemeManager sharedThemeManager] colorForModalSheetBorder];

    }
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
    self.keepSelectedTheme = YES;
    
    if (self.delegate) {
        [self.delegate themePickerControllerSelectedClose:self];
    }
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
    if ([themeName isEqualToString:[SCHThemeManager sharedThemeManager].theme] == NO) {
        [SCHThemeManager sharedThemeManager].theme = themeName;
        self.navigationController.navigationBar.tintColor = [[SCHThemeManager sharedThemeManager] colorForModalSheetBorder];

        [self.tableView reloadData];    
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 10;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
    [self.tableView reloadData];
}

#pragma mark - Popover Size

- (CGSize) contentSizeForViewInPopover
{
    CGFloat height = ([[[SCHThemeManager sharedThemeManager] themeNames:NO] count] * 44) + 44 + 18;
    return CGSizeMake(240, height);
}

@end
