//
//  SCHBaseSetupViewController.h
//  Scholastic
//
//  Created by Neil Gall on 20/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHSettingsDelegate.h"
#import "SCHProfileSetupDelegate.h"

@class SCHCustomToolbar;
@protocol SCHModalPresenterDelegate; 

@interface SCHBaseModalViewController : UIViewController {}

@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topToolbar;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIImageView *backgroundView;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *barSpacer;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *backButton;
@property (nonatomic, assign) id<SCHSettingsDelegate> settingsDelegate; // Mutually excludes profileSetupDelegate. Both cannot be set.
@property (nonatomic, assign) id<SCHProfileSetupDelegate> profileSetupDelegate; // Mutually excludes settingsDelegate. Both cannot be set.


// set the appropriate button background for a setup screen button
- (void)setButtonBackground:(UIButton *)button;

// hook to 'back' button in toolbar; default behaviour pops the navigation controller
- (IBAction)back:(id)sender;
- (void)setEnablesBackButton:(BOOL)enablesBackButton;

// close the entire settings dialog
- (IBAction)close;

- (void)releaseViewObjects;
- (void)setupAssetsForOrientation:(UIInterfaceOrientation)toInterfaceOrientation;

@end
