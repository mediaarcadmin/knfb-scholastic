//
//  SCHBSBReplacedElementDropdownControl.h
//  Scholastic
//
//  Created by Matt Farrugia on 10/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

enum {
    SCHBSBReplacedElementDropdownControlNoItem = -1   // item index for no selected item
};

@interface SCHBSBReplacedElementDropdownControl : UIControl

- (id)initWithFont:(UIFont *)font width:(CGFloat)width items:(NSArray *)items; // items can be NSStrings. Control is automatically sized to fit content in width

- (void)setTitle:(NSString *)title forItemAtIndex:(NSUInteger)index;
- (NSString *)titleForItemAtIndex:(NSUInteger)index;

@property (nonatomic, readonly, assign) NSUInteger numberOfItems;

// Returns last segment pressed. default is SCHBSBReplacedElementDropdownControlNoItem until a button is pressed
// the UIControlEventValueChanged action is invoked when the button changes via a user event. set to SCHBSBReplacedElementDropdownControlNoItem to turn off selection
@property (nonatomic, assign) NSInteger selectedItemIndex;

+ (CGSize)sizeWithFont:(UIFont *)font forWidth:(CGFloat)width items:(NSArray *)items;

@end
