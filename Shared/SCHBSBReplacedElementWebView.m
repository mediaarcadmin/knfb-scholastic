//
//  SCHBSBReplacedElementWebView.m
//  Scholastic
//
//  Created by Matt Farrugia on 10/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElementWebView.h"

@implementation SCHBSBReplacedElementWebView

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


@end
