//
//  SCHLoginViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 19/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHCustomToolbar;

@interface SCHLoginViewController : UIViewController <UITextFieldDelegate> 
{
}

@property (nonatomic, retain) IBOutlet UITextField *userName;
@property (nonatomic, retain) IBOutlet UITextField *password;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topBar;

- (IBAction)login:(id)sender;
- (IBAction)cancel:(id)sender;

- (void)removeCancelButton;

@end
