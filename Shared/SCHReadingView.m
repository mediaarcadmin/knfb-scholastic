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

@interface SCHReadingView()

@property (nonatomic, assign) id <SCHReadingViewDelegate> delegate;
@property (nonatomic, retain) EucSelectorRange *currentSelectorRange;

- (void)selectorDismissedWithSelection:(EucSelectorRange *)selectorRange;

@end

@implementation SCHReadingView

@synthesize isbn;
@synthesize delegate;
@synthesize xpsProvider;
@synthesize textFlow;
@synthesize selectionMode;
@synthesize currentSelectorRange;

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

- (NSString *)pageLabelForPageAtIndex:(NSUInteger)pageIndex
{
    NSString *ret = nil;
    
    NSString* section = [self.textFlow sectionUuidForPageIndex:pageIndex];
    THPair* chapter   = [self.textFlow presentationNameAndSubTitleForSectionUuid:section];
    NSString* pageStr = [self displayPageNumberForPageAtIndex:pageIndex];
    
    if (section && chapter.first) {
        if (pageStr) {
            ret = [NSString stringWithFormat:NSLocalizedString(@"Page %@ \u2013 %@",@"Page label with page number and chapter"), pageStr, chapter.first];
        } else {
            ret = [NSString stringWithFormat:@"%@", chapter.first];
        }
    } else {
        if (pageStr) {
            ret = [NSString stringWithFormat:NSLocalizedString(@"Page %@ of %lu",@"Page label X of Y (page number of page count) in SCHLayoutView"), pageStr, (unsigned long)self.pageCount];
        } else {
            SCHAppBook *book = [[SCHBookManager sharedBookManager] bookWithIdentifier:self.isbn];
            ret = [book XPSTitle];
        }
    }
    
    return ret;
}

- (NSString *)displayPageNumberForPageAtIndex:(NSUInteger)pageIndex
{
    return [self.textFlow contentsTableViewController:nil displayPageNumberForPageIndex:pageIndex];
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
                if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
                    EucMenuItem *dictionaryItem = [[[EucMenuItem alloc] initWithTitle:NSLocalizedString(@"Look Up", "Older reader iPhone Look Up option in popup menu")
                                                                               action:nil] autorelease];
                    
                    ret = [NSArray arrayWithObjects:dictionaryItem, nil];
                }
        } break;
        case SCHReadingViewSelectionModeYoungerDictionary: {
            EucMenuItem *dictionaryItem = [[[EucMenuItem alloc] initWithTitle:NSLocalizedString(@"Look Up", "Younger Reader iPhone and iPad Look Up option in popup menu")
                                                                       action:nil] autorelease];
            
            ret = [NSArray arrayWithObjects:dictionaryItem, nil];
        } break;
        default:
            break;
    }
        
    return ret;
}

- (UIColor *)eucSelector:(EucSelector *)selector willBeginEditingHighlightWithRange:(EucSelectorRange *)selectedRange
{
//    UIColor *selectionColor = nil;
//        
//    switch (self.selectionMode) {
//        case SCHReadingViewSelectionModeHighlights:
//            selectionColor = [UIColor yellowColor];
//            break;
//        default:
//            break;
//    }
//    
    return nil;
}

- (void)eucSelector:(EucSelector *)selector didEndEditingHighlightWithRange:(EucSelectorRange *)originalRange movedToRange:(EucSelectorRange *)movedToRange;
{
    
}

- (SCHBookRange *)bookRangeForHighlight:(SCHHighlight *)highlight
{
    SCHBookPoint *startPoint = [[SCHBookPoint alloc] init];
    startPoint.layoutPage = [highlight startLayoutPage];
    startPoint.wordOffset = [highlight startWordOffset];
    
    NSArray *startWordBlocks = [self.textFlow blocksForPageAtIndex:startPoint.layoutPage - 1 includingFolioBlocks:NO];

    for (int i = 0 ; i < [startWordBlocks count]; i++) {
        KNFBTextFlowBlock *block = [startWordBlocks objectAtIndex:i];
        if (startPoint.wordOffset < [[block words] count]) {
            break;
        } else {
            startPoint.wordOffset -= [[block words] count];
            startPoint.blockOffset++;
        }
    }

    SCHBookPoint *endPoint = [[SCHBookPoint alloc] init];
    endPoint.layoutPage = [highlight endLayoutPage];
    endPoint.wordOffset = [highlight endWordOffset];
    
    NSArray *endWordBlocks = [self.textFlow blocksForPageAtIndex:endPoint.layoutPage - 1 includingFolioBlocks:NO];
    
    for (int i = 0 ; i < [endWordBlocks count]; i++) {
        KNFBTextFlowBlock *block = [endWordBlocks objectAtIndex:i];
        if (endPoint.wordOffset < [[block words] count]) {
            break;
        } else {
            endPoint.wordOffset -= [[block words] count];
            endPoint.blockOffset++;
        }
    }
    
    SCHBookRange *bookRange = [[SCHBookRange alloc] init];
    bookRange.startPoint = startPoint;
    bookRange.endPoint = endPoint;
    
    [startPoint release];
    [endPoint release];
    
    return [bookRange autorelease];
        
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

- (void)updateHighlight {
    
    EucSelectorRange *fromSelectorRange = [self.selector selectedRangeOriginalHighlightRange];
    EucSelectorRange *toSelectorRange   = [self.selector selectedRange];
    
    [self.selector setSelectedRange:nil];
    
    SCHBookRange *fromBookRange = [self bookRangeFromSelectorRange:fromSelectorRange];
    SCHBookRange *toBookRange   = [self bookRangeFromSelectorRange:toSelectorRange];

    NSInteger startIndex;
    NSInteger endIndex;
    
    if ([self.selector selectedRangeIsHighlight]) {
        startIndex = MIN(fromBookRange.startPoint.layoutPage, toBookRange.startPoint.layoutPage) - 1;
        endIndex   = MAX(fromBookRange.endPoint.layoutPage, toBookRange.endPoint.layoutPage) - 1;
        [self.delegate updateHighlightAtBookRange:fromBookRange toBookRange:toBookRange];
    } else {
        startIndex = toBookRange.startPoint.layoutPage - 1;
        endIndex   = toBookRange.endPoint.layoutPage - 1;
        //[self.delegate addHighlightAtBookRange:toBookRange];
    }
    
    for (int i = startIndex; i <= endIndex; i++) {
        [self refreshHighlightsForPageAtIndex:i];
    }
    
}

- (void)addHighlightWithSelection:(EucSelectorRange *)selectorRange
{
    SCHBookRange *highlightRange = [self bookRangeFromSelectorRange:selectorRange];
    
    NSUInteger startPage = highlightRange.startPoint.layoutPage;
    NSUInteger startWord = highlightRange.startPoint.wordOffset;
    NSUInteger endPage   = highlightRange.endPoint.layoutPage;
    NSUInteger endWord   = highlightRange.endPoint.wordOffset;

    if (highlightRange.startPoint.blockOffset > 0) {
        NSArray *startWordBlocks = [self.textFlow blocksForPageAtIndex:startPage - 1 includingFolioBlocks:NO];
        for (int i = 0; i < highlightRange.startPoint.blockOffset; i++) {
            if (i < [startWordBlocks count]) {
                startWord += [[[startWordBlocks objectAtIndex:i] words] count];
            }
        }
    }
    
    if (highlightRange.endPoint.blockOffset > 0) {
        NSArray *endWordBlocks = [self.textFlow blocksForPageAtIndex:endPage - 1 includingFolioBlocks:NO];
        for (int i = 0; i < highlightRange.endPoint.blockOffset; i++) {
            if (i < [endWordBlocks count]) {
                endWord += [[[endWordBlocks objectAtIndex:i] words] count];
            }
        }
    }
    
    [self.delegate addHighlightBetweenStartPage:startPage startWord:startWord endPage:endPage endWord:endWord];
    
    for (int i = startPage; i <= endPage; i++) {
        [self refreshHighlightsForPageAtIndex:i - 1];
    }
}

- (void)selectorDismissedWithSelection:(EucSelectorRange *)selectorRange
{
    switch (self.selectionMode) {
        case SCHReadingViewSelectionModeHighlights:
            [self addHighlightWithSelection:selectorRange];
            break;
        default:
            break;
    }
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

- (SCHBookRange *)bookRangeFromSelectorRange:(EucSelectorRange *)selectorRange { return nil; }

- (void)refreshHighlightsForPageAtIndex:(NSUInteger)index {}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {}
- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {}

#pragma mark - KVO

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if ([keyPath isEqualToString:@"trackingStage"]) {
        switch (self.selector.trackingStage) {
            case EucSelectorTrackingStageNone:
                if (self.currentSelectorRange != nil) {
                    [self selectorDismissedWithSelection:self.currentSelectorRange];
                }
                self.currentSelectorRange = nil;
                break;
            case EucSelectorTrackingStageFirstSelection:
            case EucSelectorTrackingStageSelectedAndWaiting:
            case EucSelectorTrackingStageChangingSelection:
                self.currentSelectorRange = self.selector.selectedRange;
                break;
            default:
                break;
        }
    }
}

@end
