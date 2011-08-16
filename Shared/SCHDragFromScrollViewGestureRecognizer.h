//
//  DragFromTableGestureRecognizer.h
//  ScrollerTest
//
//  Created by Neil Gall on 01/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SCHDragFromScrollViewGestureRecognizer : UIPanGestureRecognizer

// the view (a superview of the scrollview) in which drags are contained
@property (nonatomic, retain) UIView *dragContainerView;

@end
