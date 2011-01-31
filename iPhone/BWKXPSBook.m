//
//  BWKXPSBook.m
//  XPSRenderer
//
//  Created by Gordon Christie on 21/12/2010.
//  Copyright 2010 BitWink Limited. All rights reserved.
//

#import "BWKXPSBook.h"

@implementation BWKXPSBook

@synthesize properties;

- (void) dealloc
{
	[properties release], properties = nil;
	[super dealloc];
}

- (id) init
{
	if (self = [super init]) {
		self.properties = [[NSMutableDictionary alloc] init];
	}
	
	return self;
	
}

@end
