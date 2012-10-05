//
//  SCHAboutViewController.h
//  Scholastic
//
//  Created by Arnold Chien on 5/5/11.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHAppController.h"

@interface SCHSupportViewController : UIViewController {}

@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIImageView *topBorderImageView;
@property (nonatomic, retain) IBOutlet UIImageView *bottomBorderImageView;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIView *shadowView;
@property (nonatomic, assign) id<SCHAppController> appController;

- (IBAction)back:(id)sender;

@end
