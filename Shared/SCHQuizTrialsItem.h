//
//  SCHQuizTrialsItem.h
//  Scholastic
//
//  Created by John S. Eddie on 05/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

// Constants
NSString * const kSCHQuizTrialsItem = @"SCHQuizTrialsItem";

@class SCHReadingStatsEntryItem;

@interface SCHQuizTrialsItem : NSManagedObject

@property (nonatomic, retain) NSNumber * quizScore;
@property (nonatomic, retain) NSNumber * quizTotal;
@property (nonatomic, retain) SCHReadingStatsEntryItem *readingStatsEntryItem;

@end
