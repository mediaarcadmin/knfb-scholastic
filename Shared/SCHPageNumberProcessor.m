//
//  SCHPageNumberProcessor.m
//  Scholastic
//
//  Created by John S. Eddie on 26/07/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHPageNumberProcessor.h"

// Constants
NSString * const kSCHPageNumberProcessorErrorDomain = @"AudioBookPlayerErrorDomain";
NSInteger const kSCHPageNumberProcessorFileError = 2000;
NSInteger const kSCHPageNumberProcessorDataError = 2001;

@interface SCHPageNumberProcessor ()

@property (nonatomic, retain) NSMutableDictionary *pages;
@property (nonatomic, assign) NSRange pageIndexRange;

@end

@implementation SCHPageNumberProcessor

@synthesize pages;
@synthesize pageIndexRange;

#pragma mark - Object lifecycle

- (void)dealloc 
{
    [pages release], pages = nil;
    [super dealloc];
}

#pragma mark - methods

- (NSDictionary *)pageNumbersFrom:(NSData *)pageData 
               withPageIndexRange:(NSRange)newPageIndexRange 
                       error:(NSError **)error
{
    if (pageData == nil || [pageData length] < 1) {
        if (error != nil) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Unable to use empty data"
                                                                 forKey:NSLocalizedDescriptionKey];		
            
            *error = [NSError errorWithDomain:kSCHPageNumberProcessorErrorDomain 
                                         code:kSCHPageNumberProcessorFileError
                                     userInfo:userInfo];
        }        
    } else {
        self.pages = [NSMutableDictionary dictionary];
        self.pageIndexRange = newPageIndexRange;
        NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:pageData];
        xmlParser.delegate = self;
        if ([xmlParser parse] == NO && error != nil) {
            NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"Unable to parse PageNumbers.xml"
                                                                 forKey:NSLocalizedDescriptionKey];		
            
            *error = [NSError errorWithDomain:kSCHPageNumberProcessorErrorDomain 
                                         code:kSCHPageNumberProcessorDataError
                                     userInfo:userInfo];
        }
        [xmlParser release], xmlParser = nil; 
    }
    
    NSDictionary *ret = [self.pages autorelease];
    self.pages = nil;
    return(ret);
}

#pragma mark - XML Parser delegate methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName 
  namespaceURI:(NSString *)namespaceURI 
 qualifiedName:(NSString *)qualifiedName 
    attributes:(NSDictionary *)attributeDict 
{    
	if ([elementName isEqualToString:@"Page"]) {
        NSUInteger index = [[attributeDict objectForKey:@"Index"] integerValue];
        if (index >= self.pageIndexRange.location && 
            index < NSMaxRange(self.pageIndexRange)) {
            // we're only interested in pages with a folio, so we ignore any empty strings
            NSString *folio = [attributeDict objectForKey:@"Folio"];
            if ([[folio stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] length] > 0) {
                [self.pages setObject:folio 
                               forKey:[NSNumber numberWithUnsignedInteger:index]];
            }
        }
    }
}

- (void)parser:(NSXMLParser *)parser parseErrorOccurred:(NSError *)parseError
{
    self.pages = nil;
}

@end
