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
	if (self.identifier && ![self isCancelled]) {
		self.success = YES;
		[super start];
	}
}

- (void)beginOperation
{
	SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.identifier 
                                                                                    inManagedObjectContext:self.localManagedObjectContext];
	
	BOOL hasAudio = [xpsProvider componentExistsAtPath:KNFBXPSAudiobookMetadataFile];
	BOOL hasStoryInteractions = [xpsProvider componentExistsAtPath:KNFBXPSStoryInteractionsMetadataFile];
	BOOL hasExtras = [xpsProvider componentExistsAtPath:KNFBXPSExtrasMetadataFile];
	
    [self performWithBookAndSave:^(SCHAppBook *book) {
        [book setValue:[NSNumber numberWithBool:hasAudio] forKey:kSCHAppBookHasAudio];
        [book setValue:[NSNumber numberWithBool:hasStoryInteractions] forKey:kSCHAppBookHasStoryInteractions];
        [book setValue:[NSNumber numberWithBool:hasExtras] forKey:kSCHAppBookHasExtras];
    }];
    
	// check for metadata file
	NSData *metadataData = [xpsProvider dataForComponentAtPath:KNFBXPSKNFBMetadataFile];
	
	[[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.identifier];
	
	if (metadataData) {
		self.parsingComplete = NO;
		self.metadataParser = [[[NSXMLParser alloc] initWithData:metadataData] autorelease];
		[self.metadataParser setDelegate:self];
		[self.metadataParser parse];

		do {
			[[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate distantFuture]];
		} while (!self.parsingComplete);
		
	}
	
    [self setProcessingState:(self.success ? SCHBookProcessingStateReadyForAudioInfoParsing : SCHBookProcessingStateBookVersionNotSupported)];
    [self setIsProcessing:NO];
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
                    [self performWithBook:^(SCHAppBook *book) {
                        [book setValue:featureName forKey:kSCHAppBookDRMVersion];
                    }];
					
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
                [self performWithBook:^(SCHAppBook *book) {
                    [book setValue:[NSNumber numberWithBool:YES] forKey:kSCHAppBookLayoutStartsOnLeftSide];
                }];
            } else {
                [self performWithBook:^(SCHAppBook *book) {
                    [book setValue:[NSNumber numberWithBool:NO] forKey:kSCHAppBookLayoutStartsOnLeftSide];
                }];
			}
        } else if ( [elementName isEqualToString:@"Contributor"] ) {
            NSString *authorVal = [attributeDict objectForKey:@"Author"];
            if(authorVal) {
                [self performWithBook:^(SCHAppBook *book) {
                    [book setValue:authorVal forKey:kSCHAppBookXPSAuthor];
                }];
			}
        } else if ( [elementName isEqualToString:@"Title"] ) {
            NSString *titleVal = [attributeDict objectForKey:@"Main"];
            if(titleVal) {
                [self performWithBook:^(SCHAppBook *book) {
                    [book setValue:titleVal forKey:kSCHAppBookXPSTitle];
                }];
			}
        } else if ( [elementName isEqualToString:@"Scholastic"] ) {
            NSString *categoryVal = [attributeDict objectForKey:@"Category"];
            if(categoryVal) {
                [self performWithBook:^(SCHAppBook *book) {
                    [book setValue:categoryVal forKey:kSCHAppBookXPSCategory];
                }];
			} else {
				categoryVal = [attributeDict objectForKey:@"BookCategory"];
				if (categoryVal) {
                    [self performWithBook:^(SCHAppBook *book) {
                        [book setValue:categoryVal forKey:kSCHAppBookXPSCategory];
                    }];
				}
			}
        }
}

- (void)parserDidEndDocument:(NSXMLParser *)parser
{
	self.parsingComplete = YES;
    
    [self performWithBookAndSave:nil];
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
	self.success = NO;
	self.parsingComplete = YES;
}

@end
