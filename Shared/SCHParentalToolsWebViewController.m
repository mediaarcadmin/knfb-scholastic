//
//  SCHParentalToolsWebViewController.m
//  Scholastic
//
//  Created by John Eddie on 17/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHParentalToolsWebViewController.h"

#import "SCHAuthenticationManager.h"
#import "NSURL+Extensions.h"
#import "SCHAccountValidationViewController.h"
#import "SCHSyncManager.h"
#import "LambdaAlert.h"

@implementation SCHParentalToolsWebViewController

@synthesize contentView;
@synthesize backgroundToolbar;
@synthesize toolbarSettingsImageView;
@synthesize pToken;
@synthesize modalPresenterDelegate;
@synthesize shouldHideToolbarSettingsImageView;

#pragma mark - View lifecycle

- (id)init
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        self = [super initWithNibName:@"SCHParentalToolsWebViewController_iPad" bundle:nil];
    } else {
        self = [super init];
    }
    
    return self;
}

- (void)dealloc 
{
    [self releaseViewObjects];
    [pToken release], pToken = nil;
    modalPresenterDelegate = nil;  
    [super dealloc];
}

- (void)releaseViewObjects
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIApplicationDidEnterBackgroundNotification 
                                                  object:nil];
    [contentView release], contentView = nil;
    [backgroundToolbar release], backgroundToolbar = nil;
    [toolbarSettingsImageView release], toolbarSettingsImageView = nil;
    [super releaseViewObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        [self.contentView.layer setShadowRadius:20];
        [self.contentView.layer setShadowOpacity:1];
        [self.contentView.layer setShadowOffset:CGSizeZero];
        [self.contentView.layer setCornerRadius:8];
        [self.contentView.layer setMasksToBounds:YES];
        [self.contentView.layer setBorderColor:[UIColor SCHRed3Color].CGColor];
        [self.contentView.layer setBorderWidth:2.0f];
        [self.backgroundToolbar setBackgroundImage:[UIImage imageNamed:@"settings-ipad-top-toolbar.png"]];
        [self.toolbarSettingsImageView setHidden:self.shouldHideToolbarSettingsImageView];
    }

    NSURL *webParentToolURL = [[SCHAuthenticationManager sharedAuthenticationManager] webParentToolURL:pToken];
    if (webParentToolURL != nil) {
        NSLog(@"Attempting to access Web Parent Tools using: %@", webParentToolURL);
        
        self.textView.delegate = self;
        [self.textView loadRequest:[NSURLRequest requestWithURL:webParentToolURL]];
        [self.textView setScalesPageToFit:YES];  
        
        // register for going into the background
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didEnterBackground:)
                                                     name:UIApplicationDidEnterBackgroundNotification
                                                   object:nil];    
        
        [self.modalPresenterDelegate waitingForWebParentToolsToComplete];
    } else {
        SCHParentalToolsWebViewController *weakSelf = self;
        LambdaAlert *lambdaAlert = [[LambdaAlert alloc]
                            initWithTitle:NSLocalizedString(@"Error", @"")
                            message:NSLocalizedString(@"A problem occured accessing web parent tools with your account. Please contact support.", @"")];
        [lambdaAlert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            [weakSelf.modalPresenterDelegate dismissModalWebParentToolsWithSync:NO showValidation:NO];
        }];
        [lambdaAlert show];
        [lambdaAlert release], lambdaAlert = nil;
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self releaseViewObjects];
}

#pragma mark - Action methods

- (void)back:(id)sender
{
    [self.modalPresenterDelegate dismissModalWebParentToolsWithSync:YES showValidation:NO];
}

- (void)requestPassword
{
    [self.modalPresenterDelegate dismissModalWebParentToolsWithSync:NO showValidation:YES];
}

#pragma mark - Notification methods

- (void)didEnterBackground:(NSNotification *)notification
{
    [self requestPassword];
}

#pragma mark - UIWebView delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType
{
    //NSLog(@"Request: %@",request);
    BOOL ret = YES;
    
    if (self.modalPresenterDelegate != nil) {
        NSDictionary *parameters = [[request URL] queryParameters];
        NSString *cmd = [parameters objectForKey:@"cmd"];
        
        if ([cmd isEqualToString:@"bookshelfSetupDidCompleteWithSuccess"] == YES) {
            ret = NO;
            
            [self.modalPresenterDelegate dismissModalWebParentToolsWithSync:YES showValidation:NO];
        }
    }
    
    return(ret);
}

@end
