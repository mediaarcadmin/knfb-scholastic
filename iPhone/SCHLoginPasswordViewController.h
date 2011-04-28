//
//  SCHLoginPasswordViewController.h
//  Scholastic
//
//  Created by John S. Eddie on 19/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@class SCHCustomToolbar;

typedef enum {
	kSCHControllerLoginView = 0,
	kSCHControllerPasswordOnlyView,
	kSCHControllerDoublePasswordView
} SCHLoginViewControllerType;

typedef void(^SCHActionBlock)(void);

@interface SCHLoginPasswordViewController : UIViewController <UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate> 
{
}

@property (readwrite) SCHLoginViewControllerType controllerType;
@property (nonatomic, copy) SCHActionBlock actionBlock;

// 
@property (nonatomic, retain) IBOutlet UITextField *userNameField;
@property (nonatomic, retain) IBOutlet UITextField *passwordField;
@property (nonatomic, retain) IBOutlet UIButton *cancelButton;
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topBar;
@property (nonatomic, retain) IBOutlet UIImageView *topShadow;
@property (nonatomic, retain) IBOutlet UILabel *headerTitleLabel;
@property (nonatomic, retain) IBOutlet UIView *headerTitleView;
@property (nonatomic, retain) IBOutlet UILabel *footerForgotLabel;
@property (nonatomic, retain) IBOutlet UITableView *tableView;

@property (nonatomic, retain)  UIActivityIndicatorView *spinner;

- (IBAction)actionButtonAction:(id)sender;
- (IBAction)cancel:(id)sender;

- (void)removeCancelButton;

- (void)startShowingProgress;
- (void)stopShowingProgress;

@end
