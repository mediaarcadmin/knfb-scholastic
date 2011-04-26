  //
//  BITNetworkActivityManager.m
//  Scholastic
//
//  Created by John S. Eddie on 23/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "BITNetworkActivityManager.h"

static BITNetworkActivityManager *sharedNetworkActivityManager = nil;

@interface BITNetworkActivityManager ()

+ (BITNetworkActivityManager *)sharedNetworkActivityManagerOnMainThread;
- (void)showNetworkActivityIndicatorOnMainThread;
- (void)hideNetworkActivityIndicatorOnMainThread;

@property (assign, nonatomic) NSInteger count;

@end

/*
 * This class is thread safe in respect to all the exposed methods being
 * wrappers for private methods that are always executed on the MainThread.
 */

@implementation BITNetworkActivityManager

@synthesize count;

#pragma mark - Singleton Instance methods

+ (BITNetworkActivityManager *)sharedNetworkActivityManager
{
    if (sharedNetworkActivityManager == nil) {
        // we block until the selector completes to make sure we always have the object before use
        [BITNetworkActivityManager performSelectorOnMainThread:@selector(sharedNetworkActivityManagerOnMainThread) withObject:nil waitUntilDone:YES];
    }
	
    return(sharedNetworkActivityManager);
}

#pragma mark - methods

- (id)init
{
	self = [super init];
	if (self != nil) {
		self.count = 0;
	}
	return(self);
}

- (void)showNetworkActivityIndicator
{
    [self performSelectorOnMainThread:@selector(showNetworkActivityIndicatorOnMainThread) withObject:nil waitUntilDone:NO];    
}

- (void)hideNetworkActivityIndicator
{
    [self performSelectorOnMainThread:@selector(hideNetworkActivityIndicatorOnMainThread) withObject:nil waitUntilDone:NO];    
}

#pragma mark - Private methods

+ (BITNetworkActivityManager *)sharedNetworkActivityManagerOnMainThread
{
    if (sharedNetworkActivityManager == nil) {
        sharedNetworkActivityManager = [[super allocWithZone:NULL] init];		
    }
	
    return(sharedNetworkActivityManager);
}

- (void)showNetworkActivityIndicatorOnMainThread
{
	self.count++;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = (self.count > 0);
}

- (void)hideNetworkActivityIndicatorOnMainThread
{
	self.count--;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = (self.count > 0);
}

@end
