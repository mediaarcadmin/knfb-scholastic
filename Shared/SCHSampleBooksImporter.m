//
//  SCHSampleBooksManager.m
//  Scholastic
//
//  Created by Matt Farrugia on 24/10/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSampleBooksImporter.h"
#import "SCHCoreDataHelper.h"
#import "SCHSampleBooksManifestOperation.h"
#import "SCHSyncManager.h"
#import "NSNumber+ObjectTypes.h"
#import "SCHBookIdentifier.h"
#import "SCHAppStateManager.h"

NSString * const kSCHSampleBooksLocalManifestFile = @"LocalSamplesManifest.xml";

@interface SCHSampleBooksImporter() <NSXMLParserDelegate>

@property (nonatomic, retain) NSMutableArray *sampleManifestEntries;
@property (nonatomic, retain) NSMutableDictionary *currentEntry;
@property (nonatomic, retain) NSMutableString *currentStringValue;

- (BOOL)populateSampleStoreFromEntries:(NSArray *)sampleEntries;
- (SCHBookIdentifier *)identifierForSampleEntry:(NSDictionary *)sampleEntry;

@end

@implementation SCHSampleBooksImporter

@synthesize sampleManifestEntries;
@synthesize currentEntry;
@synthesize currentStringValue;

- (void)dealloc
{
    [sampleManifestEntries release], sampleManifestEntries = nil;
    [currentEntry release], currentEntry = nil;
    [currentStringValue release], currentStringValue = nil;
    [super dealloc];
}

- (NSUInteger)sampleBookCount
{
    // TODO: refactor this parsing to make it DRY
    NSString *localManifest = [[NSBundle mainBundle] pathForResource:kSCHSampleBooksLocalManifestFile ofType:nil];
    NSURL *localManifestURL = localManifest ? [NSURL fileURLWithPath:localManifest] : nil;
    NSData *data = [NSData dataWithContentsOfURL:localManifestURL];
    
    self.sampleManifestEntries = [NSMutableArray array];
    
    NSXMLParser *aParser = [[NSXMLParser alloc] initWithData:data];
    aParser.delegate = self;
    [aParser parse];
    [aParser release];
    
    return [self.sampleManifestEntries count];
}

- (BOOL)importSampleBooks
{
    BOOL success = NO;
    NSString *localManifest = [[NSBundle mainBundle] pathForResource:kSCHSampleBooksLocalManifestFile ofType:nil];
    NSURL *localManifestURL = localManifest ? [NSURL fileURLWithPath:localManifest] : nil;
    NSData *data = [NSData dataWithContentsOfURL:localManifestURL];
    
    self.sampleManifestEntries = [NSMutableArray array];
    
    NSXMLParser *aParser = [[NSXMLParser alloc] initWithData:data];
    aParser.delegate = self;
    [aParser parse];
    [aParser release];
        
    success = [self populateSampleStoreFromEntries:self.sampleManifestEntries];
    
    return success;
}

- (BOOL)importLocalBooks
{
    BOOL success = [[SCHSyncManager sharedSyncManager] populateSampleStoreFromImport];
    return success;
}

- (SCHBookIdentifier *)identifierForSampleEntry:(NSDictionary *)sampleEntry
{
    NSString *isbn = [sampleEntry valueForKey:@"Isbn13"];
    NSNumber *drmQualifier = [NSNumber numberWithInt:kSCHDRMQualifiersNone];
    
    SCHBookIdentifier *sampleIdentifier = nil;
    
    if (isbn && drmQualifier) {
        sampleIdentifier = [[[SCHBookIdentifier alloc] initWithISBN:isbn DRMQualifier:drmQualifier] autorelease];
    }

    return sampleIdentifier;
}
                          
- (BOOL)populateSampleStoreFromEntries:(NSArray *)sampleEntries {
    
    BOOL success = NO;
    
    if ([sampleEntries count]) {
        
        // Remove duplicates from samples, newest version trumps
        NSMutableArray *uniqueSamples = [NSMutableArray array];
        
        [sampleEntries enumerateObjectsUsingBlock:^(id sampleObj, NSUInteger sampleIdx, BOOL *sampleStop) {
            SCHBookIdentifier *sampleIdentifier = [self identifierForSampleEntry:(NSDictionary *)sampleObj];
            
            if (sampleIdentifier) {
                
                __block id sampleToBeRemoved = nil;
                __block id sampleToBeAdded = sampleObj;
                
                [uniqueSamples enumerateObjectsUsingBlock:^(id existingObj, NSUInteger exampleIdx, BOOL *existingStop) {
                    
                    SCHBookIdentifier *existingIdentifier = [self identifierForSampleEntry:(NSDictionary *)existingObj];
                    
                    if ([existingIdentifier isEqual:sampleIdentifier]) {
                        
                        NSInteger existingVersion = [[(NSDictionary *)existingObj valueForKey:@"Version"] intValue];
                        NSInteger sampleVersion = [[(NSDictionary *)sampleObj valueForKey:@"Version"] intValue];
                        
                        if (existingVersion >= sampleVersion) {
                            sampleToBeAdded = nil;
                        } else {
                            sampleToBeRemoved = existingObj;
                        }
                        
                        *existingStop = YES;
                    }
                }];
                
                if (sampleToBeRemoved) {
                    [uniqueSamples removeObject:sampleToBeRemoved];
                }
                
                if (sampleToBeAdded) {
                    [uniqueSamples addObject:sampleToBeAdded];
                }
            }
        }];
        
        
        success = [[SCHSyncManager sharedSyncManager] populateSampleStoreFromManifestEntries:uniqueSamples];
        
    }
    
    return success;
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
        if (self.currentEntry != nil) {
            [self.sampleManifestEntries addObject:self.currentEntry];
            self.currentEntry = nil;
        }
	} else if ([elementName isEqualToString:@"Isbn13"] ||
               [elementName isEqualToString:@"Title"] ||
               [elementName isEqualToString:@"Author"] ||
               [elementName isEqualToString:@"Category"] ||
               [elementName isEqualToString:@"CoverUrl"] ||
               [elementName isEqualToString:@"DownloadUrl"] ||
               [elementName isEqualToString:@"Version"] ||
               [elementName isEqualToString:@"IsEnhanced"] ||
               [elementName isEqualToString:@"FileSize"]) {
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

@end
