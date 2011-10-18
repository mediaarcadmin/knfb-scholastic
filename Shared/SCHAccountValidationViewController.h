//
//  SCHAccountValidationViewController.h
//  Scholastic
//
//  Created by Neil Gall on 21/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHBaseSetupViewController.h"

@protocol SCHSetupDelegete;

@interface SCHAccountValidationViewController : SCHBaseSetupViewController <UITextFieldDelegate> {}

@property (nonatomic, retain) IBOutlet UILabel *promptLabel;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIButton *validateButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView; // iPhone only

- (IBAction)validate:(id)sender;

@end
