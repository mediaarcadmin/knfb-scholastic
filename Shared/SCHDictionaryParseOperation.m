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
        
        if (self.manifestEntry.fromVersion == nil) {
            [dictManager initialParseEntryTable];
            [dictManager initialParseWordFormTable];
        } else {
            [dictManager updateParseEntryTable];
            [dictManager updateParseWordFormTable];
        }
        
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateManifestVersionCheck];
        dictManager.isProcessing = NO;

        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        
        self.executing = NO;
        self.finished = YES;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];	
    }
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
