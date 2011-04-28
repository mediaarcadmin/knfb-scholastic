//
//  SCHLoginViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 19/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHLoginViewController.h"

#import "SCHAuthenticationManager.h"
#import "SCHSyncManager.h"
#import "SCHURLManager.h"
#import "SCHCustomToolbar.h"


static const CGFloat kProfileViewCellButtonWidth = 283.0f;
static const CGFloat kProfileViewCellButtonHeight = 48.0f;

#pragma mark - Class Extension

@interface SCHLoginViewController ()

- (void)releaseViewObjects;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)scrollToTextField:(UITextField *)textField animated: (BOOL) animated;

@property (nonatomic, retain) UIButton *loginButton;

@end

@implementation SCHLoginViewController

@synthesize showHeaders;
@synthesize passwordOnly;
@synthesize actionBlock;
@synthesize loginButtonText;

@synthesize userNameField;
@synthesize passwordField;
@synthesize loginButton;
@synthesize cancelButton;
@synthesize spinner;
@synthesize topBar;
@synthesize topShadow;
@synthesize headerTitleLabel;
@synthesize headerTitleView;
@synthesize footerForgotLabel;
@synthesize tableView;

#pragma mark - Object Lifecycle

- (void)releaseViewObjects
{
	[userNameField release], userNameField = nil;
	[passwordField release], passwordField = nil;
	[loginButton release], loginButton = nil;
	[cancelButton release], cancelButton = nil;
	[spinner release], spinner = nil;
    [topBar release], topBar = nil;
    [topShadow release], topShadow = nil;
    [headerTitleLabel release], headerTitleLabel = nil;
    [headerTitleView release], headerTitleView = nil;
    [footerForgotLabel release], footerForgotLabel = nil;
    [tableView release], tableView = nil;
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [actionBlock release], actionBlock = nil;
    [loginButtonText release], loginButtonText = nil;
	
    [self releaseViewObjects];    
    [super dealloc];
}


- (void)viewDidUnload 
{
    [super viewDidUnload];
    [self releaseViewObjects];    
}

#pragma mark - View Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    topBar.items = [NSArray arrayWithObjects:
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], 
                    [[UIBarButtonItem alloc] initWithCustomView:headerImage],
                    [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil], nil];
    [headerImage release];

	self.userNameField.text = @"";
	self.passwordField.text = @"";
    
    [[NSNotificationCenter defaultCenter] addObserver:self 
                                             selector:@selector(keyboardWillShow:) 
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillHide:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
    if (self.showHeaders) {
        self.tableView.tableHeaderView = self.headerTitleView;
        self.tableView.tableFooterView = self.footerForgotLabel;
    } else {
        float fillerHeight = 44;
        UIView *fillerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, fillerHeight)];
        self.tableView.tableHeaderView = fillerView;
        [fillerView release];
    }
    
    UIImage *bgImage = [UIImage imageNamed:@"button-translucent"];
    UIImage *cellBGImage = [bgImage stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    
    self.userNameField.background = cellBGImage;
    self.userNameField.leftViewMode = UITextFieldViewModeAlways;
    UIView *fillerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
    self.userNameField.leftView = fillerView;
    [fillerView release];
    
    cellBGImage = [bgImage stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    self.passwordField.background = cellBGImage;
    self.passwordField.leftViewMode = UITextFieldViewModeAlways;
    fillerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
    self.passwordField.leftView = fillerView;
    [fillerView release];
    
    bgImage = [UIImage imageNamed:@"button-blue"];
    cellBGImage = [bgImage stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setBackgroundImage:cellBGImage forState:UIControlStateNormal];
    [self.loginButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [self.loginButton addTarget:self 
                         action:@selector(login:) 
               forControlEvents:UIControlEventTouchUpInside];
    
    self.loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.loginButton.titleLabel.minimumFontSize = 14;
    self.loginButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.loginButton.titleLabel.textColor = [UIColor whiteColor];
    self.loginButton.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5F];
    self.loginButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    self.loginButton.titleLabel.textAlignment = UITextAlignmentCenter;
    
    if (!self.loginButtonText) {
        [self.loginButton setTitle:NSLocalizedString(@"Log In", @"Log In") forState:UIControlStateNormal];
    } else {
        [self.loginButton setTitle:self.loginButtonText forState:UIControlStateNormal];
    }
    
      [self.topShadow setImage:[[UIImage imageNamed:@"reading-view-iphone-top-shadow.png"] stretchableImageWithLeftCapWidth:15.0f topCapHeight:0]];

}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    [self setupAssetsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
}

#pragma mark - Orientation

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return YES;
}

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
    [self setupAssetsForOrientation:toInterfaceOrientation];
}

- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation
{
    if (UIInterfaceOrientationIsLandscape(orientation)) {
        [self.topBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-landscape-top-toolbar.png"]];
        CGRect barFrame = self.topBar.frame;
        if (barFrame.size.height == 44) {
            barFrame.size.height = 34;
            self.topBar.frame = barFrame;
            
            CGRect tableFrame = self.tableView.frame;
            tableFrame.size.height += 10;
            tableFrame.origin.y -= 10;
            self.tableView.frame = tableFrame;
        }
    } else {
        [self.topBar setBackgroundImage:[UIImage imageNamed:@"admin-iphone-portrait-top-toolbar.png"]];
        CGRect barFrame = self.topBar.frame;
        if (barFrame.size.height == 34) {
            barFrame.size.height = 44;
            self.topBar.frame = barFrame;

            CGRect tableFrame = self.tableView.frame;
            tableFrame.size.height -= 10;
            tableFrame.origin.y += 10;
            self.tableView.frame = tableFrame;
        }
        
    }
    
    CGRect topShadowFrame = self.topShadow.frame;
    topShadowFrame.origin.y = CGRectGetMinY(self.tableView.frame);
    self.topShadow.frame = topShadowFrame;
}

#pragma mark - Authentication Manager

- (void)authenticationManager:(NSNotification *)notification
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
	
	[spinner stopAnimating];
	self.loginButton.enabled = YES;
	self.cancelButton.enabled = YES;

	if ([notification.name compare:kSCHAuthenticationManagerSuccess] == NSOrderedSame) {
		[[SCHURLManager sharedURLManager] clear];
		[[SCHSyncManager sharedSyncManager] clear];
		[[SCHSyncManager sharedSyncManager] firstSync];
		[self dismissModalViewControllerAnimated:YES];	
	} else {
		NSError *error = [notification.userInfo objectForKey:kSCHAuthenticationManagerNSError];
		if (error!= nil) {
			UIAlertView *errorAlert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Error", @"Error") 
																 message:[error localizedDescription]
																delegate:nil 
													   cancelButtonTitle:NSLocalizedString(@"OK", @"OK")
													   otherButtonTitles:nil]; 
			[errorAlert show]; 
			[errorAlert release];
		}		
	}
}

#pragma mark - Button Actions

- (IBAction)login:(id)sender
{
    if (self.actionBlock) {
        self.actionBlock();
    }
    
	[self.userNameField resignFirstResponder];
	[self.passwordField resignFirstResponder];
    [spinner startAnimating];
    self.loginButton.enabled = NO;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerSuccess object:nil];			
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticationManager:) name:kSCHAuthenticationManagerFailure object:nil];					
    
    [[SCHAuthenticationManager sharedAuthenticationManager] authenticateWithUserName:[self.userNameField text] withPassword:[self.passwordField text]];
}

- (IBAction)cancel:(id)sender
{
	[self.userNameField resignFirstResponder];
	[self.passwordField resignFirstResponder];
	
	[self dismissModalViewControllerAnimated:YES];	
}

- (void)removeCancelButton
{
	CGPoint center = self.loginButton.center;
	center.x = self.view.superview.center.x;
	self.loginButton.center = center;
	
	self.cancelButton.hidden = YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.passwordOnly) {
        return 1;
    } else {
        return 2;
    }
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        if (self.passwordOnly) {
            return 1;
        } else {
            return 2;
        }
    } else if (section == 1) {
        return 1;
    } else {
        return 0;
    }
}
/*
- (float)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // login button height is different from cell height
    if ([indexPath section] == 1) {
        return 54;
    } else {
        return aTableView.rowHeight;
    }
}
*/
- (UITableViewCell*)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"loginViewCell";
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0 && !self.passwordOnly) {
                CGRect fieldFrame = self.userNameField.frame;
                fieldFrame.origin.x = ceilf((CGRectGetWidth(cell.contentView.bounds) - kProfileViewCellButtonWidth) / 2.0f);
                fieldFrame.size.height = kProfileViewCellButtonHeight;
                fieldFrame.size.width = kProfileViewCellButtonWidth;
                fieldFrame.origin.y = 2;
                self.userNameField.frame = fieldFrame;
                [cell addSubview:self.userNameField];
                break;
            } else {
                CGRect fieldFrame = self.passwordField.frame;
                fieldFrame.origin.x = ceilf((CGRectGetWidth(cell.contentView.bounds) - kProfileViewCellButtonWidth) / 2.0f);
                fieldFrame.size.height = kProfileViewCellButtonHeight;
                fieldFrame.size.width = kProfileViewCellButtonWidth;
                fieldFrame.origin.y = 2;
                self.passwordField.frame = fieldFrame;
                [cell addSubview:self.passwordField];
                break;
            }
            break;
        }
        case 1:
        {
            UIImage *bgImage = [UIImage imageNamed:@"button-blue"];

            CGRect buttonFrame = CGRectMake(ceilf((CGRectGetWidth(cell.contentView.bounds) - kProfileViewCellButtonWidth) / 2.0f), 
                                            ceilf(((CGRectGetHeight(cell.contentView.bounds) - 10) - bgImage.size.height) / 2.0f) + 4, 
                                            kProfileViewCellButtonWidth, 
                                            kProfileViewCellButtonHeight);
            
            [self.loginButton setFrame:buttonFrame];

            [cell.contentView addSubview:self.loginButton];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            break;
        }
    }
    
    return cell;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if (textField == self.userNameField) {
        [self.passwordField becomeFirstResponder];
        return YES;
    }
    
    if (textField == self.passwordField && [self.userNameField.text length] > 0 && [self.passwordField.text length] > 0) {
        [self.passwordField resignFirstResponder];
        [self login:nil];
    }
    
    return YES;
}

- (void)scrollToTextField:(UITextField *)textField animated: (BOOL) animated
{
    NSIndexPath *indexPath = nil;
    
    if (textField == self.userNameField) {
        CGPoint offset = CGPointMake(0, CGRectGetHeight(self.headerTitleView.frame) - 25);
        [self.tableView setContentOffset:offset animated:animated];
    } else if (textField == self.passwordField) {
        if (self.passwordOnly) {
            indexPath = [NSIndexPath indexPathForRow:0 inSection:0];
        } else {
            indexPath = [NSIndexPath indexPathForRow:1 inSection:0];
        }
    }
    
    if (indexPath) {
        [self.tableView scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionNone animated:animated];
    }
}

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    [self scrollToTextField:textField animated:YES];
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
}

#pragma mark - UIKeyboard Notifications

- (void)keyboardWillShow:(NSNotification *) notification
{
 	CGRect keyboardFrame;
	CGFloat keyboardHeight;
    double keyboardAnimDuration;
    UIViewAnimationCurve keyboardCurve;

	// 3.2 and above
	if (UIKeyboardFrameEndUserInfoKey) {		
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];		
        [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardAnimDuration];		
        [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardCurve];		
        if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
            keyboardHeight = keyboardFrame.size.height;
        } else {
            keyboardHeight = keyboardFrame.size.width;
        }
    }
	 
    CGRect tableFrame = self.tableView.frame;
    tableFrame.size.height = tableFrame.size.height - keyboardHeight;

    [UIView beginAnimations:@"tableSizeAnimation" context:nil];
    [UIView setAnimationCurve:keyboardCurve];
    [UIView setAnimationDuration:keyboardAnimDuration];
    [UIView setAnimationBeginsFromCurrentState:YES];
    
    self.tableView.frame = tableFrame;
    [UIView commitAnimations];
   
    if ([self.userNameField isFirstResponder]) {
        [self scrollToTextField:self.userNameField animated:YES];
    } else if ([self.passwordField isFirstResponder]) {
        [self scrollToTextField:self.passwordField animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *) notification
{
//    NSLog(@"Firing keyboardWillHide");
 	CGRect keyboardFrame;
	CGFloat keyboardHeight;
    double keyboardAnimDuration;
    UIViewAnimationCurve keyboardCurve;
	
	// 3.2 and above
	if (UIKeyboardFrameEndUserInfoKey) {		
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];		
        [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardAnimDuration];		
        [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardCurve];		
        if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
            keyboardHeight = keyboardFrame.size.height;
        } else {
            keyboardHeight = keyboardFrame.size.width;
        }
    }
    
    float barHeight = MIN(self.topBar.frame.size.height, self.topBar.frame.size.width);
    
    CGRect tableFrame = self.tableView.frame;

    tableFrame.size.height = self.view.bounds.size.height - barHeight;

    [UIView beginAnimations:@"tableSizeAnimation" context:nil];
    [UIView setAnimationCurve:keyboardCurve];
    [UIView setAnimationDuration:keyboardAnimDuration];
    [UIView setAnimationBeginsFromCurrentState:YES];

    self.tableView.frame = tableFrame;
    [UIView commitAnimations];
    
}

@end
