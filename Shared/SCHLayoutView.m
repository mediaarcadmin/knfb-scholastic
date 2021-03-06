//
//  SCHLayoutView.m
//  Scholastic
//
//  Created by Matt Farrugia on 23/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHLayoutView.h"
#import "SCHXPSProvider.h"
#import "SCHBookManager.h"
#import "SCHBookRange.h"
#import "SCHTextFlow.h"
#import "SCHAppBook.h"
#import "KNFBTextFlowBlock.h"
#import "KNFBTextFlowPositionedWord.h"
#import <libEucalyptus/THPositionedCGContext.h>
#import <libEucalyptus/EucSelector.h>
#import <libEucalyptus/EucSelectorRange.h>
#import <libEucalyptus/THPair.h>

#define LAYOUT_LANDSCAPE_PAGE_EDGE_COUNT 3

static const NSUInteger kSCHLayoutViewPageViewCacheLimit = 2;

@interface SCHLayoutView() <EucSelectorDataSource>

@property (nonatomic, retain) EucIndexBasedPageTurningView *pageTurningView;
@property (nonatomic, assign) NSUInteger pageCount;
@property (nonatomic, assign) NSUInteger currentPageIndex;
@property (nonatomic, assign) CGRect firstPageCrop;
@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, retain) NSMutableDictionary *pageCropsCache;
@property (nonatomic, retain) NSLock *layoutCacheLock;
@property (nonatomic, retain) EucSelector *selector;
@property (nonatomic, retain) SCHBookRange *temporaryHighlightRange;
@property (nonatomic, retain) EucSelectorRange *currentSelectorRange;
@property (nonatomic, copy) dispatch_block_t zoomCompletionHandler;
@property (nonatomic, copy) dispatch_block_t jumpToPageCompletionHandler;
@property (nonatomic, assign) BOOL suppressZoomingCallback;
@property (nonatomic, retain) SCHBookPoint *openingPoint;
@property (nonatomic, retain) NSCache *generatedPageViewsCache;
@property (nonatomic, retain) NSLock *pageViewsCacheLock;
@property (nonatomic, assign) BOOL twoUp;

- (void)initialiseView;

- (CGRect)cropForPage:(NSInteger)page allowEstimate:(BOOL)estimate;
- (void)jumpToZoomBlock:(id)zoomBlock;
- (void)zoomOutToCurrentPage;

- (NSArray *)highlightRangesForCurrentPage;
- (NSArray *)highlightRectsForPageAtIndex:(NSInteger)pageIndex excluding:(SCHBookRange *)excludedBookmark;
- (NSArray *)rectsFromBlocksAtPageIndex:(NSInteger)pageIndex inBookRange:(SCHBookRange *)bookRange;

- (CGPoint)translationToFitRect:(CGRect)aRect onPageAtIndex:(NSUInteger)pageIndex zoomScale:(CGFloat *)scale;
- (CGAffineTransform)pageTurningViewTransformForPageAtIndex:(NSInteger)pageIndex offsetOrigin:(BOOL)offset applyZoom:(BOOL)applyZoom;

- (void)updateCurrentPageIndex;
- (BOOL)pageAtIndexIsOnRight:(NSUInteger)pageIndex;

- (UIView *)createGeneratedPageViewForPageAtIndex:(NSInteger)pageIndex;
- (UIView *)generatedViewForPageAtIndex:(NSInteger)pageIndex;

- (NSUInteger)generatedPageCount;

@end

@implementation SCHLayoutView

@synthesize pageTurningView;
@synthesize pageCount;
@synthesize currentPageIndex;
@synthesize firstPageCrop;
@synthesize pageSize;
@synthesize pageCropsCache;
@synthesize layoutCacheLock;
@synthesize selector;
@synthesize temporaryHighlightRange;
@synthesize currentSelectorRange;
@synthesize zoomCompletionHandler;
@synthesize jumpToPageCompletionHandler;
@synthesize suppressZoomingCallback;
@synthesize openingPoint;
@synthesize generatedPageViewsCache; // Lazily instantiated;
@synthesize pageViewsCacheLock;
@synthesize twoUp;

- (void)dealloc
{
    // In case the pageTurningView is kept around for texture generation completeion - nil dangling pointers
    [pageTurningView setDelegate:nil]; 
    [pageTurningView setIndexBasedDataSource:nil];

    [pageTurningView release], pageTurningView = nil;
    [pageCropsCache release], pageCropsCache = nil;
    [layoutCacheLock release], layoutCacheLock = nil;
    [temporaryHighlightRange release], temporaryHighlightRange = nil;
    [currentSelectorRange release], currentSelectorRange = nil;
    [zoomCompletionHandler release], zoomCompletionHandler = nil;
    [jumpToPageCompletionHandler release], jumpToPageCompletionHandler = nil;
    [openingPoint release], openingPoint = nil;
    [generatedPageViewsCache release], generatedPageViewsCache = nil;
    [pageViewsCacheLock release], pageViewsCacheLock = nil;
    
    [super dealloc];
}

- (void)initialiseView
{
    if (self.xpsProvider) {
        layoutCacheLock = [[NSLock alloc] init];
        pageViewsCacheLock = [[NSLock alloc] init];
        
        pageCount = [self.xpsProvider pageCount];
        firstPageCrop = [self cropForPage:1 allowEstimate:NO];
        
        pageTurningView = [[EucIndexBasedPageTurningView alloc] initWithFrame:self.bounds];
        pageTurningView.delegate = self;
        pageTurningView.indexBasedDataSource = self;
        pageTurningView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        pageTurningView.zoomHandlingKind = EucPageTurningViewZoomHandlingKindZoom;
        pageTurningView.vibratesOnInvalidTurn = NO;
        [pageTurningView.tapGestureRecognizer setCancelsTouchesInView:NO];
        
        // Must do this here so that the page aspect ratio takes account of the twoUp property
        CGRect myBounds = self.bounds;
        if(myBounds.size.width > myBounds.size.height) {
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                pageTurningView.potentiallyVisiblePageEdgeCount = LAYOUT_LANDSCAPE_PAGE_EDGE_COUNT;
            } else {
                pageTurningView.potentiallyVisiblePageEdgeCount = 0;
            }
			self.twoUp = YES;
        } else {
            pageTurningView.potentiallyVisiblePageEdgeCount = 0;
			self.twoUp = NO;
        } 
        
        if (CGRectEqualToRect(firstPageCrop, CGRectZero)) {
            [pageTurningView setPageAspectRatio:0];
        } else {
            [pageTurningView setPageAspectRatio:firstPageCrop.size.width/firstPageCrop.size.height];
        }
        
        [self addSubview:pageTurningView];
        
        if (self.openingPoint) {
            [self jumpToBookPoint:self.openingPoint animated:NO];
            self.openingPoint = nil;
        }
    }    
}

- (void)attachSelector
{
    if (selector) {
        [self detachSelector];
    }
    
    selector = [[EucSelector alloc] init];
    selector.dataSource = self;
    selector.delegate =  self;
    
    [selector attachToView:self];
    [selector addObserver:self forKeyPath:@"tracking" options:0 context:NULL];
    
    [super attachSelector];
}

- (void)detachSelector
{    
    if (selector) {
        [selector detatch];

        [selector removeObserver:self forKeyPath:@"tracking"];

        [super detachSelector];

        [selector release], selector = nil;
    }
}

- (id)initWithFrame:(CGRect)frame 
     bookIdentifier:(SCHBookIdentifier *)bookIdentifier 
managedObjectContext:(NSManagedObjectContext *)managedObjectContext 
           delegate:(id<SCHReadingViewDelegate>)delegate
              point:(SCHBookPoint *)point
{
    self = [super initWithFrame:frame 
                 bookIdentifier:bookIdentifier 
           managedObjectContext:managedObjectContext
                       delegate:delegate
                          point:point];
    if (self) {        
        openingPoint = [point retain];
        [self initialiseView];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect myBounds = self.bounds;
    if(myBounds.size.width > myBounds.size.height) {
        if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
            pageTurningView.potentiallyVisiblePageEdgeCount = LAYOUT_LANDSCAPE_PAGE_EDGE_COUNT;
        } else {
            pageTurningView.potentiallyVisiblePageEdgeCount = 0;
        }
		self.twoUp = YES;      
    } else {
        self.pageTurningView.potentiallyVisiblePageEdgeCount = 0;
		self.twoUp = NO;
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
        [self performSelector:@selector(updateCurrentPageIndex) withObject:nil afterDelay:0.0f];
    }
}

- (void)willMoveToSuperview:(UIView *)newSuperview
{
    if (!newSuperview) {
        [self detachSelector];
    } else {
        [self attachSelector];
    }
}

- (void)updateCurrentPageIndex
{
    NSUInteger newIndex = self.pageTurningView.focusedPageIndex;
    
    self.currentPageIndex = newIndex;
}


- (void)setCurrentPageIndex:(NSUInteger)newPageIndex
{
    if(currentPageIndex != self.pageTurningView.leftPageIndex &&
       currentPageIndex != self.pageTurningView.rightPageIndex) {
        self.selector.selectedRange = nil;
    }
    
    BOOL multiplePagesDisplayed = NO;
    
    currentPageIndex = newPageIndex;
    
    if ((self.pageTurningView.isTwoUp) &&
        (self.pageTurningView.leftPageIndex  != NSUIntegerMax) && 
        (self.pageTurningView.rightPageIndex != NSUIntegerMax)) {
        
        multiplePagesDisplayed = YES;
    }
    
    if (multiplePagesDisplayed) {
        NSRange pageIndices = NSMakeRange(self.pageTurningView.leftPageIndex, 2);
        [self.delegate readingView:self hasMovedToPageIndicesInRange:pageIndices withFocusedPageIndex:currentPageIndex];
    } else {
        [self.delegate readingView:self hasMovedToPageAtIndex:currentPageIndex];
    }
}

- (void)jumpToZoomBlock:(id)zoomBlock
{
    
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
    NSAssert(![layoutCacheLock tryLock], @"layoutCacheLock should always have been previously acquired prior to creating a new cached value");
    
    if (nil == self.pageCropsCache) {
        self.pageCropsCache = [NSMutableDictionary dictionaryWithCapacity:pageCount];
    }
      
    // Grab the next 50 pages in one go to stop this interfering with the main thread on each turn
    int j = page + 50;
    for (int i = page; i < j; i++) {
        if (i <= [self pageCount]) {
            NSValue *pageCropValue = [self.pageCropsCache objectForKey:[NSNumber numberWithInt:i]];
            if (nil == pageCropValue) {
                CGRect cropRect = [self.xpsProvider cropRectForPage:i];
                if (!CGRectEqualToRect(cropRect, CGRectZero)) {
                    [self.pageCropsCache setObject:[NSValue valueWithCGRect:cropRect] forKey:[NSNumber numberWithInt:i]];
                }
            }
        }
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

- (NSString *)pageTurningView:(EucIndexBasedPageTurningView *)pageTurningView accessibilityPageDescriptionForPagesAtIndexes:(NSArray *)pageIdentifiers
{ 
    return nil;
}

#pragma mark - SCHReadingView methods

- (SCHBookPoint *)currentBookPointIgnoringMultipleDisplayPages:(BOOL)ignoreMultipleDisplayPages
{
    NSUInteger pageIndex;
    
    if (ignoreMultipleDisplayPages) {
        pageIndex = self.currentPageIndex;
    } else {
        BOOL multiplePagesDisplayed = NO;
    
        if ((self.pageTurningView.isTwoUp) &&
            (self.pageTurningView.leftPageIndex  != NSUIntegerMax) && 
            (self.pageTurningView.rightPageIndex != NSUIntegerMax)) {
        
            multiplePagesDisplayed = YES;
        }
    
        if (multiplePagesDisplayed) {
            pageIndex = self.pageTurningView.leftPageIndex;
        } else {
            pageIndex = self.currentPageIndex;
        }
    }
    
    SCHBookPoint *ret = [[SCHBookPoint alloc] init];
    ret.layoutPage = MAX(pageIndex + 1, 1);
    return [ret autorelease];
}

- (SCHBookPoint *)currentBookPoint {
    return [self currentBookPointIgnoringMultipleDisplayPages:YES];
}

- (CGFloat)currentProgressPosition
{
    return (self.currentPageIndex + 1)/(CGFloat)MAX([self generatedPageCount], 1);
}

- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated
{
    [self jumpToBookPoint:bookPoint animated:animated withCompletionHandler:nil];
}

- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion
{
    [self jumpToPageAtIndex:bookPoint.layoutPage - 1 animated:animated withCompletionHandler:completion];
}

- (void)jumpToPageAtIndex:(NSUInteger)pageIndex animated: (BOOL) animated
{	
    [self jumpToPageAtIndex:pageIndex animated:animated withCompletionHandler:nil];
}

- (void)jumpToPageAtIndex:(NSUInteger)pageIndex animated:(BOOL)animated withCompletionHandler:(dispatch_block_t)completion
{
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self jumpToPageAtIndex:pageIndex animated:animated withCompletionHandler:completion];
        });
        
        return;
    }
    
    if (animated) {
        self.jumpToPageCompletionHandler = completion;
    }
    
    BOOL animatedPageTurn = animated;
    
    if (pageIndex < [self generatedPageCount]) {
        [self.pageTurningView turnToPageAtIndex:pageIndex animated:animated];
	} else {
        animatedPageTurn = NO;
    }
    
    if (!animatedPageTurn) {
        [self updateCurrentPageIndex];
        if (completion != nil) {
            completion();
        }
    }
}

- (void)jumpToProgressPositionInBook:(CGFloat)progress animated:(BOOL)animated
{
    NSLog(@"WARNING: jumpToProgressPositionInBook should not be called on Layout View.");
}

- (void)setPageTexture:(UIImage *)image isDark:(BOOL)isDark
{
    [self.pageTurningView setPageTexture:image isDark:isDark];
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

- (void)zoomOutToCurrentPageWithCompletionHandler:(dispatch_block_t)completion
{
    if (self.pageTurningView.zoomFactor > self.pageTurningView.minZoomFactor) {
        self.zoomCompletionHandler = completion;
        [self zoomOutToCurrentPage];
    } else {
        if (completion) {
            completion();
        }
    }
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

- (NSString *)displayPageNumberForPageAtIndex:(NSUInteger)pageIndex
{
    NSString *displayPageNumber = nil;    

    if ([self.xpsProvider respondsToSelector:@selector(displayPageNumberForPage:)]) {
        displayPageNumber = [self.xpsProvider displayPageNumberForPage:pageIndex + 1];
    }
    
    return displayPageNumber;
        
}

- (NSString *)displayPageLabelForBookPoint:(SCHBookPoint *)bookPoint
{    
    NSUInteger pageIndex = MAX(bookPoint.layoutPage, 1) - 1;
    
    // Return Cover for the first page as a special case
    if (pageIndex == 0) {
        return @"Cover";
    }
    
    NSString *displayPageStr = [self displayPageNumberForPageAtIndex:pageIndex];
    if (displayPageStr) {
        return [NSString stringWithFormat:NSLocalizedString(@"Page %@",@"Page label X (page number (string)) (layout view)"), displayPageStr];
    } else {
        return [NSString stringWithFormat:NSLocalizedString(@"Page %@",@"Page label X (page number (string)) (layout view)"), [self.textFlow contentsTableViewController:nil displayPageNumberForPageIndex:pageIndex]];
    }
}

- (NSString *)pageLabelForPageAtIndex:(NSUInteger)pageIndex showChapters:(BOOL)showChapters
{
    if (pageIndex == 0) {
        return NSLocalizedString(@"Cover", @"Override page label for page index 0 in Layout view");
    }

    NSString *displayPageStr = [self displayPageNumberForPageAtIndex:pageIndex];
    
    NSString *chapterPrefix = NSLocalizedString(@"Chapter ", @"Scrubber label chapter prefix for layout view");
    NSString *pagePrefix = NSLocalizedString(@"Page ", @"Scrubber label page prefix for layout view");
    NSString *chapterPageSeparator = NSLocalizedString(@" │ ", @"Scrubber label chapter page separator for layout view");
    
    NSString *pageLabel = nil;
    
    if (showChapters) {
        NSString *chapterName = nil;
        
        // Ignore chapter names if we have less than 2 sections in the TOC - it will never change!
        if ([[self.textFlow tableOfContents] count] > 1) {
            NSString *uuid = [self.textFlow sectionUuidForPageIndex:pageIndex];
            chapterName = [self.textFlow contentsTableViewController:nil presentationNameAndSubTitleForSectionIdentifier:uuid].first;
        }
        
        if (chapterName) {
            
            NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
            [formatter setAllowsFloats:NO];
            
            if(![formatter numberFromString:chapterName]) {
                chapterPrefix = @"";
            }
            
            [formatter release];
            
            if ([displayPageStr length]) {
                pageLabel = [NSString stringWithFormat:NSLocalizedString(@"%@%@%@%@%@",@"Page label with page number and chapter (layout view)"), chapterPrefix, chapterName, chapterPageSeparator, pagePrefix, displayPageStr];
            } else {
                pageLabel = [NSString stringWithFormat:@"%@%@", chapterPrefix, chapterName];
            }
        }
    }
    
    if (!pageLabel) {
        NSString *lastPageStr = [self displayPageNumberForPageAtIndex:[self pageCount] - 1];
        
        if ([displayPageStr isEqualToString:@""]) {
            // This is the case for empty values in the mapping - we don't want a label in this case
            pageLabel = nil;
        } else if (displayPageStr && lastPageStr) {
             pageLabel = [NSString stringWithFormat:NSLocalizedString(@"Page %@ of %@",@"Page label X of Y (display page number (string) of display last page) (layout view)"), displayPageStr, lastPageStr];
        } else if (displayPageStr) {
            // We cannot mix and match a mapped display string and an actual end page count so just drop this
            pageLabel = [NSString stringWithFormat:NSLocalizedString(@"Page %@",@"Page label X (page number (string)) (layout view)"), displayPageStr];
        } else {
            // Just show the display page number for the page number
            pageLabel = [NSString stringWithFormat:NSLocalizedString(@"Page %@",@"Page label X (page number (string)) (layout view)"), [self.textFlow contentsTableViewController:nil displayPageNumberForPageIndex:pageIndex]];
        }
    }     
    
    return pageLabel;
}


#pragma mark - Cached generated pageViews

- (NSCache *)generatedPageViewsCache
{
    return nil; // turn off cache
    if (!generatedPageViewsCache) {
        generatedPageViewsCache = [[NSCache alloc] init];
        generatedPageViewsCache.countLimit = kSCHLayoutViewPageViewCacheLimit;
    }
    
    return generatedPageViewsCache;
}

- (UIView *)createGeneratedPageViewForPageAtIndex:(NSInteger)pageIndex 
{
    NSAssert(![pageViewsCacheLock tryLock], @"pageViewsCacheLock should always have been previously acquired prior to creating a new cached value");
    
    UIView *pageView = [self.generatedPageViewsCache objectForKey:[NSNumber numberWithInt:pageIndex]];
    if (nil == pageView) {
        pageView = [self.delegate generatedViewForPageAtIndex:pageIndex];
        if (pageView) {
            [self.generatedPageViewsCache setObject:pageView forKey:[NSNumber numberWithInt:pageIndex]];
        }
    }
    
    return pageView;
}

- (UIView *)generatedViewForPageAtIndex:(NSInteger)pageIndex 
{    
    [pageViewsCacheLock lock];

    UIView *pageView = [self.generatedPageViewsCache objectForKey:[NSNumber numberWithInt:pageIndex]];
    
    if (nil == pageView) {
        pageView = [self createGeneratedPageViewForPageAtIndex:pageIndex];
    }
    
    [pageViewsCacheLock unlock];

    return pageView;
}

- (NSUInteger)generatedPageCount
{
    return [self.delegate generatedPageCountForReadingView:self];
}

#pragma mark -
#pragma mark EucIndexBasedPageTurningViewDataSource

- (CGRect)pageTurningView:(EucIndexBasedPageTurningView *)aPageTurningView contentRectForPageAtIndex:(NSUInteger)index 
{
    if ((index == ([self generatedPageCount] - 1)) && 
        ([self.delegate readingView:self shouldGenerateViewForPageAtIndex:index])) {
        
        if ([self pageAtIndexIsOnRight:index]) {
            return [self.pageTurningView unzoomedRightPageFrame];
        } else {
            return [self.pageTurningView unzoomedLeftPageFrame];
        }
    }
    
    return [self cropForPage:index + 1];
}

- (THPositionedCGContext *)pageTurningView:(EucIndexBasedPageTurningView *)aPageTurningView 
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

- (void)pageTurningView:(EucPageTurningView *)pageTurningView didUpdateTextureForPageWithIdentifier:(id)identifier
{
    [self.delegate readingView:self hasRenderedPageAtIndex:[(NSNumber *)identifier integerValue]];
}


- (UIImage *)pageTurningView:(EucIndexBasedPageTurningView *)aPageTurningView
fastThumbnailUIImageForPageAtIndex:(NSUInteger)index
{
    return [self.xpsProvider thumbnailForPage:index + 1];
}

- (NSArray *)pageTurningView:(EucIndexBasedPageTurningView *)pageTurningView highlightsForPageAtIndex:(NSUInteger)pageIndex
{
    return [self highlightRectsForPageAtIndex:pageIndex excluding:nil];
}

- (NSUInteger)pageTurningViewPageCount:(EucIndexBasedPageTurningView *)pageTurningView
{
	return [self generatedPageCount];
}

- (UIView *)pageTurningView:(EucIndexBasedPageTurningView *)pageTurningView
       UIViewForPageAtIndex:(NSUInteger)pageIndex
{
    UIView *aView = nil;
    
    if ([self.delegate readingView:self shouldGenerateViewForPageAtIndex:pageIndex]) {
        aView = [self generatedViewForPageAtIndex:pageIndex];     
        
        // Turn on autoresizing before setting the frame and turn it off again immediately afterwards
        // as it doesn't play nicely with teh page turning view
        
        aView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        aView.autoresizesSubviews = YES;
        
        if ([self pageAtIndexIsOnRight:pageIndex]) {
            aView.frame = [self.pageTurningView unzoomedRightPageFrame];
        } else {
            aView.frame = [self.pageTurningView unzoomedLeftPageFrame];
        }
        
        aView.autoresizingMask = UIViewAutoresizingNone;
        aView.autoresizesSubviews = NO;
    }
    
    return aView;
}

#pragma mark - EucPageTurningViewDelegate

- (BOOL)pageTurningViewShouldBeTwoUp:(EucPageTurningView *)pageTurningView
{
    return self.twoUp;
}

- (void)pageTurningViewWillBeginPageTurn:(EucPageTurningView *)pageTurningView
{
    self.selector.selectionDisabled = YES;
    [self.delegate readingViewWillBeginTurning:self];
}

- (void)pageTurningViewDidEndPageTurn:(EucPageTurningView *)aPageTurningView
{
    [self updateCurrentPageIndex];
    self.selector.selectionDisabled = !self.allowsSelection;
    
    if (self.jumpToPageCompletionHandler != nil) {
        dispatch_block_t handler = Block_copy(self.jumpToPageCompletionHandler);
        self.jumpToPageCompletionHandler = nil;
        handler();
        Block_release(handler);
    }
}

- (void)pageTurningViewWillBeginAnimating:(EucPageTurningView *)aPageTurningView
{
    [self dismissFollowAlongHighlighter];
}

- (void)pageTurningViewDidEndAnimating:(EucPageTurningView *)aPageTurningView
{    
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
    
    if (!self.suppressZoomingCallback) {
        [self.delegate readingViewWillBeginUserInitiatedZooming:self];
    }
}

- (void)pageTurningViewDidEndZooming:(EucPageTurningView *)scrollView 
{
    // See comment in pageTurningViewWillBeginZooming: about disabling selection
    // during zoom.
    // [self.selector setShouldHideMenu:NO];
    [self.selector setSelectionDisabled:!self.allowsSelection];
    
    if (self.zoomCompletionHandler != nil) {
        dispatch_block_t handler = Block_copy(self.zoomCompletionHandler);
        self.zoomCompletionHandler = nil;
        handler();
        Block_release(handler);
    }
}

- (CGFloat)pageTurningView:(EucPageTurningView *)pageTurningView tapTurnMarginForPageWithIdentifier:(id)pageIdentifier
{
    return 0;
}

- (void)pageTurningView:(EucPageTurningView *)pageTurningView unhandledTapAtPoint:(CGPoint)point;
{
    [self unhandledTapAtPoint:point];
}

#pragma mark - Rotation

- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    [self detachSelector];
	self.temporaryHighlightRange = nil;
    [generatedPageViewsCache release], generatedPageViewsCache = nil;
    [self.pageTurningView willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [self.pageTurningView didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self attachSelector];
}

#pragma mark - Highlights

- (void)addHighlightWithSelection:(EucSelectorRange *)selectorRange
{
    [super addHighlightWithSelection:selectorRange];
}

- (void)refreshHighlightsForPageAtIndex:(NSUInteger)index
{
    [self.pageTurningView refreshHighlightsForPageAtIndex:index];
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

- (void)followAlongHighlightWordAtPoint:(SCHBookPoint *)bookPoint withCompletionHandler:(dispatch_block_t)completion
{
    
    if (![NSThread isMainThread]) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self followAlongHighlightWordAtPoint:bookPoint withCompletionHandler:completion];
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
            [self jumpToPageAtIndex:targetIndex animated:YES withCompletionHandler:completion];
        } else {        
            
			if (self.pageTurningView.zoomFactor > self.pageTurningView.minZoomFactor) {
				self.suppressZoomingCallback = YES;
                [self zoomOutToCurrentPageWithCompletionHandler:^{
                    self.suppressZoomingCallback = NO;
                }];
			}
			
			EucSelectorRange *range = [self selectorRangeFromBookRange:highlightRange];
			[self.selector temporarilyHighlightSelectorRange:range animated:YES];
            
            if (completion) {
                completion();
            }
		}
    } else {
        if (bookPoint) {
            __block SCHLayoutView *weakSelf = self;
            self.jumpToPageCompletionHandler = ^{
                [weakSelf followAlongHighlightWordAtPoint:bookPoint withCompletionHandler:completion];
            };
        }
        [self dismissFollowAlongHighlighter];
    }
}

#pragma mark - EucSelectorDataSource

- (NSArray *)blockIdentifiersForEucSelector:(EucSelector *)selector
{
    NSMutableArray *pagesBlocks = [NSMutableArray array];
    
    // N.B. we use pageCount, not generatedPageCount for determining if we should return blocks. This is because sample books
    // can have left page blocks beyond their page count. The correct fix for this eventually will be to implement the new selector 
    // didReceiveTouch functionality and stop the selector from recieving a touch on a generated page. 
    // Scholastic needs to be on future-stable for that.
    
    if (self.pageTurningView.isTwoUp) {
        NSInteger leftPageIndex = [self.pageTurningView leftPageIndex];
        if ((leftPageIndex >= 0) && (leftPageIndex < pageCount)) {
            [pagesBlocks addObjectsFromArray:[self.textFlow blocksForPageAtIndex:leftPageIndex includingFolioBlocks:NO]];
        }
    }
    
    NSInteger rightPageIndex = [self.pageTurningView rightPageIndex];
    if (rightPageIndex < pageCount) {
        [pagesBlocks addObjectsFromArray:[self.textFlow blocksForPageAtIndex:rightPageIndex includingFolioBlocks:NO]];
    }
    
    return [pagesBlocks valueForKey:@"blockID"];
}

- (CGRect)eucSelector:(EucSelector *)selector frameOfBlockWithIdentifier:(id)blockId
{
    NSInteger pageIndex = [KNFBTextFlowBlock pageIndexForBlockID:blockId];
    NSInteger blockIndex = [KNFBTextFlowBlock blockIndexForBlockID:blockId];

    KNFBTextFlowBlock *block = nil;
    NSArray *blocks = [self.textFlow blocksForPageAtIndex:pageIndex includingFolioBlocks:YES];
    if (blockIndex < blocks.count) {
        block = [blocks objectAtIndex:blockIndex];
    }
    
    if (block) {
        CGAffineTransform viewTransform = [self pageTurningViewTransformForPageAtIndex:pageIndex];
        return CGRectApplyAffineTransform([block rect], viewTransform);
    } else {
        return CGRectZero;
    }
}

- (NSArray *)eucSelector:(EucSelector *)selector identifiersForElementsOfBlockWithIdentifier:(id)blockId
{
    NSInteger pageIndex = [KNFBTextFlowBlock pageIndexForBlockID:blockId];
    NSInteger blockIndex = [KNFBTextFlowBlock blockIndexForBlockID:blockId];

    KNFBTextFlowBlock *block = nil;
    NSArray *blocks = [self.textFlow blocksForPageAtIndex:pageIndex includingFolioBlocks:YES];
    if (blockIndex < blocks.count) {
        block = [blocks objectAtIndex:blockIndex];
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
    NSInteger blockIndex = [KNFBTextFlowBlock blockIndexForBlockID:blockId];
    
    KNFBTextFlowBlock *block = nil;
    NSArray *blocks = [self.textFlow blocksForPageAtIndex:pageIndex includingFolioBlocks:YES];
    if (blockIndex < blocks.count) {
        block = [blocks objectAtIndex:blockIndex];
    }

    if (block) {
        NSUInteger wordIndex = [KNFBTextFlowPositionedWord wordIndexForWordID:elementId];
        
        KNFBTextFlowPositionedWord *word = nil;
        NSArray *blockWords = [block words];
        if (wordIndex < blockWords.count) {
            word = [blockWords objectAtIndex:wordIndex];
        }
        if (word) {
            CGAffineTransform viewTransform = [self pageTurningViewTransformForPageAtIndex:pageIndex];
            CGRect wordRect = CGRectZero;
            NSInteger elementValue = [elementId integerValue];
            NSArray *words = [block words];
            if (elementValue < [words count]) {
                wordRect = [[words objectAtIndex:elementValue] rect];            
            }
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

- (UIImage *)pageSnapshot
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

- (BOOL)pageAtIndexIsOnRight:(NSUInteger)pageIndex
{
    BOOL isOnRight = YES;
	if (self.pageTurningView.isTwoUp) {
		if ((pageIndex % 2) != 0) {
			isOnRight = NO;
		}
	}
    
    return isOnRight;
}

- (CGAffineTransform)pageTurningViewTransformForPageAtIndex:(NSInteger)pageIndex offsetOrigin:(BOOL)offset applyZoom:(BOOL)applyZoom {
    // TODO: Make sure this is cached in LayoutView or pageTurningView
    CGRect pageCrop = [self pageTurningView:self.pageTurningView contentRectForPageAtIndex:pageIndex];
    CGRect pageFrame;
    
	BOOL isOnRight = [self pageAtIndexIsOnRight:pageIndex];
    	
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

- (CGRect)pageRect
{
    if (self.pageTurningView.leftPageIndex != NSUIntegerMax) {
        return self.pageTurningView.leftPageFrame;
    } else {
        return self.pageTurningView.rightPageFrame;
    }
}

@end
