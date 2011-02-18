//
//  SCHSyncEntity+Extensions.m
//  Scholastic
//
//  Created by John S. Eddie on 17/01/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSyncEntity+Extensions.h"

#import "NSNumber+ObjectTypes.h"

@interface SCHSyncEntity (CoreDataGeneratedPrimitiveAccessors)

- (NSDate *)primitiveLastModified;
- (void)setPrimitiveLastModified:(NSDate *)newDate;
- (NSNumber *)primitiveState;
- (void)setPrimitiveState:(NSNumber *)newState;

@end

@implementation SCHSyncEntity (SCHSyncEntityExtensions)

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	
	[self setPrimitiveLastModified:[NSDate date]];
	[self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusCreated]];						
}

- (void)willSave
{
	[super willSave];
	
	if (self.isInserted == NO && [self.State isEqualToNumber:[NSNumber numberWithStatus:kSCHStatusDeleted]] == NO) {
		[self setPrimitiveLastModified:[NSDate date]];
		[self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusModified]];	
	}
}

- (void)syncDelete
{
	[self setPrimitiveLastModified:[NSDate date]];
	[self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusDeleted]];					
}

- (void)syncReset
{
	[self setPrimitiveLastModified:[NSDate date]];
	[self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusUnmodified]];					
}

@end
