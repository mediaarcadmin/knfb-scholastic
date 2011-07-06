//
//  SCHReadingStatsDetailItem.h
//  Scholastic
//
//  Created by John S. Eddie on 06/07/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class SCHReadingStatsContentItem;

static NSString * const kSCHReadingStatsDetailItem = @"SCHReadingStatsDetailItem";

@interface SCHReadingStatsDetailItem : NSManagedObject 
{
}

@property (nonatomic, retain) NSNumber *ProfileID;
@property (nonatomic, retain) NSSet *ReadingStatsContentItem;

@end
