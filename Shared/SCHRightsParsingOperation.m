//
//  SCHRightsParsingOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 16/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHRightsParsingOperation.h"
#import "SCHXPSProvider.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "KNFBXPSConstants.h"

#pragma mark - Class Extension

@interface SCHRightsParsingOperation ()

@property BOOL success;
@property BOOL parsingComplete;

@property (nonatomic, retain) NSXMLParser *metadataParser;

@end

@implementation SCHRightsParsingOperation

@synthesize success;
@synthesize parsingComplete;
@synthesize metadataParser;

#pragma mark - Object Lifecycle

- (void)dealloc 
{
    [metadataParser release], metadataParser = nil;
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
	
	BOOL hasAudio = [xpsProvider componentExistsAtPath:KNFBXPSAudiobookMetadataFile];
	BOOL hasStoryInteractions = [xpsProvider componentExistsAtPath:KNFBXPSStoryInteractionsMetadataFile];
	BOOL hasExtras = [xpsProvider componentExistsAtPath:KNFBXPSExtrasMetadataFile];
	
	[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
															setValue:[NSNumber numberWithBool:hasAudio]
															  forKey:kSCHAppBookHasAudio];
	[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
															setValue:[NSNumber numberWithBool:hasStoryInteractions]
															  forKey:kSCHAppBookHasStoryInteractions];
	[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
															setValue:[NSNumber numberWithBool:hasExtras]
															  forKey:kSCHAppBookHasExtras];
    
	// check for metadata file
	NSData *metadataData = [xpsProvider dataForComponentAtPath:KNFBXPSKNFBMetadataFile];
	
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
		[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyForAudioInfoParsing];
	} else {
		[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateBookVersionNotSupported];
	}
	
	[book setProcessing:NO];

    [self endOperation];
	
	return;
}

#pragma mark - NSXMLParserDelegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict {

    if ( [elementName isEqualToString:@"Feature"] ) {
			
			NSString * featureName = [attributeDict objectForKey:@"Name"];
			NSString * featureVersion = [attributeDict objectForKey:@"Version"];
			NSString * isRequired = [attributeDict objectForKey:@"IsRequired"];
			if (featureName && featureVersion && isRequired) {
				if ([isRequired isEqualToString:@"true"]) {
					
					float floatVersion = [featureName floatValue];
					[[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn
																			setValue:featureName
																			  forKey:kSCHAppBookDRMVersion];
					
                    NSLog(@"book drm version: %f", floatVersion);
                    
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
