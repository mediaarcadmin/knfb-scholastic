//
//  SCHBookStoryInteractions.m
//  Scholastic
//
//  Created by Neil Gall on 01/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookStoryInteractions.h"
#import "SCHStoryInteraction.h"
#import "SCHStoryInteractionParser.h"
#import "SCHXPSProvider.h"
#import "KNFBXPSConstants.h"

@interface SCHBookStoryInteractions ()
@property (nonatomic, retain) NSArray *storyInteractions;
@property (nonatomic, retain) NSDictionary *storyInteractionsByPage;
@property (nonatomic, retain) NSMutableDictionary *storyInteractionCurrentCount;
@property (nonatomic, retain) NSMutableDictionary *storyInteractionsComplete;
@end

@implementation SCHBookStoryInteractions

@synthesize storyInteractions;
@synthesize storyInteractionsByPage;
@synthesize storyInteractionCurrentCount;
@synthesize storyInteractionsComplete;

- (void)dealloc
{
    [storyInteractions release];
    [storyInteractionsByPage release];
    [super dealloc];
}

- (id)initWithXPSProvider:(SCHXPSProvider *)xpsProvider
{
    if ((self = [super init])) {
        
        self.storyInteractionCurrentCount = [NSMutableDictionary dictionary];
        self.storyInteractionsComplete = [NSMutableDictionary dictionary];
        
        // get the raw array of stories from the parser
        NSData *xml = [xpsProvider dataForComponentAtPath:KNFBXPSStoryInteractionsMetadataFile];
        SCHStoryInteractionParser *parser = [[SCHStoryInteractionParser alloc] init];
        NSArray *all = [parser parseStoryInteractionsFromData:xml];
        [parser release];
        
        // only use valid story interactions
        all = [all filteredArrayUsingPredicate:[NSPredicate predicateWithFormat:@"isValid == YES"]];
        
        self.storyInteractions = [all sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
            return [(SCHStoryInteraction *)obj1 documentPageNumber] - [(SCHStoryInteraction *)obj2 documentPageNumber];
        }];
        
        // add reference to the Book Story Interactions object
        for (SCHStoryInteraction *interaction in self.storyInteractions) {
            interaction.bookStoryInteractions = self;
        }
        
        // organise by page
        NSMutableDictionary *byPage = [[NSMutableDictionary alloc] init];
        for (SCHStoryInteraction *story in self.storyInteractions) {
            NSNumber *page = [NSNumber numberWithInteger:story.documentPageNumber];
            NSMutableArray *pageArray = [byPage objectForKey:page];
            if (!pageArray) {
                pageArray = [NSMutableArray array];
                [byPage setObject:pageArray forKey:page];
            }
            [pageArray addObject:story];
            
            // set the current answered question count
            NSNumber *currentCount = [NSNumber numberWithInteger:0];
            [self.storyInteractionCurrentCount setObject:currentCount forKey:page];
            
            // set the complete flag to NO
            [self.storyInteractionsComplete setObject:[NSNumber numberWithBool:NO] forKey:page];
        }
        
        self.storyInteractionsByPage = [NSDictionary dictionaryWithDictionary:byPage];
        [byPage release];
    }
    return self;
}

- (NSArray *)allStoryInteractionsExcludingInteractionWithPage:(BOOL)excludeInteractionWithPage
{
    NSArray *unfiltered = self.storyInteractions;
    if (!excludeInteractionWithPage) {
        return unfiltered;
    }
    
    NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:[unfiltered count]];
    for (SCHStoryInteraction *si in unfiltered) {
        if (![si requiresInteractionWithPage]) {
            [filtered addObject:si];
        }
    }
    return filtered;
}

- (NSArray *)storyInteractionsForPage:(NSInteger)pageNumber
         excludingInteractionWithPage:(BOOL)excludeInteractionWithPage
{
    NSArray *unfiltered = [self.storyInteractionsByPage objectForKey:[NSNumber numberWithInteger:pageNumber]];
    if (!excludeInteractionWithPage) {
        return unfiltered;
    }
    
    NSMutableArray *filtered = [NSMutableArray arrayWithCapacity:[unfiltered count]];
    for (SCHStoryInteraction *si in unfiltered) {
        if (![si requiresInteractionWithPage]) {
            [filtered addObject:si];
        }
    }
    return filtered;
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

- (NSInteger)storyInteractionQuestionCountForPage:(NSInteger)pageNumber
{
    SCHStoryInteraction *interaction = [[self storyInteractionsForPage:pageNumber excludingInteractionWithPage:NO] objectAtIndex:0];
    
    if (interaction) {
        return [interaction questionCount];
    } else {
        return 0;
    }
}

#pragma mark - Interactions Complete methods

- (NSInteger)storyInteractionQuestionsCompletedForPage:(NSInteger)page
{
    int result = -1;
    
    NSNumber *count = [self.storyInteractionCurrentCount objectForKey:[NSNumber numberWithInteger:page]];
    
    if (count) {
        result = [count intValue];
    }
    
    //NSLog(@"Completed %d interactions for page %d", result, page);
    
    return result;
}

- (void)incrementStoryInteractionQuestionsCompletedForPage:(NSInteger)page
{
    NSNumber *count = [self.storyInteractionCurrentCount objectForKey:[NSNumber numberWithInteger:page]];
    
    if (!count) {
        NSLog(@"Warning: trying to increment count for a page that doesn't exist (%d).", page);
        return;
    }
    
    SCHStoryInteraction *interaction = [self.storyInteractionsByPage objectForKey:[NSNumber numberWithInteger:page]];
    
    if (!interaction) {
        NSLog(@"Warning: story interaction does not exist for page %d", page);
        return;
    }
    
    int questionCount = [[[self storyInteractionsForPage:page excludingInteractionWithPage:NO] objectAtIndex:0] questionCount];
    
    count = [NSNumber numberWithInteger:[count intValue] + 1];
    
    // if we've answered all the questions, set the interaction as complete
    if ([count intValue] >= questionCount) {
        count = [NSNumber numberWithInteger:0];
        [self.storyInteractionsComplete setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInt:page]];
    }
    
    [self.storyInteractionCurrentCount setObject:count forKey:[NSNumber numberWithInteger:page]];
    NSLog(@"Now completed %d interactions for page %d", [count intValue], page);
}

- (BOOL)storyInteractionsFinishedOnPage:(NSInteger)page
{
    return [[self.storyInteractionsComplete objectForKey:[NSNumber numberWithInt:page]] boolValue];
}

- (void)setStoryInteractionsFinishedForPage:(NSInteger)page
{
    [self.storyInteractionsComplete setObject:[NSNumber numberWithBool:YES] forKey:[NSNumber numberWithInt:page]];
}


@end