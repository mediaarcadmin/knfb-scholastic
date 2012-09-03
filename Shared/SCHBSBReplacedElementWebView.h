//
//  SCHBSBReplacedElementWebView.h
//  Scholastic
//
//  Created by Matt Farrugia on 10/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHBSBReplacedElementWebView : UIWebView <UIWebViewDelegate>

// locations of the form js-bridge:selectorName or js-bridge:selectorName:stringParam will be messaged to the jsBridgeTarget
@property (nonatomic, assign) id jsBridgeTarget;

@end
