//
//  SCHReadingManagerViewController.m
//  Scholastic
//
//  Created by Matt Farrugia on 14/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHReadingManagerViewController.h"
#import "SCHAuthenticationManager.h"
#import "NSURL+Extensions.h"
#import "SCHReadingManagerAuthorisationViewController.h"
#import "SCHSyncManager.h"
#import "LambdaAlert.h"

@interface SCHReadingManagerViewController () <UIWebViewDelegate>

@end

@implementation SCHReadingManagerViewController

@synthesize pToken;
@synthesize appController;

- (void)dealloc
{
    [pToken release], pToken = nil;
    appController = nil;
    [super dealloc];
}

- (void)loadView
{
    UIWebView *webView = [[UIWebView alloc] init];
    self.view = webView;
    [webView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSURL *webParentToolURL = [[SCHAuthenticationManager sharedAuthenticationManager] webParentToolURL:pToken];
    if (webParentToolURL != nil) {
        NSLog(@"Attempting to access Web Parent Tools using: %@", webParentToolURL);
        
        UIWebView *webView = (UIWebView *)self.view;
        webView.delegate = self;
        [webView loadRequest:[NSURLRequest requestWithURL:webParentToolURL]];
        [webView setScalesPageToFit:YES];
        
        [self.navigationController setNavigationBarHidden:YES animated:NO];
        
        UIButton *close = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [close setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin];
        [close addTarget:self action:@selector(back:) forControlEvents:UIControlEventTouchUpInside];
        [close setTitle:@"Client Close" forState:UIControlStateNormal];
        [close setFrame:CGRectMake(CGRectGetWidth(self.view.bounds) - 137, 7, 130, 30)];
        [self.view addSubview:close];
        
        [self.appController waitForWebParentToolsToComplete];
    } else {
        LambdaAlert *lambdaAlert = [[LambdaAlert alloc]
                                    initWithTitle:NSLocalizedString(@"Error", @"")
                                    message:NSLocalizedString(@"A problem occured accessing web Parent Tools with your account. Please contact support.", @"")];
        [lambdaAlert addButtonWithTitle:NSLocalizedString(@"OK", @"") block:^{
            [self.appController presentSettings];
        }];
        [lambdaAlert show];
        [lambdaAlert release], lambdaAlert = nil;
	}
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        return UIInterfaceOrientationIsLandscape(interfaceOrientation);
    } else {
        return (interfaceOrientation == UIInterfaceOrientationPortrait);
    }
}

- (void)back:(id)sender
{
    [self.appController presentSettings];
}

#pragma mark - UIWebView delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    //NSLog(@"Request: %@",request);
    BOOL ret = YES;
    
        NSDictionary *parameters = [[request URL] queryParameters];
        NSString *cmd = [parameters objectForKey:@"cmd"];
        
        if ([cmd isEqualToString:@"bookshelfSetupDidCompleteWithSuccess"] == YES) {
            ret = NO;
            
            [self.appController presentSettings];
        }    
    return(ret);
}

@end
