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
#import "KNFBTextFlowParagraphSource.h"
#import <libEucalyptus/EucBookView.h>
#import <libEucalyptus/EucBUpeBook.h>
#import <libEucalyptus/EucBookPageIndexPoint.h>
#import <libEucalyptus/EucHighlightRange.h>
#import <libEucalyptus/EucMenuItem.h>
#import <libEucalyptus/EucCSSIntermediateDocument.h>
#import <libEucalyptus/EucSelectorRange.h>
#import <libEucalyptus/EucHighlightRange.h>
#import <libEucalyptus/THPair.h>
#import <libEucalyptus/EucConfiguration.h>

@interface SCHFlowView ()

@property (nonatomic, retain) SCHFlowEucBook *eucBook;
@property (nonatomic, retain) KNFBTextFlowParagraphSource *paragraphSource;
@property (nonatomic, retain) EucBookView *eucBookView;

@property (nonatomic, retain) UIImage *currentPageTexture;
@property (nonatomic, assign) BOOL textureIsDark;

@end

@implementation SCHFlowView

@synthesize eucBook;
@synthesize paragraphSource;
@synthesize eucBookView;

@synthesize currentPageTexture;
@synthesize textureIsDark;

- (void)initialiseView
{
    if((eucBookView = [[EucBookView alloc] initWithFrame:self.bounds book:self.eucBook])) {
        eucBookView.delegate = self;
        eucBookView.allowsSelection = YES;
        eucBookView.selectorDelegate = self;
        eucBookView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        eucBookView.vibratesOnInvalidTurn = NO;
        [eucBookView setPageTexture:self.currentPageTexture isDark:self.textureIsDark];
        [self addSubview:eucBookView];        
    }
}

- (void)dealloc
{    
    if(paragraphSource) {
        [paragraphSource release], paragraphSource = nil;
        [[SCHBookManager sharedBookManager] checkInParagraphSourceForBookIdentifier:self.isbn];   
    }
    
    if(eucBook) {
        [eucBook release], eucBook = nil;
        [[SCHBookManager sharedBookManager] checkInEucBookForBookIdentifier:self.isbn];  
    }
    
    [currentPageTexture release], currentPageTexture = nil;

    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame isbn:(id)isbn delegate:(id<SCHReadingViewDelegate>)delegate
{
    self = [super initWithFrame:frame isbn:isbn delegate:delegate];
    if (self) {        
        self.opaque = YES;
        
        SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
        
        eucBook = [[bookManager checkOutEucBookForBookIdentifier:self.isbn] retain];
        paragraphSource = [[bookManager checkOutParagraphSourceForBookIdentifier:self.isbn] retain];
    }
    return self;
}

- (void)willMoveToWindow:(UIWindow *)newWindow 
{
    [super willMoveToWindow:newWindow];
    
    // The selector observer must be dealloced here before the selector is torn down inside eucbookview
    if (newWindow == nil) {
        [self.eucBookView.selector removeObserver:self forKeyPath:@"trackingStage"];
        [self.eucBookView removeObserver:self forKeyPath:@"currentPageIndexPoint"];
        self.eucBookView = nil;

    } else {
        // N.B. We must initialise the view _after_ the view frame has been set because
        // the eucBookView paginates the eucBook using the view bounds. If we initialise too early
        // the nib frame size will be used instead. The correct fix for this is probably to
        // initialise the _pageLayoutController in EucBookView in willMoveToWindow rather than init
        [self initialiseView];
    }
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.window) {
        // This needs to be done here to add the observer after the willMoveToWindow code in
        // eucBookView which sets the page count
        [self.eucBookView addObserver:self forKeyPath:@"currentPageIndexPoint" options:NSKeyValueObservingOptionInitial context:NULL];
        [self.eucBookView.selector addObserver:self forKeyPath:@"trackingStage" options:NSKeyValueObservingOptionPrior context:NULL];
    }
}

#pragma mark - BookView Methods

- (SCHBookPoint *)currentBookPoint
{
    return [self.eucBook bookPointFromBookPageIndexPoint:[self.eucBook currentPageIndexPoint]];
}

- (void)jumpToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated
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
    
    [self.eucBookView goToIndexPoint:point animated:animated];
}

- (void)jumpToPageAtIndex:(NSUInteger)pageIndex animated: (BOOL) animated
{                           
    [self.eucBookView goToPageIndex:pageIndex animated:animated];
}

- (void)jumpToProgressPositionInBook:(CGFloat)progress animated:(BOOL)animated
{
    EucBookPageIndexPoint *point = [self.eucBook estimatedIndexPointForPercentage:progress];
    [self.eucBookView goToIndexPoint:point animated:animated];
}

- (NSInteger) maximumFontIndex
{
    return ([[EucConfiguration objectForKey:EucConfigurationFontSizesKey] count] - 1);
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object
                        change:(NSDictionary *)change context:(void *)context
{
    [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    
    if ([keyPath isEqualToString:@"currentPageIndexPoint"]) {
        if ((self.eucBookView.pageCount != 0) && (self.eucBookView.pageCount != -1)) {
            [self.delegate readingView:self hasMovedToPageAtIndex:eucBookView.currentPageIndex];
        } else {
            CGFloat progress = [self.eucBook estimatedPercentageForIndexPoint:eucBookView.currentPageIndexPoint];
            [self.delegate readingView:self hasMovedToProgressPositionInBook:progress];
        }
    }
}

- (void)bookView:(EucBookView *)bookView unhandledTapAtPoint:(CGPoint)point
{
    [self.delegate toggleToolbars];
}

- (void)bookViewPageTurnWillBegin:(EucBookView *)bookView
{
    [self.delegate readingViewWillBeginTurning:self];
}

- (NSArray *)bookView:(EucBookView *)bookView highlightRangesFromPoint:(EucBookPageIndexPoint *)startPoint toPoint:(EucBookPageIndexPoint *)endPoint
{
    NSArray *ret = nil;
    
    SCHBookPoint *startBookPoint = [self.eucBook bookPointFromBookPageIndexPoint:startPoint];
    SCHBookPoint *endBookPoint = [self.eucBook bookPointFromBookPageIndexPoint:endPoint];
    
    NSMutableArray *allHighlights = [NSMutableArray array];
    
    for (int i = startBookPoint.layoutPage; i <= endBookPoint.layoutPage; i++) {
        NSArray *highlightRanges = [self highlightsForLayoutPage:i];
        [allHighlights addObjectsFromArray:highlightRanges];
    }
            
    NSUInteger count = allHighlights.count;
    if(count) {
        NSMutableArray *eucRanges = [[NSMutableArray alloc] initWithCapacity:count];
        for(SCHBookRange *bookRange in allHighlights) {
            EucHighlightRange *eucRange = [[EucHighlightRange alloc] init];
            eucRange.startPoint = [self.eucBook bookPageIndexPointFromBookPoint:bookRange.startPoint];
            eucRange.endPoint = [self.eucBook bookPageIndexPointFromBookPoint:bookRange.endPoint];
            eucRange.color = [self.delegate highlightColor];
            [eucRanges addObject:eucRange];
            [eucRange release];
        }
        ret = [eucRanges autorelease];
    }
    
    return ret;
}

- (NSString *)displayPageNumberForBookPoint:(SCHBookPoint *)bookPoint
{
    return [self.eucBookView displayPageNumberForPageIndex:[self.eucBookView pageIndexForIndexPoint:[self.eucBook bookPageIndexPointFromBookPoint:bookPoint]]];
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

- (void)setFontPointIndex:(NSUInteger)index
{
    NSArray *eucFontSizeNumbers = [EucConfiguration objectForKey:EucConfigurationFontSizesKey];
    
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
    // Just refresh them all even if it is called on multiple pages in flow view
    [self.eucBookView refreshHighlights];
}

- (SCHBookRange *)bookRangeFromSelectorRange:(EucSelectorRange *)selectorRange
{
    if (nil == selectorRange) return nil;
    
    EucBookPageIndexPoint *indexPoint = [[EucBookPageIndexPoint alloc] init];
    
    indexPoint.source = [self.eucBook currentPageIndexPoint].source;
    
    indexPoint.block = [selectorRange.startBlockId unsignedIntValue];
    indexPoint.word = [selectorRange.startElementId unsignedIntValue];
    SCHBookPoint *startPoint = [self.eucBook bookPointFromBookPageIndexPoint:indexPoint];
    
    indexPoint.block = [selectorRange.endBlockId unsignedIntValue];
    indexPoint.word = [selectorRange.endElementId unsignedIntValue];
    SCHBookPoint *endPoint = [self.eucBook bookPointFromBookPageIndexPoint:indexPoint];
    
    [indexPoint release];
    
    SCHBookRange *range = [[SCHBookRange alloc] init];
    range.startPoint = startPoint;
    range.endPoint = endPoint;    
    
    return [range autorelease];
}

@end