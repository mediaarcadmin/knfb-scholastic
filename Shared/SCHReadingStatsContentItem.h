//
//  SCHReadingStatsContentItem.h
//  Scholastic
//
//  Created by John S. Eddie on 06/07/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

#import "SCHContentItem.h"

// Constants
extern NSString * const kSCHReadingStatsContentItem;

extern NSString * const kSCHReadingStatsContentItemFetchReadingStatsContentItemForBook;
extern NSString * const kSCHReadingStatsContentItemCONTENT_IDENTIFIER;
extern NSString * const kSCHReadingStatsContentItemDRM_QUALIFIER;

@interface SCHReadingStatsContentItem : SCHContentItem 
{
}

@property (nonatomic, retain) NSString * Format;
@property (nonatomic, retain) NSManagedObject * ReadingStatsDetailItem;
@property (nonatomic, retain) NSSet *ReadingStatsEntryItem;

@end
