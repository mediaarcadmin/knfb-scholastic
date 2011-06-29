//
//  SCHDownloadFileOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 22/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDownloadBookFileOperation.h"
#import "SCHProcessingManager.h"
#import "SCHAppBook.h"
#import "SCHBookManager.h"

#pragma mark - Class Extension

@interface SCHDownloadBookFileOperation ()

@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, assign) unsigned long bookFileSize;

@end

@implementation SCHDownloadBookFileOperation

@synthesize resume;
@synthesize localPath;
@synthesize fileType;
@synthesize bookFileSize;

- (void)dealloc 
{
    [localPath release], localPath = nil;
	[super dealloc];
}

#pragma mark - Operation Methods

- (void)beginOperation
{
    if (self.isbn == nil) {
        NSLog(@"WARNING: tried to download a book without setting the ISBN");
        [self setProcessingState:SCHBookProcessingStateError forBook:self.isbn];
        [self endOperation];
        return;
    }
    
    // check first to see if the file has been created
	NSMutableURLRequest *request = nil;

    [self withBook:self.isbn perform:^(SCHAppBook *book) {
        self.bookFileSize = [book.FileSize unsignedLongValue];
    }];

	if (self.fileType == kSCHDownloadFileTypeXPSBook) {
	
        __block NSString *bookFileURL = nil;
        [self withBook:self.isbn perform:^(SCHAppBook *book) {
            self.localPath = [book xpsPath];
            bookFileURL = [[book BookFileURL] retain];
        }];
        
        if (self.localPath == nil || bookFileURL == nil || [bookFileURL compare:@""] == NSOrderedSame) {
            NSLog(@"WARNING: problem with SCHAppBook (ISBN: %@ localPath: %@ bookFileURL: %@", self.isbn, self.localPath, bookFileURL);
            [self setProcessingState:SCHBookProcessingStateError forBook:self.isbn];
            [self endOperation];
            return;
        }
        
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:bookFileURL]];
        [bookFileURL release];
		
	} else if (self.fileType == kSCHDownloadFileTypeCoverImage) {

        __block NSString *cacheDir = nil;
        __block NSString *contentIdentifier = nil;
        __block NSString *coverURL = nil;
        [self withBook:self.isbn perform:^(SCHAppBook *book) {
            cacheDir = [[book cacheDirectory] retain];
            contentIdentifier = [[book ContentIdentifier] retain];
            coverURL = [[book BookCoverURL] retain];
        }];
        
		self.localPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", contentIdentifier]];
		
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:coverURL]];
        
        [cacheDir release];
        [contentIdentifier release];
        [coverURL release];

	} else {
		[NSException raise:@"SCHDownloadFileOperationUnknownFileType" format:@"Unknown file type for SCHDownloadFileOperation."];
	}
	
	unsigned long long fileSize = 0;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.localPath]) {
		// check to see how much of the file has been downloaded

		if (!self.resume) {
			// if we're not resuming, delete the existing file first
            NSError *error = nil;
			if (![[NSFileManager defaultManager] removeItemAtPath:localPath error:&error]) {
				NSLog(@"Error when deleting an existing file. Stopping. (%@)", [error localizedDescription]);
				return;
			}
		} else {
            NSError *error = nil;
			NSDictionary *attributes = [[NSFileManager defaultManager] attributesOfItemAtPath:localPath error:&error];
            if (!attributes) {
				NSLog(@"Error when reading file attributes. Stopping. (%@)", [error localizedDescription]);
				return;
			}
            fileSize = [attributes fileSize];
		}
	}
		
	if (fileSize > 0) {
        NSLog(@"Already have %llu bytes, need %llu bytes more.", fileSize, self.bookFileSize - fileSize);
		[request setValue:[NSString stringWithFormat:@"bytes=%llu-", fileSize] forHTTPHeaderField:@"Range"];
	} else {
		[[NSFileManager defaultManager] createFileAtPath:self.localPath contents:nil attributes:nil];
	}

	
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];

	[connection start];
	
	if (connection != nil) {
		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (!self.finished);
	}
    
	[self setBook:self.isbn isProcessing:NO];
	return;
}

#pragma mark -
#pragma mark Notification methods

- (void)percentageUpdate:(NSDictionary *)userInfo
{
	if (self.fileType == kSCHDownloadFileTypeXPSBook) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookDownloadPercentageUpdate" object:nil userInfo:userInfo];
	}
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
	@synchronized(self) {
		NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:self.localPath];
		[handle seekToEndOfFile];
		[handle writeData:data];
		[handle closeFile];
	}
	
	if ([self isCancelled] || [self processingStateForBook:self.isbn] == SCHBookProcessingStateDownloadPaused) {
		[connection cancel];
        
        [self endOperation];
        
		return;
	}
	
	NSError *error = nil;
	
	unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.localPath error:&error] fileSize];

	if (error) {
		NSLog(@"Warning: could not get filesize for %@. %@", self.localPath, [error localizedDescription]);
	}
	
	
	float percentage = (float) ((float) fileSize/self.bookFileSize);
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat:percentage], @"currentPercentage",
							  self.isbn, @"isbn",
							  nil];
	
	//NSLog(@"percentage for %@: %2.2f%%", self.bookInfo.contentMetadata.Title, percentage * 100);
	
	[self performSelectorOnMainThread:@selector(percentageUpdate:) 
						   withObject:userInfo
						waitUntilDone:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"Finished file %@.", [self.localPath lastPathComponent]);
	
	switch (self.fileType) {
		case kSCHDownloadFileTypeXPSBook:
            [self setProcessingState:SCHBookProcessingStateReadyForLicenseAcquisition forBook:self.isbn];
			break;
		case kSCHDownloadFileTypeCoverImage:
            [self setProcessingState:SCHBookProcessingStateReadyForBookFileDownload forBook:self.isbn];
			break;
		default:
			break;
	}
	
	
    [self endOperation];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Error downloading file %@!", [self.localPath lastPathComponent]);

    [self setProcessingState:SCHBookProcessingStateError forBook:self.isbn];
    [self endOperation];
}

@end
