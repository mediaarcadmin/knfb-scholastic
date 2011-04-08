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
#import <libEucalyptus/THPositionedCGContext.h>

@interface SCHLayoutView()

@property (nonatomic, retain) SCHXPSProvider *xpsProvider;
@property (nonatomic, retain) EucPageTurningView *pageTurningView;
@property (nonatomic, assign) NSUInteger pageCount;
@property (nonatomic, assign) CGRect firstPageCrop;
@property (nonatomic, assign) CGSize pageSize;
@property (nonatomic, retain) NSMutableDictionary *pageCropsCache;
@property (nonatomic, retain) NSLock *layoutCacheLock;

- (void)initialiseView;
- (CGRect)cropForPage:(NSInteger)page allowEstimate:(BOOL)estimate;

@end

@implementation SCHLayoutView

@synthesize xpsProvider;
@synthesize pageTurningView;
@synthesize pageCount;
@synthesize firstPageCrop;
@synthesize pageSize;
@synthesize pageCropsCache;
@synthesize layoutCacheLock;

- (void)dealloc
{
    
    if (xpsProvider) {
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:self.isbn];
        [xpsProvider release], xpsProvider = nil;
    }
    
    [pageTurningView release], pageTurningView = nil;
    [pageCropsCache release], pageCropsCache = nil;
    [layoutCacheLock release], layoutCacheLock = nil;
    [super dealloc];
}

- (void)initialiseView
{
    xpsProvider = [[[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.isbn] retain];
    
    if (xpsProvider) {
        layoutCacheLock = [[NSLock alloc] init];
        
        pageCount = [xpsProvider pageCount];
        firstPageCrop = [self cropForPage:1 allowEstimate:NO];
        
        pageTurningView = [[[EucPageTurningView alloc] initWithFrame:self.bounds] retain];
        pageTurningView.delegate = self;
        pageTurningView.bitmapDataSource = self;
        pageTurningView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        pageTurningView.zoomHandlingKind = EucPageTurningViewZoomHandlingKindZoom;
        pageTurningView.vibratesOnInvalidTurn = NO;
        
        // Must do this here so that the page aspect ratio takes account of the twoUp property
        CGRect myBounds = self.bounds;
        if(myBounds.size.width > myBounds.size.height) {
            pageTurningView.twoUp = YES;
        } else {
            pageTurningView.twoUp = NO;
        } 
        
        if (CGRectEqualToRect(firstPageCrop, CGRectZero)) {
            [pageTurningView setPageAspectRatio:0];
        } else {
            [pageTurningView setPageAspectRatio:firstPageCrop.size.width/firstPageCrop.size.height];
        }
        
        [self addSubview:pageTurningView];
        
        [pageTurningView setPageTexture:[UIImage imageNamed: @"paper-white.png"] isDark:NO];
        [pageTurningView turnToPageAtIndex:0 animated:NO];
        [pageTurningView waitForAllPageImagesToBeAvailable];
    }
}

- (id)initWithFrame:(CGRect)frame isbn:(id)aIsbn
{
    self = [super initWithFrame:frame isbn:aIsbn];
    if (self) {        
        [self initialiseView];
    }
    return self;
}

- (void)layoutSubviews {
    CGRect myBounds = self.bounds;
    if(myBounds.size.width > myBounds.size.height) {
        self.pageTurningView.twoUp = YES;        
        // The first page is page 0 as far as the page turning view is concerned,
        // so it's an even page, so if it's mean to to be on the left, the odd 
        // pages should be on the right.
        
        // Disabled for now because many books seem to have the property set even
        // though their first page is the cover, and the odd pages are 
        // clearly meant to be on the left (e.g. they have page numbers on the 
        // outside).
        //self.pageTurningView.oddPagesOnRight = [[[BlioBookManager sharedBookManager] bookWithID:self.bookID] firstLayoutPageOnLeft];
    } else {
        self.pageTurningView.twoUp = NO;
    }   
    [super layoutSubviews];
    CGSize newSize = self.bounds.size;
    
    if(!CGSizeEqualToSize(newSize, self.pageSize)) {
		self.pageSize = newSize;
        // Perform this after a delay in order to give time for layoutSubviews 
        // to be called on the pageTurningView before we start the zoom
        // (Ick!).
        [self performSelector:@selector(zoomForNewPageAnimatedWithNumberThunk:) withObject:[NSNumber numberWithBool:NO] afterDelay:0.0f];
    }
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

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (NSString *)pageTurningViewAccessibilityPageDescriptionForPagesAtIndexes:(NSArray *)pageIndexes
{ 
    return nil;
}

- (void) jumpToPage: (NSInteger) page animated: (BOOL) animated
{
    [pageTurningView turnToPageAtIndex:page animated:animated];
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
    
    NSLog(@"index: %d", index);
    
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

@end
