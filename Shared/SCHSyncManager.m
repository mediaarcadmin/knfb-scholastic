//
//  SCHSyncManager.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSyncManager.h"

#import "SCHBackgroundSync.h"
#import "SCHProfileSyncComponent.h"
#import "SCHContentSyncComponent.h"
#import "SCHBookshelfSyncComponent.h"
#import "SCHAnnotationSyncComponent.h"
#import "SCHReadingStatsSyncComponent.h"
#import "SCHSettingsSyncComponent.h"

static SCHSyncManager *sharedSyncManager = nil;

@implementation SCHSyncManager

@synthesize managedObjectContext;

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

#pragma mark -
#pragma mark Sync methods

// after login or opening the app
// also coming out of background
- (void)firstSync
{
	NSLog(@"Scheduling First Sync");
	
//	[profileSyncComponent synchronize];
//	[contentSyncComponent synchronize];
//	[bookshelfSyncComponent synchronize];
//
//	SCHProfileSyncComponent *profileSyncComponent;
//	SCHContentSyncComponent *contentSyncComponent;
//	SCHBookshelfSyncComponent *bookshelfSyncComponent;
//	SCHAnnotationSyncComponent *annotationSyncComponent;
//	SCHReadingStatsSyncComponent *readingStatsSyncComponent;
//	SCHSettingsSyncComponent *settingsSyncComponent;
	
	
	// profiles GetUserProfile
	// content ListUserContent
	// bookshelf ListContentMetadata
	
	// annotations ListProfileContentAnnotations
	
	// reading stats
	
	// settings ListUserSettings
}

// also coming out of background
- (void)openDocument
{
	NSLog(@"Scheduling Open Document");
	
	// annotations SaveProfileContentAnnotations/ListProfileContentAnnotations
}

- (void)closeDocument
{
	NSLog(@"Scheduling Close Document");
	
	// annotations SaveProfileContentAnnotations/ListProfileContentAnnotations
	
	// reading stats SaveReadingStatisticsDetailed
}

- (void)exitParentalTools:(BOOL)syncNow
{
	NSLog(@"Scheduling Exit Parental Tools");

	// profiles SaveUserProfile/GetUserProfile
	// content SaveContentProfileAssignment/ListUserContent
	// bookshelf ListContentMetadata
	
	// settings SaveUserSettings/ListUserSettings
}

@end
