//
//  SCHReadingStatsContentItem.m
//  Scholastic
//
//  Created by John S. Eddie on 06/07/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHReadingStatsContentItem.h"

// Constants
NSString * const kSCHReadingStatsContentItem = @"SCHReadingStatsContentItem";

NSString * const kSCHReadingStatsContentItemFetchReadingStatsContentItemForBook = @"fetchReadingStatsContentItemForBook";
NSString * const kSCHReadingStatsContentItemCONTENT_IDENTIFIER = @"CONTENT_IDENTIFIER";
NSString * const kSCHReadingStatsContentItemDRM_QUALIFIER = @"DRM_QUALIFIER";

@implementation SCHReadingStatsContentItem

@dynamic Format;
@dynamic ReadingStatsDetailItem;
@dynamic ReadingStatsEntryItem;

@end
