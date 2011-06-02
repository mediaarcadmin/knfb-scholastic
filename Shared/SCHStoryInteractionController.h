//
//  SCHStoryInteractionController.h
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHStoryInteraction;

// Because Story Interactions have a non-modal behaviour in the reading view, StoryInteractionController 
// is not a UIViewController but relies on ReadingViewController to host its view. 

@interface SCHStoryInteractionController : NSObject {}

@property (nonatomic, readonly) SCHStoryInteraction *storyInteraction;

// obtain a Controller for a StoryInteraction.
+ (SCHStoryInteractionController *)storyInteractionControllerForStoryInteraction:(SCHStoryInteraction *)storyInteraction;

- (id)initWithStoryInteraction:(SCHStoryInteraction *)storyInteraction;

- (void)presentInHostView:(UIView *)hostView;
- (void)removeFromHostView;

#pragma mark - subclass overrides

- (void)setupView;

@end
