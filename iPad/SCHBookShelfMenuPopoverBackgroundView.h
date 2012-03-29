//
//  SCHBookShelfMenuPopoverBackgroundView.h
//  Scholastic
//
//  Created by Gordon Christie on 26/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <UIKit/UIPopoverBackgroundView.h>

@interface SCHBookShelfMenuPopoverBackgroundView : UIPopoverBackgroundView

@property (nonatomic, assign) CGFloat arrowOffset;
@property (nonatomic, assign) UIPopoverArrowDirection arrowDirection;
@property (nonatomic, retain) UIImageView *arrowImageView;
@property (nonatomic, retain) UIImageView *popoverBackgroundImageView;

+ (CGFloat)arrowHeight;
+ (CGFloat)arrowBase;
+ (UIEdgeInsets)contentViewInsets;

@end
