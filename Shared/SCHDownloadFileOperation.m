//
//  SCHDownloadFileOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 22/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDownloadFileOperation.h"
#import "SCHProcessingManager.h"

@interface SCHDownloadFileOperation ()

@property (readwrite, retain) NSString *localPath;
@property BOOL executing;
@property BOOL finished;

- (void) beginConnection;
- (void) waitForCompletion;
- (void) startWaitingForFileDownload;

@end


@implementation SCHDownloadFileOperation


@synthesize bookInfo, resume, localPath, executing, finished, fileType;

- (void)dealloc {
	self.bookInfo = nil;
	self.localPath = nil;
	
	[super dealloc];
}

- (void) setBookInfo:(SCHBookInfo *) newBookInfo
{
	
	if ([self isExecuting] || [self isFinished]) {
		return;
	}
	
	SCHBookInfo *oldInfo = bookInfo;
	bookInfo = [newBookInfo retain];
	[oldInfo release];
	
	switch (self.fileType) {
		case kSCHDownloadFileTypeXPSBook:
			[[SCHProcessingManager defaultManager] setBookFileWaiting:self.bookInfo operation:self];
			break;
		case kSCHDownloadFileTypeCoverImage:
			[[SCHProcessingManager defaultManager] setCoverImageWaiting:self.bookInfo operation:self];
			break;
		default:
			NSLog(@"Warning: unknown file type for download!");
			break;
	}
}

- (void) start
{
//	@synchronized([SCHProcessingManager defaultManager]) {
		NSLog(@"Starting file download.");
		if (!(self.bookInfo)) {
			NSLog(@"No book info.");
		} else if ([self isCancelled]) {
			NSLog(@"Cancelled.");
		} else {
			switch (self.fileType) {
				case kSCHDownloadFileTypeXPSBook:
					
					if ([self.bookInfo isCurrentlyDownloadingBookFile]) {
						[self startWaitingForFileDownload];
					} else {
						[self beginConnection];
					}
					
					break;
				case kSCHDownloadFileTypeCoverImage:
					
					if ([self.bookInfo isCurrentlyDownloadingCoverImage]) {
						[self startWaitingForFileDownload];
					} else {
						[self beginConnection];
					}
					
					break;
				default:
					break;
			}
			
		}
//	}
}

- (void) beginConnection
{
	NSError *error = nil;
	
	// check first to see if the file has been created
	NSMutableURLRequest *request = nil;

	if (self.fileType == kSCHDownloadFileTypeXPSBook) {
	
//		if ([self.bookInfo isCurrentlyDownloading]) {
//			NSLog(@"--**--**--**--**--**--Operation: already downloading the file.");
//			[self startWaitingForFileDownload];
//			return;
//		}
		
		BookFileProcessingState state = [self.bookInfo processingState];
		
		if (state == bookFileProcessingStateFullyDownloaded) {
//			NSLog(@"--**--**--**--**--**--Already fully downloaded the file. Stopping.");
			return;
		}
		
		self.localPath = [self.bookInfo xpsPath];
		
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.bookInfo.bookFileURL]];
		
	} else if (self.fileType == kSCHDownloadFileTypeCoverImage) {
		
//		if ([self.bookInfo isCurrentlyDownloadingCoverImage]) {
//			NSLog(@"--**--**--**--**--**--Operation: already downloading the file.");
//			[self startWaitingForFileDownload];
//			return;
//		}
		
		NSString *cacheDir  = [SCHProcessingManager cacheDirectory];
		self.localPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", bookInfo.bookIdentifier]];
		
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.bookInfo.coverURL]];

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
		[request setValue:[NSString stringWithFormat:@"bytes=%llu-", fileSize] forHTTPHeaderField:@"Range"];
	} else {
		[[NSFileManager defaultManager] createFileAtPath:self.localPath contents:nil attributes:nil];
	}

	
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];

	switch (self.fileType) {
		case kSCHDownloadFileTypeXPSBook:
			[[SCHProcessingManager defaultManager] setBookFileDownloading:self.bookInfo operation:self];
			break;
		case kSCHDownloadFileTypeCoverImage:
			[[SCHProcessingManager defaultManager] setCoverImageDownloading:self.bookInfo operation:self];
			break;
		default:
			break;
	}
	
	
	[connection start];
	
//	NSLog(@"--**--**--**--**--**--Connection started for file %@...", [self.localPath lastPathComponent]);
//	if (fileSize > 0) {
//		NSLog(@"--**--**--**--**--**--Continuing from file position %llu...", fileSize);
//	}
	
	if (connection != nil) {
		[self waitForCompletion];
	}
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  self.bookInfo, @"bookInfo", 
							  [NSNumber numberWithInt:self.fileType], @"type", 
							  nil];
	
	
	[self performSelectorOnMainThread:@selector(fileDownloadComplete:) 
						   withObject:userInfo
						waitUntilDone:YES];
							  
	return;
	
}

#pragma mark -
#pragma mark Notification methods

- (void) percentageUpdate: (NSDictionary *) userInfo
{
	if (self.fileType == kSCHDownloadFileTypeXPSBook) {
		[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookDownloadPercentageUpdate" object:self.bookInfo.bookIdentifier userInfo:userInfo];
	}
}

- (void) fileDownloadComplete: (NSDictionary *) userInfo
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookFileDownloadWaiting" object:nil userInfo:userInfo];
}

#pragma mark -
#pragma mark Waiting for completion

- (void) waitForCompletion
{
	do {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	} while (!self.finished);
	
}

#pragma mark -
#pragma mark Waiting for another operation to complete

- (void) startWaitingForFileDownload
{
	// FIXME: verify that this actually works
	NSLog(@"--**--**--**--**--**-- Starting to wait for download of file %@", self.bookInfo.contentMetadata.Title);
	[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fileWaitFinished:) name:@"SCHBookFileDownloadWaiting" object:self.bookInfo];
	[self waitForCompletion];
	[[NSNotificationCenter defaultCenter] removeObserver:self name:@"SCHBookFileDownloadWaiting" object:self.bookInfo];
}

- (void) fileWaitFinished: (NSNotification *) notification
{
	NSLog(@"--**--**--**--**--**-- bookFileWaitFinished");
	NSDictionary *userInfo = [notification userInfo];
	SCHBookInfo *otherInfo = [userInfo objectForKey:@"bookInfo"];
	kSCHDownloadFileType type = [(NSNumber *) [userInfo objectForKey:@"type"] intValue];
	
	if ([self.bookInfo.bookIdentifier compare:otherInfo.bookIdentifier] == NSOrderedSame && type == self.fileType) {
		self.executing = NO;
		self.finished = YES;
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
	
	NSError *error = nil;
	
	unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.localPath error:&error] fileSize];

	if (error) {
		NSLog(@"Warning: could not get filesize.");
	}
	
	
	float percentage = (float) ((float) fileSize/[self.bookInfo.contentMetadata.FileSize floatValue]);
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat:percentage], @"currentPercentage",
							  nil];
	
	//NSLog(@"percentage for %@: %2.2f%%", self.bookInfo.contentMetadata.Title, percentage * 100);
	
	[self performSelectorOnMainThread:@selector(percentageUpdate:) 
						   withObject:userInfo
						waitUntilDone:YES];
	
	
	if ([self isCancelled]) {
		[connection cancel];
		self.executing = NO;
		self.finished = YES;
		return;
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"Finished file %@.", [self.localPath lastPathComponent]);
	switch (self.fileType) {
		case kSCHDownloadFileTypeXPSBook:
			[[SCHProcessingManager defaultManager] removeBookFromDownload:self.bookInfo];
			break;
		case kSCHDownloadFileTypeCoverImage:
			[[SCHProcessingManager defaultManager] removeCoverImageFromDownload:self.bookInfo];
			break;
		default:
			break;
	}
	
	self.executing = NO;
	self.finished = YES;
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Error downloading file %@!", [self.localPath lastPathComponent]);
	switch (self.fileType) {
		case kSCHDownloadFileTypeXPSBook:
			[[SCHProcessingManager defaultManager] removeBookFromDownload:self.bookInfo];
			break;
		case kSCHDownloadFileTypeCoverImage:
			[[SCHProcessingManager defaultManager] removeCoverImageFromDownload:self.bookInfo];
			break;
		default:
			break;
	}
	
	self.executing = NO;
	self.finished = YES;
}

- (BOOL)isConcurrent {
	return YES;
}

- (BOOL)isExecuting {
	return self.executing;
}

- (BOOL)isFinished {
	return self.finished;
}

- (void) cancel
{
	NSLog(@"%%%% cancelling download file operation");
	self.finished = YES;
	self.executing = NO;
	[super cancel];
}

@end
