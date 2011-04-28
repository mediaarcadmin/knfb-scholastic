//
//  SCHLoginViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 19/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHCustomToolbar;

typedef void(^LoginBlock)(void);

@interface SCHLoginViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> 
{
}

@property (readwrite) BOOL showHeaders;
@property (readwrite) BOOL passwordOnly;
@property (nonatomic, copy) LoginBlock actionBlock;
@property (nonatomic, copy) NSString *loginButtonText;

@property (nonatomic, retain) IBOutlet UITextField *userNameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topBar;
@property (nonatomic, retain) IBOutlet UIImageView *topShadow;
@property (nonatomic, retain) IBOutlet UILabel *headerTitleLabel;
@property (nonatomic, retain) IBOutlet UIView *headerTitleView;
@property (nonatomic, retain) IBOutlet UILabel *footerForgotLabel;
@property (nonatomic, retain) IBOutlet UITableView *tableView;


- (IBAction)login:(id)sender;
- (IBAction)cancel:(id)sender;

- (void)removeCancelButton;

@end
