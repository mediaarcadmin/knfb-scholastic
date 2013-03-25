//
//  SCHAppDictionaryState.m
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHAppDictionaryState.h"

#import "SCHAppDictionaryManifestEntry.h"

// Constants
NSString * const kSCHAppDictionaryState = @"SCHAppDictionaryState";

@implementation SCHAppDictionaryState

@dynamic LastModified;
@dynamic remainingFileSize;
@dynamic State;
@dynamic Version;
@dynamic appDictionaryManifestEntry;

- (SCHAppDictionaryManifestEntry *)appDictionaryManifestEntryForDictionaryCategory:(NSString *)dictionaryCategory
{
    NSParameterAssert(dictionaryCategory);
    SCHAppDictionaryManifestEntry *ret = nil;

    if (dictionaryCategory != nil) {
        for (SCHAppDictionaryManifestEntry *entry in self.appDictionaryManifestEntry) {
            if ([entry.category isEqualToString:dictionaryCategory] == YES) {
                ret = entry;
                break;
            }
        }
    }

    return ret;
}

@end
