//
//  SCHReadingView.m
//  Scholastic
//
//  Created by Matt Farrugia on 27/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHReadingView.h"
#import "SCHBookManager.h"
#import "SCHAppBook.h"
#import "SCHTextFlow.h"
#import "SCHBookPoint.h"
#import "SCHBookRange.h"
#import "SCHHighlight.h"
#import "KNFBTextFlowBlock.h"
#import "KNFBTextFlowPositionedWord.h"
#import <libEucalyptus/THPair.h>
#import <libEucalyptus/EucMenuItem.h>
#import <libEucalyptus/EucSelector.h>
#import <libEucalyptus/EucSelectorRange.h>
#import "SCHDictionaryAccessManager.h"
#import "SCHDictionaryDownloadManager.h"

@interface SCHReadingView()

@property (nonatomic, assign) id <SCHReadingViewDelegate> delegate;
@property (nonatomic, retain) EucSelectorRange *currentSelectorRange;
@property (nonatomic, retain) EucSelectorRange *singleWordSelectorRange;
@property (nonatomic, assign) BOOL createHighlightFromSelection;

- (void)selectorWillBeginSelecting;
- (void)selectorDidBeginSelectingWithSelection:(EucSelectorRange *)selectorRange;
- (void)selectorDidEndSelectingWithSelection:(EucSelectorRange *)selectorRange;

- (void)selectedWordInMode:(SCHReadingViewSelectionMode)mode;

- (SCHBookRange *)firstBookRangeFromSelectorRange:(EucSelectorRange *)selectorRange;

@end

@implementation SCHReadingView

@synthesize isbn;
@synthesize delegate;
@synthesize xpsProvider;
@synthesize textFlow;
@synthesize selectionMode;
@synthesize currentSelectorRange;
@synthesize singleWordSelectorRange;
@synthesize createHighlightFromSelection;

- (void) dealloc
{
    if (xpsProvider) {
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:isbn];
        [xpsProvider release], xpsProvider = nil;
    }
    
    if (textFlow) {
        [[SCHBookManager sharedBookManager] checkInTextFlowForBookIdentifier:isbn];
        [textFlow release], textFlow = nil;
    }
    
    [isbn release], isbn = nil;
    [currentSelectorRange release], currentSelectorRange = nil;
    [singleWordSelectorRange release], singleWordSelectorRange = nil;
    delegate = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame isbn:(id)newIsbn delegate:(id<SCHReadingViewDelegate>)newDelegate
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isbn = [newIsbn retain];
        delegate = newDelegate;
        createHighlightFromSelection = YES;
        
        self.opaque = YES;
        self.multipleTouchEnabled = YES;
        self.userInteractionEnabled = YES;

        xpsProvider = [[[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn] retain];
        textFlow    = [[[SCHBookManager sharedBookManager] checkOutTextFlowForBookIdentifier:self.isbn] retain];
    }
    return self;
}

// Overridden methods

- (SCHBookPoint *)currentBookPoint
{
    NSLog(@"WARNING: currentBookPoint not being overridden correctly.");
    return 0;
}

- (void)jumpToPageAtIndex:(NSUInteger)page animated:(BOOL)animated
{
    NSLog(@"WARNING: jumpToPage:animated: not being overridden correctly.");
}

- (void)jumpToProgressPositionInBook:(CGFloat)progress animated:(BOOL)animated
{
    NSLog(@"WARNING: jumpToProgressPositionInBook:animated: not being overridden correctly.");
}

- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated
{
    NSLog(@"WARNING: jumpToBookPoint:animated: not being overridden correctly.");
}

- (void)jumpToNextZoomBlock
{
    // Do nothing
}

- (void)jumpToPreviousZoomBlock
{
    // Do nothing
}

- (void)didEnterSmartZoomMode
{
    // Do nothing
}

- (void)didExitSmartZoomMode
{
    // Do nothing
}

- (void) setFontPointIndex: (NSUInteger) index
{
    // Do nothing
}

- (NSInteger) maximumFontIndex
{
    // Do nothing
    return 0;
}

-(NSInteger) pageCount
{
    // Do nothing
    return 0;
}

- (void)setPageTexture:(UIImage *)image isDark:(BOOL)isDark
{
    return;
}

- (NSUInteger)pageIndexForBookPoint:(SCHBookPoint *)bookPoint
{
    return bookPoint.layoutPage - 1;
}

- (NSString *)displayPageNumberForBookPoint:(SCHBookPoint *)bookPoint 
{
    return nil;
}

#pragma mark - SCHBookPoint Conversions

- (void)layoutPage:(NSUInteger *)layoutPage pageWordOffset:(NSUInteger *)pageWordOffset forBookPoint:(SCHBookPoint *)bookPoint
{
    *layoutPage = bookPoint.layoutPage;
    *pageWordOffset = bookPoint.wordOffset;
    
    if (bookPoint.blockOffset > 0) {
        NSArray *wordBlocks = [self.textFlow blocksForPageAtIndex:bookPoint.layoutPage - 1 includingFolioBlocks:NO];
        for (int i = 0; i < bookPoint.blockOffset; i++) {
            if (i < [wordBlocks count]) {
                *pageWordOffset += [[[wordBlocks objectAtIndex:i] words] count];
            }
        }
    }
}

- (SCHBookPoint *)bookPointForLayoutPage:(NSUInteger)layoutPage pageWordOffset:(NSUInteger)pageWordOffset
{
    SCHBookPoint *bookPoint = [[SCHBookPoint alloc] init];
    bookPoint.layoutPage = layoutPage;
    bookPoint.wordOffset = pageWordOffset;
    
    NSArray *wordBlocks = [self.textFlow blocksForPageAtIndex:bookPoint.layoutPage - 1 includingFolioBlocks:NO];
    
    for (int i = 0 ; i < [wordBlocks count]; i++) {
        KNFBTextFlowBlock *block = [wordBlocks objectAtIndex:i];
        if (bookPoint.wordOffset < [[block words] count]) {
            break;
        } else {
            bookPoint.wordOffset -= [[block words] count];
            bookPoint.blockOffset++;
        }
    }
    
    return [bookPoint autorelease];
}

#pragma mark - Selector

- (EucSelector *)selector
{ 
    return nil; 
}

- (NSArray *)menuItemsForEucSelector:(EucSelector *)selector 
{
    NSArray *ret = nil;

    switch (self.selectionMode) {
        case SCHReadingViewSelectionModeOlderDictionary: {
            EucMenuItem *dictionaryItem = [[[EucMenuItem alloc] initWithTitle:NSLocalizedString(@"Look Up", "Older reader iPhone Look Up option in popup menu")
                                                                       action:@selector(selectOlderWord:)] autorelease];
            
            ret = [NSArray arrayWithObjects:dictionaryItem, nil];
            
        } break;
        case SCHReadingViewSelectionModeYoungerDictionary: {

            EucMenuItem *dictionaryItem = [[[EucMenuItem alloc] initWithTitle:NSLocalizedString(@"Look Up", "Younger Reader iPhone and iPad Look Up option in popup menu")
                                                                       action:@selector(selectYoungerWord:)] autorelease];
            
            ret = [NSArray arrayWithObjects:dictionaryItem, nil];
        } break;
        default:
            break;
    }
        
    return ret;
}

- (void)selectedWordInMode:(SCHReadingViewSelectionMode)mode
{
    
    SCHBookRange *bookRange = [self firstBookRangeFromSelectorRange:[self.selector selectedRange]];
    [self.selector setSelectedRange:nil];
    
    NSString *word = nil;
    NSUInteger page = bookRange.startPoint.layoutPage;
    NSUInteger blockOffset = bookRange.startPoint.blockOffset;
    NSUInteger wordOffset = bookRange.startPoint.wordOffset;
    
    NSArray *pageBlocks = [self.textFlow blocksForPageAtIndex:page - 1 includingFolioBlocks:NO];
    
    if (blockOffset < [pageBlocks count]) {
        NSArray *words = [[pageBlocks objectAtIndex:blockOffset] words];
        if (wordOffset < [words count]) {
            word = [[words objectAtIndex:wordOffset] string];
        }
    }
    
    NSLog(@"Word: %@", word);
    
    if (word) {
        if ([self.delegate respondsToSelector:@selector(requestDictionaryForWord:mode:)]) {
            [self.delegate requestDictionaryForWord:word mode:mode];
        }
    } else {
        NSLog(@"WARNING: could not retrieve selected word from textflow");
    }

}

- (void)selectOlderWord: (id) object
{    
    [self selectedWordInMode:SCHReadingViewSelectionModeOlderDictionary];
}

- (void)selectYoungerWord: (id) object
{
    [self selectedWordInMode:SCHReadingViewSelectionModeYoungerDictionary];
}

#pragma mark - EucSelectorDelegate

- (UIColor *)eucSelector:(EucSelector *)selector willBeginEditingHighlightWithRange:(EucSelectorRange *)selectedRange
{
    // This disables the creation of a new highlight on top of the old one
    self.createHighlightFromSelection = NO;
    [self.selector setSelectedRange:nil];
    return nil;
    //[self.selector performSelector:@selector(setSelectedRange:) withObject:nil afterDelay:0.1f];
    
    return [self.delegate highlightColor];
}

- (void)currentLayoutPage:(NSUInteger *)layoutPage pageWordOffset:(NSUInteger *)pageWordOffset
{
    SCHBookPoint *bookPoint = [self currentBookPoint];
    
    if (bookPoint) {
        [self layoutPage:layoutPage pageWordOffset:pageWordOffset forBookPoint:[self currentBookPoint]];
    }    
}

- (void)selectorWillBeginSelecting
{
    switch (self.selectionMode) {
        case SCHReadingViewSelectionModeOlderDictionary:
        case SCHReadingViewSelectionModeYoungerDictionary:
            [self.selector setAllowsAdjustment:NO];
            break;
        default:
            [self.selector setAllowsAdjustment:YES];
            break;
    }
    
    [self.delegate hideToolbars];

}

- (void)selectorDidBeginSelectingWithSelection:(EucSelectorRange *)selectorRange
{
    
    switch (self.selectionMode) {
        case SCHReadingViewSelectionModeYoungerDictionary:
            [self.selector setAllowsAdjustment:NO];
            
            if (self.singleWordSelectorRange != selectorRange) {
                
                if ([[SCHDictionaryDownloadManager sharedDownloadManager] dictionaryProcessingState] == SCHDictionaryProcessingStateReady) {
                    
                    SCHBookRange *bookRange = [self firstBookRangeFromSelectorRange:self.selector.selectedRange];
                    
                    if (bookRange.startPoint.layoutPage == bookRange.endPoint.layoutPage && 
                        bookRange.startPoint.wordOffset == bookRange.endPoint.wordOffset) {
                                                    
                            NSUInteger page = bookRange.startPoint.layoutPage;
                            NSUInteger wordOffset = bookRange.startPoint.wordOffset;
                            
                            NSArray *wordBlocks = [self.textFlow blocksForPageAtIndex:page - 1 includingFolioBlocks:NO];
                            
                            if (wordBlocks && [wordBlocks count] > 0) {
                                
                                NSString *word = [[[[wordBlocks objectAtIndex:bookRange.startPoint.blockOffset] words] objectAtIndex:wordOffset] string];
                                
                                if (word) {
                                    if (self.delegate && [self.delegate respondsToSelector:@selector(readingView:hasSelectedWordForSpeaking:)]) {
                                        [self.delegate readingView:self hasSelectedWordForSpeaking:word];
                                    }
                                }
                            }
                    }
                }
                
                self.singleWordSelectorRange = self.selector.selectedRange;
            }

            break;
        default:
            break;
    }        
}

- (void)selectorDidEndSelectingWithSelection:(EucSelectorRange *)selectorRange
{
    switch (self.selectionMode) {
        case SCHReadingViewSelectionModeHighlights:
            if (self.createHighlightFromSelection) {
                [self addHighlightWithSelection:selectorRange];
            }
            break;
        default:
            break;
    }
    
    self.createHighlightFromSelection = YES;    
}

- (EucSelectorRange *)selectorRangeFromBookRange:(SCHBookRange *)range 
{
    if (nil == range) return nil;
    
    SCHBookPoint *startPoint = range.startPoint;
    SCHBookPoint *endPoint = range.endPoint;
    
    EucSelectorRange *selectorRange = [[EucSelectorRange alloc] init];
    selectorRange.startBlockId      = [KNFBTextFlowBlock blockIDForPageIndex:startPoint.layoutPage - 1 blockIndex:startPoint.blockOffset];
    selectorRange.startElementId    = [KNFBTextFlowPositionedWord wordIDForWordIndex:startPoint.wordOffset];
    selectorRange.endBlockId        = [KNFBTextFlowBlock blockIDForPageIndex:endPoint.layoutPage - 1 blockIndex:endPoint.blockOffset];
    selectorRange.endElementId      = [KNFBTextFlowPositionedWord wordIDForWordIndex:endPoint.wordOffset];
    
    return [selectorRange autorelease];
}

- (SCHBookRange *)firstBookRangeFromSelectorRange:(EucSelectorRange *)selectorRange
{
    id ret = nil;
    
    NSArray *bookRanges = [self bookRangesFromSelectorRange:selectorRange];
    
    if ([bookRanges count]) {
        ret = [bookRanges objectAtIndex:0];
    }
    
    return ret;
}

- (NSArray *)bookRangesFromSelectorRange:(EucSelectorRange *)selectorRange
{
    
    SCHBookRange *bookRange = [self bookRangeFromSelectorRange:selectorRange];
    NSMutableArray *bookRanges = [NSMutableArray array];
    
    if (nil == bookRange) {
        return bookRanges;
    }
    
    for (int i = bookRange.startPoint.layoutPage; i <= bookRange.endPoint.layoutPage; i++) {
        SCHBookPoint *startPoint = [[SCHBookPoint alloc] init];
        SCHBookPoint *endPoint = [[SCHBookPoint alloc] init];
        
        [startPoint setLayoutPage:i];
        [endPoint   setLayoutPage:i];
        
        NSArray *pageBlocks = [self.textFlow blocksForPageAtIndex:i - 1 includingFolioBlocks:NO];
        NSUInteger maxBlockOffset = 0;
        NSUInteger maxWordOffset = 0;
        
        if ([pageBlocks count]) {
            maxBlockOffset = [pageBlocks count] - 1;
            maxWordOffset  = MAX([[[pageBlocks objectAtIndex:maxBlockOffset] words] count], 1) - 1;
        }
        
        if (i == bookRange.startPoint.layoutPage) {
            [startPoint setBlockOffset:bookRange.startPoint.blockOffset];
            [startPoint setWordOffset:bookRange.startPoint.wordOffset];
        } else {
            [startPoint setBlockOffset:0];
            [startPoint setWordOffset:0];
        }
        
        if (i == bookRange.endPoint.layoutPage) {
            [endPoint setBlockOffset:bookRange.endPoint.blockOffset];
            [endPoint setWordOffset:bookRange.endPoint.wordOffset];
        } else {
            [endPoint setBlockOffset:maxBlockOffset];
            [endPoint setWordOffset:maxWordOffset];
        }
        
        SCHBookRange *range = [[SCHBookRange alloc] init];
        [range setStartPoint:startPoint];
        [range setEndPoint:endPoint];
        [bookRanges addObject:range];
        
        [startPoint release];
        [endPoint release];
        [range release];
    }
        
    return bookRanges;
}

- (SCHBookRange *)bookRangeFromSelectorRange:(EucSelectorRange *)selectorRange
{ 
    return nil;
}

#pragma mark - Highlights

- (NSArray *)highlightRangesForEucSelector:(EucSelector *)selector
{  
    NSMutableArray *selectorRanges = [NSMutableArray array];
    
    switch (self.selectionMode) {
        case SCHReadingViewSelectionModeHighlights:
            for (SCHBookRange *highlightRange in [self highlightRangesForCurrentPage]) {
                EucSelectorRange *range = [self selectorRangeFromBookRange:highlightRange];
                [selectorRanges addObject:range];
            }
            break;
        default:
            break;
    }

    return selectorRanges;
}

- (void)dismissFollowAlongHighlighter {}

- (void)followAlongHighlightWordAtPoint:(SCHBookPoint *)bookPoint {}

- (void)followAlongHighlightWordForLayoutPage:(NSUInteger)layoutPage pageWordOffset:(NSUInteger)pageWordOffset
{
    SCHBookPoint *pointToHighlight = [self bookPointForLayoutPage:layoutPage pageWordOffset:pageWordOffset];
    [self followAlongHighlightWordAtPoint:pointToHighlight];
}

- (SCHBookRange *)bookRangeForHighlight:(SCHHighlight *)highlight
{
    SCHBookPoint *startPoint = [self bookPointForLayoutPage:[highlight startLayoutPage] pageWordOffset:[highlight startWordOffset]];
    
    SCHBookPoint *endPoint = [self bookPointForLayoutPage:[highlight endLayoutPage] pageWordOffset:[highlight endWordOffset]];
       
    SCHBookRange *bookRange = [[SCHBookRange alloc] init];
    bookRange.startPoint = startPoint;
    bookRange.endPoint = endPoint;
    
    return [bookRange autorelease];
}

- (NSArray *)highlightRangesForCurrentPage
{
    return nil;
}

- (NSArray *)highlightsForLayoutPage:(NSUInteger)page
{
    NSMutableArray *highlights = [NSMutableArray array];
    
    for (SCHHighlight *highlight in [self.delegate highlightsForLayoutPage:page]) {
        SCHBookRange *range = [self bookRangeForHighlight:highlight];
        [highlights addObject:range];
    }
    
    return highlights;
}

- (void)addHighlightWithSelection:(EucSelectorRange *)selectorRange
{
    for (SCHBookRange *highlightRange in [self bookRangesFromSelectorRange:selectorRange]) {    
        NSUInteger startLayoutPage     = 0;
        NSUInteger startPageWordOffset = 0;
        NSUInteger endLayoutPage       = 0;
        NSUInteger endPageWordOffset   = 0;
        
        [self layoutPage:&startLayoutPage pageWordOffset:&startPageWordOffset forBookPoint:highlightRange.startPoint];
        [self layoutPage:&endLayoutPage pageWordOffset:&endPageWordOffset forBookPoint:highlightRange.endPoint];

        [self.delegate addHighlightBetweenStartPage:startLayoutPage startWord:startPageWordOffset endPage:endLayoutPage endWord:endPageWordOffset];
    
        for (int i = startLayoutPage; i <= endLayoutPage; i++) {
            [self refreshHighlightsForPageAtIndex:i - 1];
        }
    }
}

- (void)deleteHighlightWithSelection:(EucSelectorRange *)selectorRange
{
    for (SCHBookRange *highlightRange in [self bookRangesFromSelectorRange:selectorRange]) {    
        NSUInteger startLayoutPage     = 0;
        NSUInteger startPageWordOffset = 0;
        NSUInteger endLayoutPage       = 0;
        NSUInteger endPageWordOffset   = 0;
        
        [self layoutPage:&startLayoutPage pageWordOffset:&startPageWordOffset forBookPoint:highlightRange.startPoint];
        [self layoutPage:&endLayoutPage pageWordOffset:&endPageWordOffset forBookPoint:highlightRange.endPoint];
        
        [self.delegate deleteHighlightBetweenStartPage:startLayoutPage startWord:startPageWordOffset endPage:endLayoutPage endWord:endPageWordOffset];
        
        for (int i = startLayoutPage; i <= endLayoutPage; i++) {
            [self refreshHighlightsForPageAtIndex:i - 1];
        }
    }
}

- (void)refreshHighlightsForPageAtIndex:(NSUInteger)index {}

- (void)dismissSelector
{
    [self.selector setSelectedRange:nil];
}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"trackingStage"]) {
        switch (self.selector.trackingStage) {
            case EucSelectorTrackingStageNone:
                if (self.currentSelectorRange != nil) {
                    [self selectorDidEndSelectingWithSelection:self.currentSelectorRange];
                }
                self.currentSelectorRange = nil;
                break;
            case EucSelectorTrackingStageSelectedAndWaiting:
                [self selectorDidBeginSelectingWithSelection:self.currentSelectorRange];
                self.currentSelectorRange = self.selector.selectedRange;                
                break;
            case EucSelectorTrackingStageFirstSelection:
                [self selectorWillBeginSelecting];
                self.currentSelectorRange = self.selector.selectedRange;
                break;
            case EucSelectorTrackingStageChangingSelection:
                self.currentSelectorRange = self.selector.selectedRange;
                break;
            default:
                break;
        }
    }
}

- (UIImage *)pageSnapshot
{
    return nil;
}

@end
