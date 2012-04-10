//
//  SCHRecommendationProcessor.m
//  Scholastic
//
//  Created by John Eddie on 15/03/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationProcessor.h"

#import "SCHRecommendationConstants.h"

@interface SCHRecommendationProcessor () <NSXMLParserDelegate>

@property (nonatomic, retain) NSMutableArray *results;
@property (nonatomic, retain) NSMutableDictionary *currentCategory;
@property (nonatomic, retain) NSMutableDictionary *currentRecommendation;
@property (nonatomic, assign) BOOL parsingCharacters;
@property (nonatomic, retain) NSMutableString *currentString;

@end

@implementation SCHRecommendationProcessor

@synthesize results;
@synthesize currentCategory;
@synthesize currentRecommendation;
@synthesize parsingCharacters;
@synthesize currentString;

- (void)dealloc
{
    [results release], results = nil;
    [currentCategory release], currentCategory = nil;
    [currentRecommendation release], currentRecommendation = nil;
    [currentString release], currentString = nil;

    [super dealloc];
}

- (NSArray *)recommendationsFrom:(NSData *)recommendationXML
{
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:recommendationXML];
    if (xmlParser != nil) {
        self.results = [NSMutableArray array];
        xmlParser.delegate = self;
        if ([xmlParser parse] == NO) {
            self.results = nil;      
        }
        self.currentRecommendation = nil;
        self.currentString = nil;    

        [xmlParser release], xmlParser = nil; 
    }
    
    return(self.results);
}

#pragma mark - NSXMLParserDelegate methods

-(void)parserDidStartDocument:(NSXMLParser *)parser
{
    self.currentString = [NSMutableString string];
}

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict 
{    
    if ([elementName isEqualToString:kSCHRecommendationWebServiceIGDREC]) {
        if ([[attributeDict objectForKey:kSCHRecommendationWebServiceInputKey] isEqualToString:kSCHRecommendationWebServiceAge]) {
            NSInteger age = [[attributeDict objectForKey:kSCHRecommendationWebServiceInputValue] integerValue];
            if (age > 0) {
                self.currentCategory = [NSMutableDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInteger:age], kSCHRecommendationWebServiceAge,
                                        [NSMutableArray array], kSCHRecommendationWebServiceItems, nil];
            }        
        } else if ([[attributeDict objectForKey:kSCHRecommendationWebServiceInputKey] isEqualToString:kSCHRecommendationWebServiceISBN]) {
            NSString *isbn = [attributeDict objectForKey:kSCHRecommendationWebServiceInputValue];
            if (isbn != nil) {
                self.currentCategory = [NSMutableDictionary dictionaryWithObjectsAndKeys:isbn, kSCHRecommendationWebServiceISBN,
                                        [NSMutableArray array], kSCHRecommendationWebServiceItems, nil];
            }        
        }
    } else if ([elementName isEqualToString:kSCHRecommendationWebServiceItem]) {		
        self.currentRecommendation = [NSMutableDictionary dictionary];
    } else if ([elementName isEqualToString:kSCHRecommendationWebServiceName] ||
               [elementName isEqualToString:kSCHRecommendationWebServiceLink] ||
               [elementName isEqualToString:kSCHRecommendationWebServiceImageLink] ||
               [elementName isEqualToString:kSCHRecommendationWebServiceRegularPrice] ||
               [elementName isEqualToString:kSCHRecommendationWebServiceSalePrice] ||
               [elementName isEqualToString:kSCHRecommendationWebServiceProductCode] ||
               [elementName isEqualToString:kSCHRecommendationWebServiceFormat] ||
               [elementName isEqualToString:kSCHRecommendationWebServiceAuthor]) {
        self.parsingCharacters = YES;
        [self.currentString setString:@""];
    }        
}

- (void)parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    if (self.parsingCharacters == YES) {
        [self.currentString appendString:string];
    }
}

- (void)parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qName
{
    if ([elementName isEqualToString:kSCHRecommendationWebServiceIGDREC]) {
        if (self.currentCategory != nil) {
            [self.results addObject:self.currentCategory];
            self.currentCategory = nil;
        }
    } else if ([elementName isEqualToString:kSCHRecommendationWebServiceItem]) {
        if (self.currentRecommendation != nil) {
            NSMutableArray *items = [self.currentCategory objectForKey:kSCHRecommendationWebServiceItems];
            if (items != nil) {
                [items addObject:self.currentRecommendation];
                [self.currentRecommendation setValue:[NSNumber numberWithInteger:[items indexOfObject:self.currentRecommendation]]
                                              forKey:kSCHRecommendationWebServiceOrder];
                self.currentRecommendation = nil;
            }
        }
    } else if ([elementName isEqualToString:kSCHRecommendationWebServiceName]) {	
        [self.currentRecommendation setValue:[NSString stringWithString:self.currentString] forKey:kSCHRecommendationWebServiceName];
        self.parsingCharacters = NO;
    } else if ([elementName isEqualToString:kSCHRecommendationWebServiceLink]) {	
        [self.currentRecommendation setValue:[NSString stringWithString:self.currentString] forKey:kSCHRecommendationWebServiceLink];
        self.parsingCharacters = NO;
    } else if ([elementName isEqualToString:kSCHRecommendationWebServiceImageLink]) {	
        [self.currentRecommendation setValue:[NSString stringWithString:self.currentString] forKey:kSCHRecommendationWebServiceImageLink];
        self.parsingCharacters = NO;
    } else if ([elementName isEqualToString:kSCHRecommendationWebServiceRegularPrice]) {	
        float regularPrice = [self.currentString floatValue];
        [self.currentRecommendation setValue:[NSNumber numberWithFloat:regularPrice] forKey:kSCHRecommendationWebServiceRegularPrice];
        self.parsingCharacters = NO;
    } else if ([elementName isEqualToString:kSCHRecommendationWebServiceSalePrice]) {	
        float salePrice = [self.currentString floatValue];        
        [self.currentRecommendation setValue:[NSNumber numberWithFloat:salePrice] forKey:kSCHRecommendationWebServiceSalePrice];
        self.parsingCharacters = NO;
    } else if ([elementName isEqualToString:kSCHRecommendationWebServiceProductCode]) {	
        [self.currentRecommendation setValue:[NSString stringWithString:self.currentString] forKey:kSCHRecommendationWebServiceProductCode];
        self.parsingCharacters = NO;
    } else if ([elementName isEqualToString:kSCHRecommendationWebServiceFormat]) {	
        [self.currentRecommendation setValue:[NSString stringWithString:self.currentString] forKey:kSCHRecommendationWebServiceFormat];
        self.parsingCharacters = NO;
    } else if ([elementName isEqualToString:kSCHRecommendationWebServiceAuthor]) {	
        [self.currentRecommendation setValue:[NSString stringWithString:self.currentString] forKey:kSCHRecommendationWebServiceAuthor];
        self.parsingCharacters = NO;
    }        
}

@end
