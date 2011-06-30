//
//  SCHTextFlowParagraphSource.m
//  Scholastic
//
//  Created by Matt Farrugia on 02/04/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHTextFlowParagraphSource.h"
#import "SCHBookManager.h"
#import "SCHTextFlow.h"
#import "SCHFlowEucBook.h"
#import "SCHBookRange.h"
#import "SCHBookIdentifier.h"
#import "KNFBTextFlowParagraphWords.h"
#import "KNFBTextFlowParagraph.h"
#import "KNFBTextFlowPositionedWord.h"
#import "KNFBTextFlowBlock.h"
#import "KNFBTextFlowFlowReference.h"
#import "KNFBTextFlowFlowTree.h"
#import "KNFBTextFlowXAMLTreeNode.h"
#import <libEucalyptus/EucBookPageIndexPoint.h>
#import <libEucalyptus/EucCSSXHTMLTree.h>
#import <libEucalyptus/EucCSSLayoutRunExtractor.h>
#import "levenshtein_distance.h"

#define MATCHING_WINDOW_SIZE 11

static NSString * const kNoWordPlaceholder = @"NO_WORD_PLACEHOLDER";

@interface SCHTextFlowParagraphSource()

@property (nonatomic, retain) SCHBookIdentifier *identifier;

@end

@implementation SCHTextFlowParagraphSource

@synthesize identifier;

- (void)dealloc
{
    
    if (self.textFlow) {
        if(self.xamlEucBook) {
            [[SCHBookManager sharedBookManager] checkInEucBookForBookIdentifier:identifier];
        }
        [[SCHBookManager sharedBookManager] checkInTextFlowForBookIdentifier:identifier];
    }
    
    [identifier release], identifier = nil;
    
    [super dealloc];
}

- (id)initWithBookIdentifier:(SCHBookIdentifier *)newIdentifier managedObjectContext:(NSManagedObjectContext *)moc
{
    if ((self = [super initWithBookID:nil])) {
        identifier = [newIdentifier retain];
        
        self.textFlow = [[SCHBookManager sharedBookManager] checkOutTextFlowForBookIdentifier:newIdentifier inManagedObjectContext:moc];
        
        if(self.textFlow.flowTreeKind == KNFBTextFlowFlowTreeKindXaml) {
            self.xamlEucBook = [[SCHBookManager sharedBookManager] checkOutEucBookForBookIdentifier:newIdentifier inManagedObjectContext:moc];
        }

    }
    return self;
}

#pragma mark -
#pragma mark Overridden methods

// FIXME: The conversion routines between fixed and flow are direct ports form Blio. Would be nice if they were generalised in libKNFBReader

- (void)bookmarkPoint:(id)bookmarkPoint toParagraphID:(id *)paragraphID wordOffset:(uint32_t *)wordOffset
{
    // This method is a straight port from Blio. Do not alter without updating Blio
    
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
        
        /*
        NSUInteger lowerBoundPageIndex = 0;
        NSUInteger upperBoundPageIndex = 0;
        BOOL upperBoundFound = NO;
        
        run = [runExtractor runForNodeWithKey:0];
        while(run && !upperBoundFound) {
            upperBoundRunKey = run.id;
            NSArray *thisParagraphTags = [run attributeValuesForWordsForAttributeName:@"Tag"];
            for(NSString *tag in thisParagraphTags) {
                if(tag != (NSString *)[NSNull null]) {
                    if([tag hasPrefix:@"__"]) {
                        NSUInteger pageIndex = [[tag substringFromIndex:2] integerValue];
                        if(pageIndex < lookForPageIndex) {
                            lowerBoundRunKey = run.id;
                            lowerBoundPageIndex = pageIndex;
                        }
                        if(pageIndex > lookForPageIndex) {
                            upperBoundFound = YES;
                            upperBoundPageIndex = pageIndex;
                            break;
                        }
                    }
                }
            }
            run = [runExtractor nextRunForRun:run];
        }
        */
        
        // Above commented out code is the 'proper' way to do this, but this is
        // MUCH faster.
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
}

- (id)bookmarkPointFromParagraphID:(id)paragraphID wordOffset:(uint32_t)wordOffset 
{
    
    // This method is a straight port from Blio. Do not alter without updating Blio
    
    SCHBookPoint *ret = nil;
    
    if(self.textFlow.flowTreeKind == KNFBTextFlowFlowTreeKindXaml) {
        // Crazily, not all the runs in the XAML document are tagged with their 
        // layout page, there's no defined way to match words in a XAML run with 
        // words in a layout block /and/ sometimes the words differ slightly!
        
        // We still need to be able to match arbitrary points in both 
        // representations though...
        
        // The idea here is to look for the closest match we can find to the 
        // MATCHING_WINDOW_SIZE words around the point that this paragraph ID
        // and word offset define in the XAML flow.
        
        // To do this, we find a range of blocks in the document that this 
        // point may match to, given the sparse information on the start points
        // of some of the runs in the XAML document, and then go through all the 
        // runs of MATCHING_WINDOW_SIZE length in this range of blocks, looking
        // for the closest match to our MATCHING_WINDOW_SIZE words from the XAML.
        
        // Closest match is done by hashing all the words in the windows
        // to single-byte values, then calculating the levenshtein distance
        // between these hash arrays for both candidate windows, and choosing
        // the word in the center if the best matching window.
        
        EucBookPageIndexPoint *eucIndexPoint = [[EucBookPageIndexPoint alloc] init];
        eucIndexPoint.source = [paragraphID indexAtPosition:0];
        EucCSSIntermediateDocument *document = [self.xamlEucBook intermediateDocumentForIndexPoint:eucIndexPoint];
        [eucIndexPoint release];
        
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
            
            NSUInteger startPageIndex = 0;
            NSUInteger endPageIndex = 0;
            
            // Find the page number of a /subsequent/ run in the XAML document
            // to bound our block search.
            {
                EucCSSLayoutRun *testRun = wordContainingRun;
                NSArray *thisParagraphTags = [testRun attributeValuesForWordsForAttributeName:@"Tag"];
                NSInteger testOffset = wordOffset + (MATCHING_WINDOW_SIZE / 2);
                NSString *thisPageTag = nil;
                do {
                    if(thisParagraphTags.count <= testOffset) {
                        testOffset -= thisParagraphTags.count;
                        do {
                            testRun = [runExtractor nextRunForRun:testRun];
                            thisParagraphTags = [testRun attributeValuesForWordsForAttributeName:@"Tag"];
                        } while(testRun && thisParagraphTags.count == 0);
                    } else {
                        thisPageTag = [thisParagraphTags objectAtIndex:testOffset++];
                    }
                } while(testRun && ![thisPageTag hasPrefix:@"__"]);
                if(testRun) {
                    endPageIndex = [[thisPageTag substringFromIndex:2] integerValue];
                }
            }
            // Search onto the next page, so that we get our trailing overlap.
            ++endPageIndex;
            
            // Find the page number of a /previous/ run in the XAML document
            // to bound our block search.
            {
                EucCSSLayoutRun *testRun = wordContainingRun;
                NSArray *thisParagraphTags = [testRun attributeValuesForWordsForAttributeName:@"Tag"];
                NSInteger testOffset = wordOffset - 1 - (MATCHING_WINDOW_SIZE / 2);
                NSString *thisPageTag = nil;
                do {
                    if(testOffset < 0) {
                        do {
                            testRun = [runExtractor previousRunForRun:testRun];
                            thisParagraphTags = [testRun attributeValuesForWordsForAttributeName:@"Tag"];
                        } while(testRun && thisParagraphTags.count == 0);
                        testOffset = thisParagraphTags.count + testOffset;
                    } else {
                        thisPageTag = [thisParagraphTags objectAtIndex:testOffset--];
                    }
                } while(testRun && ![thisPageTag hasPrefix:@"__"]);
                if(testRun) {
                    startPageIndex = [[thisPageTag substringFromIndex:2] integerValue];
                }
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
    } else {
        KNFBTextFlowParagraph *paragraph = [self paragraphWithID:(NSIndexPath *)paragraphID];
        if(paragraph) {
            KNFBTextFlowParagraphWords *paragraphWords = paragraph.paragraphWords;
            NSArray *words = paragraphWords.words;
            
            if(wordOffset >= words.count) {
                ret = [self bookmarkPointFromParagraphID:[self nextParagraphIdForParagraphWithID:paragraphID]
                                              wordOffset:0];
            } else {
                KNFBTextFlowPositionedWord *word = [words objectAtIndex:wordOffset];
                ret = [[SCHBookPoint alloc] init];
                
                ret.layoutPage = [KNFBTextFlowBlock pageIndexForBlockID:word.blockID] + 1;
                ret.blockOffset = [KNFBTextFlowBlock blockIndexForBlockID:word.blockID];
                ret.wordOffset = word.wordIndex;
                
                [ret autorelease];
            }
        }
    }
    
    return ret;
}

- (NSUInteger)pageNumberForBookmarkPoint:(id)bookmarkPoint
{
    return [bookmarkPoint layoutPage];
}

- (id)bookmarkPointForPageNumber:(NSUInteger)pageNumber
{
    SCHBookPoint *point = [[SCHBookPoint alloc] init];
    point.layoutPage = pageNumber;
    return [point autorelease];
}

@end
