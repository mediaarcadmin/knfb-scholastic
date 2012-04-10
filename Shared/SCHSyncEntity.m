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
#import "NSDate+ServerDate.h"

// Constants
NSString * const SCHSyncEntityState = @"State";
NSString * const SCHSyncEntityLastModified = @"LastModified";

@interface SCHSyncEntity (CoreDataGeneratedPrimitiveAccessors)

- (NSDate *)primitiveLastModified;
- (void)setPrimitiveLastModified:(NSDate *)newDate;
- (NSNumber *)primitiveState;
- (void)setPrimitiveState:(NSNumber *)newState;

- (BOOL)shouldResetStateFromSync;
- (BOOL)shouldSetAsModified;

@end

@implementation SCHSyncEntity 

@dynamic LastModified;
@dynamic State;

- (void)awakeFromInsert
{
	[super awakeFromInsert];
	
	[self setPrimitiveLastModified:[NSDate serverDate]];
	[self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusCreated]];						
}

- (void)willSave
{
	[super willSave];
    
	if ([self shouldResetStateFromSync] == YES) {
        // the sync has made changes reset the state for use
        [self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusUnmodified]];
	} else if ([self shouldSetAsModified] == YES) {
        // record user changes were made by setting lastModified and State
        [self setPrimitiveLastModified:[NSDate serverDate]];
        // never change the state from CREATED as the sync would never inform
        // the server to create it and do not stamp on an existing State change
        if ([self.State isEqualToNumber:[NSNumber numberWithStatus:kSCHStatusCreated]] == NO &&
            [[self changedValues] objectForKey:@"State"] == nil) {
            [self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusModified]];	
        }        
    }
}

- (BOOL)shouldResetStateFromSync
{
    return [self.State isEqualToNumber:[NSNumber numberWithStatus:kSCHStatusSyncUpdate]] == YES;
}

- (BOOL)shouldSetAsModified
{
    BOOL ret = YES;
    
    if (self.isInserted == YES) {
        // It's just been created so no need to set to modified
        ret = NO;
    } else if ([self.State isEqualToNumber:[NSNumber numberWithStatus:kSCHStatusDeleted]] == YES) {
        // It's being deleted so no need to set to modified
        ret = NO;
    } else {
        // If there are only relationship changes no need to set to modified
        // If we did we'd signal unnecessary syncing
        if ([[self changedValues] count] > 0) {
            NSArray *changedValues = [[self changedValues] allKeys];
            NSArray *dictionaryNames = [[[self entity] relationshipsByName] allKeys];    
            __block BOOL setLastModified = NO;
            [changedValues enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                if (![dictionaryNames containsObject:obj]) {
                    setLastModified = YES;
                    *stop = YES;
                }
            }];
            ret = setLastModified;   
        } else {
            // If a value was changed but to the same value it does not appear in changedValues
            ret = YES;
        }
    }
    
    return ret;
}

- (void)syncDelete
{
    [self willChangeValueForKey:SCHSyncEntityLastModified];
    [self willChangeValueForKey:SCHSyncEntityState];
	[self setPrimitiveLastModified:[NSDate serverDate]];
	[self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusDeleted]];		
    [self didChangeValueForKey:SCHSyncEntityState];
    [self didChangeValueForKey:SCHSyncEntityLastModified];
}

- (void)syncReset
{
    [self willChangeValueForKey:SCHSyncEntityLastModified];
    [self willChangeValueForKey:SCHSyncEntityState];
	[self setPrimitiveLastModified:[NSDate serverDate]];
	[self setPrimitiveState:[NSNumber numberWithStatus:kSCHStatusUnmodified]];	
    [self didChangeValueForKey:SCHSyncEntityState];
    [self didChangeValueForKey:SCHSyncEntityLastModified];
}

- (void)setLastModified:(NSDate *)LastModified
{
    // if the sync gave us a nil last modified date then we ignore it as 
    // last modified is mandatory 
    if (LastModified != nil) {
        [self willChangeValueForKey:SCHSyncEntityLastModified];
        [self setPrimitiveValue:LastModified forKey:SCHSyncEntityLastModified];
        [self didChangeValueForKey:SCHSyncEntityLastModified];    
    }
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
	
	return ret;
}

@end
