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

@property (assign, nonatomic) NSInteger count;

@end

@implementation BITNetworkActivityManager

@synthesize count;

#pragma mark -
#pragma mark Singleton methods

+ (BITNetworkActivityManager *)sharedNetworkActivityManager
{
    if (sharedNetworkActivityManager == nil) {
        sharedNetworkActivityManager = [[super allocWithZone:NULL] init];		
    }
	
    return(sharedNetworkActivityManager);
}

+ (id)allocWithZone:(NSZone *)zone
{
    return([[self sharedNetworkActivityManager] retain]);
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
		self.count = 0;
	}
	return(self);
}

- (void)showNetworkActivityIndicator
{
	self.count++;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = (self.count > 0);
}

- (void)hideNetworkActivityIndicator
{
	self.count--;
	[UIApplication sharedApplication].networkActivityIndicatorVisible = (self.count > 0);
}

@end
