//
//  SCHRecommendationDownloadCoverOperation.m
//  Scholastic
//
//  Created by Matt Farrugia on 23/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationDownloadCoverOperation.h"
#import "BITNetworkActivityManager.h"
#import "SCHAppRecommendationItem.h"

@interface SCHRecommendationDownloadCoverOperation()

@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, retain) QHTTPOperation *downloadOperation;
@property (nonatomic, assign) unsigned long long alreadyDownloadedSize;
@property (nonatomic, assign) unsigned long long currentDownloadedSize;

- (void)completedDownload;
- (void)failedDownload;
- (NSData *)jpegEOF;
- (NSData *)lastTwoBytes;
- (void)cancelOperationAndSuboperations;

@end

@implementation SCHRecommendationDownloadCoverOperation

@synthesize localPath;
@synthesize downloadOperation;
@synthesize alreadyDownloadedSize;
@synthesize currentDownloadedSize;

- (void)dealloc 
{
    [downloadOperation release], downloadOperation = nil;
    [localPath release], localPath = nil;
	[super dealloc];
}

#pragma mark - Operation Methods

- (void)beginOperation
{
    
    if (self.isbn == nil) {
        NSLog(@"WARNING: tried to download a book without setting the ISBN");
        [self failedDownload];
        return;
    }
    
    __block NSString *recommendationDirectory = nil;
    __block NSString *coverURL = nil;
    __block NSString *coverPath = nil;
    
    [self performWithRecommendation:^(SCHAppRecommendationItem *item) {
        recommendationDirectory = [[item recommendationDirectory] copy];
        coverPath = [[item coverImagePath] copy];
        coverURL = [[item CoverURL] copy];
    }];
    
    [recommendationDirectory autorelease];
    [coverPath autorelease];
    [coverURL autorelease];
    
    self.localPath = coverPath;
    
    BOOL coverURLIsValid = [SCHRecommendationManager urlIsValid:coverURL];
    
    if (!coverURLIsValid) {
        [self setCoverURLExpiredState];
        [self endOperation];
        return;            
    }
    
    if (self.localPath == nil || coverURL == nil || [coverURL isEqualToString:@""]) {
        NSLog(@"WARNING: problem with SCHAppRecommendation (ISBN: %@ localPath: %@ coverURL: %@", self.isbn, self.localPath, coverURL);
        [self setProcessingState:kSCHAppRecommendationProcessingStateUnspecifiedError];
        [self endOperation];
        return;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:coverURL]];
    
    [self willChangeValueForKey:@"isExecuting"];
    
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
	if ([fileManager fileExistsAtPath:self.localPath]) {
        // Delete the existing file first
        NSError *error = nil;
        if (![fileManager removeItemAtPath:self.localPath error:&error]) {
            NSLog(@"Error when deleting an existing file. Stopping. (%@)", [error localizedDescription]);
            [self failedDownload];
            return;
        }
    }
    
    [fileManager createFileAtPath:self.localPath contents:nil attributes:nil];
    
    NSMutableIndexSet *acceptableStatusCodes = [NSMutableIndexSet indexSetWithIndex:200];
    [acceptableStatusCodes addIndex:206];
    
    self.downloadOperation = [[[QHTTPOperation alloc] initWithRequest:request] autorelease];
    self.downloadOperation.acceptableStatusCodes = acceptableStatusCodes;
    self.downloadOperation.responseOutputStream = [NSOutputStream outputStreamToFileAtPath:self.localPath append:NO];
    self.downloadOperation.delegate = self;
	
    __block SCHRecommendationDownloadCoverOperation *unretained_self = self;
    self.downloadOperation.completionBlock = ^{        
        [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
        [unretained_self completedDownload];
    };
    
    [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];                
    
    [self.downloadOperation start];
    [self didChangeValueForKey:@"isExecuting"];
}

#pragma mark - QHTTPOperationDelegate methods

- (void)httpOperation:(QHTTPOperation *)operation startedDownloadingDataSize:(long long)expectedDataSize
{
    // Do nothing
}

- (void)httpOperation:(QHTTPOperation *)operation updatedDownloadSize:(long long)downloadedSize
{
    // Do nothing
}

- (void)httpOperation:(QHTTPOperation *)operation didFailWithError:(NSError *)error
{
    if ([error.domain isEqualToString:NSCocoaErrorDomain] && error.code == NSUserCancelledError) {
        [self endOperation];
    } else {
        NSLog(@"recommendation download operation failed with error: %@", error);
        
        [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
        
        // allow the operation to complete but change the completion handling
        __block SCHRecommendationDownloadCoverOperation *unretained_self = self;
        operation.completionBlock = ^{
            self.downloadOperation = nil;
            [unretained_self setProcessingState:kSCHAppRecommendationProcessingStateDownloadFailed];
            [unretained_self endOperation];
        };        
    }    
}

#pragma mark - File Download

- (void)completedDownload
{
    BOOL validImage = YES;
    
    // if there has been no data received, then the image is invalid
    if (!self.lastTwoBytes) {
        NSLog(@"Error downloading file %@ (no image data)", [self.localPath lastPathComponent]);
        validImage = NO;
    }
    
    // ignore validity check for books copied from a local file
    if (self.downloadOperation != nil) {
        NSData *jpegEOF = [self jpegEOF];
        
        // if the last two bytes don't match the EOI marker, the image is invalid
        if (![jpegEOF isEqualToData:self.lastTwoBytes]) {
            NSLog(@"Error downloading file %@ (invalid JPEG End Of Image marker)", [self.localPath lastPathComponent]);
            validImage = NO;
        }
        
        // NOTE: this could be expanded to verify PNG images too
        // IEND Image Trailer is 73 69 78 68 (decimal)
        // reference: http://www.w3.org/TR/PNG/#11IEND
    }
    
    if (!validImage) {
        [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
        
        // if there was an error, the file is invalid and is removed
        NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
        [fileManager removeItemAtPath:self.localPath error:nil];
        
        [self setProcessingState:kSCHAppRecommendationProcessingStateDownloadFailed];        
        
    } else {        
        [self setProcessingState:kSCHAppRecommendationProcessingStateNoThumbnails];
    }
	
    
    self.downloadOperation = nil;
    [self endOperation];
}

- (void)failedDownload
{
    [self setProcessingState:kSCHAppRecommendationProcessingStateDownloadFailed];
    [self endOperation];
}

- (NSData *)jpegEOF
{
    // these two bytes are the JPEG End Of Image Marker (EOI)
    // reference: http://www.fileformat.info/format/jpeg/egff.htm
    const char bytes[] = "\xff\xd9";
    // string literals have implicit trailing '\0'
    size_t length = (sizeof bytes) - 1; 
    
    // create a NSData matching the bytes
    return [NSData dataWithBytes:bytes length:length];
}

- (NSData *)lastTwoBytes
{
    NSData *downloadedFile = [NSData dataWithContentsOfMappedFile:self.localPath];
    if ([downloadedFile length] < 2) {
        return nil;
    }
    return [downloadedFile subdataWithRange:NSMakeRange([downloadedFile length]-2, 2)];
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

- (BOOL)isExecuting
{
    return self.downloadOperation != nil && [self.downloadOperation isExecuting];
}

@end
