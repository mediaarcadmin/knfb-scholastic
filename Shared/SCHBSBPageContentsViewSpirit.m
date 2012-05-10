//
//  SCHBSBPageContentsViewSpirit.m
//  Scholastic
//
//  Created by Matt Farrugia on 09/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBPageContentsViewSpirit.h"
#import "SCHBSBEucBook.h"
#import <libEucalyptus/EucCSSDPI.h>
#import <libEucalyptus/EucCSSIntermediateDocument.h>
#import <libEucalyptus/EucCSSRenderPageViewSpirit.h>
#import <libEucalyptus/EucBookPageIndexPointRange.h>
#import <libEucalyptus/EucUIViewViewSpiritElement.h>

@interface SCHBSBPageContentsViewSpirit()

@property (nonatomic, retain) EucCSSRenderPageViewSpirit *pageCSSViewSpirit;

@end

@implementation SCHBSBPageContentsViewSpirit

@synthesize pageOptions;
@synthesize pointSize;
@synthesize pageRanges;
@synthesize pageCSSViewSpirit;

- (void)dealloc
{
    [pageOptions release], pageOptions = nil;
    [pageRanges release], pageRanges = nil;
    [pageCSSViewSpirit release], pageCSSViewSpirit = nil;
    
    [super dealloc];
}

#pragma mark - EucPageContentsViewSpirit

- (id)initWithStartPoint:(EucBookPageIndexPoint *)point
                  inBook:(id<EucBook>)book
                 inFrame:(CGRect)frame
             pageOptions:(NSDictionary *)aPageOptions
               pointSize:(CGFloat)aPointSize
            centerOnPage:(BOOL)center
{
    if ((self = [super initWithFrame:frame])) {
        pageOptions = [aPageOptions retain];
        pointSize = aPointSize;
        
        pageRanges = [[self layoutPageFromPoint:point
                                        inBook:(SCHBSBEucBook *)book
                                  centerOnPage:center] retain];
    }
    return self;
}

- (NSArray *)layoutPageFromPoint:(EucBookPageIndexPoint *)point
                          inBook:(SCHBSBEucBook *)book
                    centerOnPage:(BOOL)centerOnPage
{
    NSArray *ret = nil;
    
    CGFloat scaleFactor = self.pointSize / EucCSSPixelsMediumFontSize;
    
    EucBookPageIndexPoint *nextPageStartPoint = nil;
    
    EucCSSIntermediateDocument *document = [book intermediateDocumentForIndexPoint:point pageOptions:self.pageOptions];
    
    EucBookIndexPointPlacement pointPlacement = point.placement;
    
    //THLog(@"Laying Out From: %@", point);
    
    if(document) {
        EucCSSLayoutPoint layoutPoint;
        layoutPoint.nodeKey = point.block ?: document.rootNode.key;
        layoutPoint.word = point.word;
        layoutPoint.element = point.element;
        switch(pointPlacement) {
            case EucBookIndexPointPlacementLeftPage:
                layoutPoint.placement = EucCSSLayoutPointPlacementLeftPage;
                break;
            case EucBookIndexPointPlacementRightPage:
                layoutPoint.placement = EucCSSLayoutPointPlacementRightPage;
                break;
            case EucBookIndexPointPlacementUnspecified:
                layoutPoint.placement = EucCSSLayoutPointPlacementUnspecified;
                break;
        }
                
        pageCSSViewSpirit = [[EucCSSRenderPageViewSpirit alloc] initWithPoint:layoutPoint
                                                                                        inDocument:document
                                                                                           inFrame:self.bounds
                                                                                       scaleFactor:scaleFactor
                                                                                    shrinkingToFit:centerOnPage 
                                                                                          delegate:nil /* self */ ];
        
        
        
        if(!pageCSSViewSpirit) {
            NSLog(@"Could not create pageCSSViewSpirit for book \"%@\", point %@", book.title, point);
        }
        
        if(!pageCSSViewSpirit || pageCSSViewSpirit.containsEndOfDocument) {
            uint32_t sourceCount = (uint32_t)book.sourceCount;
            uint32_t newSource = point.source;
            
            nextPageStartPoint = [[EucBookPageIndexPoint alloc] init];
            
            do {
                nextPageStartPoint.source = ++newSource;
            } while(newSource < book.sourceCount &&
                    ![book intermediateDocumentForIndexPoint:nextPageStartPoint
                                                 pageOptions:self.pageOptions]);
            
            if(newSource < sourceCount) {
                // Sections always start on the right hand page, if we're two-up 
                // (i.e. if the previous page had a specified placement).
                if(pointPlacement != EucBookIndexPointPlacementUnspecified) {
                    nextPageStartPoint.placement = EucBookIndexPointPlacementRightPage;
                }
            } else {
                nextPageStartPoint = nil;
            }
        } else {
            EucCSSLayoutPoint nextPageStartLayoutPoint = pageCSSViewSpirit.nextPageStartPoint;
            
            nextPageStartPoint = [[EucBookPageIndexPoint alloc] init];
            nextPageStartPoint.source = point.source;
            nextPageStartPoint.block = nextPageStartLayoutPoint.nodeKey;
            nextPageStartPoint.word = nextPageStartLayoutPoint.word;
            nextPageStartPoint.element = nextPageStartLayoutPoint.element;
            if(nextPageStartLayoutPoint.placement == EucCSSLayoutPointPlacementUnspecified) {
                switch(pointPlacement) {
                    case EucBookIndexPointPlacementLeftPage:
                        nextPageStartPoint.placement = EucBookIndexPointPlacementRightPage;
                        break;
                    case EucBookIndexPointPlacementRightPage:
                        nextPageStartPoint.placement = EucBookIndexPointPlacementLeftPage;
                        break;
                    case EucBookIndexPointPlacementUnspecified:
                        break;            
                }
            } else {
                if(nextPageStartLayoutPoint.placement == EucCSSLayoutPointPlacementLeftPage) {
                    nextPageStartPoint.placement = EucBookIndexPointPlacementLeftPage;
                } else { // EucCSSLayoutPointPlacementRightPage:
                    nextPageStartPoint.placement = EucBookIndexPointPlacementRightPage;
                }
            }            
        }    
        
        if (pageCSSViewSpirit) {
            [self addSubSpirit:pageCSSViewSpirit];
        }
                
        // Work out if you started on the left and the next page is on the left it adds a blank page
        
        if(nextPageStartPoint &&
           pointPlacement != EucBookIndexPointPlacementUnspecified && 
           pointPlacement == nextPageStartPoint.placement) {
            EucBookPageIndexPoint *midPoint = [nextPageStartPoint copy];
            if(pointPlacement == EucBookIndexPointPlacementLeftPage) {
                midPoint.placement = EucBookIndexPointPlacementRightPage;
            } else {
                midPoint.placement = EucBookIndexPointPlacementLeftPage;
            }
            ret = [NSArray arrayWithObjects:[EucBookPageIndexPointRange indexPointRangeWithStartPoint:point endPoint:midPoint],
                   [EucBookPageIndexPointRange indexPointRangeWithStartPoint:midPoint endPoint:nextPageStartPoint],
                   nil];
        } else {
            if(!nextPageStartPoint) {
                nextPageStartPoint = book.offTheEndIndexPoint;
            } 
            EucBookPageIndexPointRange *pageRange = [[EucBookPageIndexPointRange alloc] initWithStartPoint:point endPoint:nextPageStartPoint];
            ret = [NSArray arrayWithObject:pageRange];
        }
    }
    
    return ret;
}

- (NSArray *)blockIdentifiers
{
    return [self.pageCSSViewSpirit blockIdentifiers];
}

- (CGRect)frameOfBlockWithIdentifier:(id)blockId
{
    return [self.pageCSSViewSpirit frameOfBlockWithIdentifier:blockId];
}

- (NSArray *)identifiersForElementsOfBlockWithIdentifier:(id)blockId
{
    return [self.pageCSSViewSpirit identifiersForElementsOfBlockWithIdentifier:blockId];
}

- (NSArray *)rectsForElementWithIdentifier:(id)elementId ofBlockWithIdentifier:(id)blockId
{
    return [self.pageCSSViewSpirit rectsForElementWithIdentifier:elementId ofBlockWithIdentifier:blockId];
}

- (NSString *)accessibilityLabelForElementWithIdentifier:(id)elementId ofBlockWithIdentifier:(id)blockId
{
    return [self.pageCSSViewSpirit accessibilityLabelForElementWithIdentifier:elementId ofBlockWithIdentifier:blockId];
}

@end
