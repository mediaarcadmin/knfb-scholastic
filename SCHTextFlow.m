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
#import "BITXPSProvider.h"
#import "KNFBTextFlowPositionedWord.h"
#import "SCHBookRange.h"
#import "KNFBTextFlowBlock.h"

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
    
    for (NSInteger pageNumber = range.startPage; pageNumber <= range.endPage; pageNumber++) {
        NSInteger pageIndex = pageNumber - 1;
        
        for (KNFBTextFlowBlock *block in [self blocksForPageAtIndex:pageIndex includingFolioBlocks:YES]) {
            if (![block isFolio]) {
                for (KNFBTextFlowPositionedWord *word in [block words]) {
                    if ((range.startPage < pageNumber) &&
                        (block.blockIndex <= range.endBlock) &&
                        (word.wordIndex <= range.endWord)) {
                        
                        [allWords addObject:word];
                        
                    } else if ((range.endPage > pageNumber) &&
                               (block.blockIndex >= range.startBlock) &&
                               (word.wordIndex >= range.startWord)) {
                        
                        [allWords addObject:word];
                        
                    } else if ((range.startPage == pageNumber) &&
                               (block.blockIndex == range.startBlock) &&
                               (word.wordIndex >= range.startWord)) {
                        
                        if ((block.blockIndex == range.endBlock) &&
                            (word.wordIndex <= range.endWord)) {
                            [allWords addObject:word];
                        } else if (block.blockIndex < range.endBlock) {
                            [allWords addObject:word];
                        }
                        
                    } else if ((range.startPage == pageNumber) &&
                               (block.blockIndex > range.startBlock)) {
                        
                        if ((block.blockIndex == range.endBlock) &&
                            (word.wordIndex <= range.endWord)) {
                            [allWords addObject:word];
                        } else if (block.blockIndex < range.endBlock) {
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
    SCHBookRange *bookRange = [[SCHBookRange alloc] initWithStartPage:startPage startBlock:startBlock startWord:startWord endPage:endPage endBlock:endBlock endWord:endBlock];
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
    BITXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
    
    data = [xpsProvider dataForComponentAtPath:[BlioXPSEncryptedTextFlowDir stringByAppendingPathComponent:path]];
    
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];

    return data;
}

- (NSData *)textFlowRootFileData
{
    BITXPSProvider *xpsProvider = [[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn];
    NSData *data = [xpsProvider dataForComponentAtPath:BlioXPSTextFlowSectionsFile];
    [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];

    return data;
}

@end
