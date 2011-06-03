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

// if this draggable view snaps onto a SCHStoryInteractionDraggableTargetView in the
// view hierarchy, that target is returned here; else nil
- (SCHStoryInteractionDraggableTargetView *)target;

@end
