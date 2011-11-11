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

@synthesize pToken;
@synthesize profileSetupDelegate;

#pragma mark - View lifecycle

- (void)dealloc 
{
    [self releaseViewObjects];
    [pToken release], pToken = nil;
    profileSetupDelegate = nil;   
    [super dealloc];
}

- (void)releaseViewObjects
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIApplicationDidEnterBackgroundNotification 
                                                  object:nil];
    [super releaseViewObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Manage eBooks", @"\"Manage eBooks\" view controller title.");        

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
        
        [self.profileSetupDelegate waitingForWebParentToolsToComplete];
    } else {
        SCHParentalToolsWebViewController *weakSelf = self;
        LambdaAlert *lambdaAlert = [[LambdaAlert alloc]
                            initWithTitle:NSLocalizedString(@"Error", @"")
                            message:NSLocalizedString(@"A problem occured accessing web parent tools with your account. Please contact support.", @"")];
        [lambdaAlert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            [weakSelf backWithNoSync];
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

- (void)backWithNoSync
{    
    [super back:nil];
}

- (void)back:(id)sender
{
    // trigger a sync to grab any changes if we are in non-wizard mode, otherwise trigger web parent tools completed
    if (self.profileSetupDelegate != nil) {
        [self.profileSetupDelegate webParentToolsCompletedWithSuccess:NO];
    } else {
        [[SCHSyncManager sharedSyncManager] firstSync:YES requireDeviceAuthentication:YES];
    }
    

    [super back:nil];
}

- (void)requestPassword
{
    SCHAccountValidationViewController *accountValidationViewController = [[[SCHAccountValidationViewController alloc] init] autorelease];
    NSMutableArray *viewControllers = [NSMutableArray arrayWithArray:self.navigationController.viewControllers];
    
    accountValidationViewController.profileSetupDelegate = self.profileSetupDelegate;
    accountValidationViewController.validatedControllerShouldHideCloseButton = YES;
    
    [viewControllers insertObject:accountValidationViewController atIndex:[viewControllers indexOfObject:self]];     
    self.navigationController.viewControllers = [NSArray arrayWithArray:viewControllers];
    
    [self.profileSetupDelegate waitingForPassword];
    
    [super back:nil];
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
    
    if (self.profileSetupDelegate != nil) {
        NSDictionary *parameters = [[request URL] queryParameters];
        NSString *cmd = [parameters objectForKey:@"cmd"];
        
        if ([cmd isEqualToString:@"bookshelfSetupDidCompleteWithSuccess"] == YES) {
            ret = NO;
            
            [self.profileSetupDelegate webParentToolsCompletedWithSuccess:YES];
        }
    }
    
    return(ret);
}

@end
