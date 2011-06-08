//
//  SCHStoryInteractionDraggableView.h
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHStoryInteractionDraggableTargetView;

@interface SCHStoryInteractionDraggableView : UIView {}

// the offset from this view's true center to the point which should align with the target's center
@property (nonatomic, assign) CGPoint centerOffset;

// square of the minimum distance this view needs to be from a target in order to snap to it
@property (nonatomic, assign) CGFloat snapDistanceSq;

// The target this source is currently attached to
@property (nonatomic, assign) SCHStoryInteractionDraggableTargetView *attachedTarget;

// set the targets which this draggable can attach to
- (void)setDragTargets:(NSArray *)dragTargets;

@end
