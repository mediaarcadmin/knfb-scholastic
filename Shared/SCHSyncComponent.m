//
//  SCHSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSyncComponent.h"
#import "SCHSyncComponentProtected.h"
#import "SCHAppStateManager.h"

// Constants
NSString * const SCHSyncComponentDidFailAuthenticationNotification = @"SCHSyncComponentDidFailAuthenticationNotification";

@interface SCHSyncComponent ()
 
@property (assign, nonatomic) NSUInteger failureCount;

@end

@implementation SCHSyncComponent

@synthesize isSynchronizing;
@synthesize managedObjectContext;
@synthesize backgroundTaskIdentifier;
@synthesize failureCount;

#pragma mark - Object lifecycle

- (id)init
{
	self = [super init];
	if (self != nil) {
		isSynchronizing = NO;
        backgroundTaskIdentifier = UIBackgroundTaskInvalid;
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
      userInfo:(NSDictionary *)userInfo
{	
	if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
		self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
	}
	self.isSynchronizing = NO;
	
    self.failureCount = 0;
    
    if (userInfo != nil) {
        NSNumber *serverDateDelta = [userInfo objectForKey:@"serverDateDelta"];
        if (serverDateDelta != nil) {
            SCHAppStateManager *appStateManager = [SCHAppStateManager sharedAppStateManager];
            if (!(fabs([appStateManager serverDateDelta]) > 0.0)) {
                [appStateManager setServerDateDelta:[serverDateDelta doubleValue]];
            }
        }
    }
    
	[super method:method didCompleteWithResult:nil userInfo:nil];	
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
	
    self.failureCount = self.failureCount + 1;
    
	[super method:method didFailWithError:error requestInfo:requestInfo result:result];
}

- (void)clearFailures
{
    self.failureCount = 0;
}

#pragma mark - Private methods

- (void)save
{
	NSError *error = nil;
	
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
	} 
}

@end
