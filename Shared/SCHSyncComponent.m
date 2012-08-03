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
double const SCHSyncComponentThreadLowPriority = 0.25;

@interface SCHSyncComponent ()
 
@property (assign, nonatomic) NSUInteger failureCount;

@end

@implementation SCHSyncComponent

@synthesize isSynchronizing;
@synthesize managedObjectContext;
@synthesize backgroundTaskIdentifier;
@synthesize failureCount;
@synthesize backgroundProcessingQueue;
@synthesize saveOnly;

#pragma mark - Object lifecycle

- (id)init
{
	self = [super init];
	if (self != nil) {
		isSynchronizing = NO;
        backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        saveOnly = NO;
	}
	
	return(self);
}

- (void)dealloc 
{
    [managedObjectContext release], managedObjectContext = nil;
    [backgroundProcessingQueue release], backgroundProcessingQueue = nil;
    
    [super dealloc];
}

#pragma mark - Methods

- (BOOL)synchronize
{
	return(NO);
}

- (void)resetSync
{
    // we purposefully don't call the self.accessor here as we don't want to 
    // create the queue if it's not required to be used
    if (backgroundProcessingQueue != nil) {
        [self.backgroundProcessingQueue cancelAllOperations];
        // yes this may block for a few seconds waiting, note currently the user
        // will be presented with a wait spinner while this operation is performed
        // each operation checks for cancellation as do all the dispatch_async calls
        [self.backgroundProcessingQueue waitUntilAllOperationsAreFinished];
    }
    
    self.isSynchronizing = NO;
    self.saveOnly = NO;
    [self clearFailures];
    [self resetWebService];
    [self clearComponent];
    [self clearCoreData];
}

- (void)resetWebService
{
    NSAssert(NO, @"SCHSyncComponent:resetWebService needs to be overidden in sub-classes");    
}

- (void)clearCoreData
{
    NSAssert(NO, @"SCHSyncComponent:clearCoreData needs to be overidden in sub-classes");        
}

- (void)completeWithSuccessMethod:(NSString *)method 
                           result:(NSDictionary *)result 
                         userInfo:(NSDictionary *)userInfo
                 notificationName:(NSString *)notificationName
             notificationUserInfo:(NSDictionary *)notificationUserInfo
{
    if (notificationName != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName 
                                                            object:self
                                                          userInfo:notificationUserInfo];                
    }
    
	[self endBackgroundTask];
	self.isSynchronizing = NO;
	
    [self clearFailures];
    
    if (userInfo != nil) {
        NSNumber *serverDateDelta = [userInfo objectForKey:@"serverDateDelta"];
        if (serverDateDelta != nil) {
            SCHAppStateManager *appStateManager = [SCHAppStateManager sharedAppStateManager];
            if (!(fabs([appStateManager serverDateDelta]) > 0.0)) {
                [appStateManager setServerDateDelta:[serverDateDelta doubleValue]];
            }
        }
    }
    
    [super completeWithSuccessMethod:method 
                              result:result 
                            userInfo:userInfo
                    notificationName:notificationName
                notificationUserInfo:notificationUserInfo];
}

- (void)completeWithFailureMethod:(NSString *)method 
                            error:(NSError *)error 
                      requestInfo:(NSDictionary *)requestInfo 
                           result:(NSDictionary *)result
                 notificationName:(NSString *)notificationName
             notificationUserInfo:(NSDictionary *)notificationUserInfo
{
    if (notificationName != nil) {
        [[NSNotificationCenter defaultCenter] postNotificationName:notificationName 
                                                            object:self 
                                                          userInfo:notificationUserInfo];        
    }
    
    [self endBackgroundTask];
	self.isSynchronizing = NO;
	
    self.failureCount = self.failureCount + 1;

    [super completeWithFailureMethod:method 
                               error:error 
                         requestInfo:requestInfo 
                              result:result
                    notificationName:notificationName
                notificationUserInfo:notificationUserInfo];
}

#pragma mark - Background task methods

- (void)beginBackgroundTask
{
    if (self.backgroundTaskIdentifier == UIBackgroundTaskInvalid) {
        self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{ 
            self.isSynchronizing = NO;
            [self endBackgroundTask];
        }];
    }
}

- (void)endBackgroundTask
{
    if (self.backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
		[[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
		self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;			
	}
}

#pragma mark - Accessor methods

- (NSOperationQueue *)backgroundProcessingQueue
{
    if (backgroundProcessingQueue == nil) {
        backgroundProcessingQueue = [[NSOperationQueue alloc] init];
        [backgroundProcessingQueue setMaxConcurrentOperationCount:1];        
    }
    
    return backgroundProcessingQueue;
}

- (void)clearFailures
{
    self.failureCount = 0;
}

#pragma mark - Private methods

- (void)saveWithManagedObjectContext:(NSManagedObjectContext *)aManagedObjectContext
{
    NSError *error = nil;
    
    if ([aManagedObjectContext hasChanges] == YES &&
        ![aManagedObjectContext save:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
    } 
}

@end
