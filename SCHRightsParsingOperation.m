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

@property BOOL ttsPermitted;
@property BOOL reflowPermitted;
@property BOOL hasAudio;
@property BOOL hasStoryInteractions;
@property BOOL hasExtras;
@property BOOL layoutStartsOnLeftSide;
@property float drmVersion;
@property (nonatomic, retain) NSString *author;
@property (nonatomic, retain) NSString *title;
@property (nonatomic, retain) NSString *category;

- (void) begin;


@end

@implementation SCHRightsParsingOperation

@synthesize bookInfo, executing, finished, success, parsingComplete, rightsParser, metadataParser;
@synthesize ttsPermitted, reflowPermitted;
@synthesize hasAudio, hasStoryInteractions, hasExtras, layoutStartsOnLeftSide;
@synthesize drmVersion, author, title, category;

- (void)dealloc {
	self.bookInfo = nil;
	self.author = nil;
	self.title = nil;
	self.category = nil;
	
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
	
	
	self.hasAudio = [xpsProvider componentExistsAtPath:BlioXPSAudiobookMetadataFile];
	self.hasStoryInteractions = [xpsProvider componentExistsAtPath:BlioXPSStoryInteractionsMetadataFile];
	self.hasExtras = [xpsProvider componentExistsAtPath:BlioXPSExtrasMetadataFile];
	BOOL hasRights = [xpsProvider componentExistsAtPath:BlioXPSKNFBRightsFile];
	NSData *rightsFileData = [xpsProvider dataForComponentAtPath:BlioXPSKNFBRightsFile];
	
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
	
	NSLog(@"Rights for %@: tts: %@ reflow: %@ audio: %@ interactions: %@ extras: %@ layoutStartsOnLeft: %@", self.bookInfo.bookIdentifier, 
		  (self.ttsPermitted?@"Yes":@"No"), 
		  (self.reflowPermitted?@"Yes":@"No"),
		  (self.hasAudio?@"Yes":@"No"),
		  (self.hasStoryInteractions?@"Yes":@"No"),
		  (self.layoutStartsOnLeftSide?@"Yes":@"No"),
		  (self.hasStoryInteractions?@"Yes":@"No")
		  );
	NSLog(@"Title: \"%@\" Author: \"%@\" Category: \"%@\" DRM Version: %f", self.title, self.author, self.category, self.drmVersion);
	
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
	} else if (parser == self.metadataParser) {
		if ( [elementName isEqualToString:@"Feature"] ) {
			
			NSString * featureName = [attributeDict objectForKey:@"Name"];
			NSString * featureVersion = [attributeDict objectForKey:@"Version"];
			NSString * isRequired = [attributeDict objectForKey:@"IsRequired"];
			if (featureName && featureVersion && isRequired) {
				if ([isRequired isEqualToString:@"true"]) {
					
					self.drmVersion = [featureName floatValue];
					
					if (![SCHBookManager checkAppCompatibilityForFeature:featureName version:self.drmVersion]) {
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
				self.layoutStartsOnLeftSide = YES;
            } else {
				self.layoutStartsOnLeftSide = NO;
			}
        } else if ( [elementName isEqualToString:@"Contributor"] ) {
            NSString *authorVal = [attributeDict objectForKey:@"Author"];
            if(authorVal) {
				self.author = authorVal;
			}
        } else if ( [elementName isEqualToString:@"Title"] ) {
            NSString *titleVal = [attributeDict objectForKey:@"Main"];
            if(titleVal) {
				self.title = titleVal;
			}
        } else if ( [elementName isEqualToString:@"Scholastic"] ) {
            NSString *categoryVal = [attributeDict objectForKey:@"Category"];
            if(categoryVal) {
				self.category = categoryVal;
			} else {
				categoryVal = [attributeDict objectForKey:@"BookCategory"];
				if (categoryVal) {
					self.category = categoryVal;
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
