//
//  SCHBaseSetupViewController.h
//  Scholastic
//
//  Created by Neil Gall on 20/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SCHBaseSetupViewController : UIViewController {}

// set the appropriate button background for a setup screen button
- (void)setButtonBackground:(UIButton *)button;

// hook to 'back' button in toolbar
- (IBAction)back:(id)sender;


@end