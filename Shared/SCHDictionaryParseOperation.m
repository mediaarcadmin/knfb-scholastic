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

        if (self.manifestEntry.firstManifestEntry == YES) {
            [dictManager initialParseEntryTable];
            [dictManager initialParseWordFormTable];
        } else {
            [dictManager updateParseEntryTable];
            [dictManager updateParseWordFormTable];
        }
        
        NSFileManager *localFileManager = [[NSFileManager alloc] init];
        [localFileManager removeItemAtPath:[dictManager dictionaryZipPath] error:nil];
        [localFileManager release];
        
        // the dictionary is ready to be used, we will do a version check
        // to see if there are any updates available though 
        [dictManager setDictionaryIsCurrentlyReadable:YES];
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateManifestVersionCheck];
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
