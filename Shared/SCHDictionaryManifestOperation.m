//
//  SCHDictionaryManifestOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 17/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDictionaryManifestOperation.h"
#import "SCHDictionaryManager.h"

@interface SCHDictionaryManifestOperation ()

@property BOOL executing;
@property BOOL finished;
@property BOOL downloadComplete;
@property BOOL parsingComplete;
@property BOOL parsingDictionaryInfo;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSXMLParser *manifestParser;
@property (nonatomic, retain) NSMutableData *connectionData;


@end

@implementation SCHDictionaryManifestOperation

@synthesize executing, finished, downloadComplete, parsingComplete, parsingDictionaryInfo;
@synthesize manifestParser, connection, connectionData;

- (void)dealloc {
	self.connection = nil;
	self.connectionData = nil;
	self.manifestParser = nil;
	
	[super dealloc];
}

- (void) start
{
/*	if (![NSThread isMainThread])
	{
		[self performSelectorOnMainThread:@selector(start)
							   withObject:nil waitUntilDone:NO];
		return;
	}*/
	
	if (![self isCancelled]) {
		
		NSLog(@"Starting operation..");
		[[SCHDictionaryManager sharedDictionaryManager] dictionaryObject].isProcessing = YES;
		
		self.connectionData = [[NSMutableData alloc] init];
		
		self.connection = [NSURLConnection 
						   connectionWithRequest:[NSURLRequest requestWithURL:
												  [NSURL URLWithString:@"http://bits.blioreader.com/partners/Scholastic/SLInstall/UpdateManifest.xml"]]
						   delegate:self];
		
		self.executing = YES;
		self.finished = NO;
		self.downloadComplete = NO;
		if (self.connection) {
			do {
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
			} while (!self.downloadComplete);
		}
		
		if (!finished) {
		
		self.parsingDictionaryInfo = NO;
		self.manifestParser = [[NSXMLParser alloc] initWithData:self.connectionData];
		[self.manifestParser setDelegate:self];
		[self.manifestParser parse];
		
		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (self.parsingDictionaryInfo);
		
		}
		
		self.finished = YES;
		self.executing = NO;
		[[SCHDictionaryManager sharedDictionaryManager] dictionaryObject].isProcessing = NO;
	}
}

#pragma mark -
#pragma mark NSURLConnection delegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response
{
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
	self.downloadComplete = YES;
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"failed download!");
	self.downloadComplete = YES;
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
	NSLog(@"parsing element %@", elementName);
	if ( [elementName isEqualToString:@"UpdateComponent"] ) {
		NSString * attributeStringValue = [attributeDict objectForKey:@"Name"];
		if (attributeStringValue && [attributeStringValue isEqualToString:@"Dictionary"]) {
			self.parsingDictionaryInfo = YES;
		}
	}
	else if (self.parsingDictionaryInfo) {
		
		if ( [elementName isEqualToString:@"UpdateEntry"] ) {
			NSString * attributeStringValue = [attributeDict objectForKey:@"EndVersion"];
			if (attributeStringValue) {
				[[SCHDictionaryManager sharedDictionaryManager] dictionaryObject].dictionaryVersion = [attributeStringValue floatValue];
			}
			attributeStringValue = [attributeDict objectForKey:@"href"];
			if (attributeStringValue) {
				[[SCHDictionaryManager sharedDictionaryManager] dictionaryObject].dictionaryURL = attributeStringValue;
			}
		}
	}
}

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
{
	if ( [elementName isEqualToString:@"UpdateComponent"] ) {
		self.parsingDictionaryInfo = NO;
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	NSLog(@"Dictionary version: %f URL: %@", [[SCHDictionaryManager sharedDictionaryManager] dictionaryObject].dictionaryVersion, 
		  [[SCHDictionaryManager sharedDictionaryManager] dictionaryObject].dictionaryURL);
	
	[[SCHDictionaryManager sharedDictionaryManager] dictionaryObject].dictionaryState = SCHDictionaryProcessingStateNeedsDownload;
	[[SCHDictionaryManager sharedDictionaryManager] dictionaryObject].isProcessing = NO;

	self.parsingComplete = YES;

}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	NSLog(@"Error: could not parse XML.");
	self.parsingComplete = YES;
}


- (void) cancel
{
	self.finished = YES;
	self.executing = NO;
	[[SCHDictionaryManager sharedDictionaryManager] dictionaryObject].isProcessing = NO;

	[super cancel];
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



@end
