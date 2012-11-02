//
//  SCHRecommendationProxyViewSpirit.m
//  Scholastic
//
//  Created by Matt Farrugia on 31/10/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHRecommendationProxyViewSpirit.h"
#import "SCHRecommendationViewSpirit.h"
#import <libEucalyptus/EucBook.h>
#import <libEucalyptus/EucBookPageIndexPoint.h>
#import "SCHRecommendationDataSource.h"

@implementation SCHRecommendationProxyViewSpirit

@dynamic pageRanges;
@dynamic pointSize;
@dynamic pageOptions;
@dynamic invertLuminance;

- (id)initWithStartPoint:(EucBookPageIndexPoint *)point
                  inBook:(id<EucBook, SCHRecommendationDataSource>)book
                 inFrame:(CGRect)frame
             pageOptions:(NSDictionary *)pageOptions
               pointSize:(CGFloat)pointSize
            centerOnPage:(BOOL)center
{
    id concreteViewSpirit = nil;
    
    EucBookPageIndexPoint *offTheEndIndexPoint = [book offTheEndIndexPoint];
    Class spiritClass = nil;
    
    if (point.source == offTheEndIndexPoint.source - 1) {
        spiritClass = [SCHRecommendationViewSpirit class];
    } else if ([book respondsToSelector:@selector(pageContentsViewSpiritSuperClass)]) {
        spiritClass = [book pageContentsViewSpiritSuperClass];
    }
    
    if (spiritClass) {
        concreteViewSpirit = [(id<EucPageContentsViewSpirit>)[spiritClass alloc] initWithStartPoint:point
                                                                                             inBook:book
                                                                                            inFrame:frame
                                                                                        pageOptions:pageOptions
                                                                                          pointSize:pointSize
                                                                                       centerOnPage:center];
    }
    
    [self release];
    
    return concreteViewSpirit;
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
