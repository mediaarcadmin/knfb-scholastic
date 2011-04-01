//
//  SCHDictionaryFileDownloadOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryFileDownloadOperation.h"
#import "SCHDictionaryManager.h"
#import "SCHAppBook.h"

#pragma mark Class Extension

@interface SCHDictionaryFileDownloadOperation ()

@property BOOL executing;
@property BOOL finished;

// the total file size reported by the HTTP header
@property unsigned long long expectedFileSize;

// the previous percentage reported - used to limit percentage notifications
@property float previousPercentage;

@property (readwrite, retain) NSString *localPath;

- (void) beginConnection;
- (void) createPercentageUpdate;

@end

#pragma mark -

@implementation SCHDictionaryFileDownloadOperation

@synthesize executing, finished, expectedFileSize, previousPercentage, localPath;

#pragma mark -
#pragma mark Memory Management

- (void) dealloc
{
	self.localPath = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Startup
- (void) start
{
	
	if ([self isCancelled]) {
		NSLog(@"Cancelled.");
	} else {
		
		self.localPath = [[SCHAppBook rootCacheDirectory] 
						  stringByAppendingFormat:@"/dictionary-%@.zip", 
						  [[SCHDictionaryManager sharedDictionaryManager] dictionaryVersion]];
		
		[self beginConnection];
	}
}

- (void) beginConnection
{
	NSError *error = nil;
	
	// check first to see if the file has been created
	NSMutableURLRequest *request = nil;
	
	request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[SCHDictionaryManager sharedDictionaryManager].dictionaryURL]];
	
	unsigned long long fileSize = 0;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.localPath]) {
		// check to see how much of the file has been downloaded
		
		fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.localPath error:&error] fileSize];
		
		if (error) {
			NSLog(@"Error when reading file attributes. Stopping. (%@)", [error localizedDescription]);
			return;
		}
	}
	
	if (fileSize > 0) {
		[request setValue:[NSString stringWithFormat:@"bytes=%llu-", fileSize] forHTTPHeaderField:@"Range"];
	} else {
		[[NSFileManager defaultManager] createFileAtPath:self.localPath contents:nil attributes:nil];
	}
	
	[UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
	
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];
	
	[connection start];
	
	if (connection != nil) {
		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (!self.finished);
	}
	
	return;
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
	
	unsigned long long fileSize = 0;
	NSError *error = nil;
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.localPath]) {
		// check to see how much of the file has been downloaded
		
		fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.localPath error:&error] fileSize];
		
		if (error) {
			NSLog(@"Error when reading file attributes. %@", [error localizedDescription]);
		}
	}
	
	self.expectedFileSize = [response expectedContentLength] + fileSize;
	self.previousPercentage = -1;
	
	[self createPercentageUpdate];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
	
	@synchronized(self) {
		NSFileHandle *handle = [NSFileHandle fileHandleForWritingAtPath:self.localPath];
		[handle seekToEndOfFile];
		[handle writeData:data];
		[handle closeFile];
	}
	
	if ([self isCancelled]) {
		[connection cancel];
		self.executing = NO;
		self.finished = YES;
		return;
	}

	[self createPercentageUpdate];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"Finished file %@.", [self.localPath lastPathComponent]);
	
	// fire a 100% notification
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat:1.0f], @"currentPercentage",
							  nil];
	
	[self performSelectorOnMainThread:@selector(firePercentageUpdate:) 
						   withObject:userInfo
						waitUntilDone:YES];
	
	
	[SCHDictionaryManager sharedDictionaryManager].dictionaryState = SCHDictionaryProcessingStateDone;
	
	self.executing = NO;
	self.finished = YES;

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Stopped downloading file - %@", [error localizedDescription]);
	
	[SCHDictionaryManager sharedDictionaryManager].dictionaryState = SCHDictionaryProcessingStateNeedsDownload;
	
	self.executing = NO;
	self.finished = YES;

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}


#pragma mark -
#pragma mark Percentage methods

- (void) createPercentageUpdate
{
	NSError *error = nil;
	
	unsigned long long fileSize = [[[NSFileManager defaultManager] attributesOfItemAtPath:self.localPath error:&error] fileSize];
	
	if (error) {
		NSLog(@"Warning: could not get filesize.");
	}
	
	if (self.expectedFileSize != NSURLResponseUnknownLength) {
		
		float percentage = (float) ((float) fileSize/(float) self.expectedFileSize);
		
		if (percentage - self.previousPercentage > 0.001f) {
			
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithFloat:percentage], @"currentPercentage",
									  nil];
			
			NSLog(@"percentage for dictionary: %2.4f%%", percentage * 100);
			
			[self performSelectorOnMainThread:@selector(firePercentageUpdate:) 
								   withObject:userInfo
								waitUntilDone:YES];
			
			self.previousPercentage = percentage;
		}
	}
}

- (void) firePercentageUpdate: (NSDictionary *) userInfo
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHDictionaryDownloadPercentageUpdate object:nil userInfo:userInfo];
}

#pragma mark -
#pragma mark NSOperation methods

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
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	[super cancel];
}
	
@end
