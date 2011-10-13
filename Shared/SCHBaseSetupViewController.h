//
//  SCHBaseSetupViewController.h
//  Scholastic
//
//  Created by Neil Gall on 20/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHCustomToolbar;
@protocol SCHSetupDelegate; 

@interface SCHBaseSetupViewController : UIViewController {}

@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topToolbar;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *barSpacer;
@property (nonatomic, assign) id<SCHSetupDelegate> setupDelegate;

// set the appropriate button background for a setup screen button
- (void)setButtonBackground:(UIButton *)button;

// hook to 'back' button in toolbar; default behaviour pops the navigation controller
- (IBAction)back:(id)sender;
- (void)setEnablesBackButton:(BOOL)enablesBackButton;

// close the entire settings dialog
- (IBAction)closeSettings;

- (void)releaseViewObjects;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
