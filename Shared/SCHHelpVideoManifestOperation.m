//
//  SCHHelpVideoManifestOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 18/10/2011.
//  Copyright (c) 2011 BitWink. All rights reserved.
//

#import "SCHHelpVideoManifestOperation.h"
#import "SCHDictionaryDownloadManager.h"

@interface SCHHelpVideoManifestOperation ()

@property BOOL executing;
@property BOOL finished;
@property BOOL parsingComplete;
@property BOOL parsingVideoFiles;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSXMLParser *manifestParser;
@property (nonatomic, retain) NSMutableData *connectionData;

- (void)startOp;
- (void)finishOp;

@end

@implementation SCHHelpVideoManifestOperation

@synthesize executing;
@synthesize finished;
@synthesize parsingComplete;
@synthesize parsingVideoFiles;
@synthesize manifestParser;
@synthesize connection;
@synthesize connectionData;
@synthesize manifestItem; 

- (void)dealloc 
{
	[connection release], connection = nil;
	[connectionData release], connectionData = nil;
	[manifestParser release], manifestParser = nil;
    [manifestItem release], manifestItem = nil;
	
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
        self.manifestItem = [[[SCHHelpVideoManifest alloc] init] autorelease];
		
		self.connection = [NSURLConnection 
						   connectionWithRequest:[NSURLRequest requestWithURL:
                                                  [NSURL URLWithString:@"http://bitwink.com/private/helpvideos/HelpVideoManifest.xml"]]
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
    
     if (![self isCancelled]) {
         self.parsingVideoFiles = NO;
         self.manifestParser = [[[NSXMLParser alloc] initWithData:self.connectionData] autorelease];
         [self.manifestParser setDelegate:self];
         [self.manifestParser parse];
    
         [SCHDictionaryDownloadManager sharedDownloadManager].helpVideoManifest = self.manifestItem; 
     } else {
         NSLog(@"VideoManifestOperation was cancelled");
     }
    
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
	if ( [elementName isEqualToString:@"HelpVideoManifest"] ) {
			self.parsingVideoFiles = YES;
	}
	else if (self.parsingVideoFiles) {
		
		if ( [elementName isEqualToString:@"HelpVideo"] ) {
			NSString *typeValue = [attributeDict objectForKey:@"Type"];
			NSString *urlValue = [attributeDict objectForKey:@"href"];
			if (typeValue && urlValue) {
                NSLog(@"Setting %@ for %@", urlValue, typeValue);
                [self.manifestItem.manifestURLs setValue:urlValue forKey:typeValue];
            }
		}
	}
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
	if ( [elementName isEqualToString:@"HelpVideoManifest"] ) {
		self.parsingVideoFiles = NO;
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
    [[SCHDictionaryDownloadManager sharedDownloadManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateDownloadingHelpVideos];
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
    [super cancel];
    [self.connection cancel];
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
