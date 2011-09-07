//
//  SCHDownloadFileOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 22/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDownloadBookFileOperation.h"

#import "SCHAppBook.h"

#pragma mark - Class Extension

@interface SCHDownloadBookFileOperation ()

@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, assign) unsigned long bookFileSize;

- (BOOL)stringBeginsWithHTTPScheme:(NSString *)string;
- (NSString *)fullPathToBundledFile:(NSString *)fileName;
- (void)completedDownload;

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
    NSError *error = nil;
    
    if (self.identifier == nil) {
        NSLog(@"WARNING: tried to download a book without setting the ISBN");
        [self setProcessingState:SCHBookProcessingStateError];
        [self endOperation];
        return;
    }
    
    // check first to see if the file has been created
	NSMutableURLRequest *request = nil;

    [self performWithBook:^(SCHAppBook *book) {
        self.bookFileSize = [book.FileSize unsignedLongValue];
    }];

	if (self.fileType == kSCHDownloadFileTypeXPSBook) {
	
        __block NSString *bookFileURL = nil;
        [self performWithBook:^(SCHAppBook *book) {
            self.localPath = [book xpsPath];
            bookFileURL = [[book BookFileURL] retain];
        }];
        
        if (self.localPath == nil || bookFileURL == nil || [bookFileURL compare:@""] == NSOrderedSame) {
            NSLog(@"WARNING: problem with SCHAppBook (ISBN: %@ localPath: %@ bookFileURL: %@", self.identifier, self.localPath, bookFileURL);
            [self setProcessingState:SCHBookProcessingStateError];
            [self endOperation];
            [bookFileURL release];            
            return;
        }
        
        if ([self stringBeginsWithHTTPScheme:bookFileURL] == NO) {
            [[NSFileManager defaultManager] copyItemAtPath:[self fullPathToBundledFile:bookFileURL]
                                                    toPath:self.localPath 
                                                     error:&error];        
            if (error != nil) {
                NSLog(@"Error copying XPS file from bundle: %@, %@", error, [error userInfo]);
            } 
            
            [self completedDownload];	
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
        [self performWithBook:^(SCHAppBook *book) {
            bookDirectory = [[book bookDirectory] retain];
            contentIdentifier = [[book ContentIdentifier] retain];
            self.localPath = [book coverImagePath];
            coverURL = [[book BookCoverURL] retain];
        }];
		
        if ([self stringBeginsWithHTTPScheme:coverURL] == NO) {
            [[NSFileManager defaultManager] copyItemAtPath:[self fullPathToBundledFile:coverURL]
                                                    toPath:self.localPath 
                                                     error:&error];        
            if (error != nil) {
                NSLog(@"Error copying cover file from bundle: %@, %@", error, [error userInfo]);
            } 
            
            [self completedDownload];
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
    
	[self setIsProcessing:NO];
	return;
}

- (BOOL)stringBeginsWithHTTPScheme:(NSString *)string
{
    BOOL ret = NO;
    
    if (([string length] >= 7 && [[string substringToIndex:7] isEqualToString:@"http://"] == YES) ||
        ([string length] >= 8 && [[string substringToIndex:8] isEqualToString:@"https://"] == YES)) {
        ret = YES;
    }
    
    return(ret);
}

- (NSString *)fullPathToBundledFile:(NSString *)fileName
{
    NSString *ret = nil;
    
    if (fileName != nil) {
        ret = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:fileName];
    }
    
    return(ret);
}

#pragma mark -
#pragma mark Notification methods

- (void)percentageUpdate:(NSDictionary *)userInfo
{
	if ([self isCancelled] || [self processingState] == SCHBookProcessingStateDownloadPaused) {
        [self endOperation];
		return;
	}
    
    //NSLog(@"Percentage update sent %@", userInfo);
	if (self.fileType == kSCHDownloadFileTypeXPSBook) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookDownloadPercentageUpdate" object:nil userInfo:userInfo];
	}
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    if ([self isCancelled] || [self processingState] == SCHBookProcessingStateDownloadPaused) {
		[connection cancel];
        [self endOperation];
		return;
	}

	@synchronized(self) {
		NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:self.localPath];
		[handle seekToEndOfFile];
		[handle writeData:data];
		[handle closeFile];
	}
		
	NSError *error = nil;
	
	unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.localPath error:&error] fileSize];

	if (error) {
		NSLog(@"Warning: could not get filesize for %@. %@", self.localPath, [error localizedDescription]);
	}
	
	
	float percentage = (self.bookFileSize > 0 ? (float) ((float) fileSize/self.bookFileSize) : 0.0);
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat:percentage], @"currentPercentage",
							  self.identifier, @"bookIdentifier",
							  nil];
	
	//NSLog(@"percentage for %@: %2.2f%%", self.bookInfo.contentMetadata.Title, percentage * 100);
	
	[self performSelectorOnMainThread:@selector(percentageUpdate:) 
						   withObject:userInfo
						waitUntilDone:YES];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"Finished file %@.", [self.localPath lastPathComponent]);
    
    [self completedDownload];
}

- (void)completedDownload
{
	switch (self.fileType) {
		case kSCHDownloadFileTypeXPSBook:
            [self performWithBookAndSave:^(SCHAppBook *book) {
                book.OnDiskVersion = book.Version;                
            }];
            [self setProcessingState:SCHBookProcessingStateReadyForLicenseAcquisition];
			break;
		case kSCHDownloadFileTypeCoverImage:
            [self setProcessingState:SCHBookProcessingStateReadyForBookFileDownload];
			break;
		default:
			break;
	}
	
    [self endOperation];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    // if there was an error may just have a partial file, so remove it
   [[NSFileManager defaultManager] removeItemAtPath:self.localPath error:nil];

    if ([self isCancelled] || [self processingState] == SCHBookProcessingStateDownloadPaused) {
		[connection cancel];        
        [self endOperation];
		return;
	}

	NSLog(@"Error downloading file %@ (%@ : %@)", [self.localPath lastPathComponent], error, [error userInfo]);

    [self setProcessingState:SCHBookProcessingStateDownloadFailed];
    [self endOperation];
}

@end
