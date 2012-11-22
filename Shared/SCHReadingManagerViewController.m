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
#import "LambdaAlert.h"
#import "SCHReadingManagerCache.h"
#import "SCHReadingManagerSplashViewController.h"

@interface SCHReadingManagerViewController () <UIWebViewDelegate>

@property (nonatomic, retain) SCHReadingManagerSplashViewController *splashViewController;

- (void)releaseViewObjects;

@end

@implementation SCHReadingManagerViewController

@synthesize pToken;
@synthesize appController;
@synthesize splashViewController;

- (void)releaseViewObjects
{
    [splashViewController release], splashViewController = nil;
}

- (void)dealloc
{
    [self releaseViewObjects];
    
    [pToken release], pToken = nil;
    appController = nil;
    [super dealloc];
}

- (void)loadView
{
    UIWebView *webView = [[UIWebView alloc] init];
    self.view = webView;
    self.splashViewController = [[[SCHReadingManagerSplashViewController alloc] init] autorelease];
    self.splashViewController.view.frame = self.view.bounds;
    [webView addSubview:self.splashViewController.view];
    [webView release];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
#if DISABLE_READING_MANAGER_CACHING
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString* documentsDirectory = [paths objectAtIndex:0];
        NSString* diskCachePath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, @"webCache"];
        NSError* error;
        [[NSFileManager defaultManager] createDirectoryAtPath:diskCachePath withIntermediateDirectories:YES attributes:nil error:&error];
        SCHReadingManagerCache* readingManagerCache = [[SCHReadingManagerCache alloc] initWithMemoryCapacity:0 diskCapacity:0 diskPath:diskCachePath];
        [NSURLCache setSharedURLCache:readingManagerCache];
    });
#endif
    
    NSURL *webParentToolURL = [[SCHAuthenticationManager sharedAuthenticationManager] webParentToolURL:pToken];
    if (webParentToolURL != nil) {
        NSLog(@"Attempting to access the reading manager using: %@", webParentToolURL);
        
        UIWebView *webView = (UIWebView *)self.view;
        webView.delegate = self;
        [webView loadRequest:[NSURLRequest requestWithURL:webParentToolURL]];
        [webView setScalesPageToFit:YES];
        
        [self.navigationController setNavigationBarHidden:YES animated:NO];
                
        [self.appController waitForWebParentToolsToComplete];
    } else {
        LambdaAlert *lambdaAlert = [[LambdaAlert alloc]
                                    initWithTitle:NSLocalizedString(@"Error", @"")
                                    message:NSLocalizedString(@"A problem occured accessing the Reading Manager with your account. Please contact support.", @"")];
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
    [self releaseViewObjects];
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
    [self.appController exitReadingManager];
}

#pragma mark - UIWebView delegate methods

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request
 navigationType:(UIWebViewNavigationType)navigationType
{
    //NSLog(@"Request: %@",request);
    BOOL ret = YES;
    
        NSString *path = [[request URL] path];
        
        if ([path isEqualToString:@"/home"]) {
            ret = NO;
            
            [self back:nil];
        }
    
    return(ret);
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    // remove the splash now the page is loading
    if (self.splashViewController.view.hidden == NO) {
        [UIView animateWithDuration:0.2
                         animations:^{ self.splashViewController.view.alpha = 0.0; }
                         completion:^(BOOL finished) { self.splashViewController.view.hidden = YES; }];
    }
}

@end
