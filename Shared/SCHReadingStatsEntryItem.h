//
//  SCHReadingStatsEntryItem.h
//  Scholastic
//
//  Created by John S. Eddie on 06/07/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHReadingStatsContentItem;

// Constants
extern NSString * const kSCHReadingStatsEntryItem;

@interface SCHReadingStatsEntryItem : NSManagedObject 
{
}

@property (nonatomic, retain) NSNumber *ReadingDuration;
@property (nonatomic, retain) NSNumber *PagesRead;
@property (nonatomic, retain) NSNumber *StoryInteractions;
@property (nonatomic, retain) NSDate *Timestamp;
@property (nonatomic, retain) NSMutableSet *DictionaryLookupsList;
@property (nonatomic, retain) SCHReadingStatsContentItem *ReadingStatsContentItem;

@property (nonatomic, retain) NSString *DeviceKey;
@property (nonatomic, retain) NSNumber *DictionaryLookups;


@end
