//
//  SCHDownloadBookFile.m
//  Scholastic
//
//  Created by Gordon Christie on 22/02/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDownloadBookFile.h"
#import "SCHProcessingManager.h"

@interface SCHDownloadBookFile ()

@property (readwrite, retain) NSString *localPath;
@property BOOL executing;
@property BOOL finished;

- (void) beginConnection;

@end


@implementation SCHDownloadBookFile


@synthesize bookInfo, resume, localPath, executing, finished;

- (void)dealloc {
	self.bookInfo = nil;
	
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
	
	
	[[SCHProcessingManager defaultManager] setBookWaiting:self.bookInfo operation:self];
	
//	self.bookInfo.downloading = NO;
//	self.bookInfo.waitingForDownload = YES;
	
//	NSLog(@"Firing selector: waiting %@, downloading %@", (self.bookInfo.waitingForDownload?@"Yes":@"No"), (self.bookInfo.downloading?@"Yes": @"No"));
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  self.bookInfo, @"bookInfo", 
							  nil];
	
	
	[self performSelectorOnMainThread:@selector(bookUpdate:) 
						   withObject:userInfo
						waitUntilDone:YES];
}

- (void) start
{
	NSLog(@"Starting book file download.");
	if (!(self.bookInfo) || [self isCancelled]) {
		NSLog(@"No book info or cancelled.");
	} else {
		[self beginConnection];
	}
	
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


- (void) beginConnection
{
	NSError *error = nil;
	
	// check first to see if the file has been created
	
	
	if ([self.bookInfo isCurrentlyDownloading]) {
		NSLog(@"Operation: already downloading the file.");
		return;
	}
	
	BookFileProcessingState state = [self.bookInfo processingState];
	
	if (state == bookFileProcessingStateFullyDownloaded) {
		NSLog(@"Already fully downloaded the file. Stopping.");
		return;
	}
	
	self.localPath = [self.bookInfo xpsPath];
	
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
		
	// FIXME: redundant check - already checked above in processingState?
/*	if (fileSize == [self.bookInfo.contentMetadata.FileSize unsignedLongLongValue]) {
		NSLog(@"Already fully downloaded the file. Stopping.");
		return;
	}
*/
	
	NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.bookInfo.contentMetadata.ContentURL]];
	
	if (fileSize > 0) {
		[request setValue:[NSString stringWithFormat:@"bytes=%llu-", fileSize] forHTTPHeaderField:@"Range"];
	} else {
		[[NSFileManager defaultManager] createFileAtPath:self.localPath contents:nil attributes:nil];
	}

	
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];

	[[SCHProcessingManager defaultManager] setBookDownloading:self.bookInfo operation:self];
	
//	self.bookInfo.downloading = YES;
//	self.bookInfo.waitingForDownload = NO;
	
	[connection start];
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  self.bookInfo, @"bookInfo", 
							  nil];
	
	
	[self performSelectorOnMainThread:@selector(bookUpdate:) 
						   withObject:userInfo
						waitUntilDone:YES];
	
	
	NSLog(@"Connection started for file %@...", [self.localPath lastPathComponent]);
	if (fileSize > 0) {
		NSLog(@"Continuing from file position %llu...", fileSize);
	}
	
	if (connection != nil) {
		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (!self.finished);
	}
	
	[self performSelectorOnMainThread:@selector(bookUpdate:) 
						   withObject:userInfo
						waitUntilDone:YES];
	
	return;
	
}

- (void) bookUpdate: (NSDictionary *) userInfo
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookDownloadStatusUpdate" object:nil userInfo:userInfo];
	
}

- (void) percentageUpdate: (NSDictionary *) userInfo
{
	[[NSNotificationCenter defaultCenter] postNotificationName:@"SCHBookDownloadPercentageUpdate" object:self.bookInfo.bookIdentifier userInfo:userInfo];
}

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
	self.executing = NO;
	self.finished = YES;
//	self.bookInfo.downloading = NO;
	[[SCHProcessingManager defaultManager] removeBookFromDownload:self.bookInfo];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Error downloading file %@!", [self.localPath lastPathComponent]);
	self.executing = NO;
	self.finished = YES;
//	self.bookInfo.downloading = NO;
	[[SCHProcessingManager defaultManager] removeBookFromDownload:self.bookInfo];
}

@end
