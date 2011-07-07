//
//  SCHBookStatistics.m
//  Scholastic
//
//  Created by John S. Eddie on 06/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBookStatistics.h"

#import "SCHReadingStatsEntryItem.h"

@interface SCHBookStatistics ()

@property (nonatomic, retain) SCHReadingStatsEntryItem *readingStatsEntryItem;

@end

@implementation SCHBookStatistics

@synthesize readingStatsEntryItem;

#pragma mark - Object lifecycle

- (id)initWithReadingStatsEntryItem:(SCHReadingStatsEntryItem *)aReadingStatsEntryItem
{
    self = [super init];
    if (self) {
        readingStatsEntryItem = [aReadingStatsEntryItem retain];
    }
    return(self); 
}

- (void)dealloc 
{
    [readingStatsEntryItem release], readingStatsEntryItem = nil;
    
    [super dealloc];
}

#pragma mark - Accessor methods

- (void)increaseReadingDurationBy:(NSUInteger)durationInSeconds
{
    self.readingStatsEntryItem.ReadingDuration = [NSNumber numberWithUnsignedInteger:
                                                  [self.readingStatsEntryItem.ReadingDuration unsignedIntegerValue] + 
                                                  durationInSeconds];
}

- (void)increasePagesReadBy:(NSUInteger)pages
{
    self.readingStatsEntryItem.PagesRead = [NSNumber numberWithUnsignedInteger:
                                            [self.readingStatsEntryItem.PagesRead unsignedIntegerValue] + 
                                            pages];
}

- (void)increaseStoryInteractionsBy:(NSUInteger)storyInteractions
{
    self.readingStatsEntryItem.StoryInteractions = [NSNumber numberWithUnsignedInteger:
                                                    [self.readingStatsEntryItem.StoryInteractions unsignedIntegerValue] + 
                                                    storyInteractions];
}

- (void)addToDictionaryLookup:(NSString *)word
{
    if (word != nil) {
        if (self.readingStatsEntryItem.DictionaryLookupsList == nil) {
            self.readingStatsEntryItem.DictionaryLookupsList = [NSMutableSet set];
        }
        [self.readingStatsEntryItem.DictionaryLookupsList addObject:word];
    }
}

@end
