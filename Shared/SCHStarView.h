//
//  SCHStarView.h
//  Scholastic
//
//  Created by Neil Gall on 22/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface SCHStarView : UIView {}

@property (nonatomic, retain) UIColor *fillColor;
@property (nonatomic, retain) UIColor *borderColor;
@property (nonatomic, assign) CGPoint targetPoint;

// to be called from within an animation block
- (void)animateToTargetPoint;

@end
