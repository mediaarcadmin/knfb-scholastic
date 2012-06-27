//
//  SCHDictionaryFileDownloadOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryFileDownloadOperation.h"
#import "BITNetworkActivityManager.h"
#import "NSFileManager+Extensions.h"

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
- (void)cancelOperationAndSuboperations;

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
    NSLog(@"SCHDictionaryFileDownloadOperation is deallocing");
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
    
    [SCHDictionaryDownloadManager sharedDownloadManager].isProcessing = YES;
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

    self.downloadOperation = [[[QHTTPOperation alloc] initWithRequest:request] autorelease];
    self.downloadOperation.runLoopThread = [NSThread currentThread];
    self.downloadOperation.responseOutputStream = [NSOutputStream outputStreamToFileAtPath:localPath append:append];
    self.downloadOperation.delegate = self;

    [self didChangeValueForKey:@"isExecuting"];
    
    [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
    
    [self.downloadOperation start];
    
    while ([self.downloadOperation isExecuting]) {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
    }
    
    [self finishedDownload];
        
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

    [SCHDictionaryDownloadManager sharedDownloadManager].isProcessing = NO;    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.downloadOperation = nil;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
}

#pragma mark - QHTTPOperationDelegate

- (void)httpOperation:(QHTTPOperation *)operation startedDownloadingDataSize:(long long)expectedDataSize
{
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    BOOL sufficientSpace;
    if (expectedDataSize == NSURLResponseUnknownLength) {
        sufficientSpace = [fileManager BITfileSystemHasBytesAvailable:1];
    } else {
        // sufficient space = 1x full file size + 1.2x compressed file size
        // we can't check this up front, but the zip file is unlikely to be
        // highly compressed, as it consists mostly of already-compressed
        // image files and MP3 files
        sufficientSpace = [fileManager BITfileSystemHasBytesAvailable:(expectedDataSize * 2.2)];
    }
    
    if (!sufficientSpace) {
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNotEnoughFreeSpaceError];
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
    
    float progress = (float)(self.alreadyDownloadedSize + downloadedSize) / (self.alreadyDownloadedSize + self.expectedFileSize);
    NSInteger percentage = (NSInteger)(100*progress);
    if (percentage != self.previousPercentage) {
        [self fireProgressUpdate:progress];
        self.previousPercentage = percentage;
    }
}

- (void)httpOperation:(QHTTPOperation *)operation didFailWithError:(NSError *)error
{
    NSLog(@"dictionary download failed with error: %@", error);

    if ([error.domain isEqualToString:kQHTTPOperationErrorDomain] && error.code == 416) {
        // There was a problem with the range. Report an error state that will results in a delete of the files on the disk        
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateDownloadError];
        [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];

    } else if (!([error.domain isEqualToString:NSCocoaErrorDomain] && error.code == NSUserCancelledError)) {
        operation.completionBlock = nil;
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUnexpectedConnectivityFailureError];
        [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
    }
    
    [SCHDictionaryDownloadManager sharedDownloadManager].isProcessing = NO;
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.downloadOperation = nil;
    [self didChangeValueForKey:@"isFinished"];
    [self didChangeValueForKey:@"isExecuting"];
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

- (void)cancelOperationAndSuboperations
{
    [super cancel];
    [self.downloadOperation setCompletionBlock:nil];
    [self.downloadOperation cancel];
    
    [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
}

- (void)cancel
{
    [self cancelOperationAndSuboperations];
}
	
@end
