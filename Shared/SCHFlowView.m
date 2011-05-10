//
//  BlioFlowView.m
//  BlioApp
//
//  Created by James Montgomerie on 04/01/2010.
//  Copyright 2010 Things Made Out Of Other Things. All rights reserved.
//

#import "SCHFlowView.h"
#import "SCHBookManager.h"
#import "SCHFlowEucBook.h"
#import "KNFBTextFlowParagraphSource.h"
#import <libEucalyptus/EucBookView.h>
#import <libEucalyptus/EucBUpeBook.h>
#import <libEucalyptus/EucBookPageIndexPoint.h>
#import <libEucalyptus/EucHighlightRange.h>
#import <libEucalyptus/EucMenuItem.h>
#import <libEucalyptus/EucCSSIntermediateDocument.h>
#import <libEucalyptus/EucSelectorRange.h>
#import <libEucalyptus/THPair.h>
#import <libEucalyptus/EucConfiguration.h>

@interface SCHFlowView ()

@property (nonatomic, retain) SCHFlowEucBook *eucBook;
@property (nonatomic, retain) KNFBTextFlowParagraphSource *paragraphSource;
@property (nonatomic, retain) EucBookView *eucBookView;

@end

@implementation SCHFlowView

@synthesize eucBook;
@synthesize paragraphSource;
@synthesize eucBookView;

- (void)initialiseView
{
    SCHBookManager *bookManager = [SCHBookManager sharedBookManager];
    
    eucBook = [[bookManager checkOutEucBookForBookIdentifier:self.isbn] retain];
    paragraphSource = [[bookManager checkOutParagraphSourceForBookIdentifier:self.isbn] retain];
    
    if((eucBookView = [[EucBookView alloc] initWithFrame:self.bounds book:eucBook])) {
        eucBookView.delegate = self;
        eucBookView.allowsSelection = YES;
        eucBookView.selectorDelegate = self;
        eucBookView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        eucBookView.vibratesOnInvalidTurn = NO;
        [eucBookView setPageTexture:[UIImage imageNamed: @"paper-white.png"] isDark:NO];
        [self addSubview:eucBookView];
    }
}

- (void)dealloc
{
    [eucBookView release], eucBookView = nil;
    
    if(paragraphSource) {
        [paragraphSource release], paragraphSource = nil;
        [[SCHBookManager sharedBookManager] checkInParagraphSourceForBookIdentifier:self.isbn];   
    }
    
    if(eucBook) {
        [eucBook release], eucBook = nil;
        [[SCHBookManager sharedBookManager] checkInEucBookForBookIdentifier:self.isbn];  
    }

    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame isbn:(NSString *)isbn
{
    self = [super initWithFrame:frame isbn:isbn];
    if (self) {        
        self.opaque = YES;

        [self initialiseView];
    }
    return self;
}

- (void)didMoveToWindow
{
    [super didMoveToWindow];
    
    if (self.window) {
        // This needs to be done here to add the observer after the willMoveToWindow code in
        // eucBookView which sets the page count
        [eucBookView addObserver:self forKeyPath:@"currentPageIndexPoint" options:NSKeyValueObservingOptionInitial context:NULL];
    } else {
        [eucBookView removeObserver:self forKeyPath:@"currentPageIndexPoint"];
    }
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
    if ([keyPath isEqualToString:@"currentPageIndexPoint"]) {
        
        if ((eucBookView.pageCount != 0) && (eucBookView.pageCount != -1)) {
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

#pragma mark - SCHReadingView methods

- (void)setPageTexture:(UIImage *)image isDark:(BOOL)isDark
{
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

- (void)goToBookPoint:(SCHBookPoint *)bookPoint animated:(BOOL)animated
{
    return;
}


@end