//
//  SCHLoginPasswordViewController.m
//  Scholastic
//
//  Created by John S. Eddie on 19/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHLoginPasswordViewController.h"

#import "SCHCustomToolbar.h"


static const CGFloat kProfileViewCellButtonWidth = 283.0f;
static const CGFloat kProfileViewCellButtonHeight = 48.0f;

#pragma mark - Class Extension

@interface SCHLoginPasswordViewController ()

- (void)releaseViewObjects;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)orientation;
- (void)scrollToTextField:(UITextField *)textField animated: (BOOL) animated;
- (IBAction)openScholasticURLInSafari:(id)sender;

@property (nonatomic, retain) UIButton *loginButton;

@end

#pragma mark -

@implementation SCHLoginPasswordViewController

@synthesize controllerType;
@synthesize actionBlock;
@synthesize cancelBlock;

@synthesize topField;
@synthesize bottomField;
@synthesize loginButton;
@synthesize spinner;
@synthesize topBar;
@synthesize topShadow;
@synthesize headerTitleLabel;
@synthesize headerTitleView;
@synthesize footerForgotButton;
@synthesize tableView;
@synthesize titleTextLabel;

#pragma mark - Object Lifecycle

- (void)releaseViewObjects
{
	[topField release], topField = nil;
	[bottomField release], bottomField = nil;
	[loginButton release], loginButton = nil;
	[spinner release], spinner = nil;
    [topBar release], topBar = nil;
    [topShadow release], topShadow = nil;
    [headerTitleLabel release], headerTitleLabel = nil;
    [headerTitleView release], headerTitleView = nil;
    [footerForgotButton release], footerForgotButton = nil;
    [tableView release], tableView = nil;
    [titleTextLabel release], titleTextLabel = nil;
}

- (void)dealloc 
{
	[[NSNotificationCenter defaultCenter] removeObserver:self];
    [actionBlock release], actionBlock = nil;
    [cancelBlock release], cancelBlock = nil;
	
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
    
    CGRect topViewFrame = CGRectMake(0, 0, 34, 34);
    
    UIBarButtonItem *leftBBI = nil;

    if (self.controllerType == kSCHControllerPasswordOnlyView ||
        self.controllerType == kSCHControllerDoublePasswordView) {
        leftBBI = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonAction:)] autorelease];

        // FIXME - even the width to centre the title properly - don't like this
        topViewFrame = CGRectMake(0, 0, 59, 34);
    } else {
        UIView *leftView = [[UIView alloc] initWithFrame:topViewFrame];
        leftBBI = [[[UIBarButtonItem alloc] initWithCustomView:leftView] autorelease];
        [leftView release];
    }
    
    UIView *rightView = [[UIView alloc] initWithFrame:topViewFrame];
    self.spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    self.spinner.center = CGPointMake(topViewFrame.size.width / 2 + 5, topViewFrame.size.height / 2);
    [rightView addSubview:self.spinner];
    [self.spinner release];
    
    if (self.controllerType == kSCHControllerLoginView) {
    
    UIImageView *headerImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"logo"]];
    topBar.items = [NSArray arrayWithObjects:
                    leftBBI,
                    [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease], 
                    [[[UIBarButtonItem alloc] initWithCustomView:headerImage] autorelease],
                    [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease], 
                    [[[UIBarButtonItem alloc] initWithCustomView:rightView] autorelease],
                    nil];
    [headerImage release];
        
    } else {
        self.titleTextLabel.text = @"Password";
        CGRect titleFrame = self.titleTextLabel.frame;
        titleFrame.size.width = self.topBar.frame.size.width - 40;
        self.titleTextLabel.frame = titleFrame;
        topBar.items = [NSArray arrayWithObjects:
                        leftBBI,
                        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease], 
                        [[[UIBarButtonItem alloc] initWithCustomView:self.titleTextLabel] autorelease],
                        [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil] autorelease], 
                        [[[UIBarButtonItem alloc] initWithCustomView:rightView] autorelease],
                        nil];
    }
    
    
    [rightView release];
    
    [self.topBar setTintColor:[UIColor colorWithRed:0.832 green:0.000 blue:0.007 alpha:1.000]];

    [self clearFields];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        [[NSNotificationCenter defaultCenter] addObserver:self 
                                                 selector:@selector(keyboardWillShow:) 
                                                     name:UIKeyboardWillShowNotification
                                                   object:nil];
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(keyboardWillHide:)
                                                     name:UIKeyboardWillHideNotification
                                                   object:nil];
    }    
    switch (self.controllerType) {
        case kSCHControllerLoginView:
        {
            self.tableView.tableHeaderView = self.headerTitleView;
            self.tableView.tableFooterView = self.footerForgotButton;
            break;   
        }
        default:
        {
            // the default is to not show titles
            float fillerHeight = 44;
            UIView *fillerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, fillerHeight)];
            self.tableView.tableHeaderView = fillerView;
            [fillerView release];
        }
    }
    
    UIImage *bgImage = [UIImage imageNamed:@"button-translucent"];
    UIImage *cellBGImage = [bgImage stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    
    self.topField.background = cellBGImage;
    self.topField.leftViewMode = UITextFieldViewModeAlways;
    UIView *fillerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
    self.topField.leftView = fillerView;
    [fillerView release];
    
    cellBGImage = [bgImage stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    self.bottomField.background = cellBGImage;
    self.bottomField.leftViewMode = UITextFieldViewModeAlways;
    fillerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 8, 8)];
    self.bottomField.leftView = fillerView;
    [fillerView release];
    
    bgImage = [UIImage imageNamed:@"button-blue"];
    cellBGImage = [bgImage stretchableImageWithLeftCapWidth:16 topCapHeight:0];
    
    self.loginButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.loginButton setBackgroundImage:cellBGImage forState:UIControlStateNormal];
    [self.loginButton setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
    [self.loginButton addTarget:self 
                         action:@selector(actionButtonAction:) 
               forControlEvents:UIControlEventTouchUpInside];
    
    self.loginButton.titleLabel.font = [UIFont boldSystemFontOfSize:20];
    self.loginButton.titleLabel.minimumFontSize = 14;
    self.loginButton.titleLabel.adjustsFontSizeToFitWidth = YES;
    self.loginButton.titleLabel.textColor = [UIColor whiteColor];
    self.loginButton.titleLabel.shadowColor = [UIColor colorWithWhite:0 alpha:0.5F];
    self.loginButton.titleLabel.shadowOffset = CGSizeMake(0, -1);
    self.loginButton.titleLabel.textAlignment = UITextAlignmentCenter;

    switch (self.controllerType) {
        case kSCHControllerLoginView:
            [self.loginButton setTitle:NSLocalizedString(@"Log In", @"Log In") forState:UIControlStateNormal];
            break;
        case kSCHControllerPasswordOnlyView:
            [self.loginButton setTitle:NSLocalizedString(@"Open Bookshelf", @"Open Bookshelf") forState:UIControlStateNormal];
            break;
            
        default:
            break;
    }
    
      [self.topShadow setImage:[[UIImage imageNamed:@"reading-view-iphone-top-shadow.png"] stretchableImageWithLeftCapWidth:15.0f topCapHeight:0]];

}

- (void)viewWillAppear:(BOOL)animated 
{
    [super viewWillAppear:animated];
    [self setupAssetsForOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if (self.controllerType == kSCHControllerPasswordOnlyView ||
        self.controllerType == kSCHControllerDoublePasswordView) {
        [self.bottomField becomeFirstResponder];
    }
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
    
    
    if (UIInterfaceOrientationIsPortrait(orientation) || UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
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
    } else {
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
    }
    
    CGRect topShadowFrame = self.topShadow.frame;
    topShadowFrame.origin.y = CGRectGetMinY(self.tableView.frame);
    self.topShadow.frame = topShadowFrame;
}

#pragma mark - Username and Password accessors

- (NSString *)username
{
    return self.topField.text;
}

- (NSString *)password
{
    return self.bottomField.text;
}

#pragma mark - External Behaviour Changing

- (void)startShowingProgress
{
 	[self.topField resignFirstResponder];
	[self.bottomField resignFirstResponder];
    [spinner startAnimating];
    self.loginButton.enabled = NO;
}

- (void)stopShowingProgress
{
    [spinner stopAnimating];
    self.loginButton.enabled = YES;
}

- (void)clearFields
{
    self.topField.text = @"";
    self.bottomField.text = @"";
}

#pragma mark - Button Actions

- (IBAction)actionButtonAction:(id)sender
{
    NSAssert(self.actionBlock != nil, @"Action block must be set!");
    
    if (self.actionBlock) {
        self.actionBlock();
    }
    
    if (self.controllerType == kSCHControllerLoginView) {
        [self startShowingProgress];
    }
}

- (IBAction)cancelButtonAction:(id)sender
{
	[self.topField resignFirstResponder];
	[self.bottomField resignFirstResponder];
    
    if (self.cancelBlock) {
        self.cancelBlock();
    } else {
        [self dismissModalViewControllerAnimated:YES];	
    }
}

- (IBAction)openScholasticURLInSafari:(id)sender
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"http://www.scholastic.com/"]];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (self.controllerType) {
        case kSCHControllerLoginView:
        {
            return 2;
        }
        default:
        {
            return 1;
        }
    }
    
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        
        switch (self.controllerType) {
            case kSCHControllerPasswordOnlyView:
            {
                return 1;
            }
            default:
            {
                return 2;
            }
        }
    } else if (section == 1) {
        return 1;
    } else {
        return 0;
    }
}

- (UITableViewCell*)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellIdentifier = @"loginViewCell";
    UITableViewCell *cell = nil;
    
    cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (!cell) {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier] autorelease];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    switch (indexPath.section) {
        case 0:
        {
            if (indexPath.row == 0 && self.controllerType != kSCHControllerPasswordOnlyView) {
                CGRect fieldFrame = self.topField.frame;
                fieldFrame.origin.x = ceilf((CGRectGetWidth(cell.contentView.bounds) - kProfileViewCellButtonWidth) / 2.0f);
                fieldFrame.size.height = kProfileViewCellButtonHeight;
                fieldFrame.size.width = kProfileViewCellButtonWidth;
                fieldFrame.origin.y = 2;
                self.topField.frame = fieldFrame;
                [cell addSubview:self.topField];
                break;
            } else {
                CGRect fieldFrame = self.bottomField.frame;
                fieldFrame.origin.x = ceilf((CGRectGetWidth(cell.contentView.bounds) - kProfileViewCellButtonWidth) / 2.0f);
                fieldFrame.size.height = kProfileViewCellButtonHeight;
                fieldFrame.size.width = kProfileViewCellButtonWidth;
                fieldFrame.origin.y = 2;
                self.bottomField.frame = fieldFrame;
                [cell addSubview:self.bottomField];
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
    switch (self.controllerType) {
        case kSCHControllerLoginView:
        {
            if (textField == self.topField) {
                [self.bottomField becomeFirstResponder];
                return YES;
            }
            
            if (textField == self.bottomField && [self.topField.text length] > 0 && [self.bottomField.text length] > 0) {
                [self.bottomField resignFirstResponder];
                [self actionButtonAction:nil];
            }
            
            return YES;
            break;
        }  
        case kSCHControllerPasswordOnlyView:
        {
            if (textField == self.bottomField && [self.bottomField.text length] > 0) {
                [self actionButtonAction:nil];
            }
            return YES;
            break;
        }
        default:
            NSLog(@"Unknown controller mode!");
            return NO;
            break;
    }
}

- (void)scrollToTextField:(UITextField *)textField animated: (BOOL) animated
{
    NSLog(@"Table view frame: %@", NSStringFromCGRect(self.tableView.frame));
    
    NSIndexPath *indexPath = nil;
    
    if (textField == self.topField) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
            CGPoint offset = CGPointMake(0, CGRectGetHeight(self.headerTitleView.frame) - 25);
            NSLog(@"offset point: %@", NSStringFromCGPoint(offset));
            [self.tableView setContentOffset:offset animated:animated];
        }
    } else if (textField == self.bottomField) {
        if (self.controllerType == kSCHControllerPasswordOnlyView) {
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
    CGRect keyboardFrame = CGRectNull;
    CGFloat keyboardHeight = 0;
    double keyboardAnimDuration = 0;
    UIViewAnimationCurve keyboardCurve = UIViewAnimationCurveLinear;
    
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
    
    if ([self.topField isFirstResponder]) {
        [self scrollToTextField:self.topField animated:YES];
    } else if ([self.bottomField isFirstResponder]) {
        [self scrollToTextField:self.bottomField animated:YES];
    }
}

- (void)keyboardWillHide:(NSNotification *) notification
{
    
    //    NSLog(@"Firing keyboardWillHide");
    CGRect keyboardFrame = CGRectNull;
    //	CGFloat keyboardHeight = 0;
    double keyboardAnimDuration = 0;
    UIViewAnimationCurve keyboardCurve = UIViewAnimationCurveLinear;
    
    // 3.2 and above
    if (UIKeyboardFrameEndUserInfoKey) {		
        [[notification.userInfo valueForKey:UIKeyboardFrameEndUserInfoKey] getValue:&keyboardFrame];		
        [[notification.userInfo valueForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&keyboardAnimDuration];		
        [[notification.userInfo valueForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&keyboardCurve];		
        //        if (UIDeviceOrientationIsPortrait([[UIDevice currentDevice] orientation])) {
        //            keyboardHeight = keyboardFrame.size.height;
        //        } else {
        //            keyboardHeight = keyboardFrame.size.width;
        //        }
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
