//
//  SCHParentalToolsWebViewController.h
//  Scholastic
//
//  Created by John Eddie on 17/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCHBaseTextViewController.h"
#import "SCHProfileSetupDelegate.h"

@interface SCHParentalToolsWebViewController : SCHBaseTextViewController <UIWebViewDelegate>

@property (nonatomic, copy) NSString *pToken;
@property (nonatomic, assign) id<SCHProfileSetupDelegate> profileSetupDelegate;

- (void)backWithNoSync;

@end
