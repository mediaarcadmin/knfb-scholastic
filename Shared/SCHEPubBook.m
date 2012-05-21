//
//  SCHEPubBook.m
//  Scholastic
//
//  Created by Matt Farrugia on 25/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHEPubBook.h"
#import "SCHEPubToTextFlowMappingParagraphSource.h"
#import "SCHBookIdentifier.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "SCHXPSProvider.h"
#import <libEucalyptus/EucEPubDataProvider.h>
#import <libEucalyptus/EucEPubBookReference.h>
#import <libEucalyptus/EucCSSIntermediateDocument.h>
#import <libEucalyptus/EucCSSLayoutRunExtractor.h>

@interface SCHEPubBook ()

@property (nonatomic, retain) SCHXPSProvider *xpsProvider;
@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, assign) BOOL fakeCover;

@end

@implementation SCHEPubBook

@synthesize identifier;
@synthesize managedObjectContext;
@synthesize xpsProvider;
@synthesize fakeCover;

- (void)dealloc
{
    if (xpsProvider) {
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:identifier];
        [xpsProvider release], xpsProvider = nil;
    }
    
    [identifier release], identifier = nil;
    [managedObjectContext release], managedObjectContext = nil;
    
    [super dealloc];
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)newIdentifier managedObjectContext:(NSManagedObjectContext *)moc
{    
    SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
    SCHAppBook *book = [bookManager bookWithIdentifier:newIdentifier inManagedObjectContext:moc];
    identifier = nil;
    
    if (book) {
        xpsProvider = [[[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:newIdentifier inManagedObjectContext:moc] retain];
        
        if (xpsProvider) {
            
            EucEPubBookReference *bookReference = [[EucEPubBookReference alloc] initWithDataProvider:xpsProvider];
            NSString *aCacheDirectoryPath = [book libEucalyptusCache];
            if (aCacheDirectoryPath) {
                if ((self = [super initWithBookReference:bookReference cacheDirectoryPath:aCacheDirectoryPath])) {
                    identifier = [newIdentifier retain];
                    managedObjectContext = [moc retain];
                }
            }
            
            [bookReference release];
        }
    }
    
    if (!identifier) {
        [self release];
        self = nil;
    }
    
    return self;
}

- (NSArray *)userAgentCSSDatasForDocumentTree:(id<EucCSSDocumentTree>)documentTree
{
    NSMutableArray *ret = [[[super userAgentCSSDatasForDocumentTree:documentTree] mutableCopy] autorelease];
    [ret addObject:[NSData dataWithContentsOfMappedFile:[[NSBundle mainBundle] pathForResource:@"ePubBaseOverrides" ofType:@"css"]]];
    return ret;
}

- (NSArray *)userCSSDatasForDocumentTree:(id<EucCSSDocumentTree>)documentTree
{
    NSMutableArray *ret = [[[super userAgentCSSDatasForDocumentTree:documentTree] mutableCopy] autorelease];
    
    NSMutableString *cssString = [NSMutableString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"SCHEPUB3Overrides" ofType:@"css"] 
                                                                  encoding:NSUTF8StringEncoding error:NULL];
    [cssString replaceOccurrencesOfString:@"%VIDEOPLACEHOLDERTEXT%" 
                               withString:NSLocalizedString(@"Sorry, this version of Storia cannot play embedded videos.", @"Placeholder text for EPUB3 video content") 
                                  options:0 
                                    range:NSMakeRange(0, cssString.length)];
    [cssString replaceOccurrencesOfString:@"%AUDIOPLACEHOLDERTEXT%" 
                               withString:NSLocalizedString(@"Sorry, this version of Storia cannot play embedded audio.", @"Placeholder text for EPUB3 audio content") 
                                  options:0 
                                    range:NSMakeRange(0, cssString.length)];
    
    if (cssString) {
        [ret addObject:[cssString dataUsingEncoding:NSUTF8StringEncoding]];
    }
    
    return ret;
}


- (SCHBookPoint *)bookPointFromBookPageIndexPoint:(EucBookPageIndexPoint *)eucIndexPoint
{
    if(!eucIndexPoint) {
        return nil;   
    } else {
        SCHBookPoint *bookPoint = [[[SCHBookPoint alloc] init] autorelease];
        if(eucIndexPoint.source == 0 && self.fakeCover) {
            // This is the cover section.
            bookPoint.layoutPage = 1;
            bookPoint.blockOffset = 0;
            bookPoint.wordOffset = 0;
            bookPoint.elementOffset = 0;
        } else {
            NSUInteger indexes[2];
            if (self.fakeCover) {
                indexes[0] = eucIndexPoint.source - 1;
            } else {
                indexes[0] = eucIndexPoint.source;
            }
            
            // Make sure that the 'block' in our index point actually corresponds to a block-level node (i.e. a paragraph)
            // in the XML, so that our constructd bookmark point is valid.
            // We do this by using the layout engine to map the index point to its canonical layout point, which always
            // refers to a valid block ID.
            EucCSSLayoutRunExtractor *extractor = [[EucCSSLayoutRunExtractor alloc] initWithDocument:[self intermediateDocumentForIndexPoint:eucIndexPoint]];
            EucCSSLayoutPoint layoutPoint = [extractor layoutPointForNode:[extractor.document nodeForKey:eucIndexPoint.block]];
            [extractor release];
            
            indexes[1] = [EucCSSIntermediateDocument documentTreeNodeKeyForKey:layoutPoint.nodeKey];
            
            NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndexes:indexes length:2];
            
            // EucIndexPoint words start with word 0 == before the first word,
            uint32_t schWordOffset;
            uint32_t schElementOffset;
            if (layoutPoint.nodeKey == eucIndexPoint.block) {
                // The layout mapping, above, didn't change anything, so the 
                // word and element offset is valid.
                
                // EucIndexPoint words start with word 0 == before the first word,
                // Scholastic starts at word 0 == the first word.
                schWordOffset =  eucIndexPoint.word > 0 ? eucIndexPoint.word - 1 : 0;
                schElementOffset = eucIndexPoint.word> 0 ? eucIndexPoint.element : 0;
            } else {
                // This mapping will be a little lossy - the original word and element offsets are
                // no longer valid, and we don't know what they should be.
                
                // EucIndexPoint words start with word 0 == before the first word,
                // Scholastic starts at word 0 == the first word.
                schWordOffset =  layoutPoint.word > 0 ? layoutPoint.word - 1 : 0;
                schElementOffset =  layoutPoint.word > 0 ? layoutPoint.element : 0;
            }
            
            SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
            id<KNFBParagraphSource> paragraphSource = [bookManager threadSafeCheckOutParagraphSourceForBookIdentifier:self.identifier];
            SCHBookPoint *mappedPoint = [paragraphSource bookmarkPointFromParagraphID:indexPath wordOffset:schWordOffset];
            [bookManager checkInParagraphSourceForBookIdentifier:self.identifier];
            
            [indexPath release];        
            
            if (mappedPoint) {
                // The layout mapping, above, didn't change anything, so the 
                // word and element offset is valid.
                bookPoint.layoutPage = mappedPoint.layoutPage;
                bookPoint.blockOffset = mappedPoint.blockOffset;
                bookPoint.wordOffset = mappedPoint.wordOffset;
                bookPoint.elementOffset = schElementOffset;
            }
        }
        return bookPoint;
    }
}

- (EucBookPageIndexPoint *)bookPageIndexPointFromBookPoint:(SCHBookPoint *)bookPoint
{
    if(!bookPoint) {
        return nil;   
    } else {
        //
        EucBookPageIndexPoint *eucIndexPoint = [[[EucBookPageIndexPoint alloc] init] autorelease];
        
        if(bookPoint.layoutPage <= 1 &&
           bookPoint.blockOffset == 0 &&
           bookPoint.wordOffset == 0 &&
           bookPoint.elementOffset == 0) {
            // Do nothing - this is the front of the book, so we want an all-zero index point.
        } else {
            NSIndexPath *paragraphID = nil;
            uint32_t wordOffset = 0;
            
            SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
            id<KNFBParagraphSource> paragraphSource = [bookManager threadSafeCheckOutParagraphSourceForBookIdentifier:self.identifier];
            
            [paragraphSource bookmarkPoint:bookPoint
                             toParagraphID:&paragraphID 
                                wordOffset:&wordOffset];
            [bookManager checkInParagraphSourceForBookIdentifier:self.identifier];
            
            eucIndexPoint.source = [paragraphID indexAtPosition:0];
            eucIndexPoint.block = [EucCSSIntermediateDocument keyForDocumentTreeNodeKey:[paragraphID indexAtPosition:1]];
            eucIndexPoint.word = wordOffset;
            eucIndexPoint.element = bookPoint.elementOffset;
            
            if(self.fakeCover) {
                eucIndexPoint.source++;
            }        
            
            // EucIndexPoint words start with word 0 == before the first word,
            // but Scholastic thinks that the first word is at 0.  This is a bit lossy,
            // but there's not much else we can do.    
            eucIndexPoint.word += 1;
        }
        
        return eucIndexPoint;  
    }
}

@end
