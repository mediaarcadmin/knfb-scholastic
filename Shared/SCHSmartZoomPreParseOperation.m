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
#import "KNFBPageMarker.h"
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
            KNFBPageMarker *newPageMarker = [[KNFBPageMarker alloc] init];
            [newPageMarker setPageIndex:newPageIndex];
            [newPageMarker setByteIndex:currentByteIndex];
            [context->buildPageMarkers addObject:newPageMarker];
            [newPageMarker release];
        }
    }
    
}

#pragma mark - Class Extension

@interface SCHSmartZoomPreParseOperation ()

- (void) updateBookWithSuccess;
- (void) updateBookWithFailure;

@end

#pragma mark -

@implementation SCHSmartZoomPreParseOperation

#pragma mark Book Operation methods

- (void)beginOperation
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn
                                                                                    inManagedObjectContext:self.localManagedObjectContext];
    BOOL hasSmartZoom = [xpsProvider componentExistsAtPath:KNFBXPSKNFBSmartZoomFile];
    
    if (hasSmartZoom) {

        NSData *data = [xpsProvider dataForComponentAtPath:KNFBXPSKNFBSmartZoomFile];

        if (nil == data) {    
            // Not all books have this data
            [self updateBookWithFailure];
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
        
        [self withBook:self.isbn perform:^(SCHAppBook *book) {
            [book setValue:context.buildPageMarkers forKey:kSCHAppBookSmartZoomPageMarkers];
        }];
    }
    
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
        
    [self updateBookWithSuccess];
    
    [pool drain];
}

#pragma mark - Book Updates

- (void)updateBookWithSuccess
{
    [self threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyForPagination];
    [self setBook:self.isbn isProcessing:NO];
    self.finished = YES;
    self.executing = NO;
}

- (void)updateBookWithFailure
{
    [self threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateError];
    [self setBook:self.isbn isProcessing:NO];
    self.finished = YES;
    self.executing = NO;
}



@end
