//
//  SCHVersionManifestOperation.m
//  Scholastic
//
//  Created by John Eddie on 23/12/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHVersionManifestOperation.h"

#import "SCHVersionDownloadManager.h"
#import "SCHVersionManifestEntry.h"

@interface SCHVersionManifestOperation ()

@property BOOL executing;
@property BOOL finished;
@property BOOL parsingComplete;
@property BOOL parsingVersionInfo;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSXMLParser *manifestParser;
@property (nonatomic, retain) NSMutableData *connectionData;
@property (nonatomic, retain) NSMutableArray *manifestEntries;
@property (nonatomic, retain) SCHVersionManifestEntry *currentEntry;

- (void)startOp;
- (void)finishOp;

@end

@implementation SCHVersionManifestOperation

@synthesize notCancelledCompletionBlock;
@synthesize executing;
@synthesize finished;
@synthesize parsingComplete;
@synthesize parsingVersionInfo;
@synthesize manifestParser;
@synthesize connection;
@synthesize connectionData;
@synthesize manifestEntries; 
@synthesize currentEntry;

- (void)dealloc 
{
    Block_release(notCancelledCompletionBlock), notCancelledCompletionBlock = nil;
    
	[connection release], connection = nil;
	[connectionData release], connectionData = nil;
	[manifestParser release], manifestParser = nil;
    [manifestEntries release], manifestEntries = nil;
    [currentEntry release], currentEntry = nil;
	
	[super dealloc];
}

- (void)start
{
	if (![self isCancelled]) {
        // Following Dave Dribins pattern 
        // http://www.dribin.org/dave/blog/archives/2009/05/05/concurrent_operations/
        if (![NSThread isMainThread])
        {
            [self performSelectorOnMainThread:@selector(start) withObject:nil waitUntilDone:NO];
            return;
        }

		NSLog(@"Starting operation..");
		
		self.connectionData = [[[NSMutableData alloc] init] autorelease];
        self.manifestEntries = [[[NSMutableArray alloc] init] autorelease];
		
		self.connection = [NSURLConnection 
						   connectionWithRequest:[NSURLRequest requestWithURL:
                                                  [NSURL URLWithString:UPDATE_MANIFEST]]
						   delegate:self];
		
        if (self.connection == nil) {
            [SCHVersionDownloadManager sharedVersionManager].state = SCHVersionDownloadManagerProcessingStateUnexpectedConnectivityFailureError;            
            [self cancel];
        } else {
            [self startOp];
        }        
	}
}

#pragma mark - Operation Methods

- (void)setNotCancelledCompletionBlock:(dispatch_block_t)block
{
    __block NSOperation *selfPtr = self;
    
    Block_release(notCancelledCompletionBlock);
    
    if (block == nil) {
        notCancelledCompletionBlock = nil;
        self.completionBlock = nil;
    } else {
        notCancelledCompletionBlock = Block_copy(block);
        
        __block dispatch_block_t blockPtr = notCancelledCompletionBlock;
        
        self.completionBlock = ^{
            if (![selfPtr isCancelled]) {
                blockPtr();
            }
        };
    }
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)conn 
didReceiveResponse:(NSURLResponse *)response
{
    if ([response isKindOfClass:[NSHTTPURLResponse class]] == YES) {
        if ([(NSHTTPURLResponse *)response statusCode] != 200) {
            [conn cancel];
            NSLog(@"Error downloading file, errorCode: %d", [(NSHTTPURLResponse *)response statusCode]);
            [self cancel];
            return;
        }
    }
    
	[self.connectionData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	NSLog(@"received data..");
	[self.connectionData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
	NSLog(@"finished download, starting parsing..");
    
    if (![self isCancelled]) {
        self.parsingVersionInfo = NO;
        self.manifestParser = [[[NSXMLParser alloc] initWithData:self.connectionData] autorelease];
        [self.manifestParser setDelegate:self];
        [self.manifestParser parse];
    
        [SCHVersionDownloadManager sharedVersionManager].manifestUpdates = self.manifestEntries;    
    } else {
        NSLog(@"VersionManifestOperation was cancelled");
    }
    
    [self finishOp];
}

- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error
{
	NSLog(@"failed download!");
    [SCHVersionDownloadManager sharedVersionManager].state = SCHVersionDownloadManagerProcessingStateUnexpectedConnectivityFailureError;                
    [self cancel];    
}

#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict
{
	if ( [elementName isEqualToString:@"UpdateComponent"] ) {
		NSString * attributeStringValue = [attributeDict objectForKey:@"Name"];
		if (attributeStringValue && [attributeStringValue isEqualToString:@"iOSReader"]) {
			self.parsingVersionInfo = YES;
		}
	}
	else if (self.parsingVersionInfo) {
		
		if ( [elementName isEqualToString:@"UpdateEntry"] ) {
            self.currentEntry = [[[SCHVersionManifestEntry alloc] init] autorelease];
            
			NSString * attributeStringValue = [attributeDict objectForKey:@"StartVersion"];
			if (attributeStringValue) {
				self.currentEntry.fromVersion = attributeStringValue;
			}
			attributeStringValue = [attributeDict objectForKey:@"EndVersion"];
			if (attributeStringValue) {
                self.currentEntry.toVersion = attributeStringValue;
			}
			attributeStringValue = [attributeDict objectForKey:@"Forced"];
			if (attributeStringValue) {
                self.currentEntry.forced = attributeStringValue;
			}
		}
	}
}

- (void)parser:(NSXMLParser *)parser 
  didEndElement:(NSString *)elementName 
   namespaceURI:(NSString *)namespaceURI 
  qualifiedName:(NSString *)qName
{
	if ( [elementName isEqualToString:@"UpdateComponent"] ) {
		self.parsingVersionInfo = NO;
	}
    
	if (self.parsingVersionInfo && [elementName isEqualToString:@"UpdateEntry"] ) {
        if (self.currentEntry) {
            [self.manifestEntries addObject:self.currentEntry];
            self.currentEntry = nil;
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [SCHVersionDownloadManager sharedVersionManager].state = SCHVersionDownloadManagerProcessingStateManifestVersionCheck;
    [SCHVersionDownloadManager sharedVersionManager].isProcessing = NO;

	self.parsingComplete = YES;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [SCHVersionDownloadManager sharedVersionManager].state = SCHVersionDownloadManagerProcessingStateParseError;
    [SCHVersionDownloadManager sharedVersionManager].isProcessing = NO;
    
	NSLog(@"Error: could not parse XML.");
	self.parsingComplete = YES;
}

#pragma mark - NSOperation methods

- (void)cancel
{
    [super cancel];
    [self.connection cancel];
    self.connection = nil;
    [SCHVersionDownloadManager sharedVersionManager].isProcessing = NO;
}

- (void)startOp
{
    [SCHVersionDownloadManager sharedVersionManager].isProcessing = YES;
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.executing = YES;
    self.finished = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)finishOp
{
    self.connection = nil;

    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
	self.finished = YES;
	self.executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
	[SCHVersionDownloadManager sharedVersionManager].isProcessing = NO;
}

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

@end
