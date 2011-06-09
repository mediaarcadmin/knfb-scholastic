//
//  SCHStoryInteractionDraggableView.h
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHStoryInteractionDraggableView;
@class SCHStoryInteractionDraggableTargetView;

@protocol SCHStoryInteractionDraggableViewDelegate
@required
- (void)draggableView:(SCHStoryInteractionDraggableView *)draggable didAttachToTarget:(SCHStoryInteractionDraggableTargetView *)target;
@end

@interface SCHStoryInteractionDraggableView : UIView {}

// a Tag that can be used to check draggables are attached to the correct target
@property (nonatomic, assign) NSInteger matchTag;

// the offset from this view's true center to the point which should align with the target's center
@property (nonatomic, assign) CGPoint centerOffset;

// square of the minimum distance this view needs to be from a target in order to snap to it
@property (nonatomic, assign) CGFloat snapDistanceSq;

// The target this source is currently attached to
@property (nonatomic, assign) SCHStoryInteractionDraggableTargetView *attachedTarget;

// optional delegate for this draggable
@property (nonatomic, assign) id<SCHStoryInteractionDraggableViewDelegate> delegate;

// set the targets which this draggable can attach to
- (void)setDragTargets:(NSArray *)dragTargets;

// send this draggable back to its original position
- (void)moveToOriginalPosition;

@end
