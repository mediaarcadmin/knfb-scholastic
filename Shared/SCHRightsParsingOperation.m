//
//  SCHRightsParsingOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 16/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHRightsParsingOperation.h"
#import "BITXPSProvider.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"

@interface SCHRightsParsingOperation ()

@property BOOL executing;
@property BOOL finished;
@property BOOL success;
@property BOOL parsingComplete;

@property (nonatomic, retain) NSXMLParser *rightsParser;
@property (nonatomic, retain) NSXMLParser *metadataParser;

- (void) begin;


@end

@implementation SCHRightsParsingOperation

@synthesize isbn, executing, finished, success, parsingComplete, rightsParser, metadataParser;

- (void)dealloc {
	self.isbn = nil;
	
	[super dealloc];
}


- (void) setIsbn: (NSString *) newIsbn
{
	
	if ([self isExecuting] || [self isFinished]) {
		return;
	}
	
	NSString *oldIsbn = isbn;
	isbn = [newIsbn retain];
	[oldIsbn release];
	
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	[book setProcessing:YES];
}

- (void) start
{
	if (self.isbn && ![self isCancelled]) {
		
		self.success = YES;
		
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
	
	SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
	BITXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
	NSData *rightsFileData = nil;
	
	BOOL hasAudio = [xpsProvider componentExistsAtPath:BlioXPSAudiobookMetadataFile];
	BOOL hasStoryInteractions = [xpsProvider componentExistsAtPath:BlioXPSStoryInteractionsMetadataFile];
	BOOL hasExtras = [xpsProvider componentExistsAtPath:BlioXPSExtrasMetadataFile];
	BOOL hasRights = [xpsProvider componentExistsAtPath:BlioXPSKNFBRightsFile];

//	[self.bookInfo setObject:[NSNumber numberWithBool:hasAudio] forLocalMetadataKey:kSCHBookInfoRightsHasAudio];
//	[self.bookInfo setObject:[NSNumber numberWithBool:hasStoryInteractions] forLocalMetadataKey:kSCHBookInfoRightsHasStoryInteractions];
//	[self.bookInfo setObject:[NSNumber numberWithBool:hasExtras] forLocalMetadataKey:kSCHBookInfoRightsHasExtras];
	
	[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
															setValue:[NSNumber numberWithBool:hasAudio]
															  forKey:kSCHAppBookHasAudio];
	[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
															setValue:[NSNumber numberWithBool:hasStoryInteractions]
															  forKey:kSCHAppBookHasStoryInteractions];
	[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
															setValue:[NSNumber numberWithBool:hasExtras]
															  forKey:kSCHAppBookHasExtras];
	if (hasRights) {
		rightsFileData = [xpsProvider dataForComponentAtPath:BlioXPSKNFBRightsFile];
	}
	
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
	
	// check for rights file
	if (hasRights) {
		if (rightsFileData) {
			// parse the XML data
			self.parsingComplete = NO;
			self.rightsParser = [[[NSXMLParser alloc] initWithData:rightsFileData] autorelease];
			[self.rightsParser setDelegate:self];
			[self.rightsParser parse];
			
			do {
				[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
			} while (!self.parsingComplete);
		}	
	}

	xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];

	// check for metadata file
	NSData *metadataData = [xpsProvider dataForComponentAtPath:BlioXPSEncryptedMetadata];
	
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
	
	if (metadataData) {
		self.parsingComplete = NO;
		self.metadataParser = [[[NSXMLParser alloc] initWithData:metadataData] autorelease];
		[self.metadataParser setDelegate:self];
		[self.metadataParser parse];

		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (!self.parsingComplete);
		
	}
	
	if (self.success) {
		[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyToRead];
	} else {
		[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateBookVersionNotSupported];
	}
	
	[book setProcessing:NO];

	self.finished = YES;
	self.executing = NO;
	
	return;
}

#pragma mark -
#pragma mark NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

	if (parser == self.rightsParser) {
	if ( [elementName isEqualToString:@"Audio"] ) {
			NSString * attributeStringValue = [attributeDict objectForKey:@"TTSRead"];
			if (attributeStringValue && [attributeStringValue isEqualToString:@"True"]) {
//				[self.bookInfo setObject:[NSNumber numberWithBool:YES] forLocalMetadataKey:kSCHBookInfoRightsTTSPermitted];
				[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
																		setValue:[NSNumber numberWithBool:YES]
																		  forKey:kSCHAppBookTTSPermitted];
			}
			else {
				[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
																		setValue:[NSNumber numberWithBool:NO]
																		  forKey:kSCHAppBookTTSPermitted];
			}
		}
		else if ( [elementName isEqualToString:@"Reflow"] ) {
			NSString * attributeStringValue = [attributeDict objectForKey:@"Enabled"];
			if (attributeStringValue && [attributeStringValue isEqualToString:@"True"]) {
				[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
																		setValue:[NSNumber numberWithBool:YES]
																		  forKey:kSCHAppBookReflowPermitted];
			}
			else {
				[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
																		setValue:[NSNumber numberWithBool:NO]
																		  forKey:kSCHAppBookReflowPermitted];
			}
		}
	} else if (parser == self.metadataParser) {
		if ( [elementName isEqualToString:@"Feature"] ) {
			
			NSString * featureName = [attributeDict objectForKey:@"Name"];
			NSString * featureVersion = [attributeDict objectForKey:@"Version"];
			NSString * isRequired = [attributeDict objectForKey:@"IsRequired"];
			if (featureName && featureVersion && isRequired) {
				if ([isRequired isEqualToString:@"true"]) {
					
					float floatVersion = [featureName floatValue];
//					[self.bookInfo setString:featureName forLocalMetadataKey:kSCHBookInfoRightsDRMVersion];
					[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
																			setValue:featureName
																			  forKey:kSCHAppBookDRMVersion];
					
					if (![SCHBookManager checkAppCompatibilityForFeature:featureName version:floatVersion]) {
						// app is not compatible
						self.success = NO;
					}
					else {
						// the app is compatible with the required version of this feature (no action required)
					}
				}
				else {
					// feature is optional
				}
			}
        } else if ( [elementName isEqualToString:@"PageLayout"] ) {
            NSString *firstPageSide = [attributeDict objectForKey:@"FirstPageSide"];
            if(firstPageSide && [firstPageSide isEqualToString:@"Left"]) {
//				[self.bookInfo setObject:[NSNumber numberWithBool:YES] forLocalMetadataKey:kSCHBookInfoRightsLayoutStartsOnLeftSide];
				[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
																		setValue:[NSNumber numberWithBool:YES]
																		  forKey:kSCHAppBookLayoutStartsOnLeftSide];
				
            } else {
				[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
																		setValue:[NSNumber numberWithBool:NO]
																		  forKey:kSCHAppBookLayoutStartsOnLeftSide];
			}
        } else if ( [elementName isEqualToString:@"Contributor"] ) {
            NSString *authorVal = [attributeDict objectForKey:@"Author"];
            if(authorVal) {
//				[self.bookInfo setObject:authorVal forLocalMetadataKey:kSCHBookInfoXPSAuthor];
				[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
																		setValue:authorVal
																		  forKey:kSCHAppBookXPSAuthor];
			}
        } else if ( [elementName isEqualToString:@"Title"] ) {
            NSString *titleVal = [attributeDict objectForKey:@"Main"];
            if(titleVal) {
				[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
																		setValue:titleVal
																		  forKey:kSCHAppBookXPSTitle];
			}
        } else if ( [elementName isEqualToString:@"Scholastic"] ) {
            NSString *categoryVal = [attributeDict objectForKey:@"Category"];
            if(categoryVal) {
				[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
																		setValue:categoryVal
																		  forKey:kSCHAppBookXPSCategory];
			} else {
				categoryVal = [attributeDict objectForKey:@"BookCategory"];
				if (categoryVal) {
					[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
																			setValue:categoryVal
																			  forKey:kSCHAppBookXPSCategory];
				}
			}
        }
		
	}
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
//	self.finished = YES;
//	self.executing = NO;
	self.parsingComplete = YES;
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	self.success = NO;
	self.parsingComplete = YES;
//	self.finished = YES;
//	self.executing = NO;
	
}


@end
