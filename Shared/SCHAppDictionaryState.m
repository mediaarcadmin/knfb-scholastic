//
//  SCHAppDictionaryState.m
//  Scholastic
//
//  Created by John S. Eddie on 18/03/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHAppDictionaryState.h"

#import "SCHAppDictionaryManifestEntry.h"
#import "SCHDictionaryFileDownloadOperation.h"

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

- (NSInteger *)freeSpaceInBytesRequiredToCompleteDownload
{
    return (NSInteger)floor([self.remainingFileSize integerValue] * kSCHDictionaryFileDownloadOperationFileSizeMultiplier);
}

- (NSString *)freeSpaceRequiredToCompleteDownloadAsString
{
    NSString *ret = nil;

    if (self.remainingFileSize == nil) {
        return @"?GB";
    } else {
        NSInteger freeSpaceInBytes = [self freeSpaceInBytesRequiredToCompleteDownload];

        if (freeSpaceInBytes <= 0) {
            ret = [NSString stringWithFormat:@"0GB"];
        } else {
            ret = [NSString stringWithFormat:@"%.1fGB", freeSpaceInBytes / 1000000000.0];
        }
    }
    
    return ret;
}

@end
