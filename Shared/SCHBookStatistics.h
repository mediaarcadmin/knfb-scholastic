//
//  SCHBookStatistics.h
//  Scholastic
//
//  Created by John S. Eddie on 06/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@class SCHReadingStatsEntryItem;

@interface SCHBookStatistics : NSObject 
{    
}

- (id)initWithReadingStatsEntryItem:(SCHReadingStatsEntryItem *)aReadingStatsEntryItem;

- (void)increaseReadingDurationBy:(NSUInteger)durationInSeconds;
- (void)increasePagesReadBy:(NSUInteger)pages;
- (void)increaseStoryInteractionsBy:(NSUInteger)storyInteractions;
- (void)addToDictionaryLookup:(NSString *)word;

@end
