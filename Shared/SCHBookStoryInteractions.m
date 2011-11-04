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
- (id)leftPageKeyForPageIndex:(NSInteger)pageIndex;
- (id)rightPageKeyForPageIndex:(NSInteger)pageIndex;
- (NSArray *)pageKeysForPageIndices:(NSRange)pageIndices;
- (NSArray *)pageKeysForStoryInteraction:(SCHStoryInteraction *)storyInteraction;
- (void)incrementQuestionsCompletedForPageKey:(id)pageKey questionCount:(NSInteger)questionCount;

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

- (id)leftPageKeyForPageIndex:(NSInteger)pageIndex
{
    if (self.oddPageIndicesAreLeftPages) {
        return [self pageKeyForPageIndex:((pageIndex-1) | 1)];
    } else {
        return [self pageKeyForPageIndex:(pageIndex & ~1)];
    }
}

- (id)rightPageKeyForPageIndex:(NSInteger)pageIndex
{
    if (self.oddPageIndicesAreLeftPages) {
        return [self pageKeyForPageIndex:((pageIndex+1) & ~1)];
    } else {
        return [self pageKeyForPageIndex:(pageIndex | 1)];
    }
}

- (NSArray *)pageKeysForStoryInteraction:(SCHStoryInteraction *)storyInteraction
{
    NSInteger pageIndex = storyInteraction.documentPageNumber-1;
    CGSize pageSize = delegate ? [delegate sizeOfPageAtIndex:pageIndex] : CGSizeZero;

    NSMutableArray *pageKeys = [NSMutableArray arrayWithCapacity:2];
    
    if ([storyInteraction hasQuestionsOnLeftPageForPageSize:pageSize]) {
        [pageKeys addObject:[self leftPageKeyForPageIndex:pageIndex]];
    }
    if ([storyInteraction hasQuestionsOnRightPageForPageSize:pageSize]) {
        [pageKeys addObject:[self rightPageKeyForPageIndex:pageIndex]];
    }
    // if the story interaction doesn't declare questions explicitly on the left/right pages,
    // they must all be on the declared page
    if ([pageKeys count] == 0) {
        [pageKeys addObject:[self pageKeyForPageIndex:pageIndex]];
    }
    
    return [NSArray arrayWithArray:pageKeys];
}

- (NSArray *)pageKeysForPageIndices:(NSRange)pageIndices
{
    if (pageIndices.length == 1) {
        return [NSArray arrayWithObject:[self pageKeyForPageIndex:pageIndices.location]];
    } else {
        NSMutableArray *pageKeys = [NSMutableArray arrayWithCapacity:pageIndices.length];
        for (NSInteger pageIndex = pageIndices.location, end = pageIndices.location+pageIndices.length; pageIndex < end; ++pageIndex) {
            [pageKeys addObject:[self pageKeyForPageIndex:pageIndex]];
        };
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
    NSInteger count = 0;
    
    NSArray *storyInteractionsOnPage = [self storyInteractionsForPageIndices:pageIndices excludingInteractionWithPage:NO];
    for (SCHStoryInteraction *storyInteraction in storyInteractionsOnPage) {
        NSInteger questionCount = [storyInteraction questionCount];
        if (pageIndices.length > 1) {
            count += questionCount;
        } else {
            CGSize pageSize = delegate ? [delegate sizeOfPageAtIndex:pageIndices.location] : CGSizeZero;
            for (NSInteger questionIndex = 0; questionIndex < questionCount; ++questionIndex) {
                switch ([storyInteraction pageAssociationForQuestionAtIndex:questionIndex withPageSize:pageSize]) {
                    case SCHStoryInteractionQuestionOnBothPages:
                        count++;
                        break;
                    case SCHStoryInteractionQuestionOnLeftPage:
                        if ([self isLeftPageIndex:pageIndices.location]) {
                            count++;
                        }
                        break;
                    case SCHStoryInteractionQuestionOnRightPage:
                        if (![self isLeftPageIndex:pageIndices.location]) {
                            count++;
                        }
                        break;
                }
            }
        }
    }
    
    return count;
}

#pragma mark - Interactions Complete methods

- (NSInteger)storyInteractionQuestionsCompletedForPageIndices:(NSRange)pageIndices
{
    NSInteger count = 0;
    
    for (id pageKey in [self pageKeysForPageIndices:pageIndices]) {
        NSNumber *countForPage = [self.storyInteractionsQuestionsCompletedCount objectForKey:pageKey];
        if (countForPage) {
            count += [countForPage integerValue];
        }
    }
    
    return count;
}

- (NSInteger)questionsCompletedForStoryInteraction:(SCHStoryInteraction *)storyInteraction
{
    NSInteger count = 0;
    
    for (id pageKey in [self pageKeysForStoryInteraction:storyInteraction]) {
        NSNumber *countForPage = [self.storyInteractionsQuestionsCompletedCount objectForKey:pageKey];
        if (countForPage) {
            count += [countForPage integerValue];
        }
    }
    
    return count;
}

- (BOOL)allQuestionsCompletedForPageIndices:(NSRange)pageIndices
{
    for (id pageKey in [self pageKeysForPageIndices:pageIndices]) {
        // ignore pages with no SIs
        if ([[self storyInteractionsForPageIndices:NSMakeRange([pageKey integerValue], 1) excludingInteractionWithPage:NO] count] == 0) {
            continue;
        }
        NSNumber *complete = [self.storyInteractionsComplete objectForKey:pageKey];
        if (!complete || ![complete boolValue]) {
            return NO;
        }
    }
    
    return YES;
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
    NSArray *storyInteractionPageKeys = [self pageKeysForStoryInteraction:storyInteraction];
    
    if ([storyInteractionPageKeys count] == 1) {
        // easy case, all this SI's questions are on one page
        [self incrementQuestionsCompletedForPageKey:[storyInteractionPageKeys objectAtIndex:0]
                                      questionCount:[storyInteraction questionCount]];

    } else if (pageIndices.length > 1) {
        // work out which page the last question was on, and update the score on that page only
        NSInteger questionIndex = [self storyInteractionQuestionsCompletedForPageIndices:pageIndices];
        CGSize pageSize = delegate ? [delegate sizeOfPageAtIndex:pageIndices.location] : CGSizeZero;
        enum SCHStoryInteractionQuestionPageAssociation pageAssociation = [storyInteraction pageAssociationForQuestionAtIndex:questionIndex withPageSize:pageSize];
        id pageKey = (pageAssociation == SCHStoryInteractionQuestionOnLeftPage) ? [self leftPageKeyForPageIndex:pageIndices.location] : [self rightPageKeyForPageIndex:pageIndices.location];
        NSInteger questionCount = [storyInteraction numberOfQuestionsWithPageAssociation:pageAssociation withPageSize:pageSize];
        [self incrementQuestionsCompletedForPageKey:pageKey questionCount:questionCount];

    } else {
        // single out the questions only on this page
        CGSize pageSize = delegate ? [delegate sizeOfPageAtIndex:pageIndices.location] : CGSizeZero;
        enum SCHStoryInteractionQuestionPageAssociation pageAssociation = ([self isLeftPageIndex:pageIndices.location]
                                                                           ? SCHStoryInteractionQuestionOnLeftPage
                                                                           : SCHStoryInteractionQuestionOnRightPage);
        NSInteger questionCount = [storyInteraction numberOfQuestionsWithPageAssociation:pageAssociation withPageSize:pageSize];
        id pageKey = [self pageKeyForPageIndex:pageIndices.location];
        [self incrementQuestionsCompletedForPageKey:pageKey questionCount:questionCount];
    }
}

- (void)incrementQuestionsCompletedForPageKey:(id)pageKey questionCount:(NSInteger)questionCount
{
    NSNumber *count = [self.storyInteractionsQuestionsCompletedCount objectForKey:pageKey];
    if (count == nil) {
        count = [NSNumber numberWithInteger:1];
    } else {
        count = [NSNumber numberWithInteger:[count integerValue]+1];
    }
    
    // if we've answered all the questions, set the interaction as complete
    if ([count integerValue] == questionCount) {
        [self.storyInteractionsComplete setObject:[NSNumber numberWithBool:YES] forKey:pageKey];
    }
    
    [self.storyInteractionsQuestionsCompletedCount setObject:count forKey:pageKey];
    
    NSLog(@"Now completed %d of %d interactions for page %@", [count intValue], questionCount, pageKey);
}


@end