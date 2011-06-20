    //
//  SCHLayoutView.m
//  Scholastic
//
//  Created by Matt Farrugia on 23/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHLayoutView.h"
#import "SCHXPSProvider.h"
#import "SCHSmartZoomBlockSource.h"
#import "SCHBookManager.h"
#import "SCHBookRange.h"
#import "SCHTextFlow.h"
#import "SCHAppBook.h"
#import "KNFBSmartZoomBlock.h"
#import "KNFBTextFlowBlock.h"
#import "KNFBTextFlowPositionedWord.h"
#import <libEucalyptus/THPositionedCGContext.h>
#import <libEucalyptus/EucSelector.h>
#import <libEucalyptus/EucSelectorRange.h>
#import <libEucalyptus/THPair.h>

#define LAYOUT_LHSHOTZONE 0.25f
#define LAYOUT_RHSHOTZONE 0.75f

#define LAYOUT_LANDSCAPE_PAGE_EDGE_COUNT 3

@interface SCHLayoutView() <EucSelectorDataSource>

@property (nonatomic, retain) EucPageTurningView *pageTurningView;
@property (nonatomic, assign) NSUInteger pageCount;
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, assign) CGRect firstPageCrop;
@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, retain) NSMutableDictionary *pageCropsCache;
@property (nonatomic, retain) NSLock *layoutCacheLock;
@property (nonatomic, retain) SCHSmartZoomBlockSource *blockSource;
@property (nonatomic, retain) id currentBlock;
@property (nonatomic, assign) BOOL smartZoomActive;
@property (nonatomic, retain) EucSelector *selector;
@property (nonatomic, retain) SCHBookRange *temporaryHighlightRange;
@property (nonatomic, retain) EucSelectorRange *currentSelectorRange;

- (void)initialiseView;
- (CGRect)cropForPage:(NSInteger)page allowEstimate:(BOOL)estimate;
- (void)jumpToZoomBlock:(id)zoomBlock;
- (void)registerGesturesForPageTurningView:(EucPageTurningView *)aPageTurningView;
- (void)zoomToCurrentBlock;
- (void)zoomOutToCurrentPage;
- (void)zoomAtPoint:(CGPoint)point ;

- (NSArray *)highlightRangesForCurrentPage;
- (NSArray *)highlightRectsForPageAtIndex:(NSInteger)pageIndex excluding:(SCHBookRange *)excludedBookmark;
- (NSArray *)rectsFromBlocksAtPageIndex:(NSInteger)pageIndex inBookRange:(SCHBookRange *)bookRange;

- (CGPoint)translationToFitRect:(CGRect)aRect onPageAtIndex:(NSUInteger)pageIndex zoomScale:(CGFloat *)scale;
- (CGAffineTransform)pageTurningViewTransformForPageAtIndex:(NSInteger)pageIndex;
- (CGAffineTransform)pageTurningViewTransformForPageAtIndex:(NSInteger)pageIndex offsetOrigin:(BOOL)offset applyZoom:(BOOL)applyZoom;

@end

@implementation SCHLayoutView

@synthesize pageTurningView;
@synthesize pageCount;
@synthesize currentPageIndex;
@synthesize firstPageCrop;
@synthesize pageSize;
@synthesize pageCropsCache;
@synthesize layoutCacheLock;
@synthesize blockSource;
@synthesize currentBlock;
@synthesize smartZoomActive;
@synthesize selector;
@synthesize temporaryHighlightRange;
@synthesize currentSelectorRange;

- (void)dealloc
{
    if (blockSource) {
        [[SCHBookManager sharedBookManager] checkInBlockSourceForBookIdentifier:self.isbn];
        [blockSource release], blockSource = nil;
    }
    
    [pageTurningView release], pageTurningView = nil;
    [pageCropsCache release], pageCropsCache = nil;
    [layoutCacheLock release], layoutCacheLock = nil;
    [currentBlock release], currentBlock = nil;
    [temporaryHighlightRange release], temporaryHighlightRange = nil;
    [currentSelectorRange release], currentSelectorRange = nil;
    
    [super dealloc];
}

- (void)initialiseView
{
    if (self.xpsProvider) {
        layoutCacheLock = [[NSLock alloc] init];
        
        pageCount = [self.xpsProvider pageCount];
        firstPageCrop = [self cropForPage:1 allowEstimate:NO];
        
        pageTurningView = [[EucPageTurningView alloc] initWithFrame:self.bounds];
        pageTurningView.delegate = self;
        pageTurningView.bitmapDataSource = self;
        pageTurningView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        pageTurningView.zoomHandlingKind = EucPageTurningViewZoomHandlingKindZoom;
        pageTurningView.vibratesOnInvalidTurn = NO;
        
        // Must do this here so that the page aspect ratio takes account of the twoUp property
        CGRect myBounds = self.bounds;
        if(myBounds.size.width > myBounds.size.height) {
            pageTurningView.twoUp = YES;
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                pageTurningView.potentiallyVisiblePageEdgeCount = LAYOUT_LANDSCAPE_PAGE_EDGE_COUNT;
            } else {
                pageTurningView.potentiallyVisiblePageEdgeCount = 0;
            }
        } else {
            pageTurningView.twoUp = NO;
            pageTurningView.potentiallyVisiblePageEdgeCount = 0;
        } 
        
        if (CGRectEqualToRect(firstPageCrop, CGRectZero)) {
            [pageTurningView setPageAspectRatio:0];
        } else {
            [pageTurningView setPageAspectRatio:firstPageCrop.size.width/firstPageCrop.size.height];
        }
        
        [self addSubview:pageTurningView];
        
        [pageTurningView setPageTexture:[UIImage imageNamed: @"paper-white.png"] isDark:NO];
        [pageTurningView turnToPageAtIndex:0 animated:NO];
       // [pageTurningView waitForAllPageImagesToBeAvailable];
        
        [self registerGesturesForPageTurningView:pageTurningView];
        
        selector = [[EucSelector alloc] init];
        selector.shouldTrackSingleTapsOnHighights = NO;
        selector.dataSource = self;
        selector.delegate =  self;
        [selector attachToView:self];
        [selector addObserver:self forKeyPath:@"tracking" options:0 context:NULL];
        [selector addObserver:self forKeyPath:@"trackingStage" options:NSKeyValueObservingOptionPrior context:NULL];
        
        blockSource = [[[SCHBookManager sharedBookManager] checkOutBlockSourceForBookIdentifier:self.isbn] retain];
        
    }    
}

- (id)initWithFrame:(CGRect)frame isbn:(id)isbn delegate:(id<SCHReadingViewDelegate>)delegate
{
    self = [super initWithFrame:frame isbn:isbn delegate:delegate];
    if (self) {        
        [self initialiseView];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect myBounds = self.bounds;
    if(myBounds.size.width > myBounds.size.height) {
        self.pageTurningView.twoUp = YES;      
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            pageTurningView.potentiallyVisiblePageEdgeCount = LAYOUT_LANDSCAPE_PAGE_EDGE_COUNT;
        } else {
            pageTurningView.potentiallyVisiblePageEdgeCount = 0;
        }
    } else {
        self.pageTurningView.twoUp = NO;
        self.pageTurningView.potentiallyVisiblePageEdgeCount = 0;
    }   
    [super layoutSubviews];
    CGSize newSize = self.bounds.size;
    
    if(!CGSizeEqualToSize(newSize, self.pageSize)) {
        
        if(self.selector.tracking) {
            [self.selector setSelectedRange:nil];
        }
        
		self.pageSize = newSize;
        // Perform this after a delay in order to give time for layoutSubviews 
        // to be called on the pageTurningView before we start the zoom
        // (Ick!).
        [self performSelector:@selector(zoomForNewPageAnimatedWithNumberThunk:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.0f];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        if (selector) {
            [selector removeObserver:self forKeyPath:@"tracking"];
            [selector removeObserver:self forKeyPath:@"trackingStage"];
            [selector detatch];
            [selector release], selector = nil;
        }
    }
}

- (void)setCurrentPageIndex:(NSUInteger)newPageIndex
{
    currentPageIndex = newPageIndex;
    [self.delegate readingView:self hasMovedToPageAtIndex:currentPageIndex];
}

- (void)jumpToZoomBlock:(id)zoomBlock
{
    
}

- (void)didEnterSmartZoomMode
{
    self.smartZoomActive = YES;
    [self jumpToNextZoomBlock];
}

- (void)didExitSmartZoomMode
{
    self.smartZoomActive = NO;
    self.currentBlock = nil;
    [self zoomOutToCurrentPage];
}


- (void)zoomForNewPageAnimated:(BOOL)animated
{
	EucPageTurningView *myPageTurningView = self.pageTurningView;
    CGRect bounds = myPageTurningView.bounds;
    
    BOOL viewIsLandscape = bounds.size.width > bounds.size.height;
    
    CGFloat zoomFactor;
	
	if(!viewIsLandscape || myPageTurningView.isTwoUp) {
        zoomFactor = 1.0f;
    } else {
        zoomFactor = myPageTurningView.fitToBoundsZoomFactor;
    }
	
	myPageTurningView.minZoomFactor = zoomFactor;
	
    CGPoint offset = CGPointMake(0, CGRectGetMidY(bounds) * zoomFactor); 
	[myPageTurningView setTranslation:offset zoomFactor:zoomFactor animated:animated];
}

- (void)zoomForNewPageAnimatedWithNumberThunk:(NSNumber *)number
{
    [self zoomForNewPageAnimated:[number boolValue]];
}

- (void)createLayoutCacheForPage:(NSInteger)page {
    // N.B. please ensure this is only called with a [layoutCacheLock lock] acquired
    if (nil == self.pageCropsCache) {
        self.pageCropsCache = [NSMutableDictionary dictionaryWithCapacity:pageCount];
    }
      
    CGRect cropRect = [self.xpsProvider cropRectForPage:page];
    if (!CGRectEqualToRect(cropRect, CGRectZero)) {
        [self.pageCropsCache setObject:[NSValue valueWithCGRect:cropRect] forKey:[NSNumber numberWithInt:page]];
    }
}

- (CGRect)cropForPage:(NSInteger)page allowEstimate:(BOOL)estimate {
    
    if (estimate) {
        return firstPageCrop;
    }
    
    [layoutCacheLock lock];
    
    NSValue *pageCropValue = [self.pageCropsCache objectForKey:[NSNumber numberWithInt:page]];
    
    if (nil == pageCropValue) {
        [self createLayoutCacheForPage:page];
        pageCropValue = [self.pageCropsCache objectForKey:[NSNumber numberWithInt:page]];
    }
    
    [layoutCacheLock unlock];
    
    if (pageCropValue) {
        CGRect cropRect = [pageCropValue CGRectValue];
        return cropRect;
    }
    
    return CGRectZero;
}

- (CGRect)cropForPage:(NSInteger)page {
    return [self cropForPage:page allowEstimate:NO];
}

- (NSString *)pageTurningViewAccessibilityPageDescriptionForPagesAtIndexes:(NSArray *)pageIndexes
{ 
    return nil;
}

#pragma mark - SCHReadingView methods

- (SCHBookPoint *)currentBookPoint {
    SCHBookPoint *ret = [[SCHBookPoint alloc] init];
    ret.layoutPage = MAX(self.currentPageIndex + 1, 1);
    return [ret autorelease];
}

- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated
{
    [self jumpToPageAtIndex:bookPoint.layoutPage - 1 animated:animated];
}

- (void)jumpToPageAtIndex:(NSUInteger)pageIndex animated: (BOOL) animated
{	
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self jumpToPageAtIndex:pageIndex animated:animated];
        });
        
        return;
    }
        
	if (pageIndex < pageCount) {
        [self.pageTurningView turnToPageAtIndex:pageIndex animated:animated];
	}
    
    if (!animated) {
        self.currentPageIndex = self.pageTurningView.focusedPageIndex;
    }
    
    self.currentBlock = nil;
}

- (void)jumpToProgressPositionInBook:(CGFloat)progress animated:(BOOL)animated
{
    NSLog(@"WARNING: jumpToProgressPositionInBook should not be called on Layout View.");
}

- (void)setPageTexture:(UIImage *)image isDark:(BOOL)isDark
{
    [self.pageTurningView setPageTexture:image isDark:isDark];
    [self.pageTurningView setNeedsDraw];
}

- (void)jumpToNextZoomBlock
{
    id zoomBlock = nil;
    
    if (self.currentBlock) {
        zoomBlock = [self.blockSource nextZoomBlockForZoomBlock:self.currentBlock onSamePage:NO];
    } else {
        zoomBlock = [self.blockSource firstZoomBlockFromPageAtIndex:self.currentPageIndex];
    }
    
    NSLog(@"next zoomBlock: %@", zoomBlock);

    self.currentBlock = zoomBlock;
    
    if (zoomBlock) {
        [self zoomToCurrentBlock];
    } else {
        [self zoomOutToCurrentPage];
    }
}

- (void)jumpToPreviousZoomBlock
{
    id zoomBlock = nil;
    
    if (self.currentBlock) {
        zoomBlock = [self.blockSource previousZoomBlockForZoomBlock:self.currentBlock onSamePage:NO];
    } else {
        zoomBlock = [self.blockSource firstZoomBlockFromPageAtIndex:self.currentPageIndex];
    }
    
    NSLog(@"prev zoomBlock: %@", zoomBlock);

    self.currentBlock = zoomBlock;
    
    if (zoomBlock) {
        [self zoomToCurrentBlock];
    } else {
        [self zoomOutToCurrentPage];
    }
}

- (void)zoomOutToCurrentPage
{
    EucPageTurningView *myPageTurningView = self.pageTurningView;
    CGRect bounds = myPageTurningView.bounds;
    
    BOOL viewIsLandscape = bounds.size.width > bounds.size.height;
    
    CGFloat zoomFactor;
	
	if(!viewIsLandscape || myPageTurningView.isTwoUp) {
        zoomFactor = 1.0f;
    } else {
        zoomFactor = myPageTurningView.fitToBoundsZoomFactor;
    }
	
	myPageTurningView.minZoomFactor = zoomFactor;
	
    CGPoint offset = CGPointMake(0, CGRectGetMidY(bounds) * zoomFactor); 
	[myPageTurningView setTranslation:offset zoomFactor:zoomFactor animated:YES];
}

- (void)zoomToCurrentBlock {
	
    NSUInteger pageIndex = [self.currentBlock pageIndex];
    CGRect targetRect = [self.currentBlock rect];
    	
	CGFloat zoomScale;
	CGPoint translation = [self translationToFitRect:targetRect onPageAtIndex:pageIndex zoomScale:&zoomScale];
	
    if (pageIndex != self.currentPageIndex) {
        if (self.pageTurningView.isTwoUp) {
            if ((self.pageTurningView.leftPageIndex != pageIndex) && (self.pageTurningView.rightPageIndex != pageIndex)) {
                [self.pageTurningView turnToPageAtIndex:pageIndex animated:YES];
            }
        } else {
            if (self.pageTurningView.rightPageIndex != pageIndex) {
                [self.pageTurningView turnToPageAtIndex:pageIndex animated:YES];
            }
        }
    }
		
    [self.pageTurningView setTranslation:translation zoomFactor:zoomScale animated:YES];

}

- (SCHBookRange *)bookRangeFromSelectorRange:(EucSelectorRange *)selectorRange
{
    if (nil == selectorRange) return nil;
    
    NSInteger startPageIndex   = [KNFBTextFlowBlock pageIndexForBlockID:[selectorRange startBlockId]];
    NSInteger endPageIndex     = [KNFBTextFlowBlock pageIndexForBlockID:[selectorRange endBlockId]];
    NSInteger startBlockOffset = [KNFBTextFlowBlock blockIndexForBlockID:[selectorRange startBlockId]];
    NSInteger endBlockOffset   = [KNFBTextFlowBlock blockIndexForBlockID:[selectorRange endBlockId]];
    NSInteger startWordOffset  = [KNFBTextFlowPositionedWord wordIndexForWordID:[selectorRange startElementId]];
    NSInteger endWordOffset    = [KNFBTextFlowPositionedWord wordIndexForWordID:[selectorRange endElementId]];
    
    SCHBookPoint *startPoint = [[SCHBookPoint alloc] init];
    [startPoint setLayoutPage:startPageIndex + 1];
    [startPoint setBlockOffset:startBlockOffset];
    [startPoint setWordOffset:startWordOffset];
    
    SCHBookPoint *endPoint = [[SCHBookPoint alloc] init];
    [endPoint setLayoutPage:endPageIndex + 1];
    [endPoint setBlockOffset:endBlockOffset];
    [endPoint setWordOffset:endWordOffset];
    
    SCHBookRange *range = [[SCHBookRange alloc] init];
    [range setStartPoint:startPoint];
    [range setEndPoint:endPoint];
    
    [startPoint release];
    [endPoint release];
    
    return [range autorelease];
}

- (NSString *)displayPageNumberForBookPoint:(SCHBookPoint *)bookPoint
{    
    NSUInteger pageIndex = MAX(bookPoint.layoutPage, 1) - 1;
    return [self.textFlow contentsTableViewController:nil displayPageNumberForPageIndex:pageIndex];
}

#pragma mark -
#pragma mark EucPageTurningViewBitmapDataSource

- (CGRect)pageTurningView:(EucPageTurningView *)aPageTurningView contentRectForPageAtIndex:(NSUInteger)index 
{
    return [self cropForPage:index + 1];
}

- (THPositionedCGContext *)pageTurningView:(EucPageTurningView *)aPageTurningView 
           RGBABitmapContextForPageAtIndex:(NSUInteger)index
                                  fromRect:(CGRect)rect 
                                    atSize:(CGSize)size {
        
    if (index == NSUIntegerMax)
    {
        return nil;
    }
    
    id backing = nil;

    CGContextRef CGContext = [self.xpsProvider RGBABitmapContextForPage:index + 1
                                                              fromRect:rect 
                                                                atSize:size
                                                            getBacking:&backing];
    
    return [[[THPositionedCGContext alloc] initWithCGContext:CGContext backing:backing] autorelease];
}

- (UIImage *)pageTurningView:(EucPageTurningView *)aPageTurningView 
   fastUIImageForPageAtIndex:(NSUInteger)index
{
    return [self.xpsProvider thumbnailForPage:index + 1];
}

- (NSArray *)pageTurningView:(EucPageTurningView *)pageTurningView highlightsForPageAtIndex:(NSUInteger)pageIndex
{
    
    EucSelectorRange *selectedRange = [self.selector selectedRange];
    NSArray *excludedRanges = [self bookRangesFromSelectorRange:selectedRange];
    
    // MATT FIXME
    return [self highlightRectsForPageAtIndex:pageIndex excluding:[excludedRanges lastObject]];
}

- (NSUInteger)pageTurningView:(EucPageTurningView *)pageTurningView pageCountBeforePageAtIndex:(NSUInteger)pageIndex
{
    return pageIndex;    
}

- (NSUInteger)pageTurningView:(EucPageTurningView *)pageTurningView pageCountAfterPageAtIndex:(NSUInteger)pageIndex
{
    return self.pageCount - pageIndex - 1;
}

#pragma mark - EucPageTurningViewDelegate

- (void)pageTurningViewWillBeginPageTurn:(EucPageTurningView *)pageTurningView
{
    [self.delegate readingViewFixedViewWillBeginTurning:self];
}

- (void)pageTurningViewDidEndPageTurn:(EucPageTurningView *)aPageTurningView
{
    self.currentPageIndex = aPageTurningView.focusedPageIndex;
}

- (void)pageTurningViewWillBeginAnimating:(EucPageTurningView *)aPageTurningView
{
    self.selector.selectionDisabled = YES;
    [self dismissFollowAlongHighlighter];
}

- (void)pageTurningViewDidEndAnimation:(EucPageTurningView *)aPageTurningView
{
    
    self.selector.selectionDisabled = NO;
    
    if(self.temporaryHighlightRange) {
		NSInteger targetIndex = self.temporaryHighlightRange.startPoint.layoutPage - 1;
		
        if((self.pageTurningView.leftPageIndex == targetIndex) || (self.pageTurningView.rightPageIndex == targetIndex)) {
            EucSelectorRange *range = [self selectorRangeFromBookRange:self.temporaryHighlightRange];
			[self.selector temporarilyHighlightSelectorRange:range animated:YES];
        }
        
		self.temporaryHighlightRange = nil;
    }
}

- (void)pageTurningViewWillBeginZooming:(EucPageTurningView *)scrollView 
{
    // Would be nice to just hide the menu and redisplay the range after every 
    // zoom step, but it's far too slow, so we just disable selection while 
    // zooming is going on.
    //[self.selector setShouldHideMenu:YES];
    [self.selector setSelectionDisabled:YES];
    [self dismissFollowAlongHighlighter];
	self.temporaryHighlightRange = nil;
	
}

- (void)pageTurningViewDidEndZooming:(EucPageTurningView *)scrollView 
{
    // See comment in pageTurningViewWillBeginZooming: about disabling selection
    // during zoom.
    // [self.selector setShouldHideMenu:NO];
    [self.selector setSelectionDisabled:NO];
}

#pragma mark - Touch handling

- (void)registerGesturesForPageTurningView:(EucPageTurningView *)aPageTurningView;
{    
    UITapGestureRecognizer *doubleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTap.numberOfTapsRequired = 2;
    [aPageTurningView addGestureRecognizer:doubleTap];
   
    [aPageTurningView.tapGestureRecognizer removeTarget:nil action:nil]; 
    [aPageTurningView.tapGestureRecognizer addTarget:self action:@selector(handleSingleTap:)];
   
    [aPageTurningView.tapGestureRecognizer requireGestureRecognizerToFail:doubleTap];

    aPageTurningView.tapGestureRecognizer.cancelsTouchesInView = NO;
    
    [doubleTap release];
}

- (void)handleSingleTap:(UITapGestureRecognizer *)sender 
{     
    if (sender.state == UIGestureRecognizerStateEnded) {
        CGPoint point = [sender locationInView:self];
        
        CGFloat screenWidth = CGRectGetWidth(self.bounds);
        CGFloat leftHandHotZone = screenWidth * LAYOUT_LHSHOTZONE;
        CGFloat rightHandHotZone = screenWidth * LAYOUT_RHSHOTZONE;
                
        if (point.x <= leftHandHotZone) {
            if (self.smartZoomActive) {
                [self jumpToPreviousZoomBlock];
            } else {
                if (self.pageTurningView.isTwoUp) {
                    [self jumpToPageAtIndex:self.pageTurningView.leftPageIndex - 1 animated:YES];
                } else {
                    [self jumpToPageAtIndex:self.pageTurningView.rightPageIndex - 1 animated:YES];
                }
            }
            [self.delegate hideToolbars];
        } else if (point.x >= rightHandHotZone) {
            if (self.smartZoomActive) {
                [self jumpToNextZoomBlock];
            } else {
                [self jumpToPageAtIndex:self.pageTurningView.rightPageIndex + 1 animated:YES];
            }
            [self.delegate hideToolbars];
        } else {
            [self.delegate toggleToolbars];
        }
    }
    
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)sender 
{     
    if ((sender.state == UIGestureRecognizerStateEnded) && 
        !self.pageTurningView.animating)
    {
        [self zoomAtPoint:[sender locationInView:self]];
        [self.delegate hideToolbars];
    } else {
        [self.delegate toggleToolbars]; 
    }
}

- (void)zoomAtPoint:(CGPoint)point 
{
    EucPageTurningView *myPageTurningView = self.pageTurningView;
    
    CGFloat currentZoomFactor = myPageTurningView.zoomFactor;
    CGFloat minZoomFactor = myPageTurningView.fitToBoundsZoomFactor;
    CGFloat doubleFitToBoundsZoomFactor = minZoomFactor * 2;

    if (currentZoomFactor < doubleFitToBoundsZoomFactor) {
        CGPoint offset = CGPointMake((CGRectGetMidX(myPageTurningView.bounds) - point.x) * doubleFitToBoundsZoomFactor, (CGRectGetMidY(myPageTurningView.bounds) - point.y) * doubleFitToBoundsZoomFactor); 
            [myPageTurningView setTranslation:offset zoomFactor:doubleFitToBoundsZoomFactor animated:YES];
    } else {
        [self zoomOutToCurrentPage];
    }
 
}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if(self.selector) {
        [self.selector removeObserver:self forKeyPath:@"tracking"];
        [self.selector removeObserver:self forKeyPath:@"trackingStage"];
        [self.selector detatch];
        self.selector = nil;
    }
	self.temporaryHighlightRange = nil;
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    selector = [[EucSelector alloc] init];
    selector.shouldTrackSingleTapsOnHighights = NO;
    selector.dataSource = self;
    selector.delegate =  self;
    [selector attachToView:self];
    [selector addObserver:self forKeyPath:@"tracking" options:0 context:NULL];
    [selector addObserver:self forKeyPath:@"trackingStage" options:0 context:NULL];
}

#pragma mark - Highlights

- (void)refreshHighlightsForPageAtIndex:(NSUInteger)index
{
    [self.pageTurningView refreshHighlightsForPageAtIndex:index];
    [self.pageTurningView setNeedsDraw];
}

- (NSArray *)highlightRangesForCurrentPage {
	NSUInteger startPageIndex = self.pageTurningView.leftPageIndex;
    NSUInteger endPageIndex = self.pageTurningView.rightPageIndex;
    if(startPageIndex == NSUIntegerMax) {
        startPageIndex = endPageIndex;
    } 
    if(endPageIndex == NSUIntegerMax) {
        endPageIndex = startPageIndex;
    }
    
    NSMutableArray *allHighlights = [NSMutableArray array];
    
    for (int i = startPageIndex; i <= endPageIndex; i++) {
        NSArray *highlightRanges = [self highlightsForLayoutPage:i + 1];
        [allHighlights addObjectsFromArray:highlightRanges];
    }
    
    return allHighlights;
}

- (NSArray *)highlightRectsForPageAtIndex:(NSInteger)pageIndex excluding:(SCHBookRange *)excludedBookmark {
    NSMutableArray *allHighlights = [NSMutableArray array];
    
    NSArray *highlightRanges = [self highlightsForLayoutPage:pageIndex + 1];
    UIColor *highlightColor = [self.delegate highlightColor];
    
    for (SCHBookRange *highlightRange in highlightRanges) {
        
        if (![highlightRange isEqual:excludedBookmark]) {
			
			NSAutoreleasePool *pool = [[NSAutoreleasePool alloc] init];
			
			NSArray *highlightRects = [self rectsFromBlocksAtPageIndex:pageIndex inBookRange:highlightRange];
            NSArray *coalescedRects = [EucSelector coalescedLineRectsForElementRects:highlightRects];
            
            for (NSValue *rectValue in coalescedRects) {
                THPair *highlightPair = [[THPair alloc] initWithFirst:(id)rectValue second:(id)highlightColor];
                [allHighlights addObject:highlightPair];
                [highlightPair release];
            }
            
            [pool drain];
        }
        
    }
    
    return allHighlights;
}

- (NSArray *)rectsFromBlocksAtPageIndex:(NSInteger)pageIndex inBookRange:(SCHBookRange *)bookRange {
	NSMutableArray *rects = [[NSMutableArray alloc] init];
	
	NSArray *pageBlocks = [self.textFlow blocksForPageAtIndex:pageIndex includingFolioBlocks:NO];
	
	CGAffineTransform  pageTransform = [self pageTurningViewTransformForPageAtIndex:pageIndex offsetOrigin:NO applyZoom:NO];
    
	for (KNFBTextFlowBlock *block in pageBlocks) {                
		for (KNFBTextFlowPositionedWord *word in [block words]) {
			// If the range starts before this word:
			if ( bookRange.startPoint.layoutPage < (pageIndex + 1) ||
				((bookRange.startPoint.layoutPage == (pageIndex + 1)) && (bookRange.startPoint.blockOffset < block.blockIndex)) ||
				((bookRange.startPoint.layoutPage == (pageIndex + 1)) && (bookRange.startPoint.blockOffset == block.blockIndex) && (bookRange.startPoint.wordOffset <= word.wordIndex)) ) {
				// If the range ends after this word:
				if ( bookRange.endPoint.layoutPage > (pageIndex +1 ) ||
					((bookRange.endPoint.layoutPage == (pageIndex + 1)) && (bookRange.endPoint.blockOffset > block.blockIndex)) ||
					((bookRange.endPoint.layoutPage == (pageIndex + 1)) && (bookRange.endPoint.blockOffset == block.blockIndex) && (bookRange.endPoint.wordOffset >= word.wordIndex)) ) {
					// This word is in the range.
					CGRect pageRect = CGRectApplyAffineTransform([word rect], pageTransform);
					[rects addObject:[NSValue valueWithCGRect:pageRect]];
					
				}                            
			}
		}
	}
	
	return [rects autorelease];
	
}

- (void)dismissFollowAlongHighlighter
{
    [self.selector removeTemporaryHighlight];
}

- (void)followAlongHighlightWordAtPoint:(SCHBookPoint *)bookPoint
{
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self followAlongHighlightWordAtPoint:bookPoint];
        });
        
        return;
    }
    
    SCHBookRange *highlightRange = [[[SCHBookRange alloc] init] autorelease];
    highlightRange.startPoint = bookPoint;
    highlightRange.endPoint   = bookPoint;
	
    if (bookPoint && ![self.pageTurningView isAnimating]) {
		BOOL pageIsVisible = YES;
		NSInteger targetIndex = bookPoint.layoutPage - 1;
		
        if ((self.pageTurningView.leftPageIndex != targetIndex) && (self.pageTurningView.rightPageIndex != targetIndex)) {
            pageIsVisible = NO;
        }
        		
        if (!pageIsVisible) {
            [self dismissFollowAlongHighlighter];
            [self jumpToPageAtIndex:targetIndex animated:YES];
        } else {        
            CGAffineTransform viewTransform = [self pageTurningViewTransformForPageAtIndex:targetIndex offsetOrigin:YES applyZoom:YES];
            CGRect visibleRect = CGRectApplyAffineTransform(self.pageTurningView.bounds, CGAffineTransformInvert(viewTransform));
			CGRect boundingRect = CGRectNull;
			
			CGAffineTransform  pageTransform = [self pageTurningViewTransformForPageAtIndex:targetIndex offsetOrigin:NO applyZoom:NO];
            
			NSArray *rectValues = [self rectsFromBlocksAtPageIndex:targetIndex inBookRange:highlightRange];
            
			for (NSValue *rectValue in rectValues) {
				CGRect rect = CGRectApplyAffineTransform([rectValue CGRectValue], CGAffineTransformInvert(pageTransform));
				boundingRect = CGRectUnion(boundingRect, rect);
			}
            
			if (!CGRectEqualToRect(CGRectIntegral(CGRectIntersection(visibleRect, boundingRect)), CGRectIntegral(boundingRect))) {
				
				[self zoomOutToCurrentPage];
			}
			
			EucSelectorRange *range = [self selectorRangeFromBookRange:highlightRange];
			[self.selector temporarilyHighlightSelectorRange:range animated:YES];
		}
    } else {
        [self dismissFollowAlongHighlighter];
    }
}

#pragma mark - EucSelectorDataSource

- (NSArray *)blockIdentifiersForEucSelector:(EucSelector *)selector
{
    NSMutableArray *pagesBlocks = [NSMutableArray array];
    
    if (self.pageTurningView.isTwoUp) {
        NSInteger leftPageIndex = [self.pageTurningView leftPageIndex];
        if (leftPageIndex >= 0) {
            [pagesBlocks addObjectsFromArray:[self.textFlow blocksForPageAtIndex:leftPageIndex includingFolioBlocks:NO]];
        }
    }
    
    NSInteger rightPageIndex = [self.pageTurningView rightPageIndex];
    if (rightPageIndex < pageCount) {
        [pagesBlocks addObjectsFromArray:[self.textFlow blocksForPageAtIndex:rightPageIndex includingFolioBlocks:NO]];
    }
    
    return [pagesBlocks valueForKey:@"blockID"];
}

- (CGRect)eucSelector:(EucSelector *)selector frameOfBlockWithIdentifier:(id)blockID
{
    NSInteger pageIndex = [KNFBTextFlowBlock pageIndexForBlockID:blockID];
    
    KNFBTextFlowBlock *block = nil;
    // We say "YES" to includingFolioBlocks here because we know that we're not going
    // to be asked about a folio block anyway, and getting all the blocks is more
    // efficient than getting just the non-folio blocks. 
    for (KNFBTextFlowBlock *candidateBlock in [self.textFlow blocksForPageAtIndex:pageIndex includingFolioBlocks:YES]) {
        if (candidateBlock.blockID == blockID) {
            block = candidateBlock;
            break;
        }
    }
    
    CGAffineTransform viewTransform = [self pageTurningViewTransformForPageAtIndex:pageIndex];
    return block ? CGRectApplyAffineTransform([block rect], viewTransform) : CGRectZero;
}

- (NSArray *)eucSelector:(EucSelector *)selector identifiersForElementsOfBlockWithIdentifier:(id)blockId
{
    NSInteger pageIndex = [KNFBTextFlowBlock pageIndexForBlockID:blockId];
    
    KNFBTextFlowBlock *block = nil;
    for (KNFBTextFlowBlock *candidateBlock in [self.textFlow blocksForPageAtIndex:pageIndex includingFolioBlocks:YES]) {
        if (candidateBlock.blockID == blockId) {
            block = candidateBlock;
            break;
        }
    }
    
    if (block) {
        NSArray *words = [block words];
        if (words.count) {
            return [words valueForKey:@"wordID"];
	    }
    }
    return [NSArray array];
}

- (NSArray *)eucSelector:(EucSelector *)selector rectsForElementWithIdentifier:(id)elementId ofBlockWithIdentifier:(id)blockId
{
    NSInteger pageIndex = [KNFBTextFlowBlock pageIndexForBlockID:blockId];
    
    KNFBTextFlowBlock *block = nil;
    for (KNFBTextFlowBlock *candidateBlock in [self.textFlow blocksForPageAtIndex:pageIndex includingFolioBlocks:YES]) {
        if (candidateBlock.blockID == blockId) {
            block = candidateBlock;
            break;
        }
    }
    
    if (block) {
        KNFBTextFlowPositionedWord *word = nil;
        for (KNFBTextFlowPositionedWord *candidateWord in [block words]) {
            if([[candidateWord wordID] isEqual:elementId]) {
                word = candidateWord;
                break;
            }
        }        
        if (word) {
            CGAffineTransform viewTransform = [self pageTurningViewTransformForPageAtIndex:pageIndex];
            CGRect wordRect = [[[block words] objectAtIndex:[elementId integerValue]] rect];            
            return [NSArray arrayWithObject:[NSValue valueWithCGRect:CGRectApplyAffineTransform(wordRect, viewTransform)]];
        }
    } 
    return [NSArray array];
}

- (NSString *)eucSelector:(EucSelector *)selector accessibilityLabelForElementWithIdentifier:(id)elementId ofBlockWithIdentifier:(id)blockId
{
    return @"";
}

- (UIImage *)viewSnapshotImageForEucSelector:(EucSelector *)selector
{
    return [self.pageTurningView screenshot];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if(object == self.selector) {
       if ([keyPath isEqualToString:@"tracking"]) {
           self.pageTurningView.userInteractionEnabled = !((EucSelector *)object).isTracking;
       }
    }
}

#pragma mark - View Geometry

CGAffineTransform transformRectToFitRect(CGRect sourceRect, CGRect targetRect, BOOL preserveAspect) {
    
    CGFloat xScale = targetRect.size.width / sourceRect.size.width;
    CGFloat yScale = targetRect.size.height / sourceRect.size.height;
    
    CGAffineTransform scaleTransform;
    if (preserveAspect) {
        CGFloat scale = xScale < yScale ? xScale : yScale;
        scaleTransform = CGAffineTransformMakeScale(scale, scale);
    } else {
        scaleTransform = CGAffineTransformMakeScale(xScale, yScale);
    } 
    CGRect scaledRect = CGRectApplyAffineTransform(sourceRect, scaleTransform);
    CGFloat xOffset = (targetRect.size.width - scaledRect.size.width);
    CGFloat yOffset = (targetRect.size.height - scaledRect.size.height);
    CGAffineTransform offsetTransform = CGAffineTransformMakeTranslation((targetRect.origin.x - scaledRect.origin.x) + xOffset/2.0f, (targetRect.origin.y - scaledRect.origin.y) + yOffset/2.0f);
    CGAffineTransform transform = CGAffineTransformConcat(scaleTransform, offsetTransform);
    return transform;
}

- (CGPoint)translationToFitRect:(CGRect)aRect onPageAtIndex:(NSUInteger)pageIndex zoomScale:(CGFloat *)scale {
	CGAffineTransform viewTransform = [self pageTurningViewTransformForPageAtIndex:pageIndex offsetOrigin:YES applyZoom:NO];
	
    CGRect targetRect = CGRectApplyAffineTransform(aRect, viewTransform);
    CGRect viewBounds = self.pageTurningView.bounds;
    CGFloat zoomScale = CGRectGetWidth(viewBounds) / CGRectGetWidth(targetRect);
	
    *scale = zoomScale;
    
    CGRect cropRect = [self cropForPage:pageIndex + 1 allowEstimate:YES];
    CGRect pageRect = CGRectApplyAffineTransform(cropRect, viewTransform);
    CGFloat contentOffsetX = roundf( CGRectGetMidX(self.pageTurningView.bounds) - CGRectGetMidX(targetRect));
	CGFloat scaledOffsetX = contentOffsetX * zoomScale;
	
	CGFloat topOfPageOffset = CGRectGetHeight(pageRect)/2.0f;
	CGFloat bottomOfPageOffset = -topOfPageOffset;
	CGFloat rectEdgeOffset;
	CGFloat scaledOffsetY;
	
    
    rectEdgeOffset = bottomOfPageOffset + (CGRectGetHeight(pageRect) - (CGRectGetMaxY(targetRect) - pageRect.origin.y));
    scaledOffsetY = roundf(rectEdgeOffset * zoomScale + CGRectGetMidY(self.pageTurningView.bounds));
	
	return CGPointMake(scaledOffsetX, scaledOffsetY);
}

- (CGAffineTransform)pageTurningViewTransformForPageAtIndex:(NSInteger)pageIndex offsetOrigin:(BOOL)offset applyZoom:(BOOL)applyZoom {
    // TODO: Make sure this is cached in LayoutView or pageTurningView
    CGRect pageCrop = [self pageTurningView:self.pageTurningView contentRectForPageAtIndex:pageIndex];
    CGRect pageFrame;
    
	BOOL isOnRight = YES;
	if (self.pageTurningView.isTwoUp) {
		BOOL rightIsEven = !self.pageTurningView.oddPagesOnRight;
		BOOL indexIsEven = (pageIndex % 2 == 0);
		if (rightIsEven != indexIsEven) {
			isOnRight = NO;
		}
	}
	
	if (isOnRight) {
		if (applyZoom) {
			pageFrame = [self.pageTurningView rightPageFrame];
		} else {
			pageFrame = [self.pageTurningView unzoomedRightPageFrame];
		}
	} else {
		if (applyZoom) {
			pageFrame = [self.pageTurningView leftPageFrame];
		} else {
			pageFrame = [self.pageTurningView unzoomedLeftPageFrame];
		}
    }
    
    if (!offset) {
        pageFrame.origin = CGPointZero;
    }
    
    CGAffineTransform pageTransform = transformRectToFitRect(pageCrop, pageFrame, false);
    
    return pageTransform;
}

- (CGAffineTransform)pageTurningViewTransformForPageAtIndex:(NSInteger)pageIndex {
    return [self pageTurningViewTransformForPageAtIndex:pageIndex offsetOrigin:YES applyZoom:YES];
}

@end
