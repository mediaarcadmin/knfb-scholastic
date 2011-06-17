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
        
        SCHDictionaryDownloadManager *dictManager = [SCHDictionaryDownloadManager sharedDownloadManager];
        
		dictManager.isProcessing = YES;
		
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        
        self.executing = YES;
        self.finished = NO;
        
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
        
        // Don't delete the zip file here - delete it once the file is fully processed
        [self unzipDictionaryFileWithZipDelete:NO];
        
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
    SCHDictionaryDownloadManager *dictManager = [SCHDictionaryDownloadManager sharedDownloadManager];
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
