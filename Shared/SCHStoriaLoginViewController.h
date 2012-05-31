//
//  SCHStoriaLoginViewController.h
//  Scholastic
//
//  Created by Matt Farrugia on 04/01/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SCHLoginHandlerDelegate.h"

@interface SCHStoriaLoginViewController : UIViewController <SCHLoginHandlerDelegate>

@property (nonatomic, copy) void (^loginBlock)(NSString *topFieldString, NSString *bottomFieldString);
@property (nonatomic, copy) dispatch_block_t previewBlock;

@property (nonatomic, retain) IBOutlet UILabel *topFieldLabel;
@property (nonatomic, retain) IBOutlet UITextField *topField;
@property (nonatomic, retain) IBOutlet UITextField *bottomField;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;
@property (nonatomic, retain) IBOutlet UIButton *previewButton;
@property (nonatomic, retain) IBOutlet UIActivityIndicatorView *spinner;
@property (nonatomic, retain) IBOutlet UILabel *promptLabel;
@property (nonatomic, retain) IBOutlet UIScrollView *scrollView;

- (IBAction)loginButtonAction:(id)sender;
- (IBAction)previewButtonAction:(id)sender;

@end