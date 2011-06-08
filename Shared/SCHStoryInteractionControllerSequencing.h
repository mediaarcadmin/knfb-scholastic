//
//  SCHStoryInteractionControllerSequencing.h
//  Scholastic
//
//  Created by Neil Gall on 08/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHStoryInteractionController.h"

@class SCHStoryInteractionDraggableView;
@class SCHStoryInteractionDraggableTargetView;

@interface SCHStoryInteractionControllerSequencing : SCHStoryInteractionController {}

@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableView *imageContainer1;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableView *imageContainer2;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableView *imageContainer3;
@property (nonatomic, retain) IBOutlet UIImageView *imageView1;
@property (nonatomic, retain) IBOutlet UIImageView *imageView2;
@property (nonatomic, retain) IBOutlet UIImageView *imageView3;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableTargetView *target1;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableTargetView *target2;
@property (nonatomic, retain) IBOutlet SCHStoryInteractionDraggableTargetView *target3;

@end
