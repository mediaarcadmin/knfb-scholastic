//
//  SCHSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSyncComponent.h"
#import "SCHSyncComponentProtected.h"


@implementation SCHSyncComponent

@synthesize isSynchronizing;
@synthesize managedObjectContext;
@synthesize backgroundTaskIdentifier;

#pragma mark - Object lifecycle

- (id)init
{
	self = [super init];
	if (self != nil) {
		isSynchronizing = NO;
	}
	
	return(self);
}

- (void)dealloc 
{
    [managedObjectContext release], managedObjectContext = nil;
    
    [super dealloc];
}

#pragma mark - Methods

- (BOOL)synchronize
{
	return(NO);
}

#pragma mark - Delegate methods

- (void)method:(NSString *)method didCompleteWithResult:(NSDictionary *)result
{	
	if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
		self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
	}
	self.isSynchronizing = NO;
	
	[super method:method didCompleteWithResult:nil];	
}

- (void)method:(NSString *)method didFailWithError:(NSError *)error 
   requestInfo:(NSDictionary *)requestInfo
        result:(NSDictionary *)result
{
	if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
		self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
	}
	self.isSynchronizing = NO;
	
	[super method:method didFailWithError:error requestInfo:requestInfo result:result];
}

#pragma mark - Private methods

- (void)save
{
	NSError *error = nil;
	
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	} 
}

@end
