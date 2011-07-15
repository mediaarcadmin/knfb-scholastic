// 
//  SCHSyncEntity.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHSyncEntity.h"

#import "NSNumber+ObjectTypes.h"
#import "SCHLibreAccessWebService.h"

@interface SCHSyncEntity (CoreDataGeneratedPrimitiveAccessors)

- (NSDate *)primitiveLastModified;
- (void)setPrimitiveLastModified:(NSDate *)newDate;
- (NSNumber *)primitiveState;
- (void)setPrimitiveState:(NSNumber *)newState;

@end

@implementation SCHSyncEntity 

@dynamic LastModified;
@dynamic State;

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	
	[self setPrimitiveLastModified:[NSDate date]];
	[self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusCreated]];						
}

- (void)willSave
{
	[super willSave];

	if ([self.State isEqualToNumber:[NSNumber numberWithStatus:kSCHStatusSyncUpdate]] == YES) {
        // sync update modifications, don't record the change        
        [self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusUnmodified]];
	} else if (self.isInserted == NO && 
               [self.State isEqualToNumber:[NSNumber numberWithStatus:kSCHStatusDeleted]] == NO) {
        // we made modifications, record the change
        [self setPrimitiveLastModified:[NSDate date]];
        // only change the state if we arnt already doing so
        if ([[self changedValues] objectForKey:@"State"] == nil) {
            [self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusModified]];	
        }
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

- (NSNumber *)Action
{
	NSNumber *ret = nil;
	
	switch ([self.State statusValue]) {
		case kSCHStatusCreated:
			ret = [NSNumber numberWithSaveAction:kSCHSaveActionsCreate];
			break;
		case kSCHStatusModified:
			ret = [NSNumber numberWithSaveAction:kSCHSaveActionsUpdate];
			break;
		case kSCHStatusDeleted:
			ret = [NSNumber numberWithSaveAction:kSCHSaveActionsRemove];
			break;
		default:
			ret = [NSNumber numberWithSaveAction:kSCHSaveActionsNone];
			break;
	}
	
	return(ret);
}

@end
