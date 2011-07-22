//
//  SCHDeregisterDeviceViewController.h
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHBaseSetupViewController.h"
#import "SCHDrmRegistrationSessionDelegate.h"

@protocol SCHSettingsViewControllerDelegate;

@interface SCHDeregisterDeviceViewController : SCHBaseSetupViewController <SCHDrmRegistrationSessionDelegate> {}

@property (nonatomic, retain) IBOutlet UILabel *promptLabel;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIButton *deregisterButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, assign) id<SCHSettingsViewControllerDelegate> settingsDelegate;

- (IBAction)back:(id)sender;
- (IBAction)deregister:(id)sender;
- (IBAction)forgotPassword:(id)sender;

@end
