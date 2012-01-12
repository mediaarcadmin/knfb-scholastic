//
//  SCHDownloadFileOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 22/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDownloadBookFileOperation.h"

#import "SCHAppBook.h"
#import "BITNetworkActivityManager.h"
#import "SCHUserContentItem.h"

#pragma mark - Class Extension

@interface SCHDownloadBookFileOperation ()

@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, assign) unsigned long bookFileSize;
@property (nonatomic, assign) unsigned long long expectedImageFileSize;
@property (nonatomic, retain) QHTTPOperation *downloadOperation;
@property (nonatomic, assign) unsigned long long alreadyDownloadedSize;
@property (nonatomic, assign) unsigned long long currentDownloadedSize;

// the previous percentage reported - used to limit percentage notifications
@property float previousPercentage;

- (NSString *)fullPathToBundledFile:(NSString *)fileName;
- (void)completedDownload;
- (void)failedDownload;
- (NSData *)lastTwoBytes;
- (NSData *)jpegEOF;
- (void)cancelOperationAndSuboperations;

@end

@implementation SCHDownloadBookFileOperation

@synthesize resume;
@synthesize localPath;
@synthesize fileType;
@synthesize bookFileSize;
@synthesize previousPercentage;
@synthesize expectedImageFileSize;
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
    NSError *error = nil;
    
    if (self.identifier == nil) {
        NSLog(@"WARNING: tried to download a book without setting the ISBN");
        [self failedDownload];
        return;
    }
    
    // check first to see if the file has been created
	NSMutableURLRequest *request = nil;
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    BOOL append = NO;
    
    [self performWithBook:^(SCHAppBook *book) {
        self.bookFileSize = [book.FileSize unsignedLongValue];
    }];

	if (self.fileType == kSCHDownloadFileTypeXPSBook) {
	
        __block NSString *bookFileURL = nil;
        __block BOOL bookFileURLIsFileURL = NO;
        [self performWithBook:^(SCHAppBook *book) {
            self.localPath = [book xpsPath];
            bookFileURL = [[book BookFileURL] retain];
            bookFileURLIsFileURL = [book bookFileURLIsBundleURL];
        }];
        
        if (self.localPath == nil || bookFileURL == nil || [bookFileURL compare:@""] == NSOrderedSame) {
            NSLog(@"WARNING: problem with SCHAppBook (ISBN: %@ localPath: %@ bookFileURL: %@", self.identifier, self.localPath, bookFileURL);
            [self failedDownload];
            [bookFileURL release];            
            return;
        }
        
        if (bookFileURLIsFileURL) {
            if ([fileManager fileExistsAtPath:self.localPath]) {
                if (![fileManager removeItemAtPath:self.localPath error:&error]) {
                    NSLog(@"Unable to remove existing item at path: %@ %@", self.localPath, error);
                }
            }
            
            if (![fileManager copyItemAtPath:[self fullPathToBundledFile:bookFileURL]
                                      toPath:self.localPath 
                                       error:&error]) {   
                NSLog(@"Error copying XPS file from bundle: %@, %@", error, [error userInfo]);
                [self failedDownload];
            } else {
                [self completedDownload];
            }
            [bookFileURL release];            
            return;
            
        } else {
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:bookFileURL]];
        }
        
        [bookFileURL release];
	} else if (self.fileType == kSCHDownloadFileTypeCoverImage) {

        __block NSString *bookDirectory = nil;
        __block NSString *contentIdentifier = nil;
        __block NSString *coverURL = nil;
        __block BOOL coverURLIsFileURL = NO;
        [self performWithBook:^(SCHAppBook *book) {
            bookDirectory = [[book bookDirectory] retain];
            contentIdentifier = [[book ContentIdentifier] retain];
            self.localPath = [book coverImagePath];
            coverURL = [[book BookCoverURL] retain];
            coverURLIsFileURL = [book bookCoverURLIsBundleURL];
        }];
		
        if (self.localPath == nil || coverURL == nil || [coverURL compare:@""] == NSOrderedSame) {
            NSLog(@"WARNING: problem with SCHAppBook (ISBN: %@ localPath: %@ coverURL: %@", self.identifier, self.localPath, coverURL);
            [self setProcessingState:SCHBookProcessingStateError];
            [self setIsProcessing:NO];                                
            [self endOperation];
            [coverURL release];            
            return;
        }

        if (coverURLIsFileURL) {
            if ([fileManager fileExistsAtPath:self.localPath]) {
                if (![fileManager removeItemAtPath:self.localPath error:&error]) {
                    NSLog(@"Unable to remove existing item at path: %@ %@", self.localPath, error);
                }
            }
            
            if (![fileManager copyItemAtPath:[self fullPathToBundledFile:coverURL]
                                                    toPath:self.localPath 
                                       error:&error]) {     
                NSLog(@"Error copying cover file from bundle: %@, %@", error, [error userInfo]);
                [self failedDownload];
            } else {
                [self completedDownload];
            }
            [bookDirectory release];
            [contentIdentifier release];
            [coverURL release];
            return;

        } else {
            request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:coverURL]];
        }
        
        [bookDirectory release];
        [contentIdentifier release];
        [coverURL release];

	} else {
		[NSException raise:@"SCHDownloadFileOperationUnknownFileType" format:@"Unknown file type for SCHDownloadFileOperation."];
	}
    
    [self willChangeValueForKey:@"isExecuting"];
	
	unsigned long long currentFilesize = 0;
    self.previousPercentage = -1;
	self.expectedImageFileSize = 0;
    self.alreadyDownloadedSize = 0;
    
	if ([fileManager fileExistsAtPath:self.localPath]) {
		// check to see how much of the file has been downloaded

		if (!self.resume) {
			// if we're not resuming, delete the existing file first
            NSError *error = nil;
			if (![fileManager removeItemAtPath:localPath error:&error]) {
				NSLog(@"Error when deleting an existing file. Stopping. (%@)", [error localizedDescription]);
                [self failedDownload];
				return;
			}
		} else {
            NSError *error = nil;
			NSDictionary *attributes = [fileManager attributesOfItemAtPath:localPath error:&error];
            if (!attributes) {
				NSLog(@"Error when reading file attributes. Stopping. (%@)", [error localizedDescription]);
                [self failedDownload];
				return;
			}
            currentFilesize = [attributes fileSize];
		}
	}
		
	if (currentFilesize > 0) {
        NSLog(@"Already have %llu bytes, need %llu bytes more.", currentFilesize, self.bookFileSize - currentFilesize);
		[request setValue:[NSString stringWithFormat:@"bytes=%llu-", currentFilesize] forHTTPHeaderField:@"Range"];
        self.alreadyDownloadedSize = currentFilesize;
        append = YES;
	} else {
		[fileManager createFileAtPath:self.localPath contents:nil attributes:nil];
	}
    
    NSMutableIndexSet *acceptableStatusCodes = [NSMutableIndexSet indexSetWithIndex:200];
    [acceptableStatusCodes addIndex:206];

    self.downloadOperation = [[[QHTTPOperation alloc] initWithRequest:request] autorelease];
    self.downloadOperation.acceptableStatusCodes = acceptableStatusCodes;
    self.downloadOperation.responseOutputStream = [NSOutputStream outputStreamToFileAtPath:self.localPath append:append];
    self.downloadOperation.delegate = self;
	
    __block SCHDownloadBookFileOperation *unretained_self = self;
    self.downloadOperation.completionBlock = ^{
        if (unretained_self.fileType == kSCHDownloadFileTypeXPSBook) {
            NSLog(@"Finished file %@. [downloaded: %llu expected:%lu]", [unretained_self.localPath lastPathComponent], 
                  currentFilesize, unretained_self.bookFileSize);
        } else {
            NSLog(@"Finished file %@. [downloaded: %llu]", [unretained_self.localPath lastPathComponent], currentFilesize);        
        }
        
        [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
        [unretained_self completedDownload];
    };
        
    [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];                
    
    [self.downloadOperation start];
    [self didChangeValueForKey:@"isExecuting"];
}

- (NSString *)fullPathToBundledFile:(NSString *)fileName
{
    NSString *ret = nil;
    
    if (fileName != nil) {
        ret = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
    }
    
    return(ret);
}

#pragma mark - Notification methods

- (void)createPercentageUpdate
{    
    float totalDownloadedSize = self.alreadyDownloadedSize + self.currentDownloadedSize;
    float percentage = (self.bookFileSize > 0 ? (totalDownloadedSize / self.bookFileSize) : 0.0);
    
    if (percentage - self.previousPercentage > 0.001f) {
        
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:percentage], @"currentPercentage",
                                  self.identifier, @"bookIdentifier",
                                  nil];
        
        [self performSelectorOnMainThread:@selector(firePercentageUpdate:) 
                               withObject:userInfo
                            waitUntilDone:NO];
        
        self.previousPercentage = percentage;
	}
}

- (void)firePercentageUpdate:(NSDictionary *)userInfo
{
    NSAssert(userInfo != nil, @"firePercentageUpdate is incorrectly being called with no userInfo");
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookDownloadPercentageUpdate" 
                                                        object:nil 
                                                      userInfo:userInfo];
}

#pragma mark - QHTTPOperationDelegate methods

- (void)httpOperation:(QHTTPOperation *)operation startedDownloadingDataSize:(long long)expectedDataSize
{
    if (self.fileType == kSCHDownloadFileTypeCoverImage) {
        self.expectedImageFileSize = expectedDataSize;
    } 
    
    NSLog(@"Filesize receiving:%llu for file %@", expectedDataSize, self.localPath);
}

- (void)httpOperation:(QHTTPOperation *)operation updatedDownloadSize:(long long)downloadedSize
{
    if ([self processingState] == SCHBookProcessingStateDownloadPaused) {
        [self cancelOperationAndSuboperations];
    } else {
        self.currentDownloadedSize = downloadedSize;
        if (self.fileType == kSCHDownloadFileTypeXPSBook) {
            [self createPercentageUpdate];
        }
    }
}

- (void)httpOperation:(QHTTPOperation *)operation didFailWithError:(NSError *)error
{
    if ([error.domain isEqualToString:NSCocoaErrorDomain] && error.code == NSUserCancelledError) {
        [self setIsProcessing:NO];        
        [self endOperation];
    } else {
        NSLog(@"book download operation failed with error: %@", error);
        
        [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
        
        // allow the operation to complete but change the completion handling
        __block SCHDownloadBookFileOperation *unretained_self = self;
        operation.completionBlock = ^{
            self.downloadOperation = nil;
            [unretained_self setIsProcessing:NO];
            [unretained_self setProcessingState:SCHBookProcessingStateDownloadFailed];
            [unretained_self endOperation];
        };        
    }    
}

- (void)completedDownload
{
	switch (self.fileType) {
		case kSCHDownloadFileTypeXPSBook:
        {
            [self performWithBookAndSave:^(SCHAppBook *book) {
                
                int contentMetadataVersion = [[[book ContentMetadataItem] Version] intValue];
                int userContentVersion = [[[[book ContentMetadataItem] UserContentItem] LastVersion] intValue];
                
                if (contentMetadataVersion > userContentVersion) {
                    book.OnDiskVersion = [[book ContentMetadataItem] Version];
                } else {
                    book.OnDiskVersion = [[[book ContentMetadataItem] UserContentItem] LastVersion];
                }
                book.XPSExists = [NSNumber numberWithBool:YES];
            }];
            
            [self setProcessingState:SCHBookProcessingStateReadyForLicenseAcquisition];
            NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                      [NSNumber numberWithFloat:1.0], @"currentPercentage",
                                      self.identifier, @"bookIdentifier",
                                      nil];
            
            [self performSelectorOnMainThread:@selector(firePercentageUpdate:) 
                                   withObject:userInfo
                                waitUntilDone:YES];            
			break;
        }
		case kSCHDownloadFileTypeCoverImage:
        {
            BOOL validImage = YES;
            
            // first, check the file size - does it match what the server said?
            // if not, it has likely become corrupt
            unsigned long long totalDownloadedSize = self.alreadyDownloadedSize + self.currentDownloadedSize;
            if (self.expectedImageFileSize != totalDownloadedSize) {
                NSLog(@"Error downloading file %@ (image filesize did not match)", [self.localPath lastPathComponent]);
                validImage = NO;
            } 
            
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
                
                [self setProcessingState:SCHBookProcessingStateDownloadFailed];        
                
            } else {
                [self performWithBookAndSave:^(SCHAppBook *book) {
                    book.BookCoverExists = [NSNumber numberWithBool:YES];
                }];            
                [self setProcessingState:SCHBookProcessingStateReadyForBookFileDownload];
            }
			break;
        }
		default:
        {
			break;
        }
	}

    self.downloadOperation = nil;
    [self setIsProcessing:NO];        
    [self endOperation];
}

- (void)failedDownload
{
    [self setProcessingState:SCHBookProcessingStateDownloadFailed];
    [self setIsProcessing:NO];                                
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
