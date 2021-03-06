//
//  SCHFlowView.m
//  Scholastic
//
//  Created by Matt farrugia
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHFlowView.h"
#import "SCHBookManager.h"
#import "SCHFlowEucBook.h"
#import "SCHBookPoint.h"
#import "SCHBookRange.h"
#import "KNFBParagraphSource.h"
#import "SCHEPubBook.h"
#import "SCHBSBEucBook.h"
#import "SCHRecommendationViewDataSource.h"
#import <libEucalyptus/EucBookView.h>
#import <libEucalyptus/EucEPubBook.h>
#import <libEucalyptus/EucBookPageIndexPoint.h>
#import <libEucalyptus/EucHighlightRange.h>
#import <libEucalyptus/EucMenuItem.h>
#import <libEucalyptus/EucCSSIntermediateDocument.h>
#import <libEucalyptus/EucSelectorRange.h>
#import <libEucalyptus/EucHighlightRange.h>
#import <libEucalyptus/THPair.h>
#import <libEucalyptus/EucOTFIndex.h>

static const CGFloat kSCHFlowViewHorizontalMarginPhone = 7.0f;
static const CGFloat kSCHFlowViewHorizontalMarginPad = 32.0f;
static const CGFloat kSCHFlowViewBottomMarginPhone = 0.0f;
static const CGFloat kSCHFlowViewBottomMarginPad = 20.0f;
static const CGFloat kSCHFlowViewTopTitlePaddingPhone = 2.0f;
static const CGFloat kSCHFlowViewTopTitlePaddingPad = 10.0f;

@interface SCHFlowView () <SCHBSBEucBookDelegate>

@property (nonatomic, retain) id<EucBook, SCHEucBookmarkPointTranslation, SCHRecommendationDataSource> eucBook;
@property (nonatomic, retain) id<KNFBParagraphSource> paragraphSource;
@property (nonatomic, retain) EucBookView *eucBookView;

@property (nonatomic, retain) NSArray *fontPointSizes;

@property (nonatomic, retain) UIImage *currentPageTexture;
@property (nonatomic, assign) BOOL textureIsDark;
@property (nonatomic, copy) dispatch_block_t jumpToPageCompletionHandler;
@property (nonatomic, retain) SCHBookPoint *openingPoint;
@property (nonatomic, assign) BOOL bookSizeMayHaveChanged;

- (void)updatePositionInBook;
- (void)jumpToPageAtIndexPoint:(EucBookPageIndexPoint *)point animated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion;

@end

@implementation SCHFlowView

@synthesize eucBook;
@synthesize paragraphSource;
@synthesize eucBookView;
@synthesize fontPointSizes;

@synthesize currentPageTexture;
@synthesize textureIsDark;
@synthesize jumpToPageCompletionHandler;
@synthesize openingPoint;
@synthesize bookSizeMayHaveChanged;

- (void)initialiseView
{
    if((eucBookView = [[EucBookView alloc] initWithFrame:self.bounds 
                                                    book:self.eucBook
                                          fontPointSizes:self.fontPointSizes])) {
        eucBookView.delegate = self;
        eucBookView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        eucBookView.vibratesOnInvalidTurn = NO;
        eucBookView.allowsTapTurn = NO;
        eucBookView.twoUpLandscape = YES;
        
        self.bookSizeMayHaveChanged = YES;
        
        [eucBookView setPageTexture:self.currentPageTexture isDark:self.textureIsDark];
        
        if (self.openingPoint) {
            if (![self.eucBook isKindOfClass:[SCHBSBEucBook class]]) {
                [self jumpToBookPoint:self.openingPoint animated:NO];
            }
            self.openingPoint = nil;
        }
        
        [self addSubview:eucBookView];
    }
}

- (void)dealloc
{    
    [eucBookView release], eucBookView = nil;
    
    if(paragraphSource) {
        [paragraphSource release], paragraphSource = nil;
        [[SCHBookManager sharedBookManager] checkInParagraphSourceForBookIdentifier:self.identifier];   
    }
    
    if(eucBook) {
        [eucBook release], eucBook = nil;
        [[SCHBookManager sharedBookManager] checkInEucBookForBookIdentifier:self.identifier];  
    }
    
    [currentPageTexture release], currentPageTexture = nil;
    [jumpToPageCompletionHandler release], jumpToPageCompletionHandler = nil;
    [openingPoint release], openingPoint = nil;

    [fontPointSizes release], fontPointSizes = nil;
    
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
     bookIdentifier:(SCHBookIdentifier *)bookIdentifier
managedObjectContext:(NSManagedObjectContext *)managedObjectContext
           delegate:(id<SCHReadingViewDelegate>)delegate
              point:(SCHBookPoint *)point
 recommendationViewDataSource:(id <SCHRecommendationViewDataSource>)recommendationViewDataSource
{
    self = [super initWithFrame:frame
                 bookIdentifier:bookIdentifier 
           managedObjectContext:managedObjectContext
                       delegate:delegate
                          point:point];
    if (self) {        
        self.opaque = YES;
        
        SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
        eucBook = [[bookManager checkOutEucBookForBookIdentifier:self.identifier inManagedObjectContext:managedObjectContext] retain];
        
        if ([eucBook respondsToSelector:@selector(setRecommendationViewDataSource:)]) {
            [eucBook setRecommendationViewDataSource:recommendationViewDataSource];
        }

        if ([eucBook isKindOfClass:[EucEPubBook class]]) {
            paragraphSource = [[bookManager checkOutParagraphSourceForBookIdentifier:self.identifier inManagedObjectContext:managedObjectContext] retain];
        } else if ([eucBook isKindOfClass:[SCHBSBEucBook class]]) {
            [(SCHBSBEucBook *)eucBook setDelegate:self];
        }
        
        openingPoint = [point retain];
    }
    return self;
}

- (void)attachSelector
{
    self.eucBookView.allowsSelection = NO;
    self.eucBookView.allowsSelection = self.allowsSelection;
    self.eucBookView.selectorDelegate = self;
    
    [super attachSelector];
}

- (void)detachSelector
{
    [super detachSelector];

    self.eucBookView.allowsSelection = NO;
    self.eucBookView.selectorDelegate = nil;
}

- (void)configureSelectorForSelectionMode
{
    [super configureSelectorForSelectionMode];
    
    switch (self.selectionMode) {
        case SCHReadingViewSelectionModeYoungerDictionary:
        case SCHReadingViewSelectionModeYoungerNoDictionary:
        case SCHReadingViewSelectionModeOlderDictionary:
            self.eucBookView.highlightsAreSelectable = NO;
            break;
        case SCHReadingViewSelectionModeHighlights:
            self.eucBookView.highlightsAreSelectable = YES;
            break;
    }
}

- (void)willMoveToWindow:(UIWindow *)newWindow 
{
    [super willMoveToWindow:newWindow];
    
    // The selector observer must be dealloced here before the selector is torn down inside eucbookview
    if (newWindow == nil) {
        [self detachSelector];
        [self.eucBookView removeObserver:self forKeyPath:@"currentPageIndexPoint"];
        [self.eucBookView removeObserver:self forKeyPath:@"pageCount"];
    } else {
        // N.B. We must initialise the view _after_ the view frame has been set because
        // the eucBookView paginates the eucBook using the view bounds. If we initialise too early
        // the nib frame size will be used instead. The correct fix for this is probably to
        // initialise the _pageLayoutController in EucBookView in willMoveToWindow rather than init
        if (!self.eucBookView) {
            [self initialiseView];
        }
    }
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.window) {
        // This needs to be done here to add the observer after the willMoveToWindow code in
        // eucBookView which sets the page count
        [self.eucBookView addObserver:self forKeyPath:@"currentPageIndexPoint" options:NSKeyValueObservingOptionInitial context:NULL];
        [self.eucBookView addObserver:self forKeyPath:@"pageCount" options:NSKeyValueObservingOptionInitial context:NULL];
        
        if (self.bookSizeMayHaveChanged) {
            // Reset needs to be here as page layout controller isn't instantiated earlier and that does the shrinking
            [self resetBookSize];
            self.bookSizeMayHaveChanged = NO;
        }
        
        [self attachSelector];
    }
}

- (void)resetBookSize
{
    if ([self.eucBook isKindOfClass:[SCHBSBEucBook class]]) {
        [self.eucBookView bookWillShrink];
        EucBookPageIndexPoint *startPoint = [[[EucBookPageIndexPoint alloc] init] autorelease];
        [self.eucBookView bookHasShrunkToIndexPoint:startPoint];
    } else {
        BOOL shouldShowRecommendation = [self.eucBook.recommendationViewDataSource shouldShowRecommendationView];
        
        if (shouldShowRecommendation) {
            [self.eucBookView bookHasGrown];
        } else  {
            [self.eucBookView bookWillShrink];
            [self.eucBookView bookHasShrunkToIndexPoint:[self.eucBook offTheEndIndexPoint]];
        }
    }
}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self.eucBookView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.eucBookView didRotateFromInterfaceOrientation:fromInterfaceOrientation];
}


#pragma mark - BookView Methods

- (SCHBookPoint *)currentBookPoint
{
    return [self.eucBook bookPointFromBookPageIndexPoint:self.eucBookView.currentPageIndexPoint];
}

- (SCHBookRange *)currentBookRange
{
    SCHBookRange *pageRange = nil;
    
    if (self.eucBookView.currentPageIndex != NSUIntegerMax) {
        EucBookPageIndexPoint *startPoint = [self.eucBookView indexPointForPageIndex:self.eucBookView.currentPageIndex];
        EucBookPageIndexPoint *endPoint   = [self.eucBookView indexPointForPageIndex:self.eucBookView.currentPageIndex + 1];

        SCHBookPoint *startBookPoint = [self.eucBook bookPointFromBookPageIndexPoint:startPoint];
        SCHBookPoint *endBookPoint;
        
        if (endPoint) {
            endBookPoint = [self.eucBook bookPointFromBookPageIndexPoint:endPoint];
            
            SCHBookPoint *nullPoint = [[[SCHBookPoint alloc] init] autorelease];
            if ([endBookPoint isEqual:nullPoint]) {
                endBookPoint.layoutPage = startBookPoint.layoutPage + 1;
            }
        } else {
            endBookPoint = [[[SCHBookPoint alloc] init] autorelease];
            endBookPoint.layoutPage = startBookPoint.layoutPage + 1;
        }
        
        pageRange = [[[SCHBookRange alloc] init] autorelease];
        pageRange.startPoint = startBookPoint;
        
        if ([startBookPoint compare:endBookPoint] == NSOrderedAscending) {
            pageRange.endPoint = endBookPoint;
        } else {
            pageRange.endPoint = startBookPoint;
        }
    }
    
    return pageRange;
}

- (CGFloat)currentProgressPosition
{
    return [self.eucBook estimatedPercentageForIndexPoint:self.eucBookView.currentPageIndexPoint];
}

- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated
{
    [self jumpToBookPoint:bookPoint animated:animated withCompletionHandler:nil];
}

- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion
{
    EucBookPageIndexPoint *point;
    if(bookPoint.layoutPage == 1 && bookPoint.blockOffset == 0 && 
       bookPoint.wordOffset == 0 && bookPoint.elementOffset == 0) {
        // This is the start of the book.  Leave the eucIndexPoint empty
        // so that we refer to the cover.
        point = [[[EucBookPageIndexPoint alloc] init] autorelease];
    } else {
        point = [self.eucBook bookPageIndexPointFromBookPoint:bookPoint];
    }

    [self jumpToPageAtIndexPoint:point animated:animated withCompletionHandler:completion];
}

- (void)jumpToPageAtIndex:(NSUInteger)pageIndex animated:(BOOL)animated
{              
    [self jumpToPageAtIndex:pageIndex animated:animated withCompletionHandler:nil];
}

- (void)jumpToPageAtIndex:(NSUInteger)pageIndex animated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion
{
    EucBookPageIndexPoint *point = [self.eucBookView indexPointForPageIndex:pageIndex];
    [self jumpToPageAtIndexPoint:point animated:animated withCompletionHandler:completion];
}

- (void)jumpToProgressPositionInBook:(CGFloat)progress animated:(BOOL)animated
{
    EucBookPageIndexPoint *point = [self.eucBook estimatedIndexPointForPercentage:progress];
    [self jumpToPageAtIndexPoint:point animated:animated withCompletionHandler:nil];
}

- (void)jumpToPageAtIndexPoint:(EucBookPageIndexPoint *)point animated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self jumpToPageAtIndexPoint:point animated:animated withCompletionHandler:completion];
        });
        
        return;
    }
    
    // The eucBookView won't turn the page if it is already visible, so we need to check that
    EucBookPageIndexPointRange *visibleIndexPointRange = [self.eucBookView visibleIndexPointRange];
    
    BOOL alreadyVisible = [visibleIndexPointRange containsPointExclusively:point];
    
    if (animated && !alreadyVisible) {
        self.jumpToPageCompletionHandler = completion;
    }
    
    [self.eucBookView goToIndexPoint:point animated:animated];
    
    if (!animated || alreadyVisible) {
        if (completion != nil) {
            completion();
        }
    }
}

- (NSArray *)fontPointSizes
{
    if(!fontPointSizes) {
        NSMutableArray *buildFontPointSizes = [[NSMutableArray alloc] init];
        static const CGFloat sFontSizesArray[] = { 14, 16, 19, 24, 32, 41 };
        NSUInteger fontSizeCount = UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone ? 5 : 6;
        for(size_t i = 0; i < fontSizeCount; ++i) {
            [buildFontPointSizes addObject:[NSNumber numberWithFloat:sFontSizesArray[i]]];
        }
        self.fontPointSizes = buildFontPointSizes;
        [buildFontPointSizes release];
    }
    return fontPointSizes;
}

- (NSInteger) maximumFontIndex
{
    return ([self.fontPointSizes count] - 1);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:@"currentPageIndexPoint"]) {
        [self updatePositionInBook];
    } else if ([keyPath isEqualToString:@"pageCount"]) {
        [self updatePositionInBook];
        
        // The page count changes when we set the font size (it explicitly uses a KVO willChange/didChange on pageCount
        [self.delegate readingView:self hasChangedFontPointToSizeAtIndex:[self fontSizeIndex]];
    }

}

- (void)updatePositionInBook
{
    // For some reason, when the pagination complete notification fires, pageCount but not currentPageIndex gets set
    // Therefore we need to construct the pageIndex when pageCount gets set at the end of pagination
    if ((self.eucBookView.pageCount != 0) && (self.eucBookView.pageCount != -1)) {
        if (self.eucBookView.currentPageIndex != NSUIntegerMax) {
            [self.delegate readingView:self hasMovedToPageAtIndex:self.eucBookView.currentPageIndex];
        } else {
            NSUInteger pageIndex = [self.eucBookView pageIndexForIndexPoint:self.eucBookView.currentPageIndexPoint];
            [self.delegate readingView:self hasMovedToPageAtIndex:pageIndex];
        }
    } else {
        CGFloat progress = [self.eucBook estimatedPercentageForIndexPoint:self.eucBookView.currentPageIndexPoint];
        [self.delegate readingView:self hasMovedToProgressPositionInBook:progress];
    }
}

- (void)bookView:(EucBookView *)bookView unhandledTapAtPoint:(CGPoint)point
{
    [self unhandledTapAtPoint:point];
}

- (BOOL)bookView:(EucBookView *)bookView shouldHandleTapOnHyperlink:(NSURL *)link
{
    return YES;
}

- (BOOL)bookView:(EucBookView *)bookView shouldAllowTurnInDirection:(EucBookViewTurnDirection)direction
{
    BOOL ret = YES;

    if ([self.eucBook isKindOfClass:[SCHBSBEucBook class]] &&
        (direction == EucBookViewTurnDirectionShowPageToLeft)) {
        
        ret = [(SCHBSBEucBook *)self.eucBook shouldAllowTurnBackFromIndexPoint:bookView.currentPageIndexPoint];
    }
    
    return ret;
}

- (void)bookViewPageTurnWillBegin:(EucBookView *)bookView
{
    [self.delegate readingViewWillBeginTurning:self];
}

- (void)bookViewPageTurnDidEnd:(EucBookView *)bookView
{
    if (self.jumpToPageCompletionHandler != nil) {
        dispatch_block_t handler = Block_copy(self.jumpToPageCompletionHandler);
        self.jumpToPageCompletionHandler = nil;
        handler();
        Block_release(handler);
    }
}

static NSPredicate *sSortedHighlightRangePredicate = nil;
pthread_once_t sSortedHighlightRangePredicateOnceControl = PTHREAD_ONCE_INIT;
static void sortedHighlightRangePredicateInit() {
    sSortedHighlightRangePredicate = [[NSPredicate predicateWithFormat:
                                       @"NOT ( startPoint.layoutPage > $MAX_LAYOUT_PAGE ) && "
                                       @"NOT ( endPoint.layoutPage < $MIN_LAYOUT_PAGE ) && "
                                       @"NOT ( startPoint.layoutPage == $MAX_LAYOUT_PAGE && startPoint.blockOffset > $MAX_BLOCK_OFFSET ) && "
                                       @"NOT ( endPoint.layoutPage == $MIN_LAYOUT_PAGE && endPoint.blockOffset < $MIN_BLOCK_OFFSET) && "
                                       @"NOT ( startPoint.layoutPage == $MAX_LAYOUT_PAGE && startPoint.blockOffset == $MAX_BLOCK_OFFSET && startPoint.wordOffset > $MAX_WORD_OFFSET ) && "
                                       @"NOT ( endPoint.layoutPage == $MIN_LAYOUT_PAGE && endPoint.blockOffset == $MIN_BLOCK_OFFSET && endPoint.wordOffset < $MIN_WORD_OFFSET )"
                                       ] retain];
}

- (NSPredicate *)sortedHighlightRangePredicate {
    pthread_once(&sSortedHighlightRangePredicateOnceControl, sortedHighlightRangePredicateInit);
    return sSortedHighlightRangePredicate;
}

- (NSArray *)sortedHighlightsInRange:(SCHBookRange *)range {
    
    SCHBookPoint *startBookPoint = range.startPoint;
    SCHBookPoint *endBookPoint = range.endPoint;
        
    NSMutableArray *allHighlights = [NSMutableArray array];
    
    for (int i = startBookPoint.layoutPage; i <= endBookPoint.layoutPage; i++) {
        NSArray *highlightRanges = [self highlightsForLayoutPage:i];
        [allHighlights addObjectsFromArray:highlightRanges];
    }
    
    NSNumber *minLayoutPage = [NSNumber numberWithInteger:range.startPoint.layoutPage];
    NSNumber *minBlockOffset = [NSNumber numberWithInteger:range.startPoint.blockOffset];
    NSNumber *minWordOffset = [NSNumber numberWithInteger:range.startPoint.wordOffset];
    
    NSNumber *maxLayoutPage = [NSNumber numberWithInteger:range.endPoint.layoutPage];
    NSNumber *maxBlockOffset = [NSNumber numberWithInteger:range.endPoint.blockOffset];
    NSNumber *maxWordOffset = [NSNumber numberWithInteger:range.endPoint.wordOffset];
    
    NSDictionary *substitutionVariables = [[NSDictionary alloc] initWithObjectsAndKeys:
                                           minLayoutPage, @"MIN_LAYOUT_PAGE",
                                           minBlockOffset, @"MIN_BLOCK_OFFSET",
                                           minWordOffset, @"MIN_WORD_OFFSET",
                                           maxLayoutPage, @"MAX_LAYOUT_PAGE",
                                           maxBlockOffset, @"MAX_BLOCK_OFFSET",
                                           maxWordOffset, @"MAX_WORD_OFFSET",
                                           nil];
    
    NSPredicate *predicate = [[self sortedHighlightRangePredicate] predicateWithSubstitutionVariables:substitutionVariables];
    
    [substitutionVariables release];
        
    NSSortDescriptor *sortPageDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"startPoint.layoutPage" ascending:YES] autorelease];
    NSSortDescriptor *sortParaDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"startPoint.blockOffset" ascending:YES] autorelease];
    NSSortDescriptor *sortWordDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"startPoint.wordOffset" ascending:YES] autorelease];
    NSSortDescriptor *sortHyphenDescriptor = [[[NSSortDescriptor alloc] initWithKey:@"startPoint.elementOffset" ascending:YES] autorelease];
    
    NSArray *sortDescriptors = [NSArray arrayWithObjects:sortPageDescriptor, sortParaDescriptor, sortWordDescriptor, sortHyphenDescriptor, nil];
    
    
    NSArray *sortedHighlights = [[allHighlights filteredArrayUsingPredicate:predicate] sortedArrayUsingDescriptors:sortDescriptors];
    
    return sortedHighlights;
    
}

- (NSArray *)bookView:(EucBookView *)bookView highlightRangesFromPoint:(EucBookPageIndexPoint *)startPoint toPoint:(EucBookPageIndexPoint *)endPoint
{
    NSArray *ret = nil;
    
    // Don't support highlights in ePub books
    if ([self.eucBook isKindOfClass:[SCHEPubBook class]]) {
        return ret;
    }
    
    SCHBookPoint *startBookPoint = [self.eucBook bookPointFromBookPageIndexPoint:startPoint];
    SCHBookPoint *endBookPoint = [self.eucBook bookPointFromBookPageIndexPoint:endPoint];
    SCHBookRange *pageRange = [[SCHBookRange alloc] init];
    pageRange.startPoint = startBookPoint;
    pageRange.endPoint = endBookPoint;
        
    NSArray *allHighlights = [self sortedHighlightsInRange:pageRange];
    
    [pageRange release];
            
    NSUInteger count = allHighlights.count;
    if(count) {
        NSMutableArray *eucRanges = [[NSMutableArray alloc] initWithCapacity:count];
        for(SCHBookRange *bookRange in allHighlights) {
            //NSLog(@"highlight range from %@ to %@ is %@", startBookPoint, endBookPoint, bookRange);

            EucHighlightRange *eucRange = [[EucHighlightRange alloc] init];
            eucRange.startPoint = [self.eucBook bookPageIndexPointFromBookPoint:bookRange.startPoint];
            eucRange.endPoint = [self.eucBook bookPageIndexPointFromBookPoint:bookRange.endPoint];
            eucRange.color = [self.delegate highlightColor];
            [eucRanges addObject:eucRange];
            
            //NSLog(@"Converted bookrange: %@ into %@", bookRange, eucRange);
            [eucRange release];
        }
        ret = [eucRanges autorelease];
    }
        
    return ret;
}

- (NSString *)displayPageLabelForBookPoint:(SCHBookPoint *)bookPoint
{
    NSInteger pageIndex = [self.eucBookView pageIndexForIndexPoint:[self.eucBook bookPageIndexPointFromBookPoint:bookPoint]];

    NSString *pageNumber = [self.eucBookView displayPageNumberForPageIndex:pageIndex];
    if (pageNumber) {
        return [NSString stringWithFormat:NSLocalizedString(@"Page %@", @"displayPageLabelForBookPoint (flow view)"), pageNumber];
    } else {
        return [self.eucBookView pageDescriptionForPageIndex:pageIndex];
    }
}

- (NSString *)pageLabelForPageAtIndex:(NSUInteger)pageIndex showChapters:(BOOL)showChapters
{
    // In Flow View page labels run from index 0 to pageCount - 1, with index 0 being handled as a special case for the cover)
    NSString *pageStr = [self.eucBookView displayPageNumberForPageIndex:pageIndex];    
    EucBookPageIndexPoint *indexPoint = [self.eucBookView indexPointForPageIndex:pageIndex];
    
    NSString *chapterPrefix = NSLocalizedString(@"Chapter ", @"Scrubber label chapter prefix for flow view");
    NSString *pagePrefix = NSLocalizedString(@"Page ", @"Scrubber label page prefix for flow view");
    NSString *chapterPageSeparator = NSLocalizedString(@" │ ", @"Scrubber label chapter page separator for flow view");

    NSString *pageLabel = nil;
    
    if (showChapters) {
        NSString *chapterName = [self.eucBookView presentationNameAndSubTitleForIndexPoint:indexPoint].first;
        
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setAllowsFloats:NO];
        
        if(![formatter numberFromString:chapterName]) {
            chapterPrefix = @"";
        }
        
        [formatter release];
               
        if (chapterName) {
            if (pageStr) {
                pageLabel = [NSString stringWithFormat:NSLocalizedString(@"%@%@%@%@%@",@"Page label with page number and chapter (flow view)"), chapterPrefix, chapterName, chapterPageSeparator, pagePrefix, pageStr];
            } else {
                pageLabel = [NSString stringWithFormat:@"%@%@", chapterPrefix, chapterName];
            }
        }
    }
    
    if (!pageLabel) {
        pageLabel = [self.eucBookView  pageDescriptionForPageIndex:pageIndex];
    }     
    
    return pageLabel;
}

#pragma mark - SCHReadingView methods

- (EucSelector *)selector
{
    return self.eucBookView.selector;
}

- (void)setPageTexture:(UIImage *)image isDark:(BOOL)isDark
{
    self.currentPageTexture = image;
    self.textureIsDark = isDark;
    
    [self.eucBookView setPageTexture:image isDark:isDark];
    [self.eucBookView setNeedsDisplay];
}

- (NSUInteger)fontSizeIndex
{
    // N.B. It should be possible to read actualFontSize from self.eucBookView.fontPointSize but it doesn't get updated on a pinch
    // FIXME: once that is fixed remove this hardcoded userDefault lookup

    CGFloat actualFontSize = [[NSUserDefaults standardUserDefaults] floatForKey:@"gs.ingsmadeoutofotherthin.th.libEucalyptus.fontPointSize"];
    CGFloat bestDifference = CGFLOAT_MAX;
    NSUInteger bestFontSizeIndex = 0;
    NSArray *fontSizeNumbers = self.eucBookView.fontPointSizes;
    
    NSUInteger fontSizeCount = fontSizeNumbers.count;
    for(NSUInteger i = 0; i < fontSizeCount; ++i) {
        CGFloat thisDifference = fabsf(((NSNumber *)[fontSizeNumbers objectAtIndex:i]).floatValue - actualFontSize);
        if(thisDifference < bestDifference) {
            bestDifference = thisDifference;
            bestFontSizeIndex = i;
        }
    }
    
    return bestFontSizeIndex;
}

- (void)setFontSizeIndex:(NSUInteger)index
{
    NSArray *eucFontSizeNumbers = self.eucBookView.fontPointSizes;
    
    if (index > ([eucFontSizeNumbers count] - 1)) {
        return;
    }
    
    CGFloat newSize = [[eucFontSizeNumbers objectAtIndex:index] floatValue];
    
    [self.eucBookView highlightWordAtIndexPoint:nil animated:YES];
    [self.eucBookView setFontPointSize:newSize];
}

- (NSInteger)pageCount
{
    return [self.eucBookView pageCount];
}

- (void)refreshHighlightsForPageAtIndex:(NSUInteger)index
{
    // No-op highlights are not supported in flow view in Storia
    //[self.eucBookView refreshHighlights];
}

- (SCHBookRange *)bookRangeFromSelectorRange:(EucSelectorRange *)selectorRange
{
    if (nil == selectorRange) return nil;
    
    EucBookPageIndexPointRange *eucIndexPointRange = [self.eucBookView pageIndexPointRangeFromSelectorRange:selectorRange];

    SCHBookRange *range = [[SCHBookRange alloc] init];
    range.startPoint = [self.eucBook bookPointFromBookPageIndexPoint:eucIndexPointRange.startPoint];
    range.endPoint = [self.eucBook bookPointFromBookPageIndexPoint:eucIndexPointRange.endPoint];    
    
    return [range autorelease];
}

- (CGRect) pageRect
{
//    return eucBookView.contentRect;
    return self.frame;
}

- (UIImage *)pageSnapshot
{
    return [self.eucBookView.pageTurningView screenshot];
}

- (NSString *)wordFromSelection:(EucSelectorRange *)selectorRange
{    
    EucBookPageIndexPointRange *indexPointRange = [self.eucBookView pageIndexPointRangeFromSelectorRange:selectorRange];
    NSString *word = [self.eucBook stringForIndexPointRange:indexPointRange];
    
    return word;
}

#pragma mark - EucSelectorDelegate

- (BOOL)eucSelector:(EucSelector *)selector shouldReceiveTouch:(UITouch *)touch
{
    return [self.eucBookView eucSelector:selector shouldReceiveTouch:touch];
}

#pragma mark - SCHBSBEucBookDelegate

- (void)bookWillShrink:(SCHBSBEucBook *)book
{
    [self.eucBookView bookWillShrink];
}

- (void)book:(SCHBSBEucBook *)book hasShrunkToIndexPoint:(EucBookPageIndexPoint *)indexPoint
{
    [self.eucBookView bookHasShrunkToIndexPoint:indexPoint];
}

- (void)book:(SCHBSBEucBook *)book hasGrownToIndexPoint:(EucBookPageIndexPoint *)indexPoint;
{
    [self.eucBookView bookHasGrown];
    [self jumpToPageAtIndexPoint:indexPoint animated:YES withCompletionHandler:nil];
}

#pragma mark - EucBookViewDelegate Margin Overrides

- (UIEdgeInsets)pageContentInsetsForFontPointSize:(CGFloat)fontPointSize;
{
    CGFloat horizontalMargin;
    CGFloat bottomMargin;
    CGFloat topTitlePadding;
        
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        horizontalMargin = kSCHFlowViewHorizontalMarginPad;
        bottomMargin = kSCHFlowViewBottomMarginPad;
        topTitlePadding = kSCHFlowViewTopTitlePaddingPad;
    } else {
        horizontalMargin = kSCHFlowViewHorizontalMarginPhone;
        bottomMargin = kSCHFlowViewBottomMarginPhone;
        topTitlePadding = kSCHFlowViewTopTitlePaddingPhone;
    }
    
    CGFloat topMargin = fontPointSize * 1.2 + 2*topTitlePadding;
    
    return UIEdgeInsetsMake(topMargin, horizontalMargin, bottomMargin, horizontalMargin);
}

- (CGSize)bookView:(EucBookView *)bookView
pageContentSizeForPageSize:(CGSize)pageSize
     fontPointSize:(CGFloat)fontPointSize
{
    UIEdgeInsets pageContentInsets = [self pageContentInsetsForFontPointSize:fontPointSize];
    
    return CGSizeMake(pageSize.width - pageContentInsets.left - pageContentInsets.right, pageSize.height - pageContentInsets.top - pageContentInsets.bottom);
}

- (CGPoint)bookView:(EucBookView *)bookView
pageContentOriginForPageSize:(CGSize)pageSize
      fontPointSize:(CGFloat)fontPointSize
          placement:(EucBookIndexPointPlacement)placement
{
    UIEdgeInsets pageContentInsets = [self pageContentInsetsForFontPointSize:fontPointSize];
    return CGPointMake(pageContentInsets.left, pageContentInsets.top);
}

- (CGFloat)bookView:(EucBookView *)bookView
pageTitleOffsetForPageSize:(CGSize)pageSize
      fontPointSize:(CGFloat)fontPointSize
{
    CGFloat topTitlePadding;
    
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
        topTitlePadding = kSCHFlowViewTopTitlePaddingPad;
    } else {
        topTitlePadding = kSCHFlowViewTopTitlePaddingPhone;
    }
    
    return fontPointSize * 1.2 + topTitlePadding;
}

@end