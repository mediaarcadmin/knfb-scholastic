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

// a story interaction is about to complete, with success indicator
- (void)storyInteractionController:(SCHStoryInteractionController *)storyInteractionController willDismissWithSuccess:(BOOL)success;

// story interaction has now been dismissed
- (void)storyInteractionControllerDidDismiss:(SCHStoryInteractionController *)storyInteractionController;

// for story interactions with different questions on each invocation, use this
// to determine the current question index
- (NSInteger)currentQuestionForStoryInteraction;

// has the current story interaction already been completed?
- (BOOL)storyInteractionFinished;

// get a snapshot of the current page
- (UIImage *)currentPageSnapshot;

// transform to convert view coordinates to page coordinates
- (CGAffineTransform)viewToPageTransform;

@end
