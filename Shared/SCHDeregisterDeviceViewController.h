//
//  SCHDeregisterDeviceViewController.h
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHAppController.h"

@class SCHSettingsViewController;

@interface SCHDeregisterDeviceViewController : UIViewController {}

@property (nonatomic, assign) id <SCHAppController> appController;
@property (nonatomic, assign) SCHSettingsViewController *settingsViewController;
@property (nonatomic, retain) IBOutlet UILabel *promptLabel;
@property (nonatomic, retain) IBOutlet UILabel *info1Label;
@property (nonatomic, retain) IBOutlet UILabel *info2Label;
//@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIButton *deregisterButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UIButton *backButton;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIView *shadowView;
@property (nonatomic, retain) IBOutlet UIView *transformableView;

- (IBAction)deregister:(id)sender;
- (IBAction)close:(id)sender;

@end
