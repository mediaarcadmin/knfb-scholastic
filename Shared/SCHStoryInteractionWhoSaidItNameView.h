//
//  SCHStoryInteractionWhoSaidItNameView.h
//  Scholastic
//
//  Created by Neil Gall on 30/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionDraggableView.h"

@class SCHStoryInteractionDraggableTargetView;

@interface SCHStoryInteractionWhoSaidItNameView : SCHStoryInteractionDraggableView

@property (nonatomic, assign) SCHStoryInteractionDraggableTargetView *attachedTarget;

- (BOOL)attachedToCorrectTarget;

@end
