//
//  SCHBaseTextViewController.h
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHCustomToolbar;

@interface SCHBaseTextViewController : UIViewController {}

@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
@property (nonatomic, retain) IBOutlet UIWebView *textView;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topToolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *closeButton;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *spacer;
@property (nonatomic, retain) IBOutlet UIImageView *topShadow;

@property (nonatomic, assign) BOOL shouldHideCloseButton;

- (void)releaseViewObjects;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)toInterfaceOrientation;
- (IBAction)back:(id)sender;

@end
