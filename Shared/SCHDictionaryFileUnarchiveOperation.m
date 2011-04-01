//
//  SCHDictionaryFileUnarchiveOperation.m
//  Scholastic
//
//  Created by John S. Eddie on 29/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryFileUnarchiveOperation.h"

#import "SCHDictionaryManager.h"
#import "SCHAppBook.h"


@interface SCHDictionaryFileUnarchiveOperation ()

- (void)performUnarchive;

@property BOOL executing;
@property BOOL finished;

// the previous percentage reported - used to limit percentage notifications
@property float previousPercentage;

@property (readwrite, retain) NSString *localPath;

@end

@implementation SCHDictionaryFileUnarchiveOperation

@synthesize executing;
@synthesize finished;
@synthesize previousPercentage;
@synthesize localPath;

#pragma mark -
#pragma mark Memory Management

- (void) dealloc
{
	self.localPath = nil;
	[super dealloc];
}

#pragma mark -
#pragma mark Startup methods

- (void)start
{
    if (self.isCancelled == YES) {
		NSLog(@"Cancelled.");
	} else {
		self.localPath = [[SCHAppBook cacheDirectory] 
						  stringByAppendingFormat:@"/dictionary-%@.zip", 
						  [[SCHDictionaryManager sharedDictionaryManager] dictionaryVersion]];
		
		[self performUnarchive];
	}
}

- (void)performUnarchive
{
    ZipArchive *aZipArchive = [[ZipArchive alloc] init];
    aZipArchive.delegate = self;
    
    self.previousPercentage = -1;
    
	if([aZipArchive UnzipOpenFile:self.localPath] == YES) {
        NSLog(@"Started unarchiving Dictionary");
		if ([aZipArchive UnzipFileTo:[SCHDictionaryManager dictionaryDirectory] overWrite:YES] == YES) {
            NSLog(@"Ended unarchiving Dictionary");
            [SCHDictionaryManager sharedDictionaryManager].dictionaryState = SCHDictionaryProcessingStateDone;
            [[NSFileManager defaultManager] removeItemAtPath:self.localPath error:nil]; 
        } else {
            [SCHDictionaryManager sharedDictionaryManager].dictionaryState = SCHDictionaryProcessingStateNeedsParsing;
        }
		[aZipArchive UnzipCloseFile];
	} else {
        [SCHDictionaryManager sharedDictionaryManager].dictionaryState = SCHDictionaryProcessingStateNeedsParsing;
    }
	[aZipArchive release], aZipArchive = nil;
    
    self.executing = NO;
	self.finished = YES;
}

#pragma mark -
#pragma mark Percentage methods

- (void)Percentage:(float)percentage
{
    if (percentage - self.previousPercentage > 0.001f) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  [NSNumber numberWithFloat:percentage], @"currentPercentage",
                                  nil];
        
        // NSLog(@"percentage for dictionary unarchiving: %2.4f%%", percentage * 100);
        
        [self performSelectorOnMainThread:@selector(firePercentageUpdate:) 
                               withObject:userInfo
                            waitUntilDone:YES];    
        
        self.previousPercentage = percentage;
    }
}

- (void) firePercentageUpdate:(NSDictionary *)userInfo
{
	[[NSNotificationCenter defaultCenter] postNotificationName:kSCHDictionaryUnarchivePercentageUpdate object:nil userInfo:userInfo];
}

#pragma mark -
#pragma mark NSOperation methods

- (BOOL)isConcurrent {
	return(YES);
}

- (BOOL)isExecuting {
	return(self.executing);
}

- (BOOL)isFinished {
	return(self.finished);
}

- (void)cancel
{
	NSLog(@"%%%% cancelling unarchiving operation");
	self.finished = YES;
	self.executing = NO;
    
	[super cancel];
}

@end
