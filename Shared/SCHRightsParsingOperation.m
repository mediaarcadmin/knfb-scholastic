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
@property BOOL success;
@property BOOL parsingComplete;

@property (nonatomic, retain) NSXMLParser *rightsParser;
@property (nonatomic, retain) NSXMLParser *metadataParser;

- (void) begin;


@end

@implementation SCHRightsParsingOperation

@synthesize bookInfo, executing, finished, success, parsingComplete, rightsParser, metadataParser;

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
	
	BWKXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBook:self.bookInfo];
	NSData *rightsFileData = nil;
	
	
	BOOL hasAudio = [xpsProvider componentExistsAtPath:BlioXPSAudiobookMetadataFile];
	BOOL hasStoryInteractions = [xpsProvider componentExistsAtPath:BlioXPSStoryInteractionsMetadataFile];
	BOOL hasExtras = [xpsProvider componentExistsAtPath:BlioXPSExtrasMetadataFile];
	BOOL hasRights = [xpsProvider componentExistsAtPath:BlioXPSKNFBRightsFile];

	[self.bookInfo setObject:[NSNumber numberWithBool:hasAudio] forLocalMetadataKey:kSCHBookInfoRightsHasAudio];
	[self.bookInfo setObject:[NSNumber numberWithBool:hasStoryInteractions] forLocalMetadataKey:kSCHBookInfoRightsHasStoryInteractions];
	[self.bookInfo setObject:[NSNumber numberWithBool:hasExtras] forLocalMetadataKey:kSCHBookInfoRightsHasExtras];
	
	if (hasRights) {
		rightsFileData = [xpsProvider dataForComponentAtPath:BlioXPSKNFBRightsFile];
	}
	
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBook:self.bookInfo];
	
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

	xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBook:self.bookInfo];

	// check for metadata file
	NSData *metadataData = [xpsProvider dataForComponentAtPath:BlioXPSEncryptedMetadata];
	
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBook:self.bookInfo];
	
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
		[self.bookInfo setProcessingState:SCHBookInfoProcessingStateReadyToRead];
	} else {
		[self.bookInfo setProcessingState:SCHBookInfoProcessingStateBookVersionNotSupported];
	}
	
	[self.bookInfo setProcessing:NO];

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
				[self.bookInfo setObject:[NSNumber numberWithBool:YES] forLocalMetadataKey:kSCHBookInfoRightsTTSPermitted];
			}
			else {
				[self.bookInfo setObject:[NSNumber numberWithBool:NO] forLocalMetadataKey:kSCHBookInfoRightsTTSPermitted];
			}
		}
		else if ( [elementName isEqualToString:@"Reflow"] ) {
			NSString * attributeStringValue = [attributeDict objectForKey:@"Enabled"];
			if (attributeStringValue && [attributeStringValue isEqualToString:@"True"]) {
				[self.bookInfo setObject:[NSNumber numberWithBool:YES] forLocalMetadataKey:kSCHBookInfoRightsReflowPermitted];
			}
			else {
				[self.bookInfo setObject:[NSNumber numberWithBool:NO] forLocalMetadataKey:kSCHBookInfoRightsReflowPermitted];
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
					[self.bookInfo setString:featureName forLocalMetadataKey:kSCHBookInfoRightsDRMVersion];

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
				[self.bookInfo setObject:[NSNumber numberWithBool:YES] forLocalMetadataKey:kSCHBookInfoRightsLayoutStartsOnLeftSide];
            } else {
				[self.bookInfo setObject:[NSNumber numberWithBool:NO] forLocalMetadataKey:kSCHBookInfoRightsLayoutStartsOnLeftSide];
			}
        } else if ( [elementName isEqualToString:@"Contributor"] ) {
            NSString *authorVal = [attributeDict objectForKey:@"Author"];
            if(authorVal) {
				[self.bookInfo setObject:authorVal forLocalMetadataKey:kSCHBookInfoXPSAuthor];
			}
        } else if ( [elementName isEqualToString:@"Title"] ) {
            NSString *titleVal = [attributeDict objectForKey:@"Main"];
            if(titleVal) {
				[self.bookInfo setObject:titleVal forLocalMetadataKey:kSCHBookInfoXPSTitle];
			}
        } else if ( [elementName isEqualToString:@"Scholastic"] ) {
            NSString *categoryVal = [attributeDict objectForKey:@"Category"];
            if(categoryVal) {
				[self.bookInfo setObject:categoryVal forLocalMetadataKey:kSCHBookInfoXPSCategory];
			} else {
				categoryVal = [attributeDict objectForKey:@"BookCategory"];
				if (categoryVal) {
					[self.bookInfo setObject:categoryVal forLocalMetadataKey:kSCHBookInfoXPSCategory];
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
