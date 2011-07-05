//
//  SCHBookStoryInteractions.h
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHXPSProvider;

@interface SCHBookStoryInteractions : NSObject {}

- (id)initWithXPSProvider:(SCHXPSProvider *)xpsProvider;

- (NSArray *)allStoryInteractionsExcludingInteractionWithPage:(BOOL)excludeInteractionWithPage;

- (NSArray *)storyInteractionsForPage:(NSInteger)pageNumber
         excludingInteractionWithPage:(BOOL)excludeInteractionWithPage;

- (NSArray *)storyInteractionsOfClass:(Class)storyInteractionClass;

- (NSInteger)storyInteractionQuestionCountForPage:(NSInteger)pageNumber;

// the total number of questions completed for a page
- (NSInteger)storyInteractionQuestionsCompletedForPage:(NSInteger)page;
- (void)incrementStoryInteractionQuestionsCompletedForPage:(NSInteger)page;

- (BOOL)storyInteractionsFinishedOnPage:(NSInteger)page;
- (void)setStoryInteractionsFinishedForPage:(NSInteger)page;

@end
