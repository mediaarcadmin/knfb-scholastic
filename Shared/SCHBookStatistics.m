//
//  SCHBookStatistics.m
//  Scholastic
//
//  Created by John S. Eddie on 06/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookStatistics.h"

#import "SCHLibreAccessConstants.h"

@interface SCHBookStatistics ()

@property (nonatomic, assign) NSUInteger readingDuration;
@property (nonatomic, assign) NSUInteger pagesRead;
@property (nonatomic, assign) NSUInteger storyInteractions;

@end

@implementation SCHBookStatistics

@synthesize readingDuration;
@synthesize pagesRead;
@synthesize storyInteractions;
@synthesize dictionaryLookupsList;
@synthesize quizResultsList;

#pragma mark - Object lifecycle

- (id)init
{
    self = [super init];
    if (self) {
        dictionaryLookupsList = [[NSMutableSet alloc] init];
        quizResultsList = [[NSMutableSet alloc] init];
    }
    return(self); 
}

- (void)dealloc 
{
    [dictionaryLookupsList release], dictionaryLookupsList = nil;
    [quizResultsList release], quizResultsList = nil;
    
    [super dealloc];
}

- (BOOL)hasStatistics
{
    return(self.pagesRead > 0 || 
           self.storyInteractions > 0 ||
           [self.dictionaryLookupsList count] > 0);
}

#pragma mark - Accessor methods

- (void)increaseReadingDurationBy:(NSUInteger)durationInSeconds
{
    //NSLog(@"increaseReadingDurationBy %d", durationInSeconds);
   
    self.readingDuration += durationInSeconds;
}

- (void)increasePagesReadBy:(NSUInteger)pages
{
    //NSLog(@"increasePagesReadBy %d", pages);

    self.pagesRead += pages;
}

- (void)increaseStoryInteractionsBy:(NSUInteger)newStoryInteractions
{
    //NSLog(@"increaseStoryInteractionsBy %d", storyInteractions);

    self.storyInteractions += newStoryInteractions;
}

- (void)addToDictionaryLookup:(NSString *)word
{
    //NSLog(@"addToDictionaryLookup %@", word);

    if ([[word stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
        [self.dictionaryLookupsList addObject:word];
    }
}

- (void)addQuizTrialsItemScore:(int)score total:(int)total
{
    NSDictionary *quizTrialsItem = [NSDictionary dictionaryWithObjectsAndKeys:
                                    [NSNumber numberWithInteger:score], kSCHLibreAccessWebServiceQuizScore,
                                    [NSNumber numberWithInteger:total], kSCHLibreAccessWebServiceQuizTotal,
                                    nil];
    
    [self.quizResultsList addObject:quizTrialsItem];
}

@end
