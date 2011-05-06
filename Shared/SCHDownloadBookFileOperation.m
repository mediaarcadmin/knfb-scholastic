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

@interface SCHDownloadBookFileOperation ()

@property (readwrite, retain) NSString *localPath;

@end


@implementation SCHDownloadBookFileOperation


@synthesize resume, localPath, fileType;

- (void)dealloc {
	self.localPath = nil;
	
	[super dealloc];
}

- (void) start
{
	NSString *type = @"XPS Book File";
	
	if (self.fileType == kSCHDownloadFileTypeCoverImage) {
		type = @"Cover Image";
	}
	
	NSLog(@"Starting %@ download.", type);
    
    [super start];
}

- (void) beginOperation
{
    if (self.isbn == nil) {
        NSLog(@"WARNING: tried to download a book without setting the ISBN");
        [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateError];
        [self endOperation];
        return;
    }
    
	NSError *error = nil;
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	

    if (book == nil) {
        NSLog(@"WARNING: invalid SCHAppBook returned for ISBN %@", self.isbn);
        [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateError];
        [self endOperation];
        return;
    }
	
    // check first to see if the file has been created
	NSMutableURLRequest *request = nil;

	if (self.fileType == kSCHDownloadFileTypeXPSBook) {
	
		self.localPath = [book xpsPath];
        NSString *bookFileURL = [book BookFileURL];
        
        if (self.localPath == nil || bookFileURL == nil || [bookFileURL compare:@""] == NSOrderedSame) {
            NSLog(@"WARNING: problem with SCHAppBook (ISBN: %@ localPath: %@ bookFileURL: %@", self.isbn, self.localPath, bookFileURL);
            [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateError];
            [self endOperation];
            return;
        }
        
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:bookFileURL]];
		
	} else if (self.fileType == kSCHDownloadFileTypeCoverImage) {
		
		NSString *cacheDir  = [book cacheDirectory];
		self.localPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", book.ContentIdentifier]];
		
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:book.BookCoverURL]];

	} else {
		[NSException raise:@"SCHDownloadFileOperationUnknownFileType" format:@"Unknown file type for SCHDownloadFileOperation."];
	}
	
	unsigned long long fileSize = 0;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.localPath]) {
		// check to see how much of the file has been downloaded

		if (!self.resume) {
			// if we're not resuming, delete the existing file first
			[[NSFileManager defaultManager] removeItemAtPath:localPath error:&error];
			
			if (error) {
				NSLog(@"Error when deleting an existing file. Stopping. (%@)", [error localizedDescription]);
				return;
			}
		} else {
			fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:localPath error:&error] fileSize];
			
			if (error) {
				NSLog(@"Error when reading file attributes. Stopping. (%@)", [error localizedDescription]);
				return;
			}
		}
	}
		
	if (fileSize > 0) {
        NSLog(@"Already have %llu bytes, need %llu bytes more.", fileSize, ([book.FileSize unsignedLongValue] - fileSize));
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
	
	[book setProcessing:NO];
	return;
	
}

#pragma mark -
#pragma mark Notification methods

- (void) percentageUpdate: (NSDictionary *) userInfo
{
	if (self.fileType == kSCHDownloadFileTypeXPSBook) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookDownloadPercentageUpdate" object:nil userInfo:userInfo];
	}
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

	@synchronized(self) {
		NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:self.localPath];
		[handle seekToEndOfFile];
		[handle writeData:data];
		[handle closeFile];
	}
	
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	
	if ([self isCancelled] || [book processingState] == SCHBookProcessingStateDownloadPaused) {
		[connection cancel];
        
        [self endOperation];
        
		return;
	}
	
	NSError *error = nil;
	
	unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.localPath error:&error] fileSize];

	if (error) {
		NSLog(@"Warning: could not get filesize for %@. %@", self.localPath, [error localizedDescription]);
	}
	
	
	float percentage = (float) ((float) fileSize/[[book FileSize] floatValue]);
	
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
			[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyForLicenseAcquisition];
			break;
		case kSCHDownloadFileTypeCoverImage:
			[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyForBookFileDownload];
			break;
		default:
			break;
	}
	
	
    [self endOperation];	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Error downloading file %@!", [self.localPath lastPathComponent]);

	[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateError];

    [self endOperation];
}

@end
