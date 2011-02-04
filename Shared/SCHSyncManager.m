//
//  SCHSyncManager.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSyncManager.h"

#import "SCHBackgroundSync.h"

static SCHSyncManager *sharedSyncManager = nil;

@implementation SCHSyncManager

@synthesize managedObjectContext=managedObjectContext_;

#pragma mark -
#pragma mark Singleton methods

+ (SCHSyncManager *)sharedSyncManager
{
    if (sharedSyncManager == nil) {
        sharedSyncManager = [[super allocWithZone:NULL] init];		
    }
	
    return(sharedSyncManager);
}

+ (id)allocWithZone:(NSZone *)zone
{
    return([[self sharedSyncManager] retain]);
}

- (id)copyWithZone:(NSZone *)zone
{
    return(self);
}

- (id)retain
{
    return(self);
}

- (NSUInteger)retainCount
{
    return(NSUIntegerMax);  //denotes an object that cannot be released
}

- (void)release
{
    // do nothing
}

- (id)autorelease
{
    return(self);
}

#pragma mark -
#pragma mark methods

- (id)init
{
	self = [super init];
	if (self != nil) {
		backgroundSync = [[SCHBackgroundSync alloc] init];
	}
	return(self);
}

- (void)dealloc
{
	[backgroundSync release], backgroundSync = nil;
	
	[super dealloc];
}


#pragma mark -
#pragma mark Background Sync methods

- (void)startBackgroundSync
{
	[backgroundSync start];	
}

- (void)stopBackgroundSync
{
	[backgroundSync stop];		
}

@end
