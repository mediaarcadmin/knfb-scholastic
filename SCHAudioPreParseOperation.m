//
//  SCHAudioPreParseOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 19/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHAudioPreParseOperation.h"
#import "SCHXPSProvider.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "KNFBXPSConstants.h"

#pragma mark - Class Extension

@interface SCHAudioPreParseOperation ()

@property BOOL success;
@property BOOL parsingComplete;

@property (nonatomic, retain) NSXMLParser *audioInfoParser;

@end

#pragma mark -

@implementation SCHAudioPreParseOperation

@synthesize success;
@synthesize parsingComplete;
@synthesize audioInfoParser;

#pragma mark - Object Lifecycle

- (void)dealloc 
{
    [audioInfoParser release], audioInfoParser = nil;
	[super dealloc];
}

#pragma mark - Book Operation methods

- (void)start
{
	if (self.isbn && ![self isCancelled]) {
		self.success = YES;
		[super start];
	}
}

- (void)beginOperation
{
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
	
	// check for metadata file
	NSData *metadataData = [xpsProvider dataForComponentAtPath:KNFBXPSKNFBMetadataFile];
	
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
	
	if (metadataData) {
		self.parsingComplete = NO;
		self.audioInfoParser = [[[NSXMLParser alloc] initWithData:metadataData] autorelease];
		[self.audioInfoParser setDelegate:self];
		[self.audioInfoParser parse];
        
		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (!self.parsingComplete);
		
	}
	
	if (self.success) {
		[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyForTextFlowPreParse];
	} else {
		[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateBookVersionNotSupported];
	}
	
	[book setProcessing:NO];
    
    [self endOperation];
	
	return;
}

#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {
    
//    if ( [elementName isEqualToString:@"PageLayout"] ) {
//        NSString *firstPageSide = [attributeDict objectForKey:@"FirstPageSide"];
//        if(firstPageSide && [firstPageSide isEqualToString:@"Left"]) {
//            [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
//                                                                    setValue:[NSNumber numberWithBool:YES]
//                                                                      forKey:kSCHAppBookLayoutStartsOnLeftSide];
//            
//        } else {
//            [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
//                                                                    setValue:[NSNumber numberWithBool:NO]
//                                                                      forKey:kSCHAppBookLayoutStartsOnLeftSide];
//        }
//    }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	self.parsingComplete = YES;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	self.success = NO;
	self.parsingComplete = YES;
}


@end
