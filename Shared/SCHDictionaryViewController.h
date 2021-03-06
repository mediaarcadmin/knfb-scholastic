//
//  SCHDictionaryViewController.h
//  Scholastic
//
//  Created by Gordon Christie on 24/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHCustomToolbar;

@interface SCHDictionaryViewController : UIViewController <UIWebViewDelegate> {
    
    UIImageView *topShadow;
    UIView *leftBarButtonItemContainer;
    UIView *notFoundView;
}

@property (nonatomic, retain) NSString *categoryMode;
@property (nonatomic, retain) NSString *word;

@property (nonatomic, retain) IBOutlet UIImageView *topShadow;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topBar;
@property (nonatomic, retain) IBOutlet UIView *contentView;
@property (nonatomic, retain) IBOutlet UIView *notFoundView;
@property (nonatomic, retain) IBOutlet UIWebView *webView;
@property (nonatomic, retain) IBOutlet UIView *downloadProgressView;

@property (nonatomic, retain) IBOutlet UIProgressView *progressBar;
@property (nonatomic, retain) IBOutlet UILabel *bottomLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (nonatomic, retain) IBOutlet UIView *leftBarButtonItemContainer;
@property (nonatomic, retain) IBOutlet UIButton *audioButton;
@property (nonatomic, retain) IBOutlet UIButton *downloadDictionaryButton;

- (IBAction) playWord;
- (IBAction)downloadDictionary:(id)sender;

@end
