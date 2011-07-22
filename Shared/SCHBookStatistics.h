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

@property (nonatomic, assign, readonly) NSUInteger readingDuration;
@property (nonatomic, assign, readonly) NSUInteger pagesRead;
@property (nonatomic, assign, readonly) NSUInteger storyInteractions;
@property (nonatomic, retain) NSMutableSet *dictionaryLookupsList;

- (void)increaseReadingDurationBy:(NSUInteger)durationInSeconds;
- (void)increasePagesReadBy:(NSUInteger)pages;
- (void)increaseStoryInteractionsBy:(NSUInteger)newStoryInteractions;
- (void)addToDictionaryLookup:(NSString *)word;

@end
