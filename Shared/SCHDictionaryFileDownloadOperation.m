//
//  SCHDictionaryFileDownloadOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryFileDownloadOperation.h"
#import "SCHAppBook.h"

#pragma mark Class Extension

@interface SCHDictionaryFileDownloadOperation ()

@property BOOL executing;
@property BOOL finished;

// a local file manager, for thread safety
@property (nonatomic, retain) NSFileManager *localFileManager;

// the total file size reported by the HTTP header
@property unsigned long long expectedFileSize;

// the previous percentage reported - used to limit percentage notifications
@property float previousPercentage;

@property (readwrite, retain) NSString *localPath;

- (void)beginConnection;
- (void)createPercentageUpdate;

@end

#pragma mark -

@implementation SCHDictionaryFileDownloadOperation

@synthesize executing;
@synthesize finished;
@synthesize expectedFileSize;
@synthesize previousPercentage;
@synthesize localPath;
@synthesize manifestEntry;
@synthesize localFileManager;

#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	[localPath release], localPath = nil;
    [localFileManager release], localFileManager = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Startup
- (void)start
{
    NSAssert(self.manifestEntry != nil, @"File URL cannot be nil for SCHDictionaryFileDownloadOperation.");

	if ([self isCancelled]) {
		NSLog(@"Cancelled.");
	} else {
		
		self.localPath = [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryZipPath];
        self.localFileManager = [[NSFileManager alloc] init];

		[self beginConnection];
	}
}

- (void)beginConnection
{
	NSError *error = nil;
	
    // check in here for available device space
    
	// check first to see if the file has been created
	NSMutableURLRequest *request = nil;
	
    NSLog(@"trying to download file with URL %@", self.manifestEntry.url);
    
	request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:self.manifestEntry.url]];
	
	unsigned long long fileSize = 0;
	
	if ([self.localFileManager fileExistsAtPath:self.localPath]) {
		// check to see how much of the file has been downloaded
		
		fileSize = [[self.localFileManager attributesOfItemAtPath:self.localPath error:&error] fileSize];
		
		if (error) {
			NSLog(@"Error when reading file attributes. Stopping. (%@)", [error localizedDescription]);
			return;
		}
	}
    
	if (fileSize > 0) {
		[request setValue:[NSString stringWithFormat:@"bytes=%llu-", fileSize] forHTTPHeaderField:@"Range"];
	} else {
		[self.localFileManager createFileAtPath:self.localPath contents:nil attributes:nil];
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
	
	if ([self.localFileManager fileExistsAtPath:self.localPath]) {
		// check to see how much of the file has been downloaded
		
		fileSize = [[self.localFileManager attributesOfItemAtPath:self.localPath error:&error] fileSize];
		
		if (error) {
			NSLog(@"Error when reading file attributes. %@", [error localizedDescription]);
		}
	}
	
    
    NSLog(@"Filesize: %llu Expected: %llu", fileSize, [response expectedContentLength]);
    
	if (fileSize == [response expectedContentLength]) {
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsUnzip];
        [connection cancel];
        [self cancel];
        return;
	}
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];            
    
    NSDictionary* fsAttr = [self.localFileManager attributesOfFileSystemForPath:docDirectory error:NULL];
    
    unsigned long long freeSize = [(NSNumber*)[fsAttr objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    NSLog(@"Freesize: %llu", freeSize);
    
    // if we cannot determine the expectedContentLength, then bail if the free space is 0
    // oherwise bail if the the free space < expectedContentLength
    if ((([response expectedContentLength] != NSURLResponseUnknownLength) && freeSize == 0) || freeSize < [response expectedContentLength]) {
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNotEnoughFreeSpace];
        [connection cancel];
        [self cancel];
        return;
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
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
		self.executing = NO;
		self.finished = YES;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
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
	
	[[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsUnzip];
//	[SCHDictionaryManager sharedDownloadManager].dictionaryState = SCHDictionaryProcessingStateNeedsUnzip;
	
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
	self.executing = NO;
	self.finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Stopped downloading file - %@", [error localizedDescription]);
	
    //	[[SCHDictionaryManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateError];
//	[SCHDictionaryManager sharedDownloadManager].dictionaryState = SCHDictionaryProcessingStateNeedsDownload;
	
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
	self.executing = NO;
	self.finished = YES;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];

	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

}


#pragma mark -
#pragma mark Percentage methods

- (void)createPercentageUpdate
{
	NSError *error = nil;
	
	unsigned long long fileSize = [[self.localFileManager attributesOfItemAtPath:self.localPath error:&error] fileSize];
	
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

- (void)firePercentageUpdate: (NSDictionary *) userInfo
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

- (void)cancel
{
	NSLog(@"%%%% cancelling download file operation");
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
	self.finished = YES;
	self.executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
	[UIApplication sharedApplication].networkActivityIndicatorVisible = NO;

	[super cancel];
}
	
@end
