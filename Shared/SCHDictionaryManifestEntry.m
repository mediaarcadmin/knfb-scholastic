//
//  SCHDictionaryManifestEntry.m
//  Scholastic
//
//  Created by John S. Eddie on 22/03/2013.
//  Copyright (c) 2013 BitWink. All rights reserved.
//

#import "SCHDictionaryManifestEntry.h"

#import "SCHAppDictionaryManifestEntry.h"

@implementation SCHDictionaryManifestEntry

@synthesize category;
@synthesize firstManifestEntry;
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

- (id)initWithAppDictionaryManifestEntry:(SCHAppDictionaryManifestEntry *)appDictionaryManifestEntry
{
    NSParameterAssert(appDictionaryManifestEntry);
    SCHDictionaryManifestEntry *ret = [self init];

    if (appDictionaryManifestEntry != nil && ret != nil) {
        ret.category = appDictionaryManifestEntry.category;
        ret.firstManifestEntry = [appDictionaryManifestEntry.firstManifestEntry boolValue];
        ret.size = [NSNumber numberWithInteger:appDictionaryManifestEntry.size];
        ret.state = [NSNumber numberWithInt:appDictionaryManifestEntry.state];
        ret.toVersion = appDictionaryManifestEntry.toVersion;
        ret.url = appDictionaryManifestEntry.url;
    }

    return ret;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"%@ %@%@ state=%i, size=%i, '%@'",
            self.category, self.toVersion,
            (self.firstManifestEntry == YES? @" (First Entry)" : @""),
            (int)self.state, self.size, self.url];
}

@end

