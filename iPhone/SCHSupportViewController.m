//
//  SCHAboutViewController.m
//  Scholastic
//
//  Created by Arnold Chien on 5/5/11.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSupportViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface SCHSupportViewController() <UIWebViewDelegate>

- (void)releaseViewObjects;

@end

@implementation SCHSupportViewController


#pragma mark -
#pragma mark View lifecycle

@synthesize webView;
@synthesize topBorderImageView;
@synthesize bottomBorderImageView;

- (void)releaseViewObjects
{
    [webView release], webView = nil;
    [topBorderImageView release], topBorderImageView = nil;
    [bottomBorderImageView release], bottomBorderImageView = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    [super dealloc];
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    [self releaseViewObjects];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UIImage *topImage = [[UIImage imageNamed:@"support-panel-top"] stretchableImageWithLeftCapWidth:12 topCapHeight:12];
    UIImage *bottomImage = [[UIImage imageNamed:@"support-panel-bottom"] stretchableImageWithLeftCapWidth:12 topCapHeight:0];
    [self.topBorderImageView setImage:topImage];
    [self.bottomBorderImageView setImage:bottomImage];
    
    // Get the marketing version from Info.plist.
    NSString *version = (NSString*)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    NSString *buildnum = (NSString*)[[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    NSString *versionText = [NSString stringWithFormat:@"<p><center style=font-family:arial;font-size:35px;><i>Version</i> %@ (%@)</center><center style=font-family:arial;font-size:30px;>&copy; Scholastic Inc.  All rights reserved.</center></p>",version, buildnum];
    
    NSString *creditsText = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/credits.html"] encoding:NSUTF8StringEncoding error:NULL];
    
    NSString *privacyText = [NSString stringWithContentsOfFile:[[[NSBundle mainBundle] resourcePath] stringByAppendingString:@"/privacy.html"] encoding:NSUTF8StringEncoding error:NULL];
    
    NSString *supportText = [NSString stringWithFormat:@"%@%@%@", versionText, creditsText, privacyText];
        
    NSString *resourcePath = [[[[NSBundle mainBundle] resourcePath]
                               stringByReplacingOccurrencesOfString:@"/" withString:@"//"]
                              stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    
    [self.webView loadHTMLString:supportText baseURL:[NSURL URLWithString:[NSString stringWithFormat:@"file:/%@//", resourcePath]]];
    [self.webView setScalesPageToFit:YES];
    
    [self.webView setDelegate:self];
    
    if ([self.webView respondsToSelector:@selector(scrollView)]) {
        [[self.webView scrollView] setIndicatorStyle:UIScrollViewIndicatorStyleBlack];
    }
}

- (BOOL)webView:(UIWebView *)inWeb shouldStartLoadWithRequest:(NSURLRequest *)inRequest navigationType:(UIWebViewNavigationType)inType
{
    if (inType == UIWebViewNavigationTypeLinkClicked ) {
        NSString *scheme = [[inRequest URL] scheme];
        
        if ([scheme isEqualToString:@"http"] || [scheme isEqualToString:@"mailto"]) {
            [[UIApplication sharedApplication] openURL:[inRequest URL]];
            return NO;
        }
    }
    
    return YES;
}

@end