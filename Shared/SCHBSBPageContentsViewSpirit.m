//
//  SCHBSBPageContentsViewSpirit.m
//  Scholastic
//
//  Created by Matt Farrugia on 09/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#if !BRANCHING_STORIES_DISABLED
#import "SCHBSBPageContentsViewSpirit.h"
#import "SCHBSBEucBook.h"
#import "SCHBSBReplacedElement.h"
#import <libEucalyptus/EucCSSDPI.h>
#import <libEucalyptus/EucCSSIntermediateDocument.h>
#import <libEucalyptus/EucCSSXHTMLTree.h>
#import <libEucalyptus/EucCSSRenderPageViewSpirit.h>
#import <libEucalyptus/EucBookPageIndexPointRange.h>
#import <libEucalyptus/EucUIViewViewSpiritElement.h>

@interface SCHBSBPageContentsViewSpirit() <EucCSSRenderPageViewSpiritDelegate>

@property (nonatomic, retain) EucCSSRenderPageViewSpirit *pageCSSViewSpirit;
@property (nonatomic, retain) EucCSSIntermediateDocument *document;

@end

@implementation SCHBSBPageContentsViewSpirit

@synthesize pageOptions;
@synthesize pointSize;
@synthesize pageRanges;
@synthesize pageCSSViewSpirit;
@synthesize document;
@synthesize invertLuminance;

- (void)dealloc
{
    [pageOptions release], pageOptions = nil;
    [pageRanges release], pageRanges = nil;
    [pageCSSViewSpirit release], pageCSSViewSpirit = nil;
    [document release], document = nil;
    
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
    
    document = [[book intermediateDocumentForIndexPoint:point pageOptions:self.pageOptions] retain];
    
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
            case EucBookIndexPointPlacementRightPaddingPage:
                NSLog(@"Warning: Unexpected placement of EucBookIndexPointPlacementRightPaddingPage");
                NSParameterAssert(pointPlacement != EucBookIndexPointPlacementRightPaddingPage);
            case EucBookIndexPointPlacementUnspecified:
                layoutPoint.placement = EucCSSLayoutPointPlacementUnspecified;
                break;
        }
                
        pageCSSViewSpirit = [[EucCSSRenderPageViewSpirit alloc] initWithPoint:layoutPoint
                                                                                        inDocument:document
                                                                                           inFrame:self.bounds
                                                                                       scaleFactor:scaleFactor
                                                                                    shrinkingToFit:centerOnPage 
                                                                                          delegate:self];
        
        
        
        if(!pageCSSViewSpirit) {
            NSLog(@"Could not create pageCSSViewSpirit for book \"%@\", point %@", book.title, point);
        }
        
        if(!pageCSSViewSpirit || pageCSSViewSpirit.containsEndOfDocument) {
            uint32_t newSource = point.source + 1;
                        
            EucBookPageIndexPoint *nextSectionStart = nil;
            for(EucBookPageIndexPoint *potentialStart in book.hardPageBreakIndexPoints) {
                if(potentialStart.source >= newSource &&
                   [book intermediateDocumentForIndexPoint:nextPageStartPoint
                                               pageOptions:self.pageOptions]) {
                       nextSectionStart = potentialStart;
                       break;
                }
            }
            
            if(nextSectionStart) {
                if(pointPlacement == EucBookIndexPointPlacementUnspecified) {
                    // We're not two-up, so we make the section start on an unspecified side.
                    if(nextSectionStart.placement != EucBookIndexPointPlacementUnspecified) {
                        nextSectionStart = [[nextSectionStart copy] autorelease];
                        nextSectionStart.placement = EucBookIndexPointPlacementUnspecified;
                    }
                } else {
                    // We're two-up, so we make sure the section starts on a specified side,
                    // if the book does not specify one (the right by default).
                    if(nextSectionStart.placement == EucBookIndexPointPlacementUnspecified) {
                        nextSectionStart = [[nextSectionStart copy] autorelease];
                        nextSectionStart.placement = EucBookIndexPointPlacementRightPage;
                    }
                }
                
                nextPageStartPoint = nextSectionStart;
            }
        } else {
            EucCSSLayoutPoint nextPageStartLayoutPoint = pageCSSViewSpirit.nextPageStartPoint;
            
            nextPageStartPoint = [[[EucBookPageIndexPoint alloc] init] autorelease];
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
                    case EucBookIndexPointPlacementRightPaddingPage:
                        NSLog(@"Warning: Unexpected placement of EucBookIndexPointPlacementRightPaddingPage");
                        NSParameterAssert(pointPlacement != EucBookIndexPointPlacementRightPaddingPage);
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
                
        if(nextPageStartPoint &&
           pointPlacement != EucBookIndexPointPlacementUnspecified && 
           pointPlacement == nextPageStartPoint.placement) {
            // If the next page starts on the same side as the current page,
            // add a blank padding page between them.

            EucBookPageIndexPoint *midPoint = [nextPageStartPoint copy];
            if(pointPlacement == EucBookIndexPointPlacementLeftPage) {
                midPoint.placement = EucBookIndexPointPlacementRightPaddingPage;
            } else {
                midPoint.placement = EucBookIndexPointPlacementLeftPage;
            }
            ret = [NSArray arrayWithObjects:[EucBookPageIndexPointRange indexPointRangeWithStartPoint:point endPoint:midPoint],
                   [EucBookPageIndexPointRange indexPointRangeWithStartPoint:midPoint endPoint:nextPageStartPoint],
                   nil];
            [midPoint release];
        } else {
            if(!nextPageStartPoint) {
                if(pointPlacement == EucBookIndexPointPlacementRightPage) {
                    nextPageStartPoint = book.offTheEndIndexPoint;
                } else {
                    // If this is a left-hand page at the end of a book,
                    // add a right-hand padding page.
                    nextPageStartPoint = book.offTheEndIndexPoint;
                    EucBookPageIndexPoint *midPoint = [nextPageStartPoint copy];
                    midPoint.placement = EucBookIndexPointPlacementRightPaddingPage;
                    ret = [NSArray arrayWithObjects:[EucBookPageIndexPointRange indexPointRangeWithStartPoint:point endPoint:midPoint],
                           [EucBookPageIndexPointRange indexPointRangeWithStartPoint:midPoint endPoint:nextPageStartPoint],
                           nil];
                    [midPoint release];
                }
            }
            if(!ret) {
                EucBookPageIndexPointRange *pageRange = [[EucBookPageIndexPointRange alloc] initWithStartPoint:point endPoint:nextPageStartPoint];
                ret = [NSArray arrayWithObject:pageRange];
                [pageRange release];
            }
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

- (THCGViewSpiritElement *)eucCSSRenderPageViewSpirit:(EucCSSRenderPageViewSpirit *)pageViewSpirit
                    overlayElementForDocumentTreeNode:(EucCSSIntermediateDocumentNode *)documentTreeNode
{
    id<EucCSSReplacedElement> replacedElement = [documentTreeNode replacedElement];

    if (replacedElement && [replacedElement isKindOfClass:[SCHBSBReplacedElement class]]) {
        //CGFloat scaleFactor = [pageViewSpirit scaleFactor];
        //CGFloat pointSize = [documentTreeNode textPointSizeWithScaleFactor:scaleFactor];
        //pointSize = pointSize;
        //THStringRenderer *renderer = [documentTreeNode stringRenderer];
        //renderer = renderer;
        [(SCHBSBReplacedElement *)replacedElement setPointSize:self.pointSize];
        return [replacedElement newViewSpiritElement];
    }
    
    return nil;
}

@end

#endif