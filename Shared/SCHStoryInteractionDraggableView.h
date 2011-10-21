//
//  SCHStoryInteractionDraggableView.h
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHStoryInteractionDraggableView;

@protocol SCHStoryInteractionDraggableViewDelegate
@optional
- (BOOL)draggableViewShouldStartDrag:(SCHStoryInteractionDraggableView *)draggableView;
- (void)draggableViewWasTapped:(SCHStoryInteractionDraggableView *)draggableView;
@required
- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView;
- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition;
- (void)draggableView:(SCHStoryInteractionDraggableView *)draggableView didMoveToPosition:(CGPoint)position;
@end

@interface SCHStoryInteractionDraggableView : UIView {}

// a Tag that can be used to check draggables are attached to the correct target
@property (nonatomic, assign) NSInteger matchTag;

// optional delegate for this draggable
@property (nonatomic, assign) NSObject<SCHStoryInteractionDraggableViewDelegate> *delegate;

// an alternative transform to use when this view is being dragged. default is 10% zoom
@property (nonatomic, assign) CGAffineTransform dragTransform;

// an alternative transform to use when this view snaps into position. default is identity transform
@property (nonatomic, assign) CGAffineTransform snappedTransform;

// home position for this draggable
@property (nonatomic, assign) CGPoint homePosition;

// the correct position has been reached for this item - lock it in place
@property (nonatomic, assign) BOOL lockedInPlace;

// animate this draggable back to its home position
- (void)moveToHomePosition;

// animate this draggable back to its home position with a completion handler after the animation
- (void)moveToHomePositionWithCompletionHandler:(dispatch_block_t)completion;

// can be overridden in subclasses, but ensure super is called
- (void)beginDrag;
- (void)endDragWithTouch:(UITouch *)touch cancelled:(BOOL)cancelled;

@end
