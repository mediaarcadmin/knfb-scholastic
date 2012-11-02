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

@end

@implementation SCHRecommendationViewSpirit

@synthesize pageRanges;
@synthesize pointSize;
@synthesize pageOptions;
@synthesize invertLuminance;
@synthesize recommendationView;
@synthesize recommendationViewSpiritElement;

- (void)dealloc
{
    [pageRanges release], pageRanges = nil;
    [pageOptions release], pageOptions = nil;
    [recommendationView release], recommendationView = nil;
    [recommendationViewSpiritElement release], recommendationViewSpiritElement = nil;
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
        
        id <SCHRecommendationViewDataSource> dataSource = [book recommendationViewDataSource];
        recommendationView = [[dataSource recommendationView] retain];
        if (recommendationView) {
            recommendationView.frame = frame;
            recommendationViewSpiritElement = [[EucUIViewViewSpiritElement alloc] initWithView:recommendationView];
            recommendationViewSpiritElement.frame = recommendationView.frame;
            [self addElement:recommendationViewSpiritElement];
        }
    }
    
    return self;
}

- (NSArray *)blockIdentifiers
{
    return [NSArray arrayWithObject:recommendationView];
}

- (CGRect)frameOfBlockWithIdentifier:(id)blockId
{
    return [(UIView *)blockId frame];
}

- (NSArray *)identifiersForElementsOfBlockWithIdentifier:(id)blockId
{
    return [(UIView *)blockId subviews];
}

- (NSArray *)rectsForElementWithIdentifier:(id)elementId ofBlockWithIdentifier:(id)blockId
{
    return [NSArray arrayWithObject:[NSValue valueWithCGRect:[(UIView *)elementId frame]]];
}

- (NSString *)accessibilityLabelForElementWithIdentifier:(id)elementId ofBlockWithIdentifier:(id)blockId
{
    return [(UIView *)elementId accessibilityLabel];
}

@end
