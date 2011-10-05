//
//  SCHDictionaryFileDownloadOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryFileDownloadOperation.h"
#import "BITNetworkActivityManager.h"

#pragma mark Class Extension

@interface SCHDictionaryFileDownloadOperation ()

@property BOOL executing;
@property BOOL finished;

// a local file manager, for thread safety
@property (nonatomic, retain) NSFileManager *localFileManager;
@property (nonatomic, retain) NSFileHandle *fileHandle;
@property (nonatomic, assign) unsigned long long currentFilesize;

// the total file size reported by the HTTP header
@property unsigned long long expectedFileSize;

// the previous percentage reported - used to limit percentage notifications
@property float previousPercentage;

@property (readwrite, retain) NSString *localPath;

- (void)beginConnection;
- (void)createPercentageUpdate;
- (BOOL)fileSystemHasBytesAvailable:(unsigned long long)sizeInBytes;

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
@synthesize fileHandle;
@synthesize currentFilesize;

#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
	[localPath release], localPath = nil;
    [localFileManager release], localFileManager = nil;
    [fileHandle closeFile];
    [fileHandle release], fileHandle = nil;
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
        // Following Dave Dribins pattern 
        // http://www.dribin.org/dave/blog/archives/2009/05/05/concurrent_operations/
        if (![NSThread isMainThread])
        {
            [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
            return;
        }
		
		self.localPath = [[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryZipPath];
        self.localFileManager = [[[NSFileManager alloc] init] autorelease];

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
	
	self.currentFilesize = 0;
	
	if ([self.localFileManager fileExistsAtPath:self.localPath]) {
		// check to see how much of the file has been downloaded
		
		self.currentFilesize = [[self.localFileManager attributesOfItemAtPath:self.localPath error:&error] fileSize];
		
		if (error) {
			NSLog(@"Error when reading file attributes. Stopping. (%@)", [error localizedDescription]);
            [self cancel];
			return;
		}
	}
    
	if (self.currentFilesize > 0) {
		[request setValue:[NSString stringWithFormat:@"bytes=%llu-", self.currentFilesize] forHTTPHeaderField:@"Range"];
	} else {
		[self.localFileManager createFileAtPath:self.localPath contents:nil attributes:nil];
	}
	
	NSURLConnection *connection = [NSURLConnection connectionWithRequest:request delegate:self];

	if (connection == nil) {
        [self cancel];
    } else {
        [connection start];
        [[BITNetworkActivityManager sharedNetworkActivityManager] showNetworkActivityIndicator];        
    }
}

#pragma mark -
#pragma mark NSURLConnection delegate methods

- (BOOL)fileSystemHasBytesAvailable:(unsigned long long)sizeInBytes
{
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docDirectory = [paths objectAtIndex:0];            
    
    NSDictionary* fsAttr = [self.localFileManager attributesOfFileSystemForPath:docDirectory error:NULL];
    
    unsigned long long freeSize = [(NSNumber*)[fsAttr objectForKey:NSFileSystemFreeSize] unsignedLongLongValue];
    //NSLog(@"Freesize: %llu", freeSize);
    
    return (sizeInBytes <= freeSize);
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]] == YES) {
        if ([(NSHTTPURLResponse *)response statusCode] != 200 && 
            [(NSHTTPURLResponse *)response statusCode] != 206) {
            [connection cancel];
            [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
            NSLog(@"Error downloading file, errorCode: %d", [(NSHTTPURLResponse *)response statusCode]);
            [self cancel];
            return;
        }
    } 

    NSLog(@"Filesize: %llu Expected: %llu", self.currentFilesize, [response expectedContentLength]);
    
	if (self.currentFilesize == [response expectedContentLength]) {
        [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsUnzip];
        [connection cancel];
        [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];        
        [self cancel];
        return;
	}
    
    // if we cannot determine the expectedContentLength, then bail if the free space is 0
    // oherwise bail if the the free space < expectedContentLength
    if (([response expectedContentLength] != NSURLResponseUnknownLength)) {
        if (![self fileSystemHasBytesAvailable:[response expectedContentLength]]) {
            [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNotEnoughFreeSpace];
            [connection cancel];
            [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];            
            [self cancel];
            return;
        }
    }

	self.expectedFileSize = [response expectedContentLength] + self.currentFilesize;
	self.previousPercentage = -1;
	
	[self createPercentageUpdate];
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.localPath];
    [self.fileHandle seekToEndOfFile];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{	
    @synchronized(self) {
        @try {
            [self.fileHandle writeData:data];
            self.currentFilesize += [data length];
        }
        @catch (NSException *exception) {
            [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNotEnoughFreeSpace];
            [connection cancel];
            [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];            
            [self cancel];
        }
    }
	
	if ([self isCancelled]) {
		[connection cancel];
        [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];        
        [self cancel];
		return;
	}

	[self createPercentageUpdate];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"Finished file %@.", [self.localPath lastPathComponent]);
	
    [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
    
	// fire a 100% notification
	NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
							  [NSNumber numberWithFloat:1.0f], @"currentPercentage",
							  nil];
	
	[self performSelectorOnMainThread:@selector(firePercentageUpdate:) 
						   withObject:userInfo
						waitUntilDone:YES];
	
	[[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsUnzip];
//	[SCHDictionaryManager sharedDownloadManager].dictionaryState = SCHDictionaryProcessingStateNeedsUnzip;
	
    [self cancel];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Stopped downloading file - %@", [error localizedDescription]);
	
    [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
    
    //	[[SCHDictionaryManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateError];
//	[SCHDictionaryManager sharedDownloadManager].dictionaryState = SCHDictionaryProcessingStateNeedsDownload;
	
    [self cancel];
}

#pragma mark - Percentage methods

- (void)createPercentageUpdate
{
	NSError *error = nil;
	
	if (error) {
		NSLog(@"Warning: could not get filesize.");
	}
	
	if (self.expectedFileSize != NSURLResponseUnknownLength) {
		
		float percentage = (float)((float)self.currentFilesize / (float)self.expectedFileSize);
		
		if (percentage - self.previousPercentage > 0.001f) {
			
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithFloat:percentage], @"currentPercentage",
									  nil];
			
			NSLog(@"percentage for dictionary: %2.4f%%", percentage * 100);
			
			[self performSelectorOnMainThread:@selector(firePercentageUpdate:) 
								   withObject:userInfo
								waitUntilDone:NO];
			
			self.previousPercentage = percentage;
		}
	}
}

- (void)firePercentageUpdate:(NSDictionary *)userInfo
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHDictionaryDownloadPercentageUpdate object:nil userInfo:userInfo];
}

#pragma mark - NSOperation methods

- (BOOL)isConcurrent
{
	return YES;
}

- (BOOL)isExecuting
{
	return self.executing;
}

- (BOOL)isFinished
{
	return self.finished;
}

- (void)cancel
{
	NSLog(@"%%%% cancelling download file operation");
    [self.fileHandle closeFile];
    self.fileHandle = nil;    
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
	self.finished = YES;
	self.executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];

	[super cancel];
}
	
@end
