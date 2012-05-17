//
//  SCHEPubParagraphSource.m
//  Scholastic
//
//  Created by Matt Farrugia on 25/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHEPubParagraphSource.h"
#import "SCHBookManager.h"
#import "SCHFlowEucBook.h"

#import <libEucalyptus/EucEPubBook.h>
#import <libEucalyptus/EucBookPageIndexPoint.h>
#import <libEucalyptus/EucBookNavPoint.h>
#import <libEucalyptus/EucCSSLayoutRunExtractor.h>
#import <libEucalyptus/EucCSSLayouter.h>
#import <libEucalyptus/EucCSSLayoutRun.h>
#import <libEucalyptus/EucCSSIntermediateDocumentNode.h>
#import <libEucalyptus/EucChapterNameFormatting.h>

@interface SCHEPubParagraphSource()

@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, retain, readonly) SCHFlowEucBook *ePubBook;

@end

@implementation SCHEPubParagraphSource

@synthesize identifier;
@synthesize ePubBook;

- (void)dealloc
{

    if(ePubBook) {
        [[SCHBookManager sharedBookManager] checkInEucBookForBookIdentifier:identifier];
        [ePubBook release], ePubBook = nil;
    }
    
    [identifier release], identifier = nil;
    [super dealloc];
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)newIdentifier managedObjectContext:(NSManagedObjectContext *)moc
{
    if ((self = [super init])) {
        identifier = [newIdentifier retain];
        ePubBook = (SCHFlowEucBook *)[[[SCHBookManager sharedBookManager] checkOutEucBookForBookIdentifier:newIdentifier inManagedObjectContext:moc] retain];
    }
    
    return self;
}

#pragma mark - KNFBParagraphSource

- (void)bookmarkPoint:(id)bookmarkPoint toParagraphID:(id *)paragraphID wordOffset:(uint32_t *)wordOffset
{
    *paragraphID = nil;
    *wordOffset = 0;
}

- (id)bookmarkPointFromParagraphID:(id)paragraphID wordOffset:(uint32_t)wordOffset
{
    return nil;
}

- (NSArray *)wordsForParagraphWithID:(id)paragraphID
{
    return nil;
}

- (id)nextParagraphIdForParagraphWithID:(id)paragraphID
{
    return nil;
}

@end
