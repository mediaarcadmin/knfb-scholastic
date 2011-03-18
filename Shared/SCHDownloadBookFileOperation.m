//
//  SCHDownloadFileOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 22/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDownloadBookFileOperation.h"
#import "SCHProcessingManager.h"

@interface SCHDownloadBookFileOperation ()

@property (readwrite, retain) NSString *localPath;
@property BOOL executing;
@property BOOL finished;

- (void) beginConnection;

@end


@implementation SCHDownloadBookFileOperation


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
	
	[self.bookInfo setProcessing:YES];

}

- (void) start
{

	NSString *type = @"XPS Book File";
	
	if (self.fileType == kSCHDownloadFileTypeCoverImage) {
		type = @"Cover Image";
	}
	
	NSLog(@"Starting %@ download.", type);
	if (!(self.bookInfo)) {
		NSLog(@"No book info.");
	} else if ([self isCancelled]) {
		NSLog(@"Cancelled.");
	} else {
		[self beginConnection];
	}
}

- (void) beginConnection
{
	NSError *error = nil;
	
	// check first to see if the file has been created
	NSMutableURLRequest *request = nil;

	if (self.fileType == kSCHDownloadFileTypeXPSBook) {
	
		self.localPath = [self.bookInfo xpsPath];
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[bookInfo stringForMetadataKey:kSCHBookInfoContentURL]]];
		
	} else if (self.fileType == kSCHDownloadFileTypeCoverImage) {
		
		NSString *cacheDir  = [SCHBookInfo cacheDirectory];
		self.localPath = [cacheDir stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.png", bookInfo.bookIdentifier]];
		
		request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[bookInfo stringForMetadataKey:kSCHBookInfoCoverURL]]];

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

	[connection start];
	
	if (connection != nil) {
		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (!self.finished);
	}
	
	[self.bookInfo setProcessing:NO];
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

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

	@synchronized(self) {
		NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:self.localPath];
		[handle seekToEndOfFile];
		[handle writeData:data];
		[handle closeFile];
	}
	
	if ([self isCancelled] || self.bookInfo.processingState == SCHBookInfoProcessingStateDownloadPaused) {
		[connection cancel];
		self.executing = NO;
		self.finished = YES;
		return;
	}
	
	NSError *error = nil;
	
	unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.localPath error:&error] fileSize];

	if (error) {
		NSLog(@"Warning: could not get filesize.");
	}
	
	
	float percentage = (float) ((float) fileSize/[[bookInfo objectForMetadataKey:kSCHBookInfoFileSize] floatValue]);
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat:percentage], @"currentPercentage",
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
			[self.bookInfo setProcessingState:SCHBookInfoProcessingStateReadyForRightsParsing];
			break;
		case kSCHDownloadFileTypeCoverImage:
			[self.bookInfo setProcessingState:SCHBookInfoProcessingStateReadyForBookFileDownload];
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

	[self.bookInfo setProcessingState:SCHBookInfoProcessingStateError];

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
