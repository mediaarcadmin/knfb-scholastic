//
//  SCHHelpVideoFileDownloadOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 18/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHHelpVideoFileDownloadOperation.h"
#import "BITNetworkActivityManager.h"

#pragma mark Class Extension

@interface SCHHelpVideoFileDownloadOperation ()

@property BOOL executing;
@property BOOL finished;

@property int currentFileIndex;
@property (nonatomic, retain) NSDictionary *downloadList;

// a local file manager, for thread safety
@property (nonatomic, retain) NSFileManager *localFileManager;
@property (nonatomic, retain) NSFileHandle *fileHandle;
@property (nonatomic, assign) unsigned long long currentFilesize;

// the total file size reported by the HTTP header
@property unsigned long long expectedFileSize;

// the previous percentage reported - used to limit percentage notifications
@property float previousPercentage;

@property (readwrite, retain) NSString *localDirectory;

- (void)beginConnection;
- (void)createPercentageUpdate;
- (BOOL)fileSystemHasBytesAvailable:(unsigned long long)sizeInBytes;
- (void)checkForNextDownload;

@end

#pragma mark -

@implementation SCHHelpVideoFileDownloadOperation

@synthesize executing;
@synthesize finished;
@synthesize expectedFileSize;
@synthesize previousPercentage;
@synthesize localDirectory;
@synthesize videoManifest;
@synthesize localFileManager;
@synthesize fileHandle;
@synthesize currentFilesize;
@synthesize currentFileIndex;
@synthesize downloadList;

#pragma mark -
#pragma mark Memory Management

- (void)dealloc
{
    [downloadList release], downloadList = nil;
	[localDirectory release], localDirectory = nil;
    [localFileManager release], localFileManager = nil;
    [fileHandle closeFile];
    [fileHandle release], fileHandle = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Startup
- (void)start
{
    NSAssert(self.videoManifest != nil, @"videoManifest cannot be nil for SCHHelpVideoFileDownloadOperation.");
    
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
		
        self.currentFileIndex = 0;
        self.downloadList = [self.videoManifest itemsForCurrentDevice];
		self.localDirectory = [[SCHDictionaryDownloadManager sharedDownloadManager] helpVideoDirectory];
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
    
    // figure out which URL we're downloading
    NSArray *keys = [self.downloadList allKeys];
    
    NSString *downloadURL = (NSString *) [self.downloadList objectForKey:[keys objectAtIndex:self.currentFileIndex]];
	
    NSLog(@"trying to download file with URL %@", downloadURL);
    
	request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:downloadURL]];
	
	self.currentFilesize = 0;
	
    NSString *fileName = [downloadURL lastPathComponent];
    
    NSString *localPath = [NSString stringWithFormat:@"%@/%@", self.localDirectory, fileName];
    
	if ([self.localFileManager fileExistsAtPath:localPath]) {
		// check to see how much of the file has been downloaded
		
		self.currentFilesize = [[self.localFileManager attributesOfItemAtPath:localPath error:&error] fileSize];
		
		if (error) {
			NSLog(@"Error when reading file attributes. Stopping. (%@)", [error localizedDescription]);
            [self cancel];
			return;
		}
	}
    
	if (self.currentFilesize > 0) {
		[request setValue:[NSString stringWithFormat:@"bytes=%llu-", self.currentFilesize] forHTTPHeaderField:@"Range"];
	} else {
		[self.localFileManager createFileAtPath:localPath contents:nil attributes:nil];
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
    
    NSLog(@"Help Video Filesize receiving:%llu expected:%llu", self.currentFilesize, [response expectedContentLength]);
    
	if (self.currentFilesize == [response expectedContentLength]) {
        [connection cancel];
        [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];        
        [self checkForNextDownload];
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
    
    NSArray *keys = [self.downloadList allKeys];
    NSString *downloadURL = (NSString *) [self.downloadList objectForKey:[keys objectAtIndex:self.currentFileIndex]];
    NSString *fileName = [downloadURL lastPathComponent];
    NSString *localPath = [NSString stringWithFormat:@"%@/%@", self.localDirectory, fileName];
    
    self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:localPath];
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
	NSLog(@"Finished file.");
    
    [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
    [self checkForNextDownload];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"Stopped downloading file - %@", [error localizedDescription]);
	
    [[BITNetworkActivityManager sharedNetworkActivityManager] hideNetworkActivityIndicator];
	
    [self cancel];
}

- (void)checkForNextDownload
{
    self.currentFileIndex++;
    
    if (self.currentFileIndex >= [self.downloadList count]) {
        // fire a 100% notification
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:1.0f], @"currentPercentage",
                                  nil];
        
        [self performSelectorOnMainThread:@selector(firePercentageUpdate:) 
                               withObject:userInfo
                            waitUntilDone:YES];
        
        // we've successfully downloaded all files
        // set the defaults version string to 1.0 (hardcoded at present)
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        [defaults setValue:@"1.0" forKey:@"helpVideoCurrentCompletedVersion"];
        [defaults setValue:downloadList forKey:@"helpVideoURLDictionary"];
        [defaults synchronize];
        
        SCHDictionaryUserRequestState userRequestState = [[SCHDictionaryDownloadManager sharedDownloadManager] userRequestState];
        
        if (userRequestState == SCHDictionaryUserDeclined) {
            [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUserDeclined];
        } else if (userRequestState == SCHDictionaryUserNotYetAsked) {
            [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateUserSetup];
        } else {
            [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateNeedsManifest];
        }

        [self cancel];
    } else {
        [self beginConnection];
    }
    
}

#pragma mark - Percentage methods

- (void)createPercentageUpdate
{
	NSError *error = nil;
	
	if (error) {
		NSLog(@"Warning: could not get filesize.");
	}
	
	if (self.expectedFileSize != NSURLResponseUnknownLength) {
		
		float currentFilePercentage = (self.expectedFileSize > 0 ? (float)((float)self.currentFilesize / (float)self.expectedFileSize) : 0.0);
		
		if (currentFilePercentage - self.previousPercentage > 0.001f) {
            
            float fileTotalPercentage = 1/(float)[self.downloadList count];
            
            float currentPercentage = (fileTotalPercentage * (self.currentFileIndex)) + (currentFilePercentage * fileTotalPercentage);
			
			NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
									  [NSNumber numberWithFloat:currentPercentage], @"currentPercentage",
									  nil];
			
			NSLog(@"percentage for help video download: %2.4f%%", currentPercentage * 100);
			
			[self performSelectorOnMainThread:@selector(firePercentageUpdate:) 
								   withObject:userInfo
								waitUntilDone:NO];
			
			self.previousPercentage = currentPercentage;
		}
	}
}

- (void)firePercentageUpdate:(NSDictionary *)userInfo
{
    NSAssert(userInfo != nil, @"firePercentageUpdate is incorrectly being called with no userInfo");
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHHelpVideoDownloadPercentageUpdate object:nil userInfo:userInfo];
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
