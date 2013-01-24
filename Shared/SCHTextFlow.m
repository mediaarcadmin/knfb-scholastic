//
//  SCHTextFlow.m
//  Scholastic
//
//  Created by Matt Farrugia on 01/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHTextFlow.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "SCHXPSProvider.h"
#import "KNFBTextFlowPositionedWord.h"
#import "SCHBookRange.h"
#import "KNFBTextFlowBlock.h"
#import "KNFBXPSConstants.h"
#import "KNFBTOCEntry.h"
#import <libEucalyptus/THPair.h>
#import <libEucalyptus/EucChapterNameFormatting.h>

@interface SCHTextFlow()

@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, retain) NSManagedObjectContext *managedObjectContext;
@property (nonatomic, retain) KNFBTOCEntry *frontOfBookTOCEntry;

@end

@implementation SCHTextFlow

@synthesize identifier;
@synthesize xpsProvider;
@synthesize managedObjectContext;
@synthesize frontOfBookTOCEntry;

- (id)initWithBookIdentifier:(SCHBookIdentifier *)newIdentifier managedObjectContext:(NSManagedObjectContext *)moc
{
    if((self = [super initWithBookID:nil])) {
        self.identifier = newIdentifier;
        self.managedObjectContext = moc;
        xpsProvider = [(SCHXPSProvider *)[[SCHBookManager sharedBookManager] checkOutBookPackageProviderForBookIdentifier:newIdentifier inManagedObjectContext:moc] retain];
    }
    
    return self;
}

- (void)dealloc
{
    
    if (xpsProvider) {
        [[SCHBookManager sharedBookManager] checkInBookPackageProviderForBookIdentifier:self.identifier];
        [xpsProvider release], xpsProvider = nil;
    }
    
    [identifier release], identifier = nil;
    [managedObjectContext release], managedObjectContext = nil;
    [frontOfBookTOCEntry release], frontOfBookTOCEntry = nil;
    [super dealloc];
}

#pragma mark - Overriden methods

- (NSArray *)wordsForRange:(id)aRange 
{
    SCHBookRange *range = (SCHBookRange *)aRange;
    
    NSMutableArray *allWords = [NSMutableArray array];
    
    for (NSInteger pageNumber = range.startPoint.layoutPage; pageNumber <= range.endPoint.layoutPage; pageNumber++) {
        NSInteger pageIndex = pageNumber - 1;
        
        for (KNFBTextFlowBlock *block in [self blocksForPageAtIndex:pageIndex includingFolioBlocks:YES]) {
            if (![block isFolio]) {
                for (KNFBTextFlowPositionedWord *word in [block words]) {
                    if ((range.startPoint.layoutPage < pageNumber) &&
                        (block.blockIndex <= range.endPoint.blockOffset) &&
                        (word.wordIndex <= range.endPoint.wordOffset)) {
                        
                        [allWords addObject:word];
                        
                    } else if ((range.endPoint.layoutPage > pageNumber) &&
                               (block.blockIndex >= range.startPoint.blockOffset) &&
                               (word.wordIndex >= range.startPoint.wordOffset)) {
                        
                        [allWords addObject:word];
                        
                    } else if ((range.startPoint.layoutPage == pageNumber) &&
                               (block.blockIndex == range.startPoint.blockOffset) &&
                               (word.wordIndex >= range.startPoint.wordOffset)) {
                        
                        if ((block.blockIndex == range.endPoint.blockOffset) &&
                            (word.wordIndex <= range.endPoint.wordOffset)) {
                            [allWords addObject:word];
                        } else if (block.blockIndex < range.endPoint.blockOffset) {
                            [allWords addObject:word];
                        }
                        
                    } else if ((range.startPoint.layoutPage == pageNumber) &&
                               (block.blockIndex > range.startPoint.blockOffset)) {
                        
                        if ((block.blockIndex == range.endPoint.blockOffset) &&
                            (word.wordIndex <= range.endPoint.wordOffset)) {
                            [allWords addObject:word];
                        } else if (block.blockIndex < range.endPoint.blockOffset) {
                            [allWords addObject:word];
                        }
                        
                    }
                }
            }
        }
    }
    
    return allWords;

}

- (NSArray *)wordStringsForRange:(id)range
{
    NSArray *words = [self wordsForRange:range];
    return [words valueForKey:@"string"];
}

- (id)rangeWithStartPage:(NSUInteger)startPage 
              startBlock:(NSUInteger)startBlock
               startWord:(NSUInteger)startWord
                 endPage:(NSUInteger)endPage
                endBlock:(NSUInteger)endBlock
                 endWord:(NSUInteger)endWord
{
    SCHBookPoint *startPoint = [[SCHBookPoint alloc] init];
    startPoint.layoutPage    = startPage;
    startPoint.blockOffset   = startBlock;
    startPoint.wordOffset    = startWord;
    
    SCHBookPoint *endPoint   = [[SCHBookPoint alloc] init];
    endPoint.layoutPage      = endPage;
    endPoint.blockOffset     = endBlock;
    endPoint.wordOffset      = endWord;
    
    SCHBookRange *bookRange  = [[SCHBookRange alloc] init];
    bookRange.startPoint     = startPoint;
    bookRange.endPoint       = endPoint;
    
    [startPoint release];
    [endPoint release];
                               
    return [bookRange autorelease];
}

- (NSSet *)persistedTextFlowPageRanges
{
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.identifier inManagedObjectContext:self.managedObjectContext];
    return [book TextFlowPageRanges];
}

- (NSData *)textFlowDataWithPath:(NSString *)path
{
    
    NSData *data = nil;    
    data = [self.xpsProvider dataForComponentAtPath:[KNFBXPSEncryptedTextFlowDir stringByAppendingPathComponent:path]];
    
    return data;
}

- (NSData *)textFlowRootFileData
{
    NSData *data = [self.xpsProvider dataForComponentAtPath:KNFBXPSTextFlowSectionsFile];

    return data;
}

- (THPair *)presentationNameAndSubTitleForSectionUuid:(NSString *)sectionUuid
{
    THPair *ret = nil;
    
    KNFBTOCEntry *tocEntry = [self tocEntryForSectionUuid:sectionUuid];
    
    // splitAndFormattedChapterName title-cases the word. We don't want that for 'Front of eBook'
    
    if ([tocEntry isEqual:[self frontOfBookTOCEntry]]) {
        ret = [THPair pairWithFirst:tocEntry.name second:nil];
    } else {
        NSString *sectionName = tocEntry.name;
        if (sectionName) {
            ret = [sectionName splitAndFormattedChapterName];
        }
    }
    
    return ret;
}

- (KNFBTOCEntry *)frontOfBookTOCEntry
{
    if (!frontOfBookTOCEntry) {
        frontOfBookTOCEntry = [[KNFBTOCEntry alloc] init];
        frontOfBookTOCEntry.name = NSLocalizedString(@"Front of eBook", @"Name for the single table-of-contents entry for the front page of an eBook that does not specify a TOC entry for the front page");
    }
    
    return frontOfBookTOCEntry;
}

@end
