//
//  SCHBSBReplacedElementWebView.h
//  Scholastic
//
//  Created by Matt Farrugia on 10/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHBSBReplacedElementWebView : UIWebView <UIWebViewDelegate>

- (void)synchronouslyLoadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

@end
