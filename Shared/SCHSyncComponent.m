//
//  SCHSyncComponent.m
//  Scholastic
//
//  Created by John S. Eddie on 04/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSyncComponent.h"


@implementation SCHSyncComponent

@synthesize isSynchronizing;

- (id) init
{
	self = [super init];
	if (self != nil) {
		isSynchronizing = NO;
	}
	return(self);
}

- (void)synchronize
{
	
}

@end
