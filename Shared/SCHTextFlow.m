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

@interface SCHTextFlow()

@property (nonatomic, retain) NSString *isbn;

@end

@implementation SCHTextFlow

@synthesize isbn;

- (id)initWithISBN:(NSString *)newIsbn
{
    if((self = [super initWithBookID:nil])) {
        isbn = [newIsbn retain];
    }
    
    return self;
}

- (void)dealloc
{
    [isbn release], isbn = nil;
    [super dealloc];
}

#pragma mark -
#pragma mark Overriden methods

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
    SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
    return [book TextFlowPageRanges];
}

- (NSData *)textFlowDataWithPath:(NSString *)path
{
    
    NSData *data = nil;
    SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
    
    data = [xpsProvider dataForComponentAtPath:[KNFBXPSEncryptedTextFlowDir stringByAppendingPathComponent:path]];
    
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];

    return data;
}

- (NSData *)textFlowRootFileData
{
    SCHXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
    NSData *data = [xpsProvider dataForComponentAtPath:KNFBXPSTextFlowSectionsFile];
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];

    return data;
}

@end
