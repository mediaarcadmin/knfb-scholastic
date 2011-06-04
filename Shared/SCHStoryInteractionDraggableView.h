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

// set the targets which this draggable can attach to
- (void)setDragTargets:(NSArray *)dragTargets;

// flash green if this object's tag equals the attached target's tag, red if the tags
// do not match, and do nothing if this object is not attached to a target
- (void)flashCorrectness;

@end
