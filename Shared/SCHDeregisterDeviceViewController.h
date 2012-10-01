//
//  SCHDeregisterDeviceViewController.h
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHAppController.h"

@interface SCHDeregisterDeviceViewController : UIViewController {}

@property (nonatomic, assign) id <SCHAppController> appController;
@property (nonatomic, retain) IBOutlet UILabel *promptLabel;
@property (nonatomic, retain) IBOutlet UILabel *info1Label;
@property (nonatomic, retain) IBOutlet UILabel *info2Label;
@property (nonatomic, retain) IBOutlet UITextField *usernameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIButton *deregisterButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;

- (IBAction)deregister:(id)sender;

@end
