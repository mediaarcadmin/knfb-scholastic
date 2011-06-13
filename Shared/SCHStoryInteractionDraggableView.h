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
@required
- (void)draggableViewDidStartDrag:(SCHStoryInteractionDraggableView *)draggableView;
- (BOOL)draggableView:(SCHStoryInteractionDraggableView *)draggableView shouldSnapFromPosition:(CGPoint)position toPosition:(CGPoint *)snapPosition;
- (void)draggableView:(SCHStoryInteractionDraggableView *)draggableView didMoveToPosition:(CGPoint)position;
@end

@interface SCHStoryInteractionDraggableView : UIView {}

// a Tag that can be used to check draggables are attached to the correct target
@property (nonatomic, assign) NSInteger matchTag;

// optional delegate for this draggable
@property (nonatomic, assign) id<SCHStoryInteractionDraggableViewDelegate> delegate;

// home position for this draggable
@property (nonatomic, assign) CGPoint homePosition;

- (void)moveToHomePosition;

@end
