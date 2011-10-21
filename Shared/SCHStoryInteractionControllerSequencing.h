//
//  SCHStoryInteractionControllerSequencing.h
//  Scholastic
//
//  Created by Neil Gall on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionController.h"
#import "SCHStoryInteractionDraggableView.h"

@class SCHStoryInteractionDraggableTargetView;

@interface SCHStoryInteractionControllerSequencing : SCHStoryInteractionController <SCHStoryInteractionDraggableViewDelegate> {}

@property (nonatomic, retain) IBOutletCollection(SCHStoryInteractionDraggableView) NSArray *imageContainers;
@property (nonatomic, retain) IBOutletCollection(UIImageView) NSArray *imageViews;
@property (nonatomic, retain) IBOutletCollection(SCHStoryInteractionDraggableTargetView) NSArray *targets;
@property (nonatomic, retain) IBOutletCollection(UILabel) NSArray *targetLabels;

@end
