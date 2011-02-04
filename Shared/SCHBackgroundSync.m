//
//  SCHBackgroundSync.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHBackgroundSync.h"

static NSInteger const kSCHBackgroundSyncTimerRepeat = 60;

@implementation SCHBackgroundSync

- (id)init
{
	self = [super init];
	if (self != nil) {
		queue = [[NSMutableArray alloc] init];
	}
	return(self);
}


- (void)dealloc
{
	[timer release], timer = nil;
	[queue release], queue = nil;
	
	[super dealloc];
}

- (void)start
{
	[self stop];
	timer = [NSTimer scheduledTimerWithTimeInterval:kSCHBackgroundSyncTimerRepeat target:self selector:@selector(backgroundSyncHeartbeat:) userInfo:nil repeats:YES];
}

- (void)stop
{
	[timer invalidate];
	[timer release], timer = nil;
}

- (void)backgroundSyncHeartbeat:(NSTimer*)theTimer
{
	NSLog(@"Background Sync Heartbeat!");
}

@end
