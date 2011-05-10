//
//  SCHPrivacyPolicyViewController.m
//  Scholastic
//
//  Created by Arnold Chien on 5/10/11.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPrivacyPolicyViewController.h"


@implementation SCHPrivacyPolicyViewController

#pragma mark -
#pragma mark View lifecycle

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Privacy Policy",@"\"Privacy Policy\" view controller title.");    
    NSString* privacyText = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/privacy.html"] encoding:NSUTF8StringEncoding error:NULL];
    NSString *resourcePath = [[[[NSBundle mainBundle] resourcePath]
                               stringByReplacingOccurrencesOfString:@"/" withString:@"//"]
                              stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    UIWebView* textView = [[UIWebView alloc] initWithFrame:[[UIScreen mainScreen] applicationFrame]];
    [textView loadHTMLString:privacyText baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"file:/%@//", resourcePath]]];
    [textView setScalesPageToFit:YES];
    self.view = textView;
    [textView release];
}
@end
