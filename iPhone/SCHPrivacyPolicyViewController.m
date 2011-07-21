//
//  SCHPrivacyPolicyViewController.m
//  Scholastic
//
//  Created by Arnold Chien on 5/10/11.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPrivacyPolicyViewController.h"

@implementation SCHPrivacyPolicyViewController

- (void)viewDidLoad 
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Privacy Policy",@"\"Privacy Policy\" view controller title.");    
    
    NSString* privacyText = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/privacy.html"] encoding:NSUTF8StringEncoding error:NULL];
    NSString *resourcePath = [[[[NSBundle mainBundle] resourcePath]
                               stringByReplacingOccurrencesOfString:@"/" withString:@"//"]
                              stringByReplacingOccurrencesOfString:@" " withString:@"%20"];

    [self.textView loadHTMLString:privacyText baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"file:/%@//", resourcePath]]];
    [self.textView setScalesPageToFit:YES];
}

@end
