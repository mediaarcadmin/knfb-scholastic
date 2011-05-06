//
//  SCHTextFlowPreParseOperation.m
//  Scholastic
//
//  Created by Gordon Christie on 30/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHTextFlowPreParseOperation.h"
#import <expat/expat.h>
#import "KNFBPageMarker.h"
#import "KNFBTextFlowPageRange.h"
#import "SCHBookManager.h"
#import "SCHXPSProvider.h"
#import "KNFBXPSConstants.h"
#import "SCHAppBook.h"

#pragma mark XML element handlers

static void pageRangeFileXMLParsingStartElementHandler(void *ctx, const XML_Char *name, const XML_Char **atts)  {
    
    NSMutableArray *pageRangesArray = (NSMutableArray *)ctx;
    
    if(strcmp("PageRange", name) == 0) {
        KNFBTextFlowPageRange *aPageRange = [[KNFBTextFlowPageRange alloc] init];
        
        for(int i = 0; atts[i]; i+=2) {
            if (strcmp("Start", atts[i]) == 0) {
                [aPageRange setStartPageIndex:atoi(atts[i+1])];
            } else if (strcmp("End", atts[i]) == 0) {
                [aPageRange setEndPageIndex:atoi(atts[i+1])];
            } else if (strcmp("Source", atts[i]) == 0) {
                NSString *sourceString = [[NSString alloc] initWithUTF8String:atts[i+1]];
                if (nil != sourceString) {
                    // Write the filename directly but set up the manifest entries once we have completed parsing
                    [aPageRange setFileName:sourceString];
                    [sourceString release];
                }
            }
        }
        
        if (nil != aPageRange) {
            [pageRangesArray addObject:aPageRange];
            [aPageRange release];
        }
    }
    
}

static void pageFileXMLParsingStartElementHandler(void *ctx, const XML_Char *name, const XML_Char **atts)  {
    
    KNFBTextFlowPageRange *pageRange = (KNFBTextFlowPageRange *)ctx;
    NSInteger newPageIndex = -1;
    
    if(strcmp("Page", name) == 0) {
        
        NSUInteger currentByteIndex = (NSUInteger)(XML_GetCurrentByteIndex(*[pageRange currentParser]));
        
        for(int i = 0; atts[i]; i+=2) {
            if (strcmp("PageIndex", atts[i]) == 0) {
                NSString *pageIndexString = [[NSString alloc] initWithUTF8String:atts[i+1]];
                if (nil != pageIndexString) {
                    newPageIndex = [pageIndexString integerValue];
                    [pageIndexString release];
                }
            } 
        }
        
        if ((newPageIndex >= 0) && (newPageIndex != [pageRange currentPageIndex])) {
            KNFBPageMarker *newPageMarker = [[KNFBPageMarker alloc] init];
            [newPageMarker setPageIndex:newPageIndex];
            [newPageMarker setByteIndex:currentByteIndex];
            [pageRange.pageMarkers addObject:newPageMarker];
            [newPageMarker release];
            [pageRange setCurrentPageIndex:newPageIndex];
        }
    }
    
}

#pragma mark - Class Extension

@interface SCHTextFlowPreParseOperation ()
    
- (void)updateBookWithSuccess;
- (void)updateBookWithFailure;

@end

#pragma mark -

@implementation SCHTextFlowPreParseOperation

#pragma mark Book Operation methods

- (void)beginOperation
{
    NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
    
    SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
    NSData *data = [xpsProvider dataForComponentAtPath:KNFBXPSTextFlowSectionsFile];
    
    if (nil == data) {
        NSLog(@"Could not pre-parse TextFlow because TextFlow file did not exist at path: %@.", KNFBXPSTextFlowSectionsFile);

        [self updateBookWithFailure];
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
        
        [pool drain];
        return;
    }
    
    NSMutableSet *pageRangesSet = [NSMutableSet set];
    
    // Parse pageRange file
    XML_Parser pageRangeFileParser = XML_ParserCreate(NULL);
    
    XML_SetStartElementHandler(pageRangeFileParser, pageRangeFileXMLParsingStartElementHandler);
    
    XML_SetUserData(pageRangeFileParser, (void *)pageRangesSet);    
    if (!XML_Parse(pageRangeFileParser, [data bytes], [data length], XML_TRUE)) {
        NSLog(@"TextFlow parsing error: '%s' in file: '%@'", (char *)XML_ErrorString(XML_GetErrorCode(pageRangeFileParser)), KNFBXPSEncryptedTextFlowDir);
    }
    XML_ParserFree(pageRangeFileParser);
    
    for (KNFBTextFlowPageRange *pageRange in pageRangesSet) {
        NSAutoreleasePool *innerPool = [[NSAutoreleasePool alloc] init];
        
        NSData *data = [xpsProvider dataForComponentAtPath:[KNFBXPSEncryptedTextFlowDir stringByAppendingPathComponent:[pageRange fileName]]];

        
        if (!data) {
            NSLog(@"Could not pre-parse TextFlow because TextFlow file did not exist with name: %@.", [pageRange fileName]);
            [self updateBookWithFailure];
            [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
            [pool drain];
            return;
        }
        
        XML_Parser flowParser = XML_ParserCreate(NULL);
        XML_SetStartElementHandler(flowParser, pageFileXMLParsingStartElementHandler);
        
        pageRange.currentPageIndex = -1;
        pageRange.currentParser = &flowParser;
        XML_SetUserData(flowParser, (void *)pageRange);    
        if (!XML_Parse(flowParser, [data bytes], [data length], XML_TRUE)) {
            NSLog(@"TextFlow parsing error: '%s' in file: '%@'", (char *)XML_ErrorString(XML_GetErrorCode(flowParser)), [pageRange fileName]);
        }
        XML_ParserFree(flowParser);   
        
        [innerPool drain];
    }

    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];

    NSSortDescriptor *sortPageDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"startPageIndex" ascending:YES] autorelease];
    NSArray *sortedRanges = [[pageRangesSet allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortPageDescriptor]];
    
    NSLog(@"layout page equivalent count: %@", [NSNumber numberWithInteger:[[sortedRanges lastObject] endPageIndex]]);

    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn setValue:[NSSet setWithSet:pageRangesSet] forKey:kSCHAppBookTextFlowPageRanges];
    
    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn setValue:[NSNumber numberWithInteger:[[sortedRanges lastObject] endPageIndex]] forKey:kSCHAppBookLayoutPageEquivalentCount];
    
    [self updateBookWithSuccess];
    
    [pool drain];
}

#pragma mark - Book Updates

- (void)updateBookWithSuccess
{
    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateReadyForSmartZoomPreParse];
    [[[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn] setProcessing:NO];
    self.finished = YES;
    self.executing = NO;
}

- (void)updateBookWithFailure
{
    [[SCHBookManager sharedBookManager] threadSafeUpdateBookWithISBN:self.isbn state:SCHBookProcessingStateError];
    [[[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn] setProcessing:NO];
    self.finished = YES;
    self.executing = NO;
}



@end
