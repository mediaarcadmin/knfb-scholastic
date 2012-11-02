//
//  SCHRecommendationViewSpirit.m
//  Scholastic
//
//  Created by Matt Farrugia on 31/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationViewSpirit.h"
#import <libEucalyptus/EucBook.h>
#import <libEucalyptus/EucBookPageIndexPoint.h>
#import <libEucalyptus/EucBookPageIndexPointRange.h>
#import <libEucalyptus/EucUIViewViewSpiritElement.h>
#import "SCHRecommendationDataSource.h"
#import "SCHRecommendationViewDataSource.h"

@interface SCHRecommendationViewSpirit()

@property (nonatomic, retain) UIView *recommendationView;
@property (nonatomic, retain) EucUIViewViewSpiritElement *recommendationViewSpiritElement;
@property (nonatomic, assign) id <SCHRecommendationViewDataSource> dataSource;
@property (nonatomic, retain) NSArray *recommendationElements;
@property (nonatomic, assign) CGRect elementFrame;

@end

@implementation SCHRecommendationViewSpirit

@synthesize pageRanges;
@synthesize pointSize;
@synthesize pageOptions;
@synthesize invertLuminance;
@synthesize recommendationView;
@synthesize recommendationViewSpiritElement;
@synthesize dataSource;
@synthesize recommendationElements;
@synthesize elementFrame;

- (void)dealloc
{
    [pageRanges release], pageRanges = nil;
    [pageOptions release], pageOptions = nil;
    [recommendationView release], recommendationView = nil;
    [recommendationViewSpiritElement release], recommendationViewSpiritElement = nil;
    [recommendationElements release], recommendationElements = nil;
    dataSource = nil;
    [super dealloc];
}

- (id)initWithStartPoint:(EucBookPageIndexPoint *)point
                  inBook:(id<EucBook, SCHRecommendationDataSource>)book
                 inFrame:(CGRect)frame
             pageOptions:(NSDictionary *)aPageOptions
               pointSize:(CGFloat)aPointSize
            centerOnPage:(BOOL)center
{
    if((self = [super initWithFrame:frame])) {
        pageOptions = [aPageOptions retain];
        pointSize = aPointSize;
        
        EucBookPageIndexPoint *startPoint = point;
        EucBookPageIndexPoint *endPoint = [[[EucBookPageIndexPoint alloc] init] autorelease];
        endPoint.source = startPoint.source + 1;

        pageRanges = [[NSArray arrayWithObject:[[[EucBookPageIndexPointRange alloc] initWithStartPoint:startPoint endPoint:endPoint] autorelease]] retain];
        dataSource = [book recommendationViewDataSource];
        elementFrame = frame;
    }
    
    return self;
}

- (NSArray *)elements
{
    if (!recommendationElements) {
        NSAssert([NSThread isMainThread], @"Must be main thread");
        recommendationView = [[self.dataSource recommendationView] retain];
        if (recommendationView) {
            recommendationView.frame = self.elementFrame;
            recommendationViewSpiritElement = [[EucUIViewViewSpiritElement alloc] initWithView:recommendationView];
            recommendationViewSpiritElement.frame = recommendationView.frame;
            recommendationElements = [[NSArray alloc] initWithObjects:recommendationViewSpiritElement, nil];
        } else {
            recommendationElements = [[NSArray alloc] init];
        }
    }
    
    return recommendationElements;
}

- (NSArray *)blockIdentifiers
{
    return nil;
}

- (CGRect)frameOfBlockWithIdentifier:(id)blockId
{
    return CGRectZero;
}

- (NSArray *)identifiersForElementsOfBlockWithIdentifier:(id)blockId
{
    return nil;
}

- (NSArray *)rectsForElementWithIdentifier:(id)elementId ofBlockWithIdentifier:(id)blockId
{
    return nil;
}

- (NSString *)accessibilityLabelForElementWithIdentifier:(id)elementId ofBlockWithIdentifier:(id)blockId
{
    return nil;
}

@end
