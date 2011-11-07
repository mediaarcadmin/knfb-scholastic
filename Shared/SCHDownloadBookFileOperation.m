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
@property (nonatomic, assign) unsigned long long expectedImageFileSize;
@property (nonatomic, retain) NSData *lastTwoBytes;

// the previous percentage reported - used to limit percentage notifications
@property float previousPercentage;

- (BOOL)stringBeginsWithHTTPScheme:(NSString *)string;
- (NSString *)fullPathToBundledFile:(NSString *)fileName;
- (void)completedDownload;
- (NSData *)jpegEOF;

@end

@implementation SCHDownloadBookFileOperation

@synthesize resume;
@synthesize localPath;
@synthesize fileType;
@synthesize bookFileSize;
@synthesize fileHandle;
@synthesize currentFilesize;
@synthesize previousPercentage;
@synthesize expectedImageFileSize;
@synthesize lastTwoBytes;

- (void)dealloc 
{
    [lastTwoBytes release], lastTwoBytes = nil;
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
		
        if (self.localPath == nil || coverURL == nil || [coverURL compare:@""] == NSOrderedSame) {
            NSLog(@"WARNING: problem with SCHAppBook (ISBN: %@ localPath: %@ coverURL: %@", self.identifier, self.localPath, coverURL);
            [self setProcessingState:SCHBookProcessingStateError];
            [self setIsProcessing:NO];                                
            [self endOperation];
            [coverURL release];            
            return;
        }

        if ([self stringBeginsWithHTTPScheme:coverURL] == NO) {
            [fileManager copyItemAtPath:[self fullPathToBundledFile:coverURL]
                                                    toPath:self.localPath 
                                                     error:&error];        
            if (error != nil) {
                NSLog(@"Error copying cover file from bundle: %@, %@", error, [error userInfo]);
            } 
            
            self.lastTwoBytes = [self jpegEOF];

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
    self.previousPercentage = -1;
	self.expectedImageFileSize = 0;
    
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

- (void)createPercentageUpdate
{    
    float percentage = (self.bookFileSize > 0 ? (float) ((float)self.currentFilesize / self.bookFileSize) : 0.0);
    
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
        
        if (self.fileType == kSCHDownloadFileTypeCoverImage) {
            self.expectedImageFileSize = [response expectedContentLength]; 
        }
    } 
    
    NSLog(@"Filesize receiving:%llu expected:%llu for file %@", self.currentFilesize, [response expectedContentLength], self.localPath);
    
    NSFileManager *manager = [[NSFileManager alloc] init];
    
    if ([manager fileExistsAtPath:self.localPath]) {
        if ([[[manager attributesOfItemAtPath:[self localPath] error:nil] valueForKey:@"NSFileSize"] intValue] > 0) {
            if ([(NSHTTPURLResponse *)response statusCode] != 206) {
                NSLog(@"WOOOOOOOOOOOAAAAAAAAHHHHHH DUUUUUUUUDE! We already have a partial file there");
            }
        }
    }
    [manager release];

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
            
            // keep a record of the last two bytes for validity checking
            NSRange lastRange = NSMakeRange([data length] - 2, 2);
            self.lastTwoBytes = [data subdataWithRange:lastRange];
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

    if (self.fileType == kSCHDownloadFileTypeXPSBook) {
        [self createPercentageUpdate];
    }
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    if (self.fileType == kSCHDownloadFileTypeXPSBook) {
        NSLog(@"Finished file %@. [downloaded: %llu expected:%lu]", [self.localPath lastPathComponent], 
              self.currentFilesize, self.bookFileSize);
    } else {
        NSLog(@"Finished file %@. [downloaded: %llu]", [self.localPath lastPathComponent], 
              self.currentFilesize);        
    }
    
    [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
    [self completedDownload];
}

- (void)completedDownload
{
	switch (self.fileType) {
		case kSCHDownloadFileTypeXPSBook:
        {
            [self performWithBookAndSave:^(SCHAppBook *book) {
                book.OnDiskVersion = book.Version;
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
            if (self.expectedImageFileSize != self.currentFilesize) {
                NSLog(@"Error downloading file %@ (image filesize did not match)", [self.localPath lastPathComponent]);
                validImage = NO;
            } 
            
            // if there has been no data received, then the image is invalid
            if (!self.lastTwoBytes) {
                NSLog(@"Error downloading file %@ (no image data)", [self.localPath lastPathComponent]);
                validImage = NO;
            }
            
            NSData *jpegEOF = [self jpegEOF];
            
            // if the last two bytes don't match the EOI marker, the image is invalid
            if (![jpegEOF isEqualToData:self.lastTwoBytes]) {
                NSLog(@"Error downloading file %@ (invalid JPEG End Of Image marker)", [self.localPath lastPathComponent]);
                validImage = NO;
            }
            
            // NOTE: this could be expanded to verify PNG images too
            // IEND Image Trailer is 73 69 78 68 (decimal)
            // reference: http://www.w3.org/TR/PNG/#11IEND

            
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
            
            self.lastTwoBytes = nil;
			break;
        }
		default:
        {
			break;
        }
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

    self.lastTwoBytes = nil;
    [self.fileHandle closeFile];
    self.fileHandle = nil;
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

@end
