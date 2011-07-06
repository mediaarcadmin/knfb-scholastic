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

- (void)increaseReadingDurationBy:(NSNumber *)duration
{
   self.readingStatsEntryItem.ReadingDuration = [NSNumber numberWithUnsignedInteger:
                                                 [self.readingStatsEntryItem.ReadingDuration unsignedIntegerValue] + 
    [duration unsignedIntegerValue]];
}

- (void)increasePagesReadBy:(NSNumber *)pages
{
    self.readingStatsEntryItem.PagesRead = [NSNumber numberWithUnsignedInteger:
                                                  [self.readingStatsEntryItem.PagesRead unsignedIntegerValue] + 
                                                  [pages unsignedIntegerValue]];
}

- (void)increaseStoryInteractionsBy:(NSNumber *)storyInteractions
{
    self.readingStatsEntryItem.StoryInteractions = [NSNumber numberWithUnsignedInteger:
                                            [self.readingStatsEntryItem.StoryInteractions unsignedIntegerValue] + 
                                            [storyInteractions unsignedIntegerValue]];
}

- (void)addToDictionaryLookup:(NSString *)word
{
    if (word != nil) {
        [self.readingStatsEntryItem.DictionaryLookupsList addObject:word];
    }
}

//@property (nonatomic, retain) NSString *DeviceKey;
//@property (nonatomic, retain) NSDate *Timestamp;

@end
