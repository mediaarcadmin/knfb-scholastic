//
//  SCHDictionaryFileUnzipOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 05/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryFileUnzipOperation.h"
#import "SCHDictionaryManager.h"
#import "ZipArchive.h"

@interface SCHDictionaryFileUnzipOperation ()

@property BOOL executing;
@property BOOL finished;

- (void) unzipDictionaryFile;

@end

@implementation SCHDictionaryFileUnzipOperation

@synthesize executing, finished;

- (void) dealloc
{
    NSLog(@"Unzip operation is definitely being deallocated.");
    [super dealloc];
}

- (void) start
{
	if (![self isCancelled]) {
		
		NSLog(@"Starting unzip operation..");
        
        SCHDictionaryManager *dictManager = [SCHDictionaryManager sharedDictionaryManager];
        
		dictManager.isProcessing = YES;
		
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        
        self.executing = YES;
        self.finished = NO;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
        
        [self unzipDictionaryFile];
        
        [[SCHDictionaryManager sharedDictionaryManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsParsing];
        
		dictManager.isProcessing = NO;
        
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        
        self.executing = NO;
        self.finished = YES;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
        
	}
}

- (void) unzipDictionaryFile
{
    SCHDictionaryManager *dictManager = [SCHDictionaryManager sharedDictionaryManager];
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    
    bool zipSuccess = YES;
    
    zipSuccess = [zipArchive UnzipOpenFile:[dictManager dictionaryZipPath]];
    
    if (zipSuccess) {
        zipSuccess = [zipArchive UnzipFileTo:[dictManager dictionaryDirectory] overWrite:YES];
    }
    
    if (zipSuccess) {
        NSLog(@"Successful unzip!");
    } else {
        NSLog(@"Unsuccessful unzip. boo.");
    }
    
    [zipArchive UnzipCloseFile];
    [zipArchive release];
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
