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

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.title = NSLocalizedString(@"Web Parent Tools", @"\"Parental Tools\" view controller title.");        

    NSURL *webParentToolURL = [[SCHAuthenticationManager sharedAuthenticationManager] webParentToolURL];
    NSLog(@"Attempting to access Web Parent Tools using: %@", webParentToolURL);
    
    self.textView.delegate = self;
    [self.textView loadRequest:[NSURLRequest requestWithURL:webParentToolURL]];
    [self.textView setScalesPageToFit:YES];    
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
