//
//  SCHHelpVideoFileDownloadOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 18/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHHelpVideoFileDownloadOperation.h"
#import "SCHDictionaryDownloadManager.h"
#import "BITNetworkActivityManager.h"

#pragma mark Class Extension

@interface SCHHelpVideoFileDownloadOperation ()

@property (nonatomic, retain) NSFileManager *localFileManager;
@property (nonatomic, retain) NSMutableArray *downloadQueue;
@property (nonatomic, retain) QHTTPOperation *currentOperation;
@property (nonatomic, assign) NSInteger totalDownloadCount;
@property (nonatomic, assign) long long currentDownloadSize;
@property (nonatomic, assign) NSInteger lastUpdatePercentage;

- (void)beginNextDownload;
- (void)finishedAllDownloads;
- (void)terminateOperation;
- (void)fireProgressUpdate:(float)progress;

@end

#pragma mark -

@implementation SCHHelpVideoFileDownloadOperation

@synthesize videoManifest;
@synthesize localFileManager;
@synthesize downloadQueue;
@synthesize totalDownloadCount;
@synthesize currentOperation;
@synthesize currentDownloadSize;
@synthesize lastUpdatePercentage;

#pragma mark - Memory Management

- (void)dealloc
{
    [localFileManager release], localFileManager = nil;
    [downloadQueue release], downloadQueue = nil;
    [currentOperation release], currentOperation = nil;
	[super dealloc];
}

#pragma mark - Main

- (void)start
{
    NSAssert(self.videoManifest != nil, @"videoManifest cannot be nil for SCHHelpVideoFileDownloadOperation.");
    
	if ([self isCancelled]) {
		NSLog(@"Cancelled.");
        return;
	}

    [self willChangeValueForKey:@"isExecuting"];

    self.localFileManager = [[[NSFileManager alloc] init] autorelease];
    
    NSString *localDirectory = [[SCHDictionaryDownloadManager sharedDownloadManager] helpVideoDirectory];

    self.downloadQueue = [NSMutableArray array];
    
    for (NSString *downloadURL in [[self.videoManifest itemsForCurrentDevice] allValues]) {
        NSString *fileName = [downloadURL lastPathComponent];
        NSString *localPath = [NSString stringWithFormat:@"%@/%@", localDirectory, fileName];
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:downloadURL]];
        BOOL append = NO;
        
        if ([self.localFileManager fileExistsAtPath:localPath]) {
            NSError *error = nil;
            unsigned long long currentFilesize = [[self.localFileManager attributesOfItemAtPath:localPath error:&error] fileSize];
            if (error) {
                NSLog(@"cannot download %@: error reading file attributes for %@: %@", fileName, localPath, error);
                continue;
            }
            if (currentFilesize > 0) {
                [request setValue:[NSString stringWithFormat:@"bytes=%llu-", currentFilesize] forHTTPHeaderField:@"Range"];
                append = YES;
            }
        }
        
        QHTTPOperation *httpOperation = [[QHTTPOperation alloc] initWithRequest:request];
        httpOperation.delegate = self;
        httpOperation.responseOutputStream = [NSOutputStream outputStreamToFileAtPath:localPath append:append];
        [self.downloadQueue addObject:httpOperation];
        [httpOperation release];
    }
    
    [self didChangeValueForKey:@"isExecuting"];
    
    [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];
    
    self.totalDownloadCount = [self.downloadQueue count];
    [self beginNextDownload];
}

- (void)beginNextDownload
{
    if ([self isCancelled]) {
        [self terminateOperation];
        return;
    }
    
    if ([self.downloadQueue count] == 0) {
        [self finishedAllDownloads];
        return;
    }
    
    self.currentOperation = [self.downloadQueue objectAtIndex:0];
    [self.downloadQueue removeObjectAtIndex:0];
    
    __block SCHHelpVideoFileDownloadOperation *unretained_self = self;
    self.currentOperation.completionBlock = ^{
        [unretained_self beginNextDownload];
    };
    [self.currentOperation start];
}

- (void)finishedAllDownloads
{
    [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];

    // we've successfully downloaded all files
    // set the version string to 1.0 (hardcoded at present)
    [[SCHDictionaryDownloadManager sharedDownloadManager] setHelpVideoVersion:@"1.0" 
                                                                     olderURL:[self.videoManifest olderURLForCurrentDevice] 
                                                                   youngerURL:[self.videoManifest youngerURLForCurrentDevice]];
    
    [self fireProgressUpdate:1.0f];
    
    SCHDictionaryUserRequestState userRequestState = [[SCHDictionaryDownloadManager sharedDownloadManager] userRequestState];
    
    if (userRequestState == SCHDictionaryUserDeclined) {
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUserDeclined];
    } else if (userRequestState == SCHDictionaryUserNotYetAsked) {
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUserSetup];
    } else {
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
    }
    
    self.currentOperation = nil;
    [self terminateOperation];
}

- (void)terminateOperation
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    
    [self.downloadQueue removeAllObjects];
    self.currentOperation.completionBlock = nil;
    [self.currentOperation waitUntilFinished];
    self.currentOperation = nil;
    
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
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

- (void)fireProgressUpdate:(float)progress
{
    dispatch_async(dispatch_get_main_queue(), ^{
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:progress], @"currentPercentage",
                                  nil];
        [[NSNotificationCenter defaultCenter] postNotificationName:kSCHHelpVideoDownloadPercentageUpdate
                                                            object:self
                                                          userInfo:userInfo];
    });
}

#pragma mark - QHTTPOperationDelegate

- (void)httpOperation:(QHTTPOperation *)operation startedDownloadingDataSize:(long long)expectedDataSize
{
    self.currentDownloadSize = expectedDataSize;
    self.lastUpdatePercentage = -1;
    
    if (![self fileSystemHasBytesAvailable:expectedDataSize]) {
        NSLog(@"unsufficient space for %@ [%llu]: cancelling download", [operation URL], expectedDataSize);
        [operation cancel];
    } else {
        NSLog(@"downloading %@ expected size = %llu", [operation URL], expectedDataSize);
    }
}

- (void)httpOperation:(QHTTPOperation *)operation updatedDownloadSize:(long long)downloadedSize
{    
    float progressForCompletedFiles = (self.totalDownloadCount-[self.downloadQueue count]-1)/(float)self.totalDownloadCount;
    float progressForCurrentFile = (float)downloadedSize/self.currentDownloadSize;
    float progress = progressForCompletedFiles + (1.0f/self.totalDownloadCount)*progressForCurrentFile;
    NSInteger percentage = (NSInteger)(100*progress);
    if (percentage != self.lastUpdatePercentage) {
        [self fireProgressUpdate:progress];
        self.lastUpdatePercentage = percentage;
        NSLog(@"downloading %@ %.f%%", [[operation URL] lastPathComponent], 100*progressForCurrentFile);
    }
}

- (void)httpOperation:(QHTTPOperation *)operation didFailWithError:(NSError *)error
{
    NSLog(@"help video download failed with error: %@", error);

    // TODO: do something about this
}

#pragma mark - NSOperation overrides

- (BOOL)isConcurrent
{
    return YES;
}

- (void)cancel
{
    [self.currentOperation cancel];
    [super cancel];
}

- (BOOL)isExecuting
{
    return self.currentOperation != nil || [self.downloadQueue count] > 0;
}

- (BOOL)isFinished
{
    return self.currentOperation == nil && [self.downloadQueue count] == 0;
}

@end
