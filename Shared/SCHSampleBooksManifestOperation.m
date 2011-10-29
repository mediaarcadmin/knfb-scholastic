//
//  SCHSampleBooksManifestOperation.m
//  Scholastic
//
//  Created by Matt Farrugia on 24/10/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSampleBooksManifestOperation.h"

@interface SCHSampleBooksManifestOperation()

@property BOOL executing;
@property BOOL finished;

@property (nonatomic, retain) NSURLConnection *connection;
@property (nonatomic, retain) NSXMLParser *manifestParser;
@property (nonatomic, retain) NSMutableData *connectionData;
@property (nonatomic, retain) NSMutableArray *sampleManifestEntries;
@property (nonatomic, retain) NSMutableDictionary *currentEntry;
@property (nonatomic, retain) NSMutableString *currentStringValue;

- (void)startOp;
- (void)finishOp;
- (void)importFailedWithReason:(NSString *)reason;

@end

@implementation SCHSampleBooksManifestOperation

@synthesize processingDelegate;
@synthesize manifestURL;
@synthesize executing;
@synthesize finished;
@synthesize manifestParser;
@synthesize connection;
@synthesize connectionData;
@synthesize sampleManifestEntries;
@synthesize currentEntry;
@synthesize currentStringValue;

- (void)dealloc 
{
    processingDelegate = nil;
    [manifestURL release], manifestURL = nil;
	[connection release], connection = nil;
	[connectionData release], connectionData = nil;
	[manifestParser release], manifestParser = nil;
    [sampleManifestEntries release], sampleManifestEntries = nil;
    [currentEntry release], currentEntry = nil;
    [currentStringValue release], currentStringValue = nil;
	
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
        
        if (self.manifestURL == nil ) {
            [self importFailedWithReason:NSLocalizedString(@"No sample eBooks URL was supplied", @"")];
        } else {
            
            self.connectionData = [[[NSMutableData alloc] init] autorelease];
            self.connection = [NSURLConnection 
                               connectionWithRequest:[NSURLRequest requestWithURL:
                                                      self.manifestURL]
                               delegate:self];
            
            if (self.connection == nil ) {
                [self importFailedWithReason:NSLocalizedString(@"Unable to create a connection for the sample eBooks download", @"")];
            } else {
                self.sampleManifestEntries = [NSMutableArray array];
                [self startOp];
            }    
        }
	}
}

- (NSArray *)sampleEntries
{
    return self.sampleManifestEntries;
}

- (void)importFailedWithReason:(NSString *)reason
{
    [self cancel];
    [self.processingDelegate importFailedWithReason:reason];
}

#pragma mark - NSURLConnection delegate

- (void)connection:(NSURLConnection *)conn 
didReceiveResponse:(NSURLResponse *)response
{
    BOOL success = YES;
    
    if ([response isKindOfClass:[NSHTTPURLResponse class]] == YES) {
        if (![(NSHTTPURLResponse *)response statusCode] == 200) {
            success = NO;
            NSLog(@"Error downloading file, errorCode: %d", [(NSHTTPURLResponse *)response statusCode]);
        }
    }
    
    if (!success) {
        [conn cancel];
        [self importFailedWithReason:NSLocalizedString(@"No response from the sample eBooks URL", @"")];
    } else {
        [self.connectionData setLength:0];
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
	[self.connectionData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{    
    NSXMLParser *aParser = [[NSXMLParser alloc] initWithData:self.connectionData];
    self.manifestParser = aParser;
    [aParser release];
    
    [self.manifestParser setDelegate:self];
    if ([self.manifestParser parse]) {
        [self finishOp];
    } else {
        [self importFailedWithReason:NSLocalizedString(@"Unable to parse the sample eBooks URL", @"")];
    }
}

- (void)connection:(NSURLConnection *)connection 
  didFailWithError:(NSError *)error
{
    [self importFailedWithReason:NSLocalizedString(@"Unable to download from the sample eBooks URL", @"")];   
}

#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser 
didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict
{		
    if ([elementName isEqualToString:@"Book"]) {
        self.currentEntry = [NSMutableDictionary dictionary];
    }
}

- (void)parser:(NSXMLParser *)parser 
 didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
	if ([elementName isEqualToString:@"Book"]) {
        [self.sampleManifestEntries addObject:self.currentEntry];
		self.currentEntry = nil;
	} else if ([elementName isEqualToString:@"Isbn13"] ||
               [elementName isEqualToString:@"Title"] ||
               [elementName isEqualToString:@"Author"] ||
               [elementName isEqualToString:@"Category"] ||
               [elementName isEqualToString:@"CoverUrl"] ||
               [elementName isEqualToString:@"DownloadUrl"]) {
        [self.currentEntry setValue:self.currentStringValue forKey:elementName];
    }
    
    self.currentStringValue = nil;
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!self.currentStringValue) {
        self.currentStringValue = [[[NSMutableString alloc] initWithCapacity:50] autorelease];
    }
    
    [self.currentStringValue appendString:[string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
}

#pragma mark - NSOperation methods

- (void)cancel
{
    [self.connection cancel];
    [self finishOp];
	[super cancel];
}

- (void)startOp
{
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
