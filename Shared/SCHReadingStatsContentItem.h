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

static NSString * const kSCHReadingStatsContentItem = @"SCHReadingStatsContentItem";

static NSString * const kSCHReadingStatsContentItemFetchReadingStatsContentItemForBook = @"fetchReadingStatsContentItemForBook";
static NSString * const kSCHReadingStatsContentItemCONTENT_IDENTIFIER = @"CONTENT_IDENTIFIER";;
static NSString * const kSCHReadingStatsContentItemDRM_QUALIFIER = @"DRM_QUALIFIER";


@interface SCHReadingStatsContentItem : SCHContentItem 
{
}

@property (nonatomic, retain) NSString * Format;
@property (nonatomic, retain) NSManagedObject * ReadingStatsDetailItem;
@property (nonatomic, retain) NSSet *ReadingStatsEntryItem;

@end
