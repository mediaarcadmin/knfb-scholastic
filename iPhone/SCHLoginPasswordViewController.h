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
    // a login view - login and password fields
	kSCHControllerLoginView = 0,
    // a password only view - used for profile password
	kSCHControllerPasswordOnlyView,
    // a double password view - used for changing/setting profile password
	kSCHControllerDoublePasswordView,
    kSCHControllerParentToolsView
} SCHLoginViewControllerType;

// defining a block type for use in the block property
typedef void(^SCHActionBlock)(void);

@interface SCHLoginPasswordViewController : UIViewController <UITextFieldDelegate> 
{
    UIButton *footerForgotButton;
}

#pragma mark - Public Properties and Methods

// the type of controller - see above for types
@property (readwrite) SCHLoginViewControllerType controllerType;

// a block to be executed when performing the "Login" or "Go" action
@property (nonatomic, copy) SCHActionBlock actionBlock;

// a block to be executed when performing the "Cancel" action
@property (nonatomic, copy) SCHActionBlock cancelBlock;

// start and stop showing the progress indicator
- (void)startShowingProgress;
- (void)stopShowingProgress;

// clears the text fields
- (void)clearFields;

// username and password accessors
// consistent access over different modes
- (NSString *)username;
- (NSString *)password;

#pragma mark - Interface Builder

// Interface Builder
@property (nonatomic, retain) IBOutlet SCHCustomToolbar *topBar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *barSpacer;
@property (nonatomic, retain) IBOutlet UILabel *profileLabel;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UIView *containerView;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

@property (nonatomic, retain) IBOutlet UITextField *topField;
@property (nonatomic, retain) IBOutlet UITextField *bottomField;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;

// IBAction - the "Login" or "Go" button action
- (IBAction)actionButtonAction:(id)sender;

// IBAction - the Cancel action
- (IBAction)cancelButtonAction:(id)sender;

@end
