//
//  SCHDictionary.m
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionary.h"

@implementation SCHDictionary

@synthesize dictionaryURL, dictionaryVersion, dictionaryState, isProcessing;

- (id) init
{
	if ((self = [super init])) {
		self.dictionaryState = SCHDictionaryProcessingStateNeedsManifest;
		self.isProcessing = NO;
	} 
	
	return self;
}

@end
