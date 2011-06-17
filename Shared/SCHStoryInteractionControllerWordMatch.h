//
//  SCHStoryInteractionControllerWordMatch.h
//  Scholastic
//
//  Created by Neil Gall on 17/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionController.h"
#import "SCHStoryInteractionDraggableView.h"

@class SCHStoryInteractionDraggableTargetView;

@interface SCHStoryInteractionControllerWordMatch : SCHStoryInteractionController <SCHStoryInteractionDraggableViewDelegate> {}

@property (nonatomic, retain) IBOutletCollection(SCHStoryInteractionDraggableView) NSArray *wordViews;
@property (nonatomic, retain) IBOutletCollection(SCHStoryInteractionDraggableTargetView) NSArray *targetViews;
@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray *imageViews;

@end
