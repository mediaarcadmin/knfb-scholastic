//
//  SCHStoryInteractionControllerDelegate.h
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHStoryInteractionController;

@protocol SCHStoryInteractionControllerDelegate <NSObject>

@required

// a story interaction completed, with success indicator
- (void)storyInteractionController:(SCHStoryInteractionController *)storyInteractionController didDismissWithSuccess:(BOOL)success;

// for story interactions with different questions on each invocation, use this
// to determine the current question index
- (NSInteger)currentQuestionForStoryInteraction;

// has the current story interaction already been completed?
- (BOOL)storyInteractionFinished;

// get a snapshot of the current page
- (UIImage *)currentPageSnapshot;

@end
