//
//  SCHStoryInteractionDraggableView.h
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHStoryInteractionDraggableTargetView;

@interface SCHStoryInteractionDraggableView : UIImageView {}

// a text label to display in the view
@property (nonatomic, copy) NSString *title;

// The target this source is currently attached to
@property (nonatomic, assign) SCHStoryInteractionDraggableTargetView *attachedTarget;

// set the targets which this draggable can attach to
- (void)setDragTargets:(NSArray *)dragTargets;

@end
