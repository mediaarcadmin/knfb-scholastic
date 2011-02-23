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
	
	self.bookInfo.downloading = NO;
	self.bookInfo.waitingForDownload = YES;
	
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
	
	BookFileProcessingState state = [self.bookInfo processingState];
	
	if (state == bookFileProcessingStateCurrentlyDownloading) {
		NSLog(@"Operation: already downloading the file.");
		return;
	}
	
	if (state == bookFileProcessingStateFullyDownloaded) {
		NSLog(@"Already fully downloaded the file. Stopping.");
		return;
	}
	
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  self.bookInfo, @"bookInfo", 
							  nil];
	
	
	[self performSelectorOnMainThread:@selector(bookUpdate:) 
						   withObject:userInfo
						waitUntilDone:YES];
	
	
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
	
	self.bookInfo.downloading = YES;
	self.bookInfo.waitingForDownload = NO;
	
	[connection start];
	NSLog(@"Connection started for file %@...", [self.localPath lastPathComponent]);
	
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

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {

	if ([self isCancelled]) {
		[connection cancel];
		self.executing = NO;
		self.finished = YES;
		return;
	}
	
	@synchronized(self) {
		NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:self.localPath];
		[handle seekToEndOfFile];
		[handle writeData:data];
		[handle closeFile];
	}
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"Finished file %@.", [self.localPath lastPathComponent]);
	self.executing = NO;
	self.finished = YES;
	self.bookInfo.downloading = NO;
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Error downloading file %@!", [self.localPath lastPathComponent]);
	self.executing = NO;
	self.finished = YES;
	self.bookInfo.downloading = NO;
}

@end
