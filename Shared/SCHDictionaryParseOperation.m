//
//  SCHDictionaryParseOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 05/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryParseOperation.h"
#import "SCHBookManager.h"
#import "SCHDictionaryEntry.h"
#import "SCHDictionaryWordForm.h"
#import "SCHDictionaryManifestEntry.h"
#import "SCHDictionaryManifestOperation.h"

@interface SCHDictionaryParseOperation ()

@property BOOL executing;
@property BOOL finished;

@end

@implementation SCHDictionaryParseOperation

@synthesize executing, finished, manifestEntry;

- (void) start
{
	if (![self isCancelled]) {
		
        SCHDictionaryDownloadManager *dictManager = [SCHDictionaryDownloadManager sharedDownloadManager];
        
		dictManager.isProcessing = YES;
		
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        
        self.executing = YES;
        self.finished = NO;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];        

        if ([self.manifestEntry.category isEqualToString:kSCHDictionaryManifestOperationDictionaryText] == YES) {
            // the dictionary should not be used during a parse
            [dictManager setDictionaryIsCurrentlyReadable:NO];

            if (self.manifestEntry.firstManifestEntry == YES) {
                [dictManager initialParseEntryTable];
                [dictManager initialParseWordFormTable];
            } else {
                [dictManager updateParseEntryTable];
                [dictManager updateParseWordFormTable];
            }

            // the dictionary is ready to be used
            [dictManager setDictionaryIsCurrentlyReadable:YES];
        }
        
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        [localFileManager removeItemAtPath:[dictManager zipPathForDictionaryManifestEntry:manifestEntry] error:nil];
        [localFileManager release];
        
        // do a version check to see if there are any updates available
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
        dictManager.isProcessing = NO;
    }
    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    self.executing = NO;
    self.finished = YES;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
	return self.executing;
}

- (BOOL)isFinished {
	return self.finished;
}

@end
