//
//  SCHDictionaryFileUnzipOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 05/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryFileUnzipOperation.h"
#import "ZipArchive.h"

@interface SCHDictionaryFileUnzipOperation ()

@property BOOL executing;
@property BOOL finished;

- (void) unzipDictionaryFileWithZipDelete: (BOOL) deleteAfterUnzip;

@end

@implementation SCHDictionaryFileUnzipOperation

@synthesize executing, finished, manifestEntry;

- (void) dealloc
{
    NSLog(@"Unzip operation is definitely being deallocated.");
    [super dealloc];
}

- (void) start
{
    NSAssert(self.manifestEntry != nil, @"File URL cannot be nil for SCHDictionaryFileUnzipOperation.");

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
        
        [self unzipDictionaryFileWithZipDelete:YES];
        
		dictManager.isProcessing = NO;
        
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        
        self.executing = NO;
        self.finished = YES;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
        
	}
}

- (void) unzipDictionaryFileWithZipDelete: (BOOL) deleteAfterUnzip
{
    SCHDictionaryManager *dictManager = [SCHDictionaryManager sharedDictionaryManager];
    ZipArchive *zipArchive = [[ZipArchive alloc] init];
    
    bool zipSuccess = YES;
    
    zipSuccess = [zipArchive UnzipOpenFile:[dictManager dictionaryZipPath]];
    
    if (zipSuccess) {
        // unzip will always overwrite whatever is already there
        // this takes care of MP3, image updates etc.
        zipSuccess = [zipArchive UnzipFileTo:[dictManager dictionaryDirectory] overWrite:YES];
    }
    
    [zipArchive UnzipCloseFile];
    [zipArchive release];
    
    if (zipSuccess) {
        NSLog(@"Successful unzip!");
    } else {
        NSLog(@"Unsuccessful unzip. boo.");
    }
    
    NSFileManager *localFileManager = [[NSFileManager alloc] init];

    if (deleteAfterUnzip) {
        [localFileManager removeItemAtPath:[dictManager dictionaryZipPath] error:nil];
    }
    
    [localFileManager release];
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
