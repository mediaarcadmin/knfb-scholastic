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

#pragma mark - Class Extension

@interface SCHDownloadBookFileOperation ()

@property (nonatomic, copy) NSString *localPath;
@property (nonatomic, assign) unsigned long bookFileSize;
@property (nonatomic, retain) NSFileHandle *fileHandle;
@property (nonatomic, assign) unsigned long long currentFilesize;

- (BOOL)stringBeginsWithHTTPScheme:(NSString *)string;
- (NSString *)fullPathToBundledFile:(NSString *)fileName;
- (void)completedDownload;

@end

@implementation SCHDownloadBookFileOperation

@synthesize resume;
@synthesize localPath;
@synthesize fileType;
@synthesize bookFileSize;
@synthesize fileHandle;
@synthesize currentFilesize;

- (void)dealloc 
{
    [localPath release], localPath = nil;
    [fileHandle closeFile];
    [fileHandle release], fileHandle = nil;
	[super dealloc];
}

#pragma mark - Operation Methods

- (void)beginOperation
{
    NSError *error = nil;
    
    // Following Dave Dribins pattern 
    // http://www.dribin.org/dave/blog/archives/2009/05/05/concurrent_operations/
    if (![NSThread isMainThread])
    {
        [self performSelectorOnMainThread:@selector(beginOperation) withObject:nil waitUntilDone:NO];
        return;
    }
    
    if (self.identifier == nil) {
        NSLog(@"WARNING: tried to download a book without setting the ISBN");
        [self setProcessingState:SCHBookProcessingStateError];
        [self setIsProcessing:NO];                
        [self endOperation];
        return;
    }
    
    // check first to see if the file has been created
	NSMutableURLRequest *request = nil;
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
    
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
            [self setIsProcessing:NO];                                
            [self endOperation];
            [bookFileURL release];            
            return;
        }
        
        if ([self stringBeginsWithHTTPScheme:bookFileURL] == NO) {
            [fileManager copyItemAtPath:[self fullPathToBundledFile:bookFileURL]
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
            [fileManager copyItemAtPath:[self fullPathToBundledFile:coverURL]
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
	
	self.currentFilesize = 0;
	
	if ([fileManager fileExistsAtPath:self.localPath]) {
		// check to see how much of the file has been downloaded

		if (!self.resume) {
			// if we're not resuming, delete the existing file first
            NSError *error = nil;
			if (![fileManager removeItemAtPath:localPath error:&error]) {
				NSLog(@"Error when deleting an existing file. Stopping. (%@)", [error localizedDescription]);
                [self setIsProcessing:NO];                
                [self endOperation];
				return;
			}
		} else {
            NSError *error = nil;
			NSDictionary *attributes = [fileManager attributesOfItemAtPath:localPath error:&error];
            if (!attributes) {
				NSLog(@"Error when reading file attributes. Stopping. (%@)", [error localizedDescription]);
                [self setIsProcessing:NO];                
                [self endOperation];
				return;
			}
            self.currentFilesize = [attributes fileSize];
		}
	}
		
	if (self.currentFilesize > 0) {
        NSLog(@"Already have %llu bytes, need %llu bytes more.", self.currentFilesize, self.bookFileSize - self.currentFilesize);
		[request setValue:[NSString stringWithFormat:@"bytes=%llu-", self.currentFilesize] forHTTPHeaderField:@"Range"];
	} else {
		[fileManager createFileAtPath:self.localPath contents:nil attributes:nil];
	}

	
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];

	if (connection == nil) {
        [self setIsProcessing:NO];        
        [self endOperation];
    } else {
        [connection start];
        [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];                
    }
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

#pragma mark - Notification methods

- (void)percentageUpdate:(NSDictionary *)userInfo
{
    //NSLog(@"Percentage update sent %@", userInfo);
	if (self.fileType == kSCHDownloadFileTypeXPSBook) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookDownloadPercentageUpdate" 
                                                            object:nil 
                                                          userInfo:userInfo];
	}
}

#pragma mark - NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]] == YES) {
        if ([(NSHTTPURLResponse *)response statusCode] != 200 && 
            [(NSHTTPURLResponse *)response statusCode] != 206) {
            [connection cancel];
            [self setProcessingState:SCHBookProcessingStateDownloadFailed];            
            [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
            NSLog(@"Error downloading file, errorCode: %d", [(NSHTTPURLResponse *)response statusCode]);
            [self setIsProcessing:NO];        
            [self endOperation];
            return;
        }
    } 
    
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.localPath];
    [self.fileHandle seekToEndOfFile];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data 
{
    if ([self isCancelled] || [self processingState] == SCHBookProcessingStateDownloadPaused) {
		[connection cancel];
        [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
        [self.fileHandle closeFile];
        self.fileHandle = nil;        
        [self setIsProcessing:NO];        
        [self endOperation];
		return;
	}

	@synchronized(self) {
        @try {
            [self.fileHandle writeData:data];
            self.currentFilesize += [data length];            
        }
        @catch (NSException *exception) {
            [connection cancel];
            [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];                        
            [self setProcessingState:SCHBookProcessingStateDownloadFailed];            
            [self.fileHandle closeFile];
            self.fileHandle = nil;            
            [self setIsProcessing:NO];        
            [self endOperation];
            return;
        }
	}
	
	float percentage = (self.bookFileSize > 0 ? (float) ((float) self.currentFilesize/self.bookFileSize) : 0.0);
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat:percentage], @"currentPercentage",
							  self.identifier, @"bookIdentifier",
							  nil];
	
	//NSLog(@"percentage for %@: %2.2f%%", self.bookInfo.contentMetadata.Title, percentage * 100);
	
	[self performSelectorOnMainThread:@selector(percentageUpdate:) 
						   withObject:userInfo
						waitUntilDone:NO];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"Finished file %@.", [self.localPath lastPathComponent]);
    [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
    [self completedDownload];
}

- (void)completedDownload
{
	switch (self.fileType) {
		case kSCHDownloadFileTypeXPSBook:
            [self performWithBookAndSave:^(SCHAppBook *book) {
                book.OnDiskVersion = book.Version;
                book.XPSExists = [NSNumber numberWithBool:YES];
            }];
            [self setProcessingState:SCHBookProcessingStateReadyForLicenseAcquisition];
			break;
		case kSCHDownloadFileTypeCoverImage:
            [self performWithBookAndSave:^(SCHAppBook *book) {
                book.BookCoverExists = [NSNumber numberWithBool:YES];
            }];            
            [self setProcessingState:SCHBookProcessingStateReadyForBookFileDownload];
			break;
		default:
			break;
	}

    [self.fileHandle closeFile];
    self.fileHandle = nil;
    [self setIsProcessing:NO];        
    [self endOperation];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
    
    // if there was an error may just have a partial file, so remove it
    NSFileManager *fileManager = [[[NSFileManager alloc] init] autorelease];
   [fileManager removeItemAtPath:self.localPath error:nil];

    if ([self isCancelled] || [self processingState] == SCHBookProcessingStateDownloadPaused) {
		[connection cancel];
	} else {
        [self setProcessingState:SCHBookProcessingStateDownloadFailed];        
    }
    
	NSLog(@"Error downloading file %@ (%@ : %@)", [self.localPath lastPathComponent], error, [error userInfo]);

    [self.fileHandle closeFile];
    self.fileHandle = nil;
    [self setIsProcessing:NO];            
    [self endOperation];
}

@end
