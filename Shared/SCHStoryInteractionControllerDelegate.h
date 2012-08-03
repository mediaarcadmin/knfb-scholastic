//
//  SCHStoryInteractionControllerDelegate.h
//  Scholastic
//
//  Created by Neil Gall on 02/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHStoryInteractionController;
@class SCHAppBook;

@protocol SCHStoryInteractionControllerDelegate <NSObject>

@required

// a story interaction is about to complete, with success indicator
- (void)storyInteractionController:(SCHStoryInteractionController *)storyInteractionController willDismissWithSuccess:(BOOL)success;

// story interaction has now been dismissed
- (void)storyInteractionControllerDidDismiss:(SCHStoryInteractionController *)storyInteractionController;

// for story interactions with different questions on each invocation, use this
// to determine the current question index
- (NSInteger)currentQuestionForStoryInteraction;

// advance to the next question for the current pages
- (void)advanceToNextQuestionForStoryInteraction;

// has the current story interaction already been completed?
- (BOOL)storyInteractionFinished;

// get a snapshot of the current page
- (UIImage *)currentPageSnapshot;

// get the size of a book page in page coordinates
- (CGSize)sizeOfPageAtIndex:(NSInteger)pageIndex;

// transform to convert view coordinates to page coordinates
- (CGAffineTransform)viewToPageTransform;

// should this be displayed as an older story interaction
- (BOOL)isOlderStoryInteraction;

// The SI Cache directory for the current SI
- (NSString *)storyInteractionCacheDirectory;

@end
