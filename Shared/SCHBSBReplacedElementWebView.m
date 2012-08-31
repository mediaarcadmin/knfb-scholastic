//
//  SCHBSBReplacedElementWebView.m
//  Scholastic
//
//  Created by Matt Farrugia on 10/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElementWebView.h"

@implementation SCHBSBReplacedElementWebView

@synthesize jsBridgeTarget;

- (void)dealloc
{
    jsBridgeTarget = nil;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        if ([self respondsToSelector:@selector(scrollView)]) {
            UIScrollView *aScrollView = [self scrollView];
            [aScrollView setCanCancelContentTouches:NO];
            [aScrollView setBounces:NO];
            [aScrollView setScrollEnabled:NO];
        }
        
        self.delegate = self;
    }
    
    return self;
}

- (void)setDelegate:(id<UIWebViewDelegate>)delegate
{
    NSAssert(delegate == self, @"Cannot change SCHBSBReplacedElementWebView delegate");
    [super setDelegate:self];
}

- (void)synchronouslyLoadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    [self loadHTMLString:string baseURL:baseURL];
    CFRunLoopRunInMode((CFStringRef)NSDefaultRunLoopMode, 0.1, NO);
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    // Only required for iOS < 4.0
    [aScrollView setContentOffset: CGPointMake(aScrollView.contentOffset.x, 0)];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CFRunLoopRef runLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];
	CFRunLoopStop(runLoop);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    CFRunLoopRef runLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];
	CFRunLoopStop(runLoop);
}

- (BOOL)eucPageTurningViewShouldRenderPresentationLayer
{
    return NO;
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    NSString *requestString = [[request URL] absoluteString];
    
    // Intercept custom location change, URL begins with "js-bridge:"
    if ([requestString hasPrefix:@"js-bridge:"]) {
        
        // Extract the selector name from the URL
        NSArray *components = [requestString componentsSeparatedByString:@":"];
        if ([components count] > 1) {
            NSString *functionName = [components objectAtIndex:1];
            
            if (self.jsBridgeTarget) {
                if ([components count] > 2) {
                    NSString *selectorName = [functionName stringByAppendingString:@":"];
                    if ([self.jsBridgeTarget respondsToSelector:NSSelectorFromString(selectorName)]) {
                        [self.jsBridgeTarget performSelector:NSSelectorFromString(selectorName) withObject:[components objectAtIndex:2]];
                    }
                } else {
                    NSString *selectorName = functionName;
                    if ([self.jsBridgeTarget respondsToSelector:NSSelectorFromString(selectorName)]) {
                        [self.jsBridgeTarget performSelector:NSSelectorFromString(selectorName)];
                    }
                }
            }
            
            // Cancel the location change
            return NO;
        }
    }
    
    // Accept this location change
    return YES;
}


@end
