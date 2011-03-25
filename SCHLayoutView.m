//
//  SCHLayoutView.m
//  Scholastic
//
//  Created by Matt Farrugia on 23/03/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHLayoutView.h"
#import "BITXPSProvider.h"
#import "SCHBookManager.h"
#import <libEucalyptus/THPositionedCGContext.h>

@interface SCHLayoutView()

@property (nonatomic, retain) id book;
@property (nonatomic, retain) id xpsProvider;

- (void)initialiseView;

@end

@implementation SCHLayoutView

@synthesize book;
@synthesize xpsProvider;

- (void)dealloc
{
    
    if (xpsProvider) {
        [[SCHBookManager sharedBookManager] checkInXPSProviderForBookIdentifier:book];
        [xpsProvider release], xpsProvider = nil;
    }
    
    [book release], book = nil;
    [super dealloc];
}

- (void)initialiseView
{
    EucPageTurningView *aPageTurningView = [[EucPageTurningView alloc] initWithFrame:self.bounds];
    aPageTurningView.delegate = self;
    aPageTurningView.bitmapDataSource = self;
    aPageTurningView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    aPageTurningView.zoomHandlingKind = EucPageTurningViewZoomHandlingKindZoom;
    aPageTurningView.vibratesOnInvalidTurn = NO;
    
    // Must do this here so that teh page aspect ration takes account of the twoUp property
    CGRect myBounds = self.bounds;
    if(myBounds.size.width > myBounds.size.height) {
        aPageTurningView.twoUp = YES;
    } else {
        aPageTurningView.twoUp = NO;
    } 
    
    [aPageTurningView setPageAspectRatio:1.5f];
    
//    if (CGRectEqualToRect(firstPageCrop, CGRectZero)) {
//        [aPageTurningView setPageAspectRatio:0];
//    } else {
//        [aPageTurningView setPageAspectRatio:firstPageCrop.size.width/firstPageCrop.size.height];
//    }
    
    //[self registerGesturesForPageTurningView:aPageTurningView];
    [self addSubview:aPageTurningView];
    //self.pageTurningView = aPageTurningView;
    
    [aPageTurningView turnToPageAtIndex:0 animated:NO];
    [aPageTurningView waitForAllPageImagesToBeAvailable];
}

- (id)initWithFrame:(CGRect)frame book:(id)aBook
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        book = [aBook retain];
        self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.backgroundColor = [UIColor yellowColor];
        
        xpsProvider = [[[SCHBookManager sharedBookManager] checkOutXPSProviderForBookIdentifier:self.book] retain];
        
        [self initialiseView];
        
    }
    return self;
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

#pragma mark -
#pragma mark EucPageTurningViewBitmapDataSource

- (CGRect)pageTurningView:(EucPageTurningView *)aPageTurningView contentRectForPageAtIndex:(NSUInteger)index 
{
    return CGRectMake(0, 0, 320, 480);
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
