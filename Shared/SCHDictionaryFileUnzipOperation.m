//
//  SCHDictionaryFileUnzipOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 05/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryFileUnzipOperation.h"

@interface SCHDictionaryFileUnzipOperation ()

@property BOOL executing;
@property BOOL finished;
@property float previousPercentage;

- (void) unzipDictionaryFileWithZipDelete: (BOOL) deleteAfterUnzip;

@end

@implementation SCHDictionaryFileUnzipOperation

@synthesize executing, finished;
@synthesize previousPercentage;
@synthesize manifestEntry;

- (void) dealloc
{
    NSLog(@"Unzip operation is definitely being deallocated.");
    [manifestEntry release], manifestEntry = nil;
    [super dealloc];
}

- (void) start
{
	if (![self isCancelled]) {
		
		NSLog(@"Starting unzip operation..");
        
        SCHDictionaryDownloadManager *dictManager = [SCHDictionaryDownloadManager sharedDownloadManager];
        
		dictManager.isProcessing = YES;
        self.previousPercentage = 0.0;
		
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
    zipArchive.delegate = self;
    
    bool zipSuccess = YES;
    
    zipSuccess = [zipArchive UnzipOpenFile:[dictManager dictionaryZipPath]];
    
    if (zipSuccess) {
        // unzip will always overwrite whatever is already there
        // this takes care of MP3, image updates etc.
        zipSuccess = [zipArchive UnzipFileTo:[dictManager dictionaryDirectory] overWrite:YES];
    } else {
        [dictManager threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUnableToOpenZipError];
        return;
    }
    
    [zipArchive UnzipCloseFile];
    [zipArchive release];
    
    if (zipSuccess) {
        NSLog(@"Successful unzip!");
    } else {
        NSLog(@"Unsuccessful unzip");
        [dictManager threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUnZipFailureError];
        return;
    }
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                              [NSNumber numberWithFloat:kSCHDictionaryFileUnzipMaxPercentage], @"currentPercentage",
                              nil];
    
    [self performSelectorOnMainThread:@selector(firePercentageUpdate:) 
                           withObject:userInfo
                        waitUntilDone:NO];

    
    NSFileManager *localFileManager = [[[NSFileManager alloc] init] autorelease];

    if (deleteAfterUnzip) {
        [localFileManager removeItemAtPath:[dictManager dictionaryZipPath] error:nil];
    }
    
    if (zipSuccess) {
        // if this is the first download, move the two text files into the current directory
        // otherwise we leave them where they are - the update text files are deleted at the end of the update parse
        BOOL firstRun = NO;
        
        if (self.manifestEntry.fromVersion == nil) {
            firstRun = YES;
        }
        
        if (firstRun) {
            NSString *currentLocation = [dictManager dictionaryDirectory];
            NSString *newLocation = [dictManager dictionaryTextFilesDirectory];
            
            [localFileManager moveItemAtPath:[currentLocation stringByAppendingPathComponent:@"EntryTable.txt"]
                                      toPath:[newLocation stringByAppendingPathComponent:@"EntryTable.txt"] error:nil];
            
            [localFileManager moveItemAtPath:[currentLocation stringByAppendingPathComponent:@"WordFormTable.txt"]
                                      toPath:[newLocation stringByAppendingPathComponent:@"WordFormTable.txt"] error:nil];
        }
        
        [dictManager threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsParse];
    }
}

-(void) UnzipProgress:(uLong)myCurrentFileIndex total:(uLong)myTotalFileCount
{
    float percentage = 0;
    
    if (myTotalFileCount > 0) {
        percentage = (float)((float)myCurrentFileIndex / (float)myTotalFileCount);
    }
    
    percentage *= kSCHDictionaryFileUnzipMaxPercentage;
    
    if (percentage - self.previousPercentage > 0.001f) {
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:percentage], @"currentPercentage",
                                  nil];
        
        NSLog(@"percentage for unzip: %2.4f%%", percentage * 100);
        
        [self performSelectorOnMainThread:@selector(firePercentageUpdate:) 
                               withObject:userInfo
                            waitUntilDone:NO];
        
        self.previousPercentage = percentage;
    }
}

- (void)firePercentageUpdate:(NSDictionary *)userInfo
{
    NSAssert(userInfo != nil, @"firePercentageUpdate is incorrectly being called with no userInfo");
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHDictionaryProcessingPercentageUpdate object:nil userInfo:userInfo];
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
