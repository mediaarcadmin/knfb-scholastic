//
//  SCHReadingStatsEntryItem.m
//  Scholastic
//
//  Created by John S. Eddie on 06/07/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHReadingStatsEntryItem.h"

#import "SCHReadingStatsContentItem.h"

extern NSString * const kSCHAuthenticationManagerDeviceKey;

@interface SCHReadingStatsEntryItem (CoreDataGeneratedPrimitiveAccessors)

- (NSDate *)primitiveTimestamp;
- (void)setPrimitiveTimestamp:(NSDate *)newDate;
- (NSMutableSet *)primitiveDictionaryLookupsList;
- (void)setPrimitiveDictionaryLookupsList:(NSMutableSet *)newSet;

@end

@implementation SCHReadingStatsEntryItem

@dynamic ReadingDuration;
@dynamic PagesRead;
@dynamic StoryInteractions;
@dynamic Timestamp;
@dynamic DictionaryLookupsList;
@dynamic ReadingStatsContentItem;

@dynamic DeviceKey;
@dynamic DictionaryLookups;

- (NSString *)DeviceKey
{
    [self willAccessValueForKey:@"DeviceKey"];
    NSString *ret = [[NSUserDefaults standardUserDefaults] stringForKey:kSCHAuthenticationManagerDeviceKey];	
    [self didAccessValueForKey:@"DeviceKey"];

    return(ret);
}

- (NSNumber *)DictionaryLookups
{
    [self willAccessValueForKey:@"DictionaryLookups"];
    NSNumber *ret = [NSNumber numberWithUnsignedInteger:[[self primitiveDictionaryLookupsList] count]];
    [self didAccessValueForKey:@"DictionaryLookups"];
    
    return(ret);
}

- (void)willSave
{
	[super willSave];
	
	if (self.isInserted == YES || self.isUpdated == YES) {
		[self setPrimitiveTimestamp:[NSDate date]];
	}
}

@end
