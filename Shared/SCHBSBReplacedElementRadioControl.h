//
//  SCHBSBReplacedElementRadioControl.h
//  Scholastic
//
//  Created by Matt Farrugia on 06/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    SCHBSBReplacedElementRadioControlNoButton = -1   // button index for no selected button
};

@interface SCHBSBReplacedElementRadioControl : UIControl

- (id)initWithItems:(NSArray *)items; // items can be NSStrings. Control is automatically sized to fit content

- (void)setFont:(UIFont *)font;

- (void)setTitle:(NSString *)title forButtonAtIndex:(NSUInteger)index;
- (NSString *)titleForButtonAtIndex:(NSUInteger)index;
- (void)setEnabled:(BOOL)enabled forButtonAtIndex:(NSUInteger)index;
- (BOOL)isEnabledForButtonAtIndex:(NSUInteger)index;


@property (nonatomic,readonly, assign) NSUInteger numberOfButtons;

// Returns last segment pressed. default is SCHBSBReplacedElementRadioControlNoButton until a button is pressed
// the UIControlEventValueChanged action is invoked when the button changes via a user event. set to SCHBSBReplacedElementRadioControlNoButton to turn off selection
@property (nonatomic, assign) NSInteger selectedButtonIndex;

@end
