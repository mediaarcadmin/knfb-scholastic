//
//  SCHBookStoryInteractions.h
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SCHBookStoryInteractionsDelegate.h"

@class SCHStoryInteraction;

@interface SCHBookStoryInteractions : NSObject {}

@property (nonatomic, assign) BOOL oddPageIndicesAreLeftPages;
@property (nonatomic, retain) NSArray *storyInteractions;
@property (nonatomic, assign) id<SCHBookStoryInteractionsDelegate> delegate;

- (NSArray *)allStoryInteractionsExcludingInteractionWithPage:(BOOL)excludeInteractionWithPage;

- (NSArray *)storyInteractionsForPageIndices:(NSRange)pageIndices
                excludingInteractionWithPage:(BOOL)excludeInteractionWithPage;

- (NSArray *)storyInteractionsOfClass:(Class)storyInteractionClass;

- (NSInteger)storyInteractionQuestionCountForPageIndices:(NSRange)pageIndices;

// the total number of questions completed for a page range
- (NSInteger)storyInteractionQuestionsCompletedForPageIndices:(NSRange)pageIndices;

// the index of the next question to be asked for a page range
- (NSInteger)storyInteractionQuestionIndexForPageIndices:(NSRange)pageIndices;

// increment the completed count for a story interaction; when all the questions have been
// completed, this wraps to 0 and allQuestionsCompletedForStoryInteraction will subsequently
// return YES
- (void)incrementQuestionsCompletedForStoryInteraction:(SCHStoryInteraction *)storyInteraction
                                           pageIndices:(NSRange)pageIndices;

// increment the question index without incrementing the completed count
- (void)incrementQuestionIndexForPageIndices:(NSRange)pageIndices;

// have all questions in the story interactions in this page range been completed at least once?
- (BOOL)allQuestionsCompletedForPageIndices:(NSRange)pageIndices;

// have all the questions been completed for a given story interaction
- (BOOL)allQuestionsCompletedForStoryInteraction:(SCHStoryInteraction *)storyInteraction;

@end
