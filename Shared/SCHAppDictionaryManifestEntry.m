//
//  SCHAppDictionaryManifestEntry.m
//  Scholastic
//
//  Created by Neil Gall on 26/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHAppDictionaryManifestEntry.h"

#import "SCHAppDictionaryState.h"
#import "SCHDictionaryManifestEntry.h"

// Constants
NSString * const kSCHAppDictionaryManifestEntry = @"SCHAppDictionaryManifestEntry";

@implementation SCHAppDictionaryManifestEntry

@dynamic category;
@dynamic firstManifestEntry;
@dynamic size;
@dynamic state;
@dynamic toVersion;
@dynamic url;
@dynamic appDictionaryState;

- (void)setAttributesFromDictionaryManifestEntry:(SCHDictionaryManifestEntry *)dictionaryManifestEntry
{
    NSParameterAssert(dictionaryManifestEntry);

    if (dictionaryManifestEntry != nil) {
        self.category = dictionaryManifestEntry.category;
        self.firstManifestEntry = [NSNumber numberWithBool:dictionaryManifestEntry.firstManifestEntry];
        self.size = [NSNumber numberWithInteger:dictionaryManifestEntry.size];
        self.state = [NSNumber numberWithInt:dictionaryManifestEntry.state];
        self.toVersion = dictionaryManifestEntry.toVersion;
        self.url = dictionaryManifestEntry.url;
    }
}

@end
