//
//  SCHParentalToolsWebViewController.h
//  Scholastic
//
//  Created by John Eddie on 17/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "SCHBaseTextViewController.h"
#import "SCHModalPresenterDelegate.h"

@interface SCHParentalToolsWebViewController : SCHBaseTextViewController <UIWebViewDelegate>

@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) IBOutlet UIView *contentShadowMask;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *backgroundToolbar;
@property (nonatomic, retain) IBOutlet UIImageView *toolbarSettingsImageView;

@property (nonatomic, copy) NSString *pToken;
@property (nonatomic, assign) id<SCHModalPresenterDelegate> modalPresenterDelegate;
@property (nonatomic, assign) BOOL shouldHideToolbarSettingsImageView;

@end
