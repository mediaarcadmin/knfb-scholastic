//
//  SCHThemePickerViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 15/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHThemePickerViewController.h"

#import <QuartzCore/QuartzCore.h>
#import "SCHThemeManager.h"
#import "SCHThemeButton.h"
#import "SCHThemeImageView.h"
#import "SCHCustomNavigationBar.h"

@interface SCHThemePickerViewController ()

@property (nonatomic, retain) SCHThemeButton *cancelButton;
@property (nonatomic, retain) SCHThemeButton *doneButton;
@property (nonatomic, retain) NSString *lastTappedTheme;

- (void)previewTheme:(NSString *)themeName;

@end

@implementation SCHThemePickerViewController

@synthesize tableView;
@synthesize shadowView;
@synthesize cancelButton;
@synthesize doneButton;
@synthesize lastTappedTheme;

- (void)releaseViewObjects
{
    [tableView release], tableView = nil;
    [shadowView release], shadowView = nil;
    [cancelButton release], shadowView = nil;
    [doneButton release], shadowView = nil;
}

- (void)dealloc 
{    
    [lastTappedTheme release], lastTappedTheme = nil;
    [self releaseViewObjects];
    
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    SCHThemeImageView *themeBackgroundView = [[[SCHThemeImageView alloc] initWithImage:nil] autorelease];
    [themeBackgroundView setTheme:kSCHThemeManagerBackgroundImage];    
    self.tableView.backgroundView = themeBackgroundView;
//    self.tableView.backgroundColor = [UIColor clearColor];

    self.cancelButton = [SCHThemeButton buttonWithType:UIButtonTypeCustom];
    [self.cancelButton setFrame:CGRectMake(0, 0, 60, 30)];
    [self.cancelButton setTitle:NSLocalizedString(@"Cancel", @"") forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor colorWithWhite:1 alpha:0.5f] forState:UIControlStateHighlighted];
    [self.cancelButton setReversesTitleShadowWhenHighlighted:YES];

    self.cancelButton.titleLabel.font = [UIFont boldSystemFontOfSize:14];
    self.cancelButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    
    [self.cancelButton setThemeButton:kSCHThemeManagerDoneButtonImage leftCapWidth:5 topCapHeight:0];
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

    [self.doneButton setThemeButton:kSCHThemeManagerButtonImage leftCapWidth:5 topCapHeight:0];
    [self.doneButton addTarget:self action:@selector(done) forControlEvents:UIControlEventTouchUpInside];    
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithCustomView:doneButton] autorelease];
    
    self.tableView.rowHeight = 58;
    self.tableView.separatorColor = [UIColor colorWithRed:0.000 green:0.365 blue:0.616 alpha:1.000];
    
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar setTheme:kSCHThemeManagerNavigationBarImage];
    
    [self.shadowView setImage:[[UIImage imageNamed:@"bookshelf-iphone-top-shadow.png"] stretchableImageWithLeftCapWidth:15.0f topCapHeight:0]];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [(SCHCustomNavigationBar *)self.navigationController.navigationBar updateTheme];
}


- (void) willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    if (self.lastTappedTheme == nil) {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar updateTheme:toInterfaceOrientation];
    } else {
        [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:
         [[SCHThemeManager sharedThemeManager] imageForTheme:self.lastTappedTheme 
                                                         key:kSCHThemeManagerNavigationBarImage 
                                                 orientation:self.interfaceOrientation]];
    }
}


- (void)previewTheme:(NSString *)themeName
{
    SCHThemeManager *themeManager = [SCHThemeManager sharedThemeManager];

    [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                     animations:^{
                         self.tableView.backgroundView.alpha = 0.7;
                         self.navigationController.navigationBar.alpha = 0.7;
                     }
                     completion:^(BOOL finished) {
                         [self.cancelButton setBackgroundImage:[[themeManager imageForTheme:themeName key:kSCHThemeManagerDoneButtonImage orientation:self.interfaceOrientation] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
                         [self.doneButton setBackgroundImage:[[themeManager imageForTheme:themeName key:kSCHThemeManagerButtonImage orientation:self.interfaceOrientation] stretchableImageWithLeftCapWidth:5 topCapHeight:0] forState:UIControlStateNormal];
                         [(SCHThemeImageView *)self.tableView.backgroundView setImage:[themeManager imageForTheme:themeName key:kSCHThemeManagerBackgroundImage orientation:self.interfaceOrientation]];
                         [(SCHCustomNavigationBar *)self.navigationController.navigationBar setBackgroundImage:[themeManager imageForTheme:themeName key:kSCHThemeManagerNavigationBarImage orientation:self.interfaceOrientation]];
                         
                         [UIView animateWithDuration:0.3 delay:0.0 options:UIViewAnimationOptionCurveEaseIn
                                          animations:^{
                                              self.tableView.backgroundView.alpha = 1.0;
                                              self.navigationController.navigationBar.alpha = 1.0;
                                          }
                                          completion:^(BOOL finished) {
                                          }];                         
                     }];    
}

- (void)done
{
    if (self.lastTappedTheme != nil) {
        [SCHThemeManager sharedThemeManager].theme = self.lastTappedTheme;    
        self.lastTappedTheme = nil;
    }
    [self dismissModalViewControllerAnimated:YES];    
    [self.tableView reloadData];    
}

- (void)cancel
{
    self.lastTappedTheme = nil;
    [self dismissModalViewControllerAnimated:YES];
    [self previewTheme:[SCHThemeManager sharedThemeManager].theme];    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    self.cancelButton = nil;
    self.doneButton = nil;
    self.lastTappedTheme = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (YES);
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UILabel *headerLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 0, self.view.frame.size.width - 32, 50)];
    headerLabel.text = NSLocalizedString(@"Themes", @"");
    headerLabel.font = [UIFont boldSystemFontOfSize:17.0f];
    headerLabel.numberOfLines = 1;
    headerLabel.backgroundColor = [UIColor clearColor];
    headerLabel.textColor = [UIColor whiteColor];
    headerLabel.shadowOffset = CGSizeMake(0, -1);
    
    UIView *containerView = [[UIView alloc] initWithFrame:CGRectZero];
    [containerView addSubview:headerLabel];
    [headerLabel release];
    
    return [containerView autorelease];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 50;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return(1);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[[SCHThemeManager sharedThemeManager] themeNames:YES] count];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [aTableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
        cell.textLabel.textAlignment = UITextAlignmentCenter;
        cell.textLabel.textColor = [UIColor whiteColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:22.0f];
        cell.textLabel.shadowOffset = CGSizeMake(0, 1);
        cell.textLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5f];
    }

    // Configure the cell...
    cell.textLabel.text = [[[SCHThemeManager sharedThemeManager] themeNames:YES] objectAtIndex:indexPath.row];
    cell.backgroundColor = [UIColor colorWithPatternImage:
                            [[SCHThemeManager sharedThemeManager] imageForTheme:cell.textLabel.text key:kSCHThemeManagerImage orientation:self.interfaceOrientation]];

    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [aTableView deselectRowAtIndexPath:indexPath animated:NO];
    
    NSString *themeName = [[[SCHThemeManager sharedThemeManager] themeNames:YES] objectAtIndex:indexPath.row];
    if ([themeName isEqualToString:self.lastTappedTheme] == NO) {
        self.lastTappedTheme = themeName;
        [self previewTheme:themeName];
    }
}

@end
