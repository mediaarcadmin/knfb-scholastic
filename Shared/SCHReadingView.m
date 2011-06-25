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

- (void)configureSelectorForSelectionMode;
- (void)selectorWillBeginSelecting;
- (void)selectorDidBeginSelectingWithSelection:(EucSelectorRange *)selectorRange;
- (void)selectorDidEndSelectingWithSelection:(EucSelectorRange *)selectorRange;

- (NSString *)wordFromSelection:(EucSelectorRange *)selectorRange;

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
        NSArray *wordBlocks = [self.textFlow blocksForPageAtIndex:bookPoint.layoutPage - 1 includingFolioBlocks:YES];
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
    
    NSArray *wordBlocks = [self.textFlow blocksForPageAtIndex:bookPoint.layoutPage - 1 includingFolioBlocks:YES];
    
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

- (void)attachSelector
{
    [self.selector addObserver:self forKeyPath:@"trackingStage" options:NSKeyValueObservingOptionPrior context:NULL];
    
    self.selector.magnifiesDuringSelection = NO;
    self.selector.selectionDelay = 0.2f;
    self.selector.allowsAdjustment = NO;

    [self configureSelectorForSelectionMode]; 
}

- (void)detachSelector
{
    [self.selector removeObserver:self forKeyPath:@"trackingStage"];
}

- (void)configureSelectorForSelectionMode
{
    switch (self.selectionMode) {
        case SCHReadingViewSelectionModeYoungerDictionary:
            self.selector.shouldTrackSingleTaps = YES;
            self.selector.allowsInitialDragSelection = NO;
            self.selector.shouldTrackSingleTapsOnHighights = NO;
            self.selector.defaultSelectionColor = nil;
            break;
        case SCHReadingViewSelectionModeOlderDictionary:
            self.selector.shouldTrackSingleTaps = NO;
            self.selector.allowsInitialDragSelection = NO;
            self.selector.shouldTrackSingleTapsOnHighights = NO;
            self.selector.defaultSelectionColor = nil;
            break;
        case SCHReadingViewSelectionModeHighlights:
            self.selector.shouldTrackSingleTaps = NO;
            self.selector.allowsInitialDragSelection = YES;
            self.selector.shouldTrackSingleTapsOnHighights = YES;
            self.selector.defaultSelectionColor = [self.delegate highlightColor];
            break;
    }
    
}

- (void)setSelectionMode:(SCHReadingViewSelectionMode)newSelectionMode
{
    if(newSelectionMode != selectionMode) {
        selectionMode = newSelectionMode;
        [self configureSelectorForSelectionMode];
    }
}

- (EucSelector *)selector
{ 
    return nil; 
}

- (NSArray *)menuItemsForEucSelector:(EucSelector *)selector 
{
    NSArray *ret = nil;

    switch (self.selectionMode) {
        case SCHReadingViewSelectionModeYoungerDictionary: {

            EucMenuItem *dictionaryItem = [[[EucMenuItem alloc] initWithTitle:NSLocalizedString(@"Look Up", "Younger Reader iPhone and iPad Look Up option in popup menu")
                                                                       action:@selector(selectYoungerWord:)] autorelease];
            
            ret = [NSArray arrayWithObjects:dictionaryItem, nil];
        } break;
        case SCHReadingViewSelectionModeHighlights: {
            if ([self.selector selectedRangeIsHighlight]) {
                EucMenuItem *dictionaryItem = [[[EucMenuItem alloc] initWithTitle:NSLocalizedString(@"Delete", "iPhone and iPad Delete option in popup menu")
                                                                           action:@selector(deleteHighlight:)] autorelease];
                
                ret = [NSArray arrayWithObjects:dictionaryItem, nil];
            }
        } break;
        default:
            break;
    }
        
    return ret;
}

- (NSString *)wordFromSelection:(EucSelectorRange *)selectorRange
{
    SCHBookRange *bookRange = [self firstBookRangeFromSelectorRange:selectorRange];
    
    NSString *word = nil;
    NSUInteger page = bookRange.startPoint.layoutPage;
    NSUInteger blockOffset = bookRange.startPoint.blockOffset;
    NSUInteger wordOffset = bookRange.startPoint.wordOffset;
    
    NSArray *pageBlocks = [self.textFlow blocksForPageAtIndex:page - 1 includingFolioBlocks:YES];
    
    if (blockOffset < [pageBlocks count]) {
        NSArray *words = [[pageBlocks objectAtIndex:blockOffset] words];
        if (wordOffset < [words count]) {
            word = [[words objectAtIndex:wordOffset] string];
        }
    }
        
    return word;
}

- (void)selectYoungerWord: (id) object
{
    NSString *word = [self wordFromSelection:[self.selector selectedRange]];
    [self dismissSelector];
    
    if (word) {
        if ([self.delegate respondsToSelector:@selector(requestDictionaryForWord:mode:)]) {
            [self.delegate requestDictionaryForWord:word mode:SCHReadingViewSelectionModeYoungerDictionary];
        }
    } else {
        NSLog(@"WARNING: could not retrieve selected word from textflow");
    }
}

#pragma mark - EucSelectorDelegate

- (UIColor *)eucSelector:(EucSelector *)selector willBeginEditingHighlightWithRange:(EucSelectorRange *)selectedRange
{
    self.createHighlightFromSelection = NO;  
    
    // Just return a clear color and keep the original highlights showing on the page
    return [UIColor clearColor];
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
    [self.delegate hideToolbars];
}

- (void)selectorDidBeginSelectingWithSelection:(EucSelectorRange *)selectorRange
{
    
    if (selectorRange) {
        
        NSString *word = nil;
        
        switch (self.selectionMode) {
            case SCHReadingViewSelectionModeYoungerDictionary:
            case SCHReadingViewSelectionModeOlderDictionary: {
                [self.selector setAllowsAdjustment:NO];
                
                if (self.singleWordSelectorRange != selectorRange) {
                    word = [self wordFromSelection:[self.selector selectedRange]];
                }
                self.singleWordSelectorRange = self.selector.selectedRange;
                
            } break;
            default:
                break;
        }        
        
        switch (self.selectionMode) {
            case SCHReadingViewSelectionModeYoungerDictionary:
                if (word) {
                    if ([self.delegate respondsToSelector:@selector(readingView:hasSelectedWordForSpeaking:)]) {
                        [self.delegate readingView:self hasSelectedWordForSpeaking:word];
                    }
                }
                break;
            case SCHReadingViewSelectionModeOlderDictionary:
                if ([self.delegate respondsToSelector:@selector(requestDictionaryForWord:mode:)]) {
                    [self.delegate requestDictionaryForWord:word mode:SCHReadingViewSelectionModeOlderDictionary];
                }
                
                // Next run-loop deselect the selector
                [self performSelector:@selector(dismissSelector) withObject:nil afterDelay:0];
                
                break;
            case SCHReadingViewSelectionModeHighlights:
                // Next run-loop deselect the selector
                if (![self.selector selectedRangeIsHighlight]) {
                    [self performSelector:@selector(dismissSelector) withObject:nil afterDelay:0];
                }
                
                break;
            default:
                break;
            }
    }
}

- (void)selectorDidEndSelectingWithSelection:(EucSelectorRange *)selectorRange
{
    if (selectorRange) {
        switch (self.selectionMode) {
            case SCHReadingViewSelectionModeHighlights:
                if (self.createHighlightFromSelection) {
                    [self addHighlightWithSelection:selectorRange];
                }
                break;
            default:
                break;
        }
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
        NSUInteger minBlockOffset = 0;
        NSUInteger minWordOffset = 0;
        NSUInteger maxBlockOffset = 0;
        NSUInteger maxWordOffset = 0;
        
        if ([pageBlocks count]) {
            KNFBTextFlowBlock *firstBlock = [pageBlocks objectAtIndex:0];
            KNFBTextFlowBlock *lastBlock = [pageBlocks lastObject];
            minBlockOffset = [firstBlock blockIndex];
            maxBlockOffset = [lastBlock blockIndex];
            maxWordOffset  = MAX([[lastBlock words] count], 1) - 1;
        }
        
        if (i == bookRange.startPoint.layoutPage) {
            [startPoint setBlockOffset:bookRange.startPoint.blockOffset];
            [startPoint setWordOffset:bookRange.startPoint.wordOffset];
        } else {
            [startPoint setBlockOffset:minBlockOffset];
            [startPoint setWordOffset:minWordOffset];
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
    
    [self refreshPageTurningViewImmediately:YES];
}

- (void)deleteHighlight:(id)sender
{
    [self deleteHighlightWithSelection:[self.selector selectedRangeOriginalHighlightRange]];
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
        
        // Deselect now because the refresh depends on it
        [self dismissSelector];
        
        for (int i = startLayoutPage; i <= endLayoutPage; i++) {
            [self refreshHighlightsForPageAtIndex:i - 1];
        }
    }
}

- (void)refreshHighlightsForPageAtIndex:(NSUInteger)index {}

- (void)refreshPageTurningViewImmediately:(BOOL)immediately {}

- (void)dismissSelector
{
    [self.selector setSelectedRange:nil];
}

#pragma mark - Touch handling

- (void)toggleToolbarsIfNoSelection
{
    // Don't toggle if the selector's up - just hide in that case.
    if(!self.selector.selectedRange) {
        [self.delegate toggleToolbars];
    } else {
        [self.delegate hideToolbars];
    }
}

- (void)unhandledTapAtPoint:(CGPoint)piont
{
    // Don't toggle if the selector's up - just hide in that case.
    if(!self.selector.selectedRange) {
        // Wait until the next runloop cycle to see if the selector selects anything 
        // in response to this tap. We don't want to display the toolbars if it does.
        [self performSelector:@selector(toggleToolbarsIfNoSelection) withObject:nil afterDelay:0];
    } else {
        [self.delegate hideToolbars];
    }
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
                if (![change valueForKey:NSKeyValueChangeNotificationIsPriorKey]) {
                    [self selectorDidBeginSelectingWithSelection:self.selector.selectedRange];
                }
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
