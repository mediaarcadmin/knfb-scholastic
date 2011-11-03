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

@property (nonatomic, retain) NSArray *storyInteractions;
@property (nonatomic, retain) NSDictionary *storyInteractionsByPage;
@property (nonatomic, retain) NSMutableDictionary *storyInteractionsQuestionsCompletedCount;
@property (nonatomic, retain) NSMutableDictionary *storyInteractionsComplete;
@property (nonatomic, assign) BOOL oddPageIndicesAreLeftPages;

- (id)pageKeyForPageIndex:(NSInteger)pageIndex;
- (NSArray *)pageKeysForStoryInteraction:(SCHStoryInteraction *)storyInteraction;

@end

@implementation SCHBookStoryInteractions

@synthesize storyInteractions;
@synthesize storyInteractionsByPage;
@synthesize storyInteractionsQuestionsCompletedCount;
@synthesize storyInteractionsComplete;
@synthesize oddPageIndicesAreLeftPages;

- (void)dealloc
{
    [storyInteractions release], storyInteractions = nil;
    [storyInteractionsByPage release], storyInteractionsByPage = nil;
    [storyInteractionsQuestionsCompletedCount release], storyInteractionsQuestionsCompletedCount = nil;
    [storyInteractionsComplete release], storyInteractionsComplete = nil;
    [super dealloc];
}

- (id)initWithStoryInteractions:(NSArray *)aStoryInteractions oddPagesOnLeft:(BOOL)oddPagesOnLeft
{
    if ((self = [super init])) {
        
        self.oddPageIndicesAreLeftPages = oddPagesOnLeft;
        self.storyInteractionsQuestionsCompletedCount = [NSMutableDictionary dictionary];
        self.storyInteractionsComplete = [NSMutableDictionary dictionary];
                
        // only use valid story interactions
        NSArray *validStoryInteractions = [aStoryInteractions filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isValid == YES"]];
        
        self.storyInteractions = [validStoryInteractions sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(SCHStoryInteraction *)obj1 documentPageNumber] - [(SCHStoryInteraction *)obj2 documentPageNumber];
        }];
        
        // add reference to the Book Story Interactions object
        for (SCHStoryInteraction *interaction in self.storyInteractions) {
            interaction.bookStoryInteractions = self;
        }
        
        // organise by page
        NSMutableDictionary *byPage = [[NSMutableDictionary alloc] init];
        for (SCHStoryInteraction *story in self.storyInteractions) {
            for (id pageKey in [self pageKeysForStoryInteraction:story]) {
                NSMutableArray *pageArray = [byPage objectForKey:pageKey];
                if (!pageArray) {
                    pageArray = [NSMutableArray array];
                    [byPage setObject:pageArray forKey:pageKey];
                }
                [pageArray addObject:story];
            }
        }
        
        self.storyInteractionsByPage = [NSDictionary dictionaryWithDictionary:byPage];
        [byPage release];
    }
    return self;
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
    NSInteger questionsOnLeft = [storyInteraction numberOfQuestionsWithPageAssociation:SCHStoryInteractionQuestionOnLeftPage];
    NSInteger questionsOnRight = [storyInteraction numberOfQuestionsWithPageAssociation:SCHStoryInteractionQuestionOnRightPage];
    NSInteger quesitionsOnBoth = [storyInteraction numberOfQuestionsWithPageAssociation:SCHStoryInteractionQuestionOnBothPages];

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
    NSMutableArray *filtered = [NSMutableArray array];
    
    [self withEachPageInRange:pageIndices perform:^(NSInteger pageIndex) {
        NSArray *unfiltered = [self.storyInteractionsByPage objectForKey:[self pageKeyForPageIndex:pageIndex]];
        for (SCHStoryInteraction *si in unfiltered) {
            if (!(excludeInteractionWithPage && [si requiresInteractionWithPage]) && ![filtered containsObject:si]) {
                [filtered addObject:si];
            }
        }
    }];
    
    return [NSArray arrayWithArray:filtered];
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
        for (SCHStoryInteraction *storyInteraction in [self.storyInteractionsByPage objectForKey:[self pageKeyForPageIndex:pageIndex]]) {
            NSInteger allQuestions = [storyInteraction numberOfQuestionsWithPageAssociation:SCHStoryInteractionQuestionOnBothPages];
            NSInteger questionsOnLeft = [storyInteraction numberOfQuestionsWithPageAssociation:SCHStoryInteractionQuestionOnLeftPage];
            NSInteger questionsOnRight = [storyInteraction numberOfQuestionsWithPageAssociation:SCHStoryInteractionQuestionOnRightPage];
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
        if ([[self.storyInteractionsByPage objectForKey:pageKey] count] > 0) {
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
            NSInteger questionCount = [storyInteraction numberOfQuestionsWithPageAssociation:pageAssociation];
    
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