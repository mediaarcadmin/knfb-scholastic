//
//  SCHSmartZoomPreParseOperation.m
//  Scholastic
//
//  Created by Matt Farrugia on 12/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHSmartZoomPreParseOperation.h"
#import <expat/expat.h>
#import "KNFBTextFlowPageRange.h"
#import "KNFBTextFlowPageMarker.h"
#import "SCHBookManager.h"
#import "SCHXPSProvider.h"
#import "KNFBXPSConstants.h"
#import "SCHAppBook.h"

#pragma mark XML element handlers

typedef struct SCHSmartZoomXMLParsingContext
{
    NSMutableSet *buildPageMarkers;
    XML_Parser *currentParser;
} SCHSmartZoomXMLParsingContext;

static void smartZoomFileXMLParsingStartElementHandler(void *ctx, const XML_Char *name, const XML_Char **atts)  {
    
    SCHSmartZoomXMLParsingContext *context = (SCHSmartZoomXMLParsingContext *)ctx;
    NSInteger newPageIndex = -1;
    
    if(strcmp("Page", name) == 0) {
        
        NSUInteger currentByteIndex = (NSUInteger)(XML_GetCurrentByteIndex(*(context->currentParser)));
        
        for(int i = 0; atts[i]; i+=2) {
            if (strcmp("Index", atts[i]) == 0) {
                NSString *pageIndexString = [[NSString alloc] initWithUTF8String:atts[i+1]];
                if (nil != pageIndexString) {
                    newPageIndex = [pageIndexString integerValue];
                    [pageIndexString release];
                }
            } 
        }
        
        if (newPageIndex >= 0) {
            KNFBTextFlowPageMarker *newPageMarker = [[KNFBTextFlowPageMarker alloc] init];
            [newPageMarker setPageIndex:newPageIndex];
            [newPageMarker setByteIndex:currentByteIndex];
            [context->buildPageMarkers addObject:newPageMarker];
            [newPageMarker release];
        }
    }
    
}

#pragma mark -

@interface SCHSmartZoomPreParseOperation ()

- (void) updateBookWithSuccess;
- (void) updateBookWithFailure;

@end

@implementation SCHSmartZoomPreParseOperation

- (void) updateBookWithSuccess
{
    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyForPagination];
    [[[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn] setProcessing:NO];
    self.finished = YES;
    self.executing = NO;
}

- (void) updateBookWithFailure
{
    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateError];
    [[[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn] setProcessing:NO];
    self.finished = YES;
    self.executing = NO;
}

- (void) beginOperation
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
    NSData *data = [xpsProvider dataForComponentAtPath:KNFBXPSKNFBSmartZoomFile];
    
    if (nil == data) {    
        // Not all books have this data
        [self updateBookWithSuccess];
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
        
        [pool drain];
        return;
    }
    
    // Parse SmartZoom file
    XML_Parser pageMarkerFileParser = XML_ParserCreate(NULL);
    XML_SetStartElementHandler(pageMarkerFileParser, smartZoomFileXMLParsingStartElementHandler);
    
    SCHSmartZoomXMLParsingContext context = { [NSMutableSet set], &pageMarkerFileParser };
    
    XML_SetUserData(pageMarkerFileParser, &context);    
    if (!XML_Parse(pageMarkerFileParser, [data bytes], [data length], XML_TRUE)) {
        NSLog(@"SmartZoom parsing error: '%s' in file: '%@'", (char *)XML_ErrorString(XML_GetErrorCode(pageMarkerFileParser)), KNFBXPSKNFBSmartZoomFile);
    }
    XML_ParserFree(pageMarkerFileParser);
    
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
    
    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn setValue:context.buildPageMarkers forKey:kSCHAppBookSmartZoomPageMarkers];
    
    [self updateBookWithSuccess];
    
    [pool drain];
}

@end