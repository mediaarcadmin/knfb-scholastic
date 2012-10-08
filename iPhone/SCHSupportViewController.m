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
@synthesize backButton;
@synthesize containerView;
@synthesize shadowView;
@synthesize appController;

- (void)releaseViewObjects
{
    [webView release], webView = nil;
    [topBorderImageView release], topBorderImageView = nil;
    [bottomBorderImageView release], bottomBorderImageView = nil;
    [backButton release], backButton = nil;
    [containerView release], containerView = nil;
    [shadowView release], shadowView = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    appController = nil;
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
    
    UIImage *backButtonImage = [[UIImage imageNamed:@"bookshelf_arrow_bttn_UNselected_3part"] stretchableImageWithLeftCapWidth:11 topCapHeight:0];
    [self.backButton setBackgroundImage:backButtonImage forState:UIControlStateNormal];
    
    self.shadowView.layer.shadowOpacity = 0.5f;
    self.shadowView.layer.shadowOffset = CGSizeMake(0, 0);
    self.shadowView.layer.shadowRadius = 4.0f;
    self.shadowView.layer.backgroundColor = [UIColor clearColor].CGColor;
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.cornerRadius = 10.0f;
    
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

- (void)back:(id)sender
{
    [self.appController presentSettings];
}

@end