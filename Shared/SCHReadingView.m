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
#import "KNFBTextFlowBlock.h"
#import "KNFBTextFlowPositionedWord.h"
#import <libEucalyptus/THPair.h>
#import <libEucalyptus/EucMenuItem.h>
#import <libEucalyptus/EucSelector.h>
#import <libEucalyptus/EucSelectorRange.h>

@interface SCHReadingView()

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

- (id) initWithFrame:(CGRect)frame isbn:(id)aIsbn
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        isbn = [aIsbn retain];
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
    
    NSString* section = [self.textFlow sectionUuidForPageNumber:pageIndex + 1];
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
        [self.delegate addHighlightWithBookRange:toBookRange];
    }
    
    for (int i = startIndex; i <= endIndex; i++) {
        [self refreshHighlightsForPageAtIndex:i];
    }
    
}

- (void)addHighlightWithSelection:(EucSelectorRange *)selectorRange
{
    SCHBookRange *highlightRange = [self bookRangeFromSelectorRange:selectorRange];
    
    NSInteger startIndex = highlightRange.startPoint.layoutPage - 1;
    NSInteger endIndex   = highlightRange.endPoint.layoutPage - 1;
    
    [self.delegate addHighlightWithBookRange:highlightRange];
    
    for (int i = startIndex; i <= endIndex; i++) {
        [self refreshHighlightsForPageAtIndex:i];
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
