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

// The loginBlock should return NO to clear the fields and refocus on the top one
@property (nonatomic, copy) BOOL (^loginBlock)(NSString *topFieldString, NSString *bottomFieldString);
@property (nonatomic, copy) dispatch_block_t previewBlock;

@property (nonatomic, retain) IBOutlet UITextField *topField;
@property (nonatomic, retain) IBOutlet UITextField *bottomField;
@property (nonatomic, retain) IBOutlet UIButton *loginButton;

- (IBAction)loginButtonAction:(id)sender;
- (IBAction)previewButtonAction:(id)sender;

@end
