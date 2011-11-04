//
//  SCHBookStoryInteractions.m
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookStoryInteractions.h"
#import "SCHStoryInteraction.h"

@interface SCHBookStoryInteractions ()

@property (nonatomic, retain) NSMutableDictionary *storyInteractionsQuestionsCompletedCount;
@property (nonatomic, retain) NSMutableDictionary *storyInteractionsComplete;

- (id)pageKeyForPageIndex:(NSInteger)pageIndex;
- (NSArray *)pageKeysForStoryInteraction:(SCHStoryInteraction *)storyInteraction;

@end

@implementation SCHBookStoryInteractions

@synthesize delegate;
@synthesize storyInteractions;
@synthesize storyInteractionsQuestionsCompletedCount;
@synthesize storyInteractionsComplete;
@synthesize oddPageIndicesAreLeftPages;

- (void)dealloc
{
    [storyInteractions release], storyInteractions = nil;
    [storyInteractionsQuestionsCompletedCount release], storyInteractionsQuestionsCompletedCount = nil;
    [storyInteractionsComplete release], storyInteractionsComplete = nil;
    [super dealloc];
}

- (void)setStoryInteractions:(NSArray *)aStoryInteractions
{
    if (aStoryInteractions == storyInteractions) {
        return;
    }
    [storyInteractions release];
    
    self.storyInteractionsQuestionsCompletedCount = [NSMutableDictionary dictionary];
    self.storyInteractionsComplete = [NSMutableDictionary dictionary];
    
    // only use valid story interactions
    NSArray *validStoryInteractions = [aStoryInteractions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isValid == YES"]];
    
    storyInteractions = [[validStoryInteractions sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        return [(SCHStoryInteraction *)obj1 documentPageNumber] - [(SCHStoryInteraction *)obj2 documentPageNumber];
    }] retain];
    
    // add reference to the Book Story Interactions object
    for (SCHStoryInteraction *interaction in self.storyInteractions) {
        interaction.bookStoryInteractions = self;
    }
}

- (BOOL)isLeftPageIndex:(NSInteger)pageIndex
{
    return self.oddPageIndicesAreLeftPages == ((pageIndex & 1) == 1);
}

- (id)pageKeyForPageIndex:(NSInteger)pageIndex
{
    return [NSNumber numberWithInteger:pageIndex];
}

- (NSArray *)pageKeysForStoryInteraction:(SCHStoryInteraction *)storyInteraction
{
    NSInteger pageIndex = storyInteraction.documentPageNumber-1;
    CGSize pageSize = delegate ? [delegate sizeOfPageAtIndex:pageIndex] : CGSizeZero;
    NSInteger questionsOnLeft = [storyInteraction numberOfQuestionsWithPageAssociation:SCHStoryInteractionQuestionOnLeftPage withPageSize:pageSize];
    NSInteger questionsOnRight = [storyInteraction numberOfQuestionsWithPageAssociation:SCHStoryInteractionQuestionOnRightPage withPageSize:pageSize];
    NSInteger quesitionsOnBoth = [storyInteraction numberOfQuestionsWithPageAssociation:SCHStoryInteractionQuestionOnBothPages withPageSize:pageSize];

    if (questionsOnLeft != quesitionsOnBoth || questionsOnRight != quesitionsOnBoth) {
        NSMutableArray *pageKeys = [NSMutableArray array];
        NSInteger leftPageIndex, rightPageIndex;
        if (self.oddPageIndicesAreLeftPages) {
            leftPageIndex = (pageIndex & 1) ? pageIndex : pageIndex-1;
            rightPageIndex = (pageIndex & 1) ? pageIndex+1 : pageIndex;
        } else {
            leftPageIndex = (pageIndex & 1) ? pageIndex-1 : pageIndex;
            rightPageIndex = (pageIndex & 1) ? pageIndex : pageIndex+1;
        }
        if (questionsOnLeft > 0) {
            [pageKeys addObject:[NSNumber numberWithInteger:leftPageIndex]];
        }
        if (questionsOnRight > 0) {
            [pageKeys addObject:[NSNumber numberWithInteger:rightPageIndex]];
        }
        return [NSArray arrayWithArray:pageKeys];
    } else {
        return [NSArray arrayWithObject:[NSNumber numberWithInteger:pageIndex]];
    }
}

- (void)withEachPageInRange:(NSRange)pageIndices perform:(void(^)(NSInteger pageIndex))block
{
    for (NSInteger pageIndex = pageIndices.location, end = pageIndices.location+pageIndices.length; pageIndex < end; ++pageIndex) {
        block(pageIndex);
    }
}

- (NSArray *)pageKeysForPageIndices:(NSRange)pageIndices
{
    if (pageIndices.length == 1) {
        return [NSArray arrayWithObject:[self pageKeyForPageIndex:pageIndices.location]];
    } else {
        NSMutableArray *pageKeys = [NSMutableArray array];
        [self withEachPageInRange:pageIndices perform:^(NSInteger pageIndex) {
            [pageKeys addObject:[self pageKeyForPageIndex:pageIndex]];
        }];
        return [NSArray arrayWithArray:pageKeys];
    }
}

- (NSArray *)allStoryInteractionsExcludingInteractionWithPage:(BOOL)excludeInteractionWithPage
{
    NSArray *unfiltered = self.storyInteractions;
    if (!excludeInteractionWithPage) {
        return unfiltered;
    }
    
    NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:[unfiltered count]];
    for (SCHStoryInteraction *si in unfiltered) {
        if (![si requiresInteractionWithPage] && ![filtered containsObject:si]) {
            [filtered addObject:si];
        }
    }
    return filtered;
}

- (NSArray *)storyInteractionsForPageIndices:(NSRange)pageIndices
         excludingInteractionWithPage:(BOOL)excludeInteractionWithPage
{
    NSMutableArray *found = [NSMutableArray array];
    NSArray *requestedPageKeys = [self pageKeysForPageIndices:pageIndices];
    
    for (SCHStoryInteraction *storyInteraction in self.storyInteractions) {
        if (excludeInteractionWithPage && [storyInteraction requiresInteractionWithPage]) {
            continue;
        }
        if ([found containsObject:storyInteraction]) {
            continue;
        }
        for (id pageKey in [self pageKeysForStoryInteraction:storyInteraction]) {
            if ([requestedPageKeys containsObject:pageKey]) {
                [found addObject:storyInteraction];
                break;
            }
        }
    }
    
    return [NSArray arrayWithArray:found];
}

- (NSArray *)storyInteractionsOfClass:(Class)storyInteractionClass
{
    NSMutableArray *result = [NSMutableArray array];
    for (SCHStoryInteraction *si in self.storyInteractions) {
        if ([si isKindOfClass:storyInteractionClass]) {
            [result addObject:si];
        }
    }
    return [NSArray arrayWithArray:result];
}

- (NSInteger)storyInteractionQuestionCountForPageIndices:(NSRange)pageIndices
{
    __block NSInteger count = 0;
    
    [self withEachPageInRange:pageIndices perform:^(NSInteger pageIndex) {
        NSArray *storyInteractionsOnPage = [self storyInteractionsForPageIndices:NSMakeRange(pageIndex, 1) excludingInteractionWithPage:NO];
        for (SCHStoryInteraction *storyInteraction in storyInteractionsOnPage) {
            CGSize pageSize = delegate ? [delegate sizeOfPageAtIndex:pageIndex] : CGSizeZero;
            NSInteger allQuestions = [storyInteraction numberOfQuestionsWithPageAssociation:SCHStoryInteractionQuestionOnBothPages withPageSize:pageSize];
            NSInteger questionsOnLeft = [storyInteraction numberOfQuestionsWithPageAssociation:SCHStoryInteractionQuestionOnLeftPage withPageSize:pageSize];
            NSInteger questionsOnRight = [storyInteraction numberOfQuestionsWithPageAssociation:SCHStoryInteractionQuestionOnRightPage withPageSize:pageSize];
            if (questionsOnLeft != allQuestions || questionsOnRight != allQuestions) {
                count += [self isLeftPageIndex:pageIndex] ? questionsOnLeft : questionsOnRight;
            } else {
                count += allQuestions;
            }
        }
    }];
    
    return count;
}

#pragma mark - Interactions Complete methods

- (NSInteger)storyInteractionQuestionsCompletedForPageIndices:(NSRange)pageIndices
{
    __block NSInteger count = 0;
    
    [self withEachPageInRange:pageIndices perform:^(NSInteger pageIndex) {
        NSNumber *countForPage = [self.storyInteractionsQuestionsCompletedCount objectForKey:[self pageKeyForPageIndex:pageIndex]];
        if (countForPage) {
            count += [countForPage integerValue];
        }
    }];
    
    return count;
}

- (BOOL)allQuestionsCompletedForPageIndices:(NSRange)pageIndices
{
    __block BOOL allCompleted = YES;
    
    [self withEachPageInRange:pageIndices perform:^(NSInteger pageIndex) {
        NSNumber *pageKey = [self pageKeyForPageIndex:pageIndex];
        if ([[self storyInteractionsForPageIndices:NSMakeRange(pageIndex, 1) excludingInteractionWithPage:NO] count] > 0) {
            NSNumber *complete = [self.storyInteractionsComplete objectForKey:pageKey];
            if (!complete || ![complete boolValue]) {
                allCompleted = NO;
            }
        }
    }];
    
    return allCompleted;
}

- (BOOL)allQuestionsCompletedForStoryInteraction:(SCHStoryInteraction *)storyInteraction
{
    for (id pageKey in [self pageKeysForStoryInteraction:storyInteraction]) {
        NSNumber *complete = [self.storyInteractionsComplete objectForKey:pageKey];
        if (!complete || ![complete boolValue]) {
            return NO;
        }
    }
    return YES;
}

- (void)incrementQuestionsCompletedForStoryInteraction:(SCHStoryInteraction *)storyInteraction
                                           pageIndices:(NSRange)pageIndices
{
    // update the page at the intersection of the story interaction page keys and the page indices page keys
    NSArray *storyInteractionPageKeys = [self pageKeysForStoryInteraction:storyInteraction];
    [self withEachPageInRange:pageIndices perform:^(NSInteger pageIndex) {
        id pageKey = [self pageKeyForPageIndex:pageIndex];
        if ([storyInteractionPageKeys containsObject:pageKey]) {
            NSNumber *count = [self.storyInteractionsQuestionsCompletedCount objectForKey:pageKey];
            if (count == nil) {
                count = [NSNumber numberWithInteger:1];
            } else {
                count = [NSNumber numberWithInteger:[count integerValue]+1];
            }

            enum SCHStoryInteractionQuestionPageAssociation pageAssociation = ([self isLeftPageIndex:pageIndex]
                                                                               ? SCHStoryInteractionQuestionOnLeftPage
                                                                               : SCHStoryInteractionQuestionOnRightPage);
            CGSize pageSize = delegate ? [delegate sizeOfPageAtIndex:pageIndex] : CGSizeZero;
            NSInteger questionCount = [storyInteraction numberOfQuestionsWithPageAssociation:pageAssociation withPageSize:pageSize];
    
            // if we've answered all the questions, set the interaction as complete
            if ([count integerValue] == questionCount) {
                [self.storyInteractionsComplete setObject:[NSNumber numberWithBool:YES] forKey:pageKey];
            }
    
            [self.storyInteractionsQuestionsCompletedCount setObject:count forKey:pageKey];

            NSLog(@"Now completed %d or %d interactions for page %@", [count intValue], questionCount, pageKey);
        }
    }];
}


@end