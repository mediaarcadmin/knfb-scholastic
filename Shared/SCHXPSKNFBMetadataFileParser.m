//
//  SCHXPSKNFBMetadataFileParser.m
//  Scholastic
//
//  Created by John Eddie on 16/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHXPSKNFBMetadataFileParser.h"

// Constants
static NSString * const kSCHXPSKNFBMetadataFileParserContributor = @"Contributor";
NSString * const kSCHXPSKNFBMetadataFileParserAuthor = @"Author";
NSString * const kSCHXPSKNFBMetadataFileParserTitle = @"Title";
static NSString * const kSCHXPSKNFBMetadataFileParserMain = @"Main";
static NSString * const kSCHXPSKNFBMetadataFileParserIdentifier = @"Identifier";
NSString * const kSCHXPSKNFBMetadataFileParserISBN = @"ISBN";

@interface SCHXPSKNFBMetadataFileParser () <NSXMLParserDelegate>

@property (nonatomic, retain) NSMutableDictionary *parsingResults;

@end

@implementation SCHXPSKNFBMetadataFileParser

@synthesize parsingResults;

- (void)dealloc
{
    [parsingResults release], parsingResults = nil;
    
    [super dealloc];
}

// returns nil if xmlString is nil or there was an error parsing 
- (NSDictionary *)parseXMLData:(NSData *)xmlData
{
    NSDictionary *ret = nil;
    
    if (xmlData != nil) {
//        NSLog(@"%@", [[[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding] autorelease]);
        NSXMLParser *xmlParser = [[[NSXMLParser alloc] initWithData:xmlData] autorelease];
        
        if (xmlParser != nil) {
            self.parsingResults = [NSMutableDictionary dictionary];            
            xmlParser.delegate = self;
            if ([xmlParser parse] == YES) {
                ret = [NSDictionary dictionaryWithDictionary:self.parsingResults];
            }
            self.parsingResults = nil;                    
        }
    }
    
    return ret;
}

#pragma - XMLParser Delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict 
{
    NSString *value = nil;
    
    if ([elementName isEqualToString:kSCHXPSKNFBMetadataFileParserContributor] == YES) {
        value = [attributeDict objectForKey:kSCHXPSKNFBMetadataFileParserAuthor];
        if (value != nil) {
            [self.parsingResults setObject:value forKey:kSCHXPSKNFBMetadataFileParserAuthor];
        }            
    } else if ([elementName isEqualToString:kSCHXPSKNFBMetadataFileParserTitle] == YES) {
        value = [attributeDict objectForKey:kSCHXPSKNFBMetadataFileParserMain];
        if (value != nil) {
            [self.parsingResults setObject:value forKey:kSCHXPSKNFBMetadataFileParserTitle];
        }            
    } else if ([elementName isEqualToString:kSCHXPSKNFBMetadataFileParserIdentifier] == YES) {
        value = [attributeDict objectForKey:kSCHXPSKNFBMetadataFileParserISBN];
        if (value != nil) {
            [self.parsingResults setObject:value forKey:kSCHXPSKNFBMetadataFileParserISBN];
        }            
    }
}

@end
