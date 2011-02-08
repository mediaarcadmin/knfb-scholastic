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

- (id) init
{
	self = [super init];
	if (self != nil) {
		isSynchronizing = NO;
	}
	return(self);
}

- (BOOL)synchronize
{
	return(NO);
}

- (void)save
{
	NSError *error = nil;
	
	if (![self.managedObjectContext save:&error]) {
		NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		abort();
	} 
}

@end
