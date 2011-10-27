//
//  SCHDictionaryManifestOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryManifestOperation.h"
#import "SCHDictionaryDownloadManager.h"

@interface SCHDictionaryManifestOperation ()

@property BOOL executing;
@property BOOL finished;
@property BOOL parsingComplete;
@property BOOL parsingDictionaryInfo;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSXMLParser *manifestParser;
@property (nonatomic, retain) NSMutableData *connectionData;
@property (nonatomic, retain) NSMutableArray *manifestEntries;
@property (nonatomic, retain) SCHDictionaryManifestEntry *currentEntry;

- (void)startOp;
- (void)finishOp;

@end

@implementation SCHDictionaryManifestOperation

@synthesize executing;
@synthesize finished;
@synthesize parsingComplete;
@synthesize parsingDictionaryInfo;
@synthesize manifestParser;
@synthesize connection;
@synthesize connectionData;
@synthesize manifestEntries; 
@synthesize currentEntry;

- (void)dealloc 
{
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
                                                  [NSURL URLWithString:@"http://reader.ebooks2.scholastic.com/reader/sch/UpdateManifest.xml"]]
						   delegate:self];
		
        if (self.connection == nil) {
            [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateError];
            [self cancel];
        } else {
            [self startOp];
        }        
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
            [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateError];
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
    
    self.parsingDictionaryInfo = NO;
    self.manifestParser = [[[NSXMLParser alloc] initWithData:self.connectionData] autorelease];
    [self.manifestParser setDelegate:self];
    [self.manifestParser parse];
    
    [SCHDictionaryDownloadManager sharedDownloadManager].manifestUpdates = self.manifestEntries;    
    
    [self finishOp];
}

- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error
{
	NSLog(@"failed download!");
    [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateError];
    [self cancel];    
}

#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict
{
//	NSLog(@"parsing element %@", elementName);
	if ( [elementName isEqualToString:@"UpdateComponent"] ) {
		NSString * attributeStringValue = [attributeDict objectForKey:@"Name"];
		if (attributeStringValue && [attributeStringValue isEqualToString:@"Dictionary"]) {
			self.parsingDictionaryInfo = YES;
		}
	}
	else if (self.parsingDictionaryInfo) {
		
		if ( [elementName isEqualToString:@"UpdateEntry"] ) {
            self.currentEntry = [[[SCHDictionaryManifestEntry alloc] init] autorelease];
            
			NSString * attributeStringValue = [attributeDict objectForKey:@"StartVersion"];
			if (attributeStringValue) {
				self.currentEntry.fromVersion = attributeStringValue;
			}
			attributeStringValue = [attributeDict objectForKey:@"EndVersion"];
			if (attributeStringValue) {
                self.currentEntry.toVersion = attributeStringValue;
			}
			attributeStringValue = [attributeDict objectForKey:@"href"];
			if (attributeStringValue) {
                self.currentEntry.url = attributeStringValue;
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
		self.parsingDictionaryInfo = NO;
	}
    
	if (self.parsingDictionaryInfo && [elementName isEqualToString:@"UpdateEntry"] ) {
        if (self.currentEntry) {
            [self.manifestEntries addObject:self.currentEntry];
            self.currentEntry = nil;
        }
    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateManifestVersionCheck];
    [SCHDictionaryDownloadManager sharedDownloadManager].isProcessing = NO;

	self.parsingComplete = YES;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateError];
    [SCHDictionaryDownloadManager sharedDownloadManager].isProcessing = NO;
    
	NSLog(@"Error: could not parse XML.");
	self.parsingComplete = YES;
}

#pragma mark - NSOperation methods

- (void)cancel
{
    [self finishOp];
	[super cancel];
}

- (void)startOp
{
    [SCHDictionaryDownloadManager sharedDownloadManager].isProcessing = YES;
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.executing = YES;
    self.finished = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
}

- (void)finishOp
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
	self.finished = YES;
	self.executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
	[SCHDictionaryDownloadManager sharedDownloadManager].isProcessing = NO;
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
