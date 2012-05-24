//
//  SCHEPubToTextFlowMappingParagraphSource.m
//  Scholastic
//
//  Created by Matt Farrugia on 25/04/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHEPubToTextFlowMappingParagraphSource.h"
#import "SCHBookManager.h"
#import "SCHFlowEucBook.h"
#import "SCHTextFlow.h"
#import "KNFBTextFlowFlowReference.h"
#import "KNFBTextFlowBlock.h"

#import <libEucalyptus/EucEPubBook.h>
#import <libEucalyptus/EucBookPageIndexPoint.h>
#import <libEucalyptus/EucBookNavPoint.h>
#import <libEucalyptus/EucCSSLayoutRunExtractor.h>
#import <libEucalyptus/EucCSSLayouter.h>
#import <libEucalyptus/EucCSSLayoutRun.h>
#import <libEucalyptus/EucCSSIntermediateDocument.h>
#import <libEucalyptus/EucCSSIntermediateDocumentNode.h>
#import <libEucalyptus/EucChapterNameFormatting.h>
#import <libEucalyptus/EucCSSXMLTree.h>
#import "levenshtein_distance.h"

#define MATCHING_WINDOW_SIZE 11

static NSString * const kNoWordPlaceholder = @"NO_WORD_PLACEHOLDER";

@interface SCHEPubToTextFlowMappingParagraphSource()

@property (nonatomic, retain) SCHBookIdentifier *identifier;
@property (nonatomic, retain, readonly) SCHFlowEucBook *ePubBook;
@property (nonatomic, retain, readonly) SCHTextFlow *textFlow;

@end

@implementation SCHEPubToTextFlowMappingParagraphSource

@synthesize identifier;
@synthesize ePubBook;
@synthesize textFlow;

- (void)dealloc
{

    if (ePubBook) {
        [[SCHBookManager sharedBookManager] checkInEucBookForBookIdentifier:identifier];
        [ePubBook release], ePubBook = nil;
    }
    
    if (textFlow) {
        [[SCHBookManager sharedBookManager] checkInTextFlowForBookIdentifier:identifier];
        [textFlow release], textFlow = nil;
    }
    
    [identifier release], identifier = nil;
    [super dealloc];
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)newIdentifier managedObjectContext:(NSManagedObjectContext *)moc
{
    if ((self = [super init])) {
        identifier = [newIdentifier retain];
        ePubBook = (SCHFlowEucBook *)[[[SCHBookManager sharedBookManager] checkOutEucBookForBookIdentifier:newIdentifier inManagedObjectContext:moc] retain];
        textFlow = [[[SCHBookManager sharedBookManager] checkOutTextFlowForBookIdentifier:newIdentifier inManagedObjectContext:moc] retain];
    }
    
    return self;
}

#pragma mark - KNFBParagraphSource

- (void)bookmarkPoint:(id)bookmarkPoint toParagraphID:(id *)paragraphID wordOffset:(uint32_t *)wordOffset
{
    // This method is a slight adaptation of the equivalent XAML method in SCHTextFlowParagraphSource which is a direct port from Blio.
#if 0    
    NSUInteger flowIndex = 0;
    NSUInteger bookmarkPageIndex = [bookmarkPoint layoutPage] - 1;
    NSArray *flowReferences = self.textFlow.flowReferences;
    NSUInteger nextFlowIndex = 0;
    for(KNFBTextFlowFlowReference *flowReference in flowReferences) {
        if(flowReference.startPage <= bookmarkPageIndex) {
            flowIndex = nextFlowIndex;
            ++nextFlowIndex;
        } else {
            break;
        }
    }
    
    if(self.textFlow.flowTreeKind == KNFBTextFlowFlowTreeKindXaml) {
        // See comments in
        // - (id)bookmarkPointFromParagraphID:(id)paragraphID wordOffset:(uint32_t)wordOffset;
        // about the overall word matching strategy used here.
        
        
        // Build an array of word hashes to search for from around the point.
        NSString *lookForStrings[MATCHING_WINDOW_SIZE];
        char lookForHashes[MATCHING_WINDOW_SIZE];
        
        NSInteger lowerPageIndexBound = [[flowReferences objectAtIndex:flowIndex] startPage];
        NSInteger upperPageIndexBound;
        if(nextFlowIndex < flowReferences.count) {
            upperPageIndexBound = [[flowReferences objectAtIndex:nextFlowIndex] startPage] - 1;
        } else {
            upperPageIndexBound = self.textFlow.lastPageIndex;
        }
        
        NSArray *bookmarkPageBlocks = [self.textFlow blocksForPageAtIndex:bookmarkPageIndex includingFolioBlocks:YES];
        NSArray *words;
        if(bookmarkPageBlocks.count > [bookmarkPoint blockOffset]) {
            words = ((KNFBTextFlowBlock *)[bookmarkPageBlocks objectAtIndex:[bookmarkPoint blockOffset]]).wordStrings;
        } else {
            words = [NSArray array];
        }
        NSInteger middleWordOffset = [bookmarkPoint wordOffset];
        
        {
            NSArray *pageBlocks = bookmarkPageBlocks;
            
            NSInteger tryPageOffset = bookmarkPageIndex;
            NSInteger tryBlockOffset = [bookmarkPoint blockOffset];
            
            while(middleWordOffset + MATCHING_WINDOW_SIZE / 2 + 1 > words.count) {
                ++tryBlockOffset;
                if(tryBlockOffset >= pageBlocks.count) {
                    tryBlockOffset = -1; // We'll increment it back to 0 on the next iteration.
                    ++tryPageOffset;
                    if(tryPageOffset > upperPageIndexBound) {
                        NSInteger needMore = middleWordOffset + MATCHING_WINDOW_SIZE / 2 + 1 - words.count;
                        NSMutableArray *newWords = [[NSMutableArray alloc] initWithCapacity:needMore];
                        for(NSInteger i = 0; i < needMore; ++i) {
                            [newWords addObject:kNoWordPlaceholder];
                        }
                        words = [words arrayByAddingObjectsFromArray:newWords];
                        [newWords release];
                    } else {
                        pageBlocks = [self.textFlow blocksForPageAtIndex:tryPageOffset includingFolioBlocks:YES];
                    }
                } else {
                    KNFBTextFlowBlock *block = [pageBlocks objectAtIndex:tryBlockOffset];
                    if(!block.folio) {
                        words = [words arrayByAddingObjectsFromArray:block.wordStrings];
                    }
                }
            }
        }
        
        {
            NSArray *pageBlocks = bookmarkPageBlocks;
            
            NSInteger tryPageOffset = bookmarkPageIndex;
            NSInteger tryBlockOffset = [bookmarkPoint blockOffset];
            
            while(middleWordOffset < MATCHING_WINDOW_SIZE / 2) {
                --tryBlockOffset;
                if(tryBlockOffset < 0) {
                    --tryPageOffset;
                    if(tryPageOffset < lowerPageIndexBound) {
                        NSInteger needMore = MATCHING_WINDOW_SIZE / 2 - middleWordOffset;
                        NSMutableArray *newWords = [[NSMutableArray alloc] initWithCapacity:needMore];
                        for(NSInteger i = 0; i < needMore; ++i) {
                            [newWords addObject:kNoWordPlaceholder];
                        }
                        words = [newWords arrayByAddingObjectsFromArray:words];
                        [newWords release];
                        middleWordOffset += needMore;
                    } else {
                        pageBlocks = [self.textFlow blocksForPageAtIndex:tryPageOffset includingFolioBlocks:YES];
                        tryBlockOffset = pageBlocks.count; // Will decrement to the index of the last block on the next iteration.
                    }
                } else {
                    KNFBTextFlowBlock *block = [pageBlocks objectAtIndex:tryBlockOffset];
                    if(!block.folio) {
                        NSArray *newWords = block.wordStrings;
                        words = [newWords arrayByAddingObjectsFromArray:words];
                        middleWordOffset += newWords.count;
                    }
                }
            }
        }
        
        NSInteger i, j;
        for(i = -(MATCHING_WINDOW_SIZE / 2), j = 0 ; i <= MATCHING_WINDOW_SIZE / 2; ++i, ++j) {
            lookForHashes[j] = [[words objectAtIndex:middleWordOffset + i] hash] % 256;
            lookForStrings[j] = [words objectAtIndex:middleWordOffset + i];
        }
        
        /*
         NSLog(@"Searching for:");
         for(NSInteger i = 0; i < MATCHING_WINDOW_SIZE; ++i) {
         NSLog(@"\t%@", lookForStrings[i]);
         }
         */
        
        EucBookPageIndexPoint *eucIndexPoint = [[EucBookPageIndexPoint alloc] init];
        eucIndexPoint.source = flowIndex;
        EucCSSIntermediateDocument *document = [self.xamlEucBook intermediateDocumentForIndexPoint:eucIndexPoint];
        [eucIndexPoint release];
        
        EucCSSLayoutRunExtractor *runExtractor = [[EucCSSLayoutRunExtractor alloc] initWithDocument:document];
        EucCSSLayoutRun *run = nil;
        
        NSUInteger lookForPageIndex = bookmarkPageIndex;
        
        // Bound our search from the last XAML run that starts on a previous
        // page to the one we're looking for, to the first XAML run on a 
        // subsequent page.
        uint32_t lowerBoundRunKey = 0;
        uint32_t upperBoundRunKey = 0;
        
        NSArray *rawNodes = ((EucCSSXMLTree *)(document.documentTree)).nodes;
        for(KNFBTextFlowXAMLTreeNode *node in rawNodes) {
            upperBoundRunKey = node.key;
            NSString *tag = node.tag;
            if(tag && [tag hasPrefix:@"__"]) {
                NSUInteger pageIndex = [[tag substringFromIndex:2] integerValue];
                if(pageIndex < lookForPageIndex) {
                    lowerBoundRunKey = node.key;
                }
                if(pageIndex > lookForPageIndex) {
                    break;
                }
            }
        }
        upperBoundRunKey = [EucCSSIntermediateDocument keyForDocumentTreeNodeKey:upperBoundRunKey];
        lowerBoundRunKey = [EucCSSIntermediateDocument keyForDocumentTreeNodeKey:lowerBoundRunKey];
        
        char blockHashes[MATCHING_WINDOW_SIZE];
        NSString *blockStrings[MATCHING_WINDOW_SIZE];
        
        uint32_t runKeys[MATCHING_WINDOW_SIZE];
        uint32_t wordOffsets[MATCHING_WINDOW_SIZE];
        
        uint32_t examiningRunKey = lowerBoundRunKey;
        run = [runExtractor runForNodeWithKey:examiningRunKey];
        examiningRunKey = run.id;
        
        char emptyHash = [kNoWordPlaceholder hash] % 256;
        for(NSInteger i = 0; i < MATCHING_WINDOW_SIZE; ++i) {
            blockStrings[i] = kNoWordPlaceholder;
            blockHashes[i] = emptyHash;
            runKeys[i] = examiningRunKey;
            wordOffsets[i] = 0;
        }
        
        int bestDistance = INT_MAX;
        uint32_t bestRunKey = examiningRunKey;
        uint32_t bestWordOffset = 0;
        
        NSArray *runWords = run.words;
        while(runWords && examiningRunKey <= upperBoundRunKey) {
            NSUInteger examiningWordOffset = 0;
            for(NSString *word in runWords) {
                memmove(blockHashes, blockHashes + 1, sizeof(char) * MATCHING_WINDOW_SIZE - 1);
                blockHashes[MATCHING_WINDOW_SIZE - 1] = [word hash] % 256;
                
                memmove(blockStrings, blockStrings + 1, sizeof(NSString *) * MATCHING_WINDOW_SIZE - 1);
                blockStrings[MATCHING_WINDOW_SIZE - 1] = word;
                
                memmove(runKeys, runKeys + 1, sizeof(uint32_t) * MATCHING_WINDOW_SIZE - 1);
                runKeys[MATCHING_WINDOW_SIZE - 1] = examiningRunKey;
                
                memmove(wordOffsets, wordOffsets + 1, sizeof(uint32_t) * MATCHING_WINDOW_SIZE - 1);
                wordOffsets[MATCHING_WINDOW_SIZE - 1] = examiningWordOffset;
                
                int distance = levenshtein_distance_with_bytes(lookForHashes, MATCHING_WINDOW_SIZE, blockHashes, MATCHING_WINDOW_SIZE);
                if(distance < bestDistance || 
                   (distance == bestDistance && [blockStrings[MATCHING_WINDOW_SIZE / 2] isEqualToString:lookForStrings[MATCHING_WINDOW_SIZE / 2]])) {
                    /*
                     NSLog(@"Found, distance %d:", distance);
                     for(NSInteger i = 0;  i < MATCHING_WINDOW_SIZE; ++i) {
                     NSLog(@"\t%@", blockStrings[i]);
                     }
                     */
                    bestDistance = distance;
                    bestRunKey = runKeys[MATCHING_WINDOW_SIZE / 2];
                    bestWordOffset = wordOffsets[MATCHING_WINDOW_SIZE / 2];
                }
                ++examiningWordOffset;
            }
            if(!run) {
                runWords = nil;
            } else {
                run = [runExtractor nextRunForRun:run];
                examiningRunKey = run.id;
                if(!run || examiningRunKey > upperBoundRunKey) {
                    // Fake out some extra words at the end to aid in matching
                    // runs at the end of sections.
                    examiningRunKey = upperBoundRunKey;
                    run = nil;
                    NSString *extraWords[MATCHING_WINDOW_SIZE / 2];
                    for(NSInteger i = 0; i < MATCHING_WINDOW_SIZE / 2; ++i) {
                        extraWords[i] = kNoWordPlaceholder;
                    }
                    runWords = [NSArray arrayWithObjects:extraWords count:MATCHING_WINDOW_SIZE / 2];                        
                } else {
                    runWords = run.words;
                }
            }
        }
        
        NSUInteger indexes[2] = { flowIndex, [EucCSSIntermediateDocument documentTreeNodeKeyForKey:bestRunKey] };
        *paragraphID = [NSIndexPath indexPathWithIndexes:indexes length:2];
        *wordOffset = bestWordOffset;
        
        [runExtractor release];
    } else {
        KNFBTextFlowFlowTree *flowFlowTree = [self flowFlowTreeForIndex:flowIndex];
        KNFBTextFlowParagraph *bestParagraph = flowFlowTree.firstParagraph;
        
        BOOL stop = NO;
        KNFBTextFlowParagraph *nextParagraph;
        while(!stop && (nextParagraph = bestParagraph.nextSibling)) {
            NSArray *ranges = nextParagraph.paragraphWords.ranges;
            if(ranges.count) {
                SCHBookRange *range = [nextParagraph.paragraphWords.ranges objectAtIndex:0];
                SCHBookPoint *startPoint = range.startPoint;
                if([startPoint compare:bookmarkPoint] == NSOrderedDescending) {
                    break;
                }
            }
            bestParagraph = nextParagraph;
        }
        
        uint32_t bestWordOffset = 0;
        SCHBookPoint *comparisonPoint = [[SCHBookPoint alloc] init];
        NSArray *words = bestParagraph.paragraphWords.words;
        for(KNFBTextFlowPositionedWord *word in words) {
            comparisonPoint.layoutPage = [KNFBTextFlowBlock pageIndexForBlockID:word.blockID] + 1;
            comparisonPoint.blockOffset = [KNFBTextFlowBlock blockIndexForBlockID:word.blockID];
            comparisonPoint.wordOffset = word.wordIndex;
            if([comparisonPoint compare:bookmarkPoint] <= NSOrderedSame) {
                ++bestWordOffset;
            } else {
                break;
            }
        }
        if(bestWordOffset) {
            bestWordOffset--;
        }        
        if(bestWordOffset == words.count) {
            bestParagraph = nextParagraph; 
            bestWordOffset = 0;
        }
        [comparisonPoint release];
        
        
        NSUInteger indexes[2] = { flowIndex, bestParagraph.key };
        *paragraphID = [NSIndexPath indexPathWithIndexes:indexes length:2];
        *wordOffset = bestWordOffset;
    }
#endif
}

- (id)bookmarkPointFromParagraphID:(id)paragraphID wordOffset:(uint32_t)wordOffset
{
    // This method is a slight adaptation of the equivalent XAML method in SCHTextFlowParagraphSource which is a direct port from Blio.
    
    SCHBookPoint *ret = nil;
    
        // This uses the fact that layout page breaks are defined in the ePub during conversion
        // in the form <a id="pageXX></a> We use closest matches to guesstimate word offsets from these anchors
        
        // Closest match is done by hashing all the words in the windows
        // to single-byte values, then calculating the levenshtein distance
        // between these hash arrays for both candidate windows, and choosing
        // the word in the center if the best matching window.
    
    // First, work out which pages in the text flow to bound the search in. Go forwards until we find the next page anchor or end of book, then 
    // go backwards until we find the previous page anchor or start of book
    
    EucBookPageIndexPoint *eucIndexPoint = [[EucBookPageIndexPoint alloc] init];
    eucIndexPoint.source = [paragraphID indexAtPosition:0];
    EucCSSIntermediateDocument *document = [self.ePubBook intermediateDocumentForIndexPoint:eucIndexPoint];
    
    if(!document) {
        ret = [[SCHBookPoint alloc] init];
        ret.layoutPage = self.textFlow.lastPageIndex + 2; // + 2 to get 1-based, and off-the-end.
        return [ret autorelease];
    }
    
    EucCSSLayoutRunExtractor *runExtractor = [[EucCSSLayoutRunExtractor alloc] initWithDocument:document];
    
    uint32_t xamlFlowTreeKey = [paragraphID indexAtPosition:1];
    uint32_t documentKey = [EucCSSIntermediateDocument keyForDocumentTreeNodeKey:xamlFlowTreeKey];
    EucCSSLayoutRun *wordContainingRun = [runExtractor runForNodeWithKey:documentKey];
    
    if(wordContainingRun) {
        if(wordOffset >= wordContainingRun.wordsCount) {
            wordOffset = wordContainingRun.wordsCount - 1;
        }
    
    NSInteger startPageIndex = NSNotFound;
    NSInteger endPageIndex   = NSNotFound;
    NSInteger sourceIndex    = [paragraphID indexAtPosition:0];
    
    NSUInteger sourceCount = [self.ePubBook sourceCount];
    

    eucIndexPoint.source = sourceIndex;
    uint32_t documentTreeNodeKey = [paragraphID indexAtPosition:1];
    
    // Search forwards through the entire book for a page anchor
    while ((sourceIndex < sourceCount) && (endPageIndex == NSNotFound)) {
        eucIndexPoint.source = sourceIndex;
        EucCSSIntermediateDocument *document = [self.ePubBook intermediateDocumentForIndexPoint:eucIndexPoint];
        
        id<EucCSSDocumentTree> documentTree = [document documentTree];
        uint32_t nodeCount = [documentTree nodeCount];
        uint32_t documentKey = [EucCSSIntermediateDocument keyForDocumentTreeNodeKey:documentTreeNodeKey];

        while (documentKey < nodeCount) {
            id<EucCSSDocumentTreeNode> currentNode = [documentTree nodeForKey:documentKey];
            
            NSString *nodeName = [currentNode name];
            NSString *nodeId   = [currentNode attributeWithName:@"id"];
            
            if (nodeName && nodeId && ([nodeName caseInsensitiveCompare:@"a"] == NSOrderedSame)) {
                if ([nodeId hasPrefix:@"page"]) {
                    NSString *pageString = [nodeId substringFromIndex:4];
                    if ([pageString length]) {
                        endPageIndex = [pageString integerValue] - 1;
                    }
                    break;
                }
            }
            
            documentKey++;
        }

        documentTreeNodeKey = 0;
        sourceIndex++;
    }
    
    // Reset the search point
    sourceIndex         = [paragraphID indexAtPosition:0];
    documentTreeNodeKey = [paragraphID indexAtPosition:1];
    
    // Search backwards through the entire book for a page anchor
    while ((sourceIndex >= 0) && (startPageIndex == NSNotFound)) {
        eucIndexPoint.source = sourceIndex;
        EucCSSIntermediateDocument *document = [self.ePubBook intermediateDocumentForIndexPoint:eucIndexPoint];
        
        id<EucCSSDocumentTree> documentTree = [document documentTree];
        NSInteger documentKey = [EucCSSIntermediateDocument keyForDocumentTreeNodeKey:documentTreeNodeKey];
        
        while (documentKey >= 0) {
            id<EucCSSDocumentTreeNode> currentNode = [documentTree nodeForKey:documentKey];
            
            NSString *nodeName = [currentNode name];
            NSString *nodeId   = [currentNode attributeWithName:@"id"];
            
            if (nodeName && nodeId && ([nodeName caseInsensitiveCompare:@"a"] == NSOrderedSame)) {
                if ([nodeId hasPrefix:@"page"]) {
                    NSString *pageString = [nodeId substringFromIndex:4];
                    if ([pageString length]) {
                        startPageIndex = [pageString integerValue] - 1;
                    }
                    break;
                }
            }
            
            documentKey--;
        }
        
        sourceIndex--;
        eucIndexPoint.source = sourceIndex;
        document = [self.ePubBook intermediateDocumentForIndexPoint:eucIndexPoint];
        documentTreeNodeKey = [documentTree nodeCount] - 1;
    }
        
        if (startPageIndex == NSNotFound) {
            startPageIndex = 0;
        }
    
    [eucIndexPoint release];
        
        if (startPageIndex != NSNotFound) {
            
            // Search onto the next page, so that we get our trailing overlap.
            ++endPageIndex;
        }
            
            if(startPageIndex > 0) {
                // Search onto the previous page, so that we get our trailing overlap.
                --startPageIndex;
            }
            

            NSArray *flowReferences = self.textFlow.flowReferences;
            
            NSUInteger sectionStartIndex = 0;
            NSUInteger thisFlow = [paragraphID indexAtPosition:0];
            if(thisFlow < flowReferences.count) {
                sectionStartIndex = ((KNFBTextFlowFlowReference *)[self.textFlow.flowReferences objectAtIndex:thisFlow]).startPage;
            }
            if(startPageIndex < sectionStartIndex) {
                startPageIndex = sectionStartIndex;
            }
            
            NSUInteger sectionEndIndex = 0;
            NSUInteger nextFlow = [paragraphID indexAtPosition:0] + 1;
            if(nextFlow < flowReferences.count) {
                sectionEndIndex = ((KNFBTextFlowFlowReference *)[self.textFlow.flowReferences objectAtIndex:nextFlow]).startPage - 1;
            } else {
                sectionEndIndex = self.textFlow.lastPageIndex;
            }
            if(endPageIndex < startPageIndex || endPageIndex > sectionEndIndex) {
                endPageIndex = sectionEndIndex;
            }        
            
            // Extract MATCHING_WINDOW_SIZE strings to look for from around the 
            // position of the word we're looking for in XAML document.        
            NSString *lookForStrings[MATCHING_WINDOW_SIZE];
            char lookForHashes[MATCHING_WINDOW_SIZE];
            {
                EucCSSLayoutRun *testRun = wordContainingRun;
                NSInteger middleWordOffset = wordOffset;
                NSArray *runWords = testRun.words;
                if(middleWordOffset < MATCHING_WINDOW_SIZE / 2) {
                    EucCSSLayoutRun *previousRun = testRun;
                    while(middleWordOffset < MATCHING_WINDOW_SIZE / 2) {
                        previousRun = [runExtractor previousRunForRun:previousRun];
                        if(previousRun) {
                            NSArray *previousWords = previousRun.words;
                            runWords = [previousWords arrayByAddingObjectsFromArray:runWords];
                            middleWordOffset += previousWords.count;
                        } else {
                            NSString *extraWords[MATCHING_WINDOW_SIZE / 2];
                            for(NSInteger i = 0; i < MATCHING_WINDOW_SIZE / 2; ++i) {
                                extraWords[i] = kNoWordPlaceholder;
                            }
                            runWords = [[NSArray arrayWithObjects:extraWords count:MATCHING_WINDOW_SIZE / 2] arrayByAddingObjectsFromArray:runWords];
                            middleWordOffset += MATCHING_WINDOW_SIZE / 2;
                        }
                    }
                }
                if(runWords.count - middleWordOffset < MATCHING_WINDOW_SIZE / 2 + 1) {
                    EucCSSLayoutRun *nextRun = testRun;
                    while(runWords.count - middleWordOffset < MATCHING_WINDOW_SIZE / 2 + 1) {
                        nextRun = [runExtractor nextRunForRun:nextRun];
                        if(nextRun) {
                            NSArray *nextWords = nextRun.words;
                            runWords = [runWords arrayByAddingObjectsFromArray:nextWords];
                        } else {
                            NSString *extraWords[MATCHING_WINDOW_SIZE / 2];
                            for(NSInteger i = 0; i < MATCHING_WINDOW_SIZE / 2; ++i) {
                                extraWords[i] = kNoWordPlaceholder;
                            }
                            runWords = [runWords arrayByAddingObjectsFromArray:[NSArray arrayWithObjects:extraWords count:MATCHING_WINDOW_SIZE / 2] ];
                        }
                    }
                }
                
                NSInteger i, j;
                for(i = -(MATCHING_WINDOW_SIZE / 2), j = 0 ; i <= MATCHING_WINDOW_SIZE / 2; ++i, ++j) {
                    lookForHashes[j] = [[runWords objectAtIndex:middleWordOffset + i] hash] % 256;
                    lookForStrings[j] = [runWords objectAtIndex:middleWordOffset + i];
                }
            }
            
            /*
             NSLog(@"Searching for:");
             for(NSInteger i = 0; i < MATCHING_WINDOW_SIZE; ++i) {
             NSLog(@"\t%@", lookForStrings[i]);
             }
             */
            
            char blockHashes[MATCHING_WINDOW_SIZE];
            NSString *blockStrings[MATCHING_WINDOW_SIZE];
            
            NSUInteger pageIndexes[MATCHING_WINDOW_SIZE];
            NSUInteger blockOffsets[MATCHING_WINDOW_SIZE];
            NSUInteger wordOffsets[MATCHING_WINDOW_SIZE];
            
            char emptyHash = [kNoWordPlaceholder hash] % 256;
            for(NSInteger i = 0; i < MATCHING_WINDOW_SIZE; ++i) {
                blockStrings[i] = kNoWordPlaceholder;
                blockHashes[i] = emptyHash;
                pageIndexes[i] = startPageIndex;
                blockOffsets[i] = 0;
                wordOffsets[i] = 0;
            }
            
            int bestDistance = INT_MAX;
            NSUInteger bestPageIndex = startPageIndex;
            NSUInteger bestBlockOffset = 0;
            NSUInteger bestWordOffset = 0;
            
            
            // Step through the words in the blocks, looking for the one that has
            // a window of MATCHING_WINDOW_SIZE that's most similar to the one
            // we're looking for.
            for(NSInteger examiningPage = startPageIndex; examiningPage <= endPageIndex; ++examiningPage) {
                NSUInteger nextNonFlioBlockOffset = 0;
                NSArray *blocks = [self.textFlow blocksForPageAtIndex:examiningPage includingFolioBlocks:YES];
                NSUInteger blockCount = blocks.count;
                for(NSUInteger blockOffset = 0; ; ++blockOffset) {
                    NSArray *words = nil;
                    if(blockOffset < blockCount) {
                        KNFBTextFlowBlock *block = [blocks objectAtIndex:blockOffset];
                        if(!block.folio) {
                            words = block.wordStrings;
                            ++nextNonFlioBlockOffset;
                        }
                    } else {
                        if(blockOffset == blockCount && 
                           examiningPage == endPageIndex) {
                            // Pad out the end of the last page so that we can
                            // correctly match the end of sections.
                            NSString *extraWords[MATCHING_WINDOW_SIZE / 2];
                            for(NSInteger i = 0; i < MATCHING_WINDOW_SIZE / 2; ++i) {
                                extraWords[i] = kNoWordPlaceholder;
                            }
                            words = [NSArray arrayWithObjects:extraWords count:MATCHING_WINDOW_SIZE / 2];                        
                        } else {
                            break;
                        }
                    }
                    if(words) {
                        NSUInteger examiningWordOffset = 0;
                        for(NSString *word in words) {
                            //NSLog(@"%@", word);
                            memmove(blockHashes, blockHashes + 1, sizeof(char) * MATCHING_WINDOW_SIZE - 1);
                            blockHashes[MATCHING_WINDOW_SIZE - 1] = [word hash] % 256;
                            
                            memmove(blockStrings, blockStrings + 1, sizeof(NSString *) * MATCHING_WINDOW_SIZE - 1);
                            blockStrings[MATCHING_WINDOW_SIZE - 1] = word;
                            
                            memmove(pageIndexes, pageIndexes + 1, sizeof(NSUInteger) * MATCHING_WINDOW_SIZE - 1);
                            pageIndexes[MATCHING_WINDOW_SIZE - 1] = examiningPage;
                            
                            memmove(blockOffsets, blockOffsets + 1, sizeof(NSUInteger) * MATCHING_WINDOW_SIZE - 1);
                            blockOffsets[MATCHING_WINDOW_SIZE - 1] = nextNonFlioBlockOffset - 1;
                            
                            memmove(wordOffsets, wordOffsets + 1, sizeof(NSUInteger) * MATCHING_WINDOW_SIZE - 1);
                            wordOffsets[MATCHING_WINDOW_SIZE - 1] = examiningWordOffset;
                            
                            int distance = levenshtein_distance_with_bytes(lookForHashes, MATCHING_WINDOW_SIZE, blockHashes, MATCHING_WINDOW_SIZE);
                            if(distance < bestDistance || 
                               (distance == bestDistance && [blockStrings[MATCHING_WINDOW_SIZE / 2] isEqualToString:lookForStrings[MATCHING_WINDOW_SIZE / 2]])) {
                                /*
                                 NSLog(@"Found, distance %d:", distance);
                                 for(NSInteger i = 0;  i < MATCHING_WINDOW_SIZE; ++i) {
                                 NSLog(@"\t%@: %ld, %ld, %ld", blockStrings[i], (long)pageIndexes[i], (long)blockOffsets[i], (long)wordOffsets[i]);
                                 }
                                 */
                                bestDistance = distance;
                                bestPageIndex = pageIndexes[MATCHING_WINDOW_SIZE / 2];
                                bestBlockOffset = blockOffsets[MATCHING_WINDOW_SIZE / 2];
                                bestWordOffset = wordOffsets[MATCHING_WINDOW_SIZE / 2];
                            }
                            ++examiningWordOffset;
                        }
                    }
                }
            }
            
            // Phew!
            ret = [[SCHBookPoint alloc] init];
            ret.layoutPage = bestPageIndex + 1;
            ret.blockOffset = bestBlockOffset;
            ret.wordOffset = bestWordOffset;
            
            [ret autorelease];
        }
        [runExtractor release];

    
    return ret;
}

- (NSArray *)wordsForParagraphWithID:(id)paragraphID
{
    NSArray *ret = nil;
    
    if (paragraphID) {
        EucBookPageIndexPoint *eucIndexPoint = [[EucBookPageIndexPoint alloc] init];
        eucIndexPoint.source = [paragraphID indexAtPosition:0];
        EucCSSIntermediateDocument *document = [self.ePubBook intermediateDocumentForIndexPoint:eucIndexPoint];
        [eucIndexPoint release];
        
        EucCSSLayoutRunExtractor *runExtractor = [[EucCSSLayoutRunExtractor alloc] initWithDocument:document];
        
        uint32_t xamlFlowTreeKey = [paragraphID indexAtPosition:1];
        uint32_t documentKey = [EucCSSIntermediateDocument keyForDocumentTreeNodeKey:xamlFlowTreeKey];
        EucCSSLayoutRun *wordsContainingRun = [runExtractor runForNodeWithKey:documentKey];
        
        ret = [wordsContainingRun words];
        
        [runExtractor release];
    }
    
    return ret;
}

- (id)nextParagraphIdForParagraphWithID:(id)paragraphID
{
    NSIndexPath *ret = nil;
    
    EucBookPageIndexPoint *eucIndexPoint = [[EucBookPageIndexPoint alloc] init];
    eucIndexPoint.source = [paragraphID indexAtPosition:0];
    EucCSSIntermediateDocument *document = [self.ePubBook intermediateDocumentForIndexPoint:eucIndexPoint];
    [eucIndexPoint release];
    
    EucCSSLayoutRunExtractor *runExtractor = [[EucCSSLayoutRunExtractor alloc] initWithDocument:document];
    
    uint32_t treeKey = [paragraphID indexAtPosition:1];
    uint32_t documentKey = [EucCSSIntermediateDocument keyForDocumentTreeNodeKey:treeKey];
    EucCSSLayoutRun *thisParagraphRun = [runExtractor runForNodeWithKey:documentKey];
    EucCSSLayoutRun *nextParagraphRun = [runExtractor nextRunForRun:thisParagraphRun];
    
    if (nextParagraphRun) {
        NSUInteger indexes[2] = { [paragraphID indexAtPosition:0], [EucCSSIntermediateDocument documentTreeNodeKeyForKey:nextParagraphRun.id] };
        ret = [NSIndexPath indexPathWithIndexes:indexes length:2];
    } else {
        EucEPubBook *myEPubBook = self.ePubBook;
        EucBookPageIndexPoint *nextSourceIndexPoint = [[EucBookPageIndexPoint alloc] init];
        nextSourceIndexPoint.source = eucIndexPoint.source;
        
        do {
            ++nextSourceIndexPoint.source;
            EucCSSIntermediateDocument *intermediateDocument = [myEPubBook intermediateDocumentForIndexPoint:nextSourceIndexPoint];
            if(intermediateDocument) {
                EucCSSLayoutRunExtractor *newDocumentRunExtractor = [[EucCSSLayoutRunExtractor alloc] initWithDocument:intermediateDocument];
                nextParagraphRun = [newDocumentRunExtractor runForNodeWithKey:0];
                if (nextParagraphRun) {
                    nextSourceIndexPoint.block = nextParagraphRun.id;
                    
                    NSUInteger indexes[2] = { [paragraphID indexAtPosition:0] + 1, 0 };
                    NSIndexPath *newID = [[NSIndexPath alloc] initWithIndexes:indexes length:2];
                    ret = [newID autorelease];
                }
                [newDocumentRunExtractor release]; 
            }            
        } while(!ret && nextSourceIndexPoint.source < myEPubBook.sourceCount);
        
        [nextSourceIndexPoint release];

    }
    
    [runExtractor release];
    
    return ret;
}

@end
