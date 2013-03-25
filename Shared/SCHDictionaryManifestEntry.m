//
//  SCHDictionaryManifestEntry.m
//  Scholastic
//
//  Created by John S. Eddie on 22/03/2013.
//  Copyright (c) 2013 BitWink. All rights reserved.
//

#import "SCHDictionaryManifestEntry.h"

@implementation SCHDictionaryManifestEntry

@synthesize category;
@synthesize size;
@synthesize state;
@synthesize toVersion;
@synthesize url;

- (void)dealloc
{
    [category release], category = nil;
    [toVersion release], toVersion = nil;
    [url release], url = nil;

    [super dealloc];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@-%@ (%i)(state:%i) '%@'", self.category,
            self.toVersion, self.size, (int)self.state, self.url];
}

@end

