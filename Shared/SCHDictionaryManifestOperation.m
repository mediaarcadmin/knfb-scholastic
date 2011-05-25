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
@property BOOL failure;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSXMLParser *manifestParser;
@property (nonatomic, retain) NSMutableData *connectionData;
@property (nonatomic, retain) NSMutableArray *manifestEntries;
@property (nonatomic, retain) SCHDictionaryManifestEntry *currentEntry;

- (void) startOp;
- (void) finishOp;

@end

@implementation SCHDictionaryManifestOperation

@synthesize executing, finished, downloadComplete, parsingComplete, parsingDictionaryInfo;
@synthesize manifestParser, connection, connectionData, manifestEntries, currentEntry;
@synthesize failure;

- (void)dealloc {
	self.connection = nil;
	self.connectionData = nil;
	self.manifestParser = nil;
    self.manifestEntries = nil;
    self.currentEntry = nil;
	
	[super dealloc];
}

- (void) start
{
	if (![self isCancelled]) {
        
        self.failure = NO;
		
		NSLog(@"Starting operation..");
		
		self.connectionData = [[NSMutableData alloc] init];
        self.manifestEntries = [[NSMutableArray alloc] init];
		
		self.connection = [NSURLConnection 
						   connectionWithRequest:[NSURLRequest requestWithURL:
												  [NSURL URLWithString:@"http://10.0.10.6/~gordon/dictionary/UpdateManifest.xml"]]
                            //                    [NSURL URLWithString:@"http://bits.blioreader.com/partners/Scholastic/SLInstall/QAStandard/UpdateManifest.xml"]]
						   delegate:self];
		
        [self startOp];
        
		if (self.connection) {
			do {
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
			} while (!self.downloadComplete);
		}
        
        if (failure) {
           
            
            [[SCHDictionaryManager sharedDictionaryManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateError];
            
            [self finishOp];
            
            return;
        }
		
		if (!finished) {
            
            self.parsingDictionaryInfo = NO;
            self.manifestParser = [[NSXMLParser alloc] initWithData:self.connectionData];
            [self.manifestParser setDelegate:self];
            [self.manifestParser parse];
            
            do {
                [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
            } while (self.parsingDictionaryInfo);
            
            [SCHDictionaryManager sharedDictionaryManager].manifestUpdates = self.manifestEntries;
            
		}
		
        [self finishOp];
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
    self.failure = NO;
	self.downloadComplete = YES;
}

- (void) connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	NSLog(@"failed download!");
    self.failure = YES;
	self.downloadComplete = YES;
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
//	NSLog(@"parsing element %@", elementName);
	if ( [elementName isEqualToString:@"UpdateComponent"] ) {
		NSString * attributeStringValue = [attributeDict objectForKey:@"Name"];
		if (attributeStringValue && [attributeStringValue isEqualToString:@"Dictionary"]) {
			self.parsingDictionaryInfo = YES;
		}
	}
	else if (self.parsingDictionaryInfo) {
		
		if ( [elementName isEqualToString:@"UpdateEntry"] ) {
            self.currentEntry = [[SCHDictionaryManifestEntry alloc] init];
            
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

- (void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName
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
    [[SCHDictionaryManager sharedDictionaryManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateManifestVersionCheck];
    [SCHDictionaryManager sharedDictionaryManager].isProcessing = NO;

	self.parsingComplete = YES;

}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    [[SCHDictionaryManager sharedDictionaryManager] threadSafeUpdateDictionaryState:SCHDictionaryProcessingStateError];
    [SCHDictionaryManager sharedDictionaryManager].isProcessing = NO;
    
	NSLog(@"Error: could not parse XML.");
	self.parsingComplete = YES;
}


- (void) cancel
{
    [self finishOp];
	[super cancel];
}

- (void) startOp
{
    [SCHDictionaryManager sharedDictionaryManager].isProcessing = YES;
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
    self.executing = YES;
    self.finished = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
    self.downloadComplete = NO;
}

- (void) finishOp
{
    [self willChangeValueForKey:@"isExecuting"];
    [self willChangeValueForKey:@"isFinished"];
	self.finished = YES;
	self.executing = NO;
    [self didChangeValueForKey:@"isExecuting"];
    [self didChangeValueForKey:@"isFinished"];
	[SCHDictionaryManager sharedDictionaryManager].isProcessing = NO;
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
