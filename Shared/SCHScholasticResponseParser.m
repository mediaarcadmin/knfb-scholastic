//
//  SCHScholasticResponseParser.m
//  Scholastic
//
//  Created by John Eddie on 13/07/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHScholasticResponseParser.h"

#import "BITAPIError.h"

static NSString * const kSCHScholasticResponseParserAttribute = @"attribute";
static NSString * const kSCHScholasticResponseParserAttributeName = @"name";
static NSString * const kSCHScholasticResponseParserAttributeValue = @"value";
static NSString * const kSCHScholasticResponseParserAttributeErrorCode = @"errorCode";
static NSString * const kSCHScholasticResponseParserAttributeErrorDesc = @"errorDesc";


@interface SCHScholasticResponseParser () <NSXMLParserDelegate>

@property (nonatomic, retain) NSMutableDictionary *parsingResults;

@end

@implementation SCHScholasticResponseParser

@synthesize parsingResults;

- (void)dealloc
{
    [parsingResults release], parsingResults = nil;

    [super dealloc];
}

// returns nil if xmlString is nil or there was an error parsing 
- (NSDictionary *)parseXMLString:(NSString *)xmlString
{
    NSDictionary *ret = nil;
    
    if (xmlString != nil) {
        NSData *xmlData = [xmlString dataUsingEncoding:NSUTF8StringEncoding];
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
    if ([elementName isEqualToString:kSCHScholasticResponseParserAttribute] == YES) {
        NSString *name = [attributeDict objectForKey:kSCHScholasticResponseParserAttributeName];
        NSString *value = [attributeDict objectForKey:kSCHScholasticResponseParserAttributeValue];
        
        if (name != nil) {
            [self.parsingResults setObject:(value != nil ? value : [NSNull null]) forKey:name];
        }
    }
}

#pragma - Class methods

+ (NSError *)errorFromDictionary:(NSDictionary *)responseDictionary
{
    NSError *ret = nil;
    
    if (responseDictionary != nil) {
        NSString *errorCode = [responseDictionary objectForKey:kSCHScholasticResponseParserAttributeErrorCode];
        NSString *errorDescription = [responseDictionary objectForKey:kSCHScholasticResponseParserAttributeErrorDesc];
        
        if (errorCode != nil && errorCode != (id)[NSNull null]) {
            NSDictionary *userInfo = nil;
            
            if (errorDescription != nil) {
                userInfo = [NSDictionary dictionaryWithObject:errorDescription 
                                            forKey:NSLocalizedDescriptionKey];
            }
            
            ret = [NSError errorWithDomain:kBITAPIErrorDomain 
                                      code:[errorCode integerValue]
                                  userInfo:userInfo];
        }
    }
    
    return ret;
}

@end
