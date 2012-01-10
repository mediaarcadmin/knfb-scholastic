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
@synthesize pToken;
@synthesize modalPresenterDelegate;

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
    [super releaseViewObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        
        [self.contentView.layer setCornerRadius:8];
        [self.contentView.layer setMasksToBounds:YES];
        [self.contentView.layer setBorderColor:[UIColor SCHRed3Color].CGColor];
        [self.contentView.layer setBorderWidth:2.0f];
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
        LambdaAlert *lambdaAlert = [[LambdaAlert alloc]
                            initWithTitle:NSLocalizedString(@"Error", @"")
                            message:NSLocalizedString(@"A problem occured accessing web parent tools with your account. Please contact support.", @"")];
        [lambdaAlert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            [self.modalPresenterDelegate dismissModalWebParentToolsWithSync:NO 
                                                             showValidation:NO];
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
