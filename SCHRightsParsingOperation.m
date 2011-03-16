//
//  SCHRightsParsingOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 16/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHRightsParsingOperation.h"
#import "BWKXPSProvider.h"
#import "SCHBookManager.h"

@interface SCHRightsParsingOperation ()

@property BOOL executing;
@property BOOL finished;
@property (nonatomic, retain) NSXMLParser *rightsParser;

@property BOOL ttsPermitted;
@property BOOL reflowPermitted;

- (void) begin;


@end

@implementation SCHRightsParsingOperation

@synthesize bookInfo, executing, finished, rightsParser;
@synthesize ttsPermitted, reflowPermitted;

- (void)dealloc {
	self.bookInfo = nil;
	
	[super dealloc];
}


- (void) setBookInfo:(SCHBookInfo *) newBookInfo
{
	
	if ([self isExecuting] || [self isFinished]) {
		return;
	}
	
	bookInfo = newBookInfo;
	[self.bookInfo setProcessing:YES];
}

- (void) start
{
	if (self.bookInfo && ![self isCancelled]) {
		
		self.ttsPermitted = YES;
		self.reflowPermitted = YES;
		
		[self begin];
	}
	
}

- (void) cancel
{
	self.finished = YES;
	self.executing = NO;
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

- (void) begin
{
	
	BWKXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBook:self.bookInfo];
	
	NSData *rightsFileData = [xpsProvider dataForComponentAtPath:BlioXPSKNFBRightsFile];
	
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBook:self.bookInfo];
	
	if (!rightsFileData) {
		[self.bookInfo setProcessingState:SCHBookInfoProcessingStateReadyToRead];
		[self.bookInfo setProcessing:NO];
		return;
	}
	
	// parse the XML data
	self.rightsParser = [[[NSXMLParser alloc] initWithData:rightsFileData] autorelease];
	[rightsParser setDelegate:self];
	[rightsParser parse];
	
	do {
		[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
	} while (!self.finished);
	
	NSLog(@"Rights for %@: tts: %@ reflow: %@", self.bookInfo.bookIdentifier, 
		  (self.ttsPermitted?@"Yes":@"No"), (self.reflowPermitted?@"Yes":@"No"));
	
	[self.bookInfo setProcessing:NO];
	return;
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
		if ( [elementName isEqualToString:@"Audio"] ) {
			NSString * attributeStringValue = [attributeDict objectForKey:@"TTSRead"];
			if (attributeStringValue && [attributeStringValue isEqualToString:@"True"]) {
				self.ttsPermitted = YES;
			}
			else {
				self.ttsPermitted = NO;
			}
		}
		else if ( [elementName isEqualToString:@"Reflow"] ) {
			NSString * attributeStringValue = [attributeDict objectForKey:@"Enabled"];
			if (attributeStringValue && [attributeStringValue isEqualToString:@"True"]) {
				self.reflowPermitted = YES;
			}
			else {
				self.reflowPermitted = NO;
			}
		}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	[self.bookInfo setProcessingState:SCHBookInfoProcessingStateReadyToRead];
	
	self.finished = YES;
	self.executing = NO;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	[self.bookInfo setProcessingState:SCHBookInfoProcessingStateError];
	
	self.finished = YES;
	self.executing = NO;
	
}


@end
