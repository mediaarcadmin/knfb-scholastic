// 
//  SCHSyncEntity.m
//  Scholastic
//
//  Created by John S. Eddie on 31/01/2011.
//  Copyright 2011 BitWink Limited. All rights reserved.
//

#import "SCHSyncEntity.h"

#import "NSNumber+ObjectTypes.h"
#import "SCHLibreAccessConstants.h"

// Constants
NSString * const SCHSyncEntityState = @"State";
NSString * const SCHSyncEntityLastModified = @"LastModified";

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
        
        // Don't set the lastModified for any relationships
        // Our sync model assumes that relationships don't trigger the lastModified date being set
        NSArray *dictionaryNames = [[[self entity] relationshipsByName] allKeys];
        NSArray *changedValues = [[self changedValues] allKeys];
        __block BOOL setLastModified = NO;
        
        [changedValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (![dictionaryNames containsObject:obj]) {
                setLastModified = YES;
                *stop = YES;
            }
        }];
        
        if (setLastModified) {
            // we made modifications, record the change
            [self setPrimitiveLastModified:[NSDate date]];
            // only change the state if we arnt already doing so
            if ([[self changedValues] objectForKey:@"State"] == nil) {
                [self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusModified]];	
            }
        }
    }
}

- (void)syncDelete
{
    [self willChangeValueForKey:SCHSyncEntityLastModified];
    [self willChangeValueForKey:SCHSyncEntityState];
	[self setPrimitiveLastModified:[NSDate date]];
	[self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusDeleted]];		
    [self didChangeValueForKey:SCHSyncEntityState];
    [self didChangeValueForKey:SCHSyncEntityLastModified];
}

- (void)syncReset
{
    [self willChangeValueForKey:SCHSyncEntityLastModified];
    [self willChangeValueForKey:SCHSyncEntityState];
	[self setPrimitiveLastModified:[NSDate date]];
	[self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusUnmodified]];	
    [self didChangeValueForKey:SCHSyncEntityState];
    [self didChangeValueForKey:SCHSyncEntityLastModified];
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
