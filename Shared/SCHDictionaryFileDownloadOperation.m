//
//  SCHDictionaryFileDownloadOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryFileDownloadOperation.h"
#import "BITNetworkActivityManager.h"

#pragma mark Class Extension

@interface SCHDictionaryFileDownloadOperation ()

// a local file manager, for thread safety
@property (nonatomic, retain) NSFileManager *localFileManager;
@property (nonatomic, retain) QHTTPOperation *downloadOperation;

// the total file size reported by the HTTP header
@property unsigned long long expectedFileSize;

// the size already downloaded when this operation started
@property unsigned long long alreadyDownloadedSize;

// the previous percentage reported - used to limit percentage notifications
@property NSInteger previousPercentage;

- (void)fireProgressUpdate:(float)progress;
- (void)finishedDownload;
- (BOOL)fileSystemHasBytesAvailable:(unsigned long long)sizeInBytes;

@end

#pragma mark -

@implementation SCHDictionaryFileDownloadOperation

@synthesize expectedFileSize;
@synthesize alreadyDownloadedSize;
@synthesize previousPercentage;
@synthesize manifestEntry;
@synthesize localFileManager;
@synthesize downloadOperation;

#pragma mark - Memory Management

- (void)dealloc
{
    [localFileManager release], localFileManager = nil;
    [downloadOperation release], downloadOperation = nil;
	[super dealloc];
}

#pragma mark - Startup

- (void)start
{
    NSAssert(self.manifestEntry != nil, @"File URL cannot be nil for SCHDictionaryFileDownloadOperation.");

	if ([self isCancelled]) {
		NSLog(@"Cancelled.");
        return;
	}

    [self willChangeValueForKey:@"isExecuting"];
    
    NSString *localPath = [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryZipPath];
    BOOL append = NO;

    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.manifestEntry.url]];
    
    self.alreadyDownloadedSize = 0;
    self.localFileManager = [[[NSFileManager alloc] init] autorelease];

	if ([self.localFileManager fileExistsAtPath:localPath]) {
		// check to see how much of the file has been downloaded
        NSError *error = nil;
		unsigned long long currentFilesize = [[self.localFileManager attributesOfItemAtPath:localPath error:&error] fileSize];
		if (error) {
			NSLog(@"Error when reading file attributes. Stopping. (%@)", [error localizedDescription]);
            [self cancel];
			return;
		}
        
        if (currentFilesize > 0) {
            [request setValue:[NSString stringWithFormat:@"bytes=%llu-", currentFilesize] forHTTPHeaderField:@"Range"];
            append = YES;
            self.alreadyDownloadedSize = currentFilesize;
            
            NSLog(@"resuming dictionary download from offset %llu", currentFilesize);
        }
    }

    self.downloadOperation = [[QHTTPOperation alloc] initWithRequest:request];
    self.downloadOperation.responseOutputStream = [NSOutputStream outputStreamToFileAtPath:localPath append:append];
    self.downloadOperation.delegate = self;
    
    __block SCHDictionaryFileDownloadOperation *unretained_self = self;
    self.downloadOperation.completionBlock = ^{
        [unretained_self finishedDownload];
    };

    [self didChangeValueForKey:@"isExecuting"];
    
    [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
    
    [self.downloadOperation start];
}

- (BOOL)fileSystemHasBytesAvailable:(unsigned long long)sizeInBytes
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];            
    
    NSDictionary* fsAttr = [self.localFileManager attributesOfFileSystemForPath:docDirectory error:NULL];
    
    unsigned long long freeSize = [(NSNumber*)[fsAttr objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    //NSLog(@"Freesize: %llu", freeSize);
    
    return (sizeInBytes <= freeSize);
}

- (void)finishedDownload
{
    [self.downloadOperation waitUntilFinished];
    
    [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
    
    if (![self isFinished]) {
        // fire a 100% notification
        [self fireProgressUpdate:1.0f];
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsUnzip];
    }

    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.downloadOperation = nil;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

#pragma mark - QHTTPOperationDelegate

- (void)httpOperation:(QHTTPOperation *)operation startedDownloadingDataSize:(long long)expectedDataSize
{
    BOOL sufficientSpace;
    if (expectedDataSize == NSURLResponseUnknownLength) {
        sufficientSpace = [self fileSystemHasBytesAvailable:1];
    } else {
        sufficientSpace = [self fileSystemHasBytesAvailable:expectedDataSize];
    }
    
    if (!sufficientSpace) {
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNotEnoughFreeSpace];
        [operation cancel];
        [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];            
        [self cancel];
        return;
    }
    
    NSLog(@"start downloading dictionary size = %llu", expectedDataSize);
    self.expectedFileSize = expectedDataSize;
    self.previousPercentage = -1;
}

- (void)httpOperation:(QHTTPOperation *)operation updatedDownloadSize:(long long)downloadedSize
{
    if (self.expectedFileSize == NSURLResponseUnknownLength) {
        return;
    }
    
    float progress = (float)(self.alreadyDownloadedSize + downloadedSize) / self.expectedFileSize;
    NSInteger percentage = (NSInteger)(100*progress);
    if (percentage != self.previousPercentage) {
        [self fireProgressUpdate:progress];
        self.previousPercentage = percentage;
    }
}

- (void)httpOperation:(QHTTPOperation *)operation didFailWithError:(NSError *)error
{
    NSLog(@"dictionary download failed with error: %@", error);
    
    operation.completionBlock = nil;
    [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateError];
    [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];            
}

#pragma mark - progress

- (void)fireProgressUpdate:(float)progress
{
	NSAssert(self.expectedFileSize != NSURLResponseUnknownLength, @"can't send progress updates for unknown file size");

    NSLog(@"percentage for dictionary: %2.4f%%", progress * 100);
    
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:progress], @"currentPercentage",
                                  nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSCHDictionaryDownloadPercentageUpdate
                                                            object:nil
                                                          userInfo:userInfo];
    });
}

#pragma mark - NSOperation methods

- (BOOL)isConcurrent
{
	return YES;
}

- (BOOL)isExecuting
{
    return [self.downloadOperation isExecuting];
}

- (BOOL)isFinished
{
	return self.downloadOperation == nil;
}

- (void)cancel
{
    [self.downloadOperation cancel];
	[super cancel];
}
	
@end
