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

@implementation SCHParentalToolsWebViewController

@synthesize pToken;

#pragma mark - View lifecycle

- (void)dealloc 
{
    [self releaseViewObjects];
    [pToken release], pToken = nil;
    
    [super dealloc];
}

- (void)releaseViewObjects
{
    [[NSNotificationCenter defaultCenter] removeObserver:self 
                                                    name:UIApplicationDidBecomeActiveNotification 
                                                  object:nil];
    [super releaseViewObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Web Parent Tools", @"\"Parental Tools\" view controller title.");        

    NSURL *webParentToolURL = [[SCHAuthenticationManager sharedAuthenticationManager] webParentToolURL:pToken];
    NSLog(@"Attempting to access Web Parent Tools using: %@", webParentToolURL);
    
    self.textView.delegate = self;
    [self.textView loadRequest:[NSURLRequest requestWithURL:webParentToolURL]];
    [self.textView setScalesPageToFit:YES];  
    
    // register for going into the background
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(willResignActiveNotification:)
                                                 name:UIApplicationWillResignActiveNotification
                                               object:nil];            
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    [self releaseViewObjects];
}

#pragma mark - Notification methods

- (void)willResignActiveNotification:(NSNotification *)notification
{
    [self back:nil];
}

#pragma mark - UIWebView delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request 
 navigationType:(UIWebViewNavigationType)navigationType
{
    BOOL ret = YES;
    
//    if (navigationType == UIWebViewNavigationTypeLinkClicked) {
//        NSDictionary *parameters = [[request URL] queryParameters];
//        NSString *cmd = [parameters objectForKey:@"cmd"];
//        
//        if ([cmd isEqualToString:@"bookshelfSetupDidCompleteWithSuccess"] == YES) {
//            ret = NO;
//            [self.setupDelegate dismissSettingsForm];
//        }
//    }
    
    return(ret);
}

@end
