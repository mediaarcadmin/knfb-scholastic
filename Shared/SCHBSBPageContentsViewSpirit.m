//
//  SCHBSBPageContentsViewSpirit.m
//  Scholastic
//
//  Created by Matt Farrugia on 09/05/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBPageContentsViewSpirit.h"
#import "SCHBSBEucBook.h"
#import "SCHBSBTreeNode.h"
#import <libEucalyptus/EucCSSDPI.h>
#import <libEucalyptus/EucCSSIntermediateDocument.h>
#import <libEucalyptus/EucCSSXHTMLTree.h>
#import <libEucalyptus/EucCSSRenderPageViewSpirit.h>
#import <libEucalyptus/EucBookPageIndexPointRange.h>
#import <libEucalyptus/EucUIViewViewSpiritElement.h>

@interface SCHBSBViewSpiritRenderableLayer : CALayer
@end

@interface SCHBSBPageContentsViewSpiritWebView : UIWebView <UIWebViewDelegate>

- (void)synchronouslyLoadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL;

@end

@interface SCHBSBPageContentsViewSpiritTextField : UITextField
@end

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

#pragma mark - EucCSSRenderPageViewSpiritDelegate

- (THCGViewSpiritElement *)eucCSSRenderPageViewSpirit:(EucCSSRenderPageViewSpirit *)pageViewSpirit
             overlayElementForDocumentTreeNodeWithKey:(uint32_t)documentTreeNode
                                              inFrame:(CGRect)frame
{
    
    SCHBSBTreeNode *node = (SCHBSBTreeNode *)[self.document.documentTree nodeForKey:documentTreeNode];
    
    if ([node isUIKitNode]) {
        
        UIView *aView = [self viewForNode:node constrainedToSize:frame.size];
        aView.frame = frame;
        
        EucUIViewViewSpiritElement *aViewSpiritElement = [[EucUIViewViewSpiritElement alloc] initWithView:aView inContainingSpirit:self];
        
        return [aViewSpiritElement autorelease];
    }
    
    return nil;
}

- (UIView *)viewForNode:(SCHBSBTreeNode *)node constrainedToSize:(CGSize)constrainedSize
{
    UIView *view = nil;
    CGRect constrainedFrame = CGRectZero;
    constrainedFrame.size = constrainedSize;
    
    NSString *dataType = [node attributeWithName:@"data-type"];
    
    if ([dataType isEqualToString:@"text"]) {
        SCHBSBPageContentsViewSpiritTextField *aTextField = [[SCHBSBPageContentsViewSpiritTextField alloc] initWithFrame:constrainedFrame];
        aTextField.frame = constrainedFrame;
        aTextField.borderStyle = UITextBorderStyleRoundedRect;
        view = [aTextField autorelease];
    } else if ([dataType isEqualToString:@"radio"]) {
        SCHBSBPageContentsViewSpiritWebView *radio = [[SCHBSBPageContentsViewSpiritWebView alloc] init];
        
        NSString *dataBinding = [node attributeWithName:@"data-binding"];
        
        NSMutableString *htmlString = [NSMutableString stringWithString:@"<body><form>"];
        
        SCHBSBTreeNode *childNode = node.firstChild;
        
        while (childNode != nil) {
            NSString *dataKey = [childNode attributeWithName:@"data-key"];
            NSString *dataValue = [childNode attributeWithName:@"data-value"];
            
            if (dataKey && dataValue) {
                [htmlString appendFormat:@"<input type='radio' name='%@' value='%@' /> %@<br />", dataBinding, dataValue, dataKey];
            }
            
            childNode = childNode.nextSibling;
        }
        
        [htmlString appendString:@"</form></body>"];
        
        [radio synchronouslyLoadHTMLString:htmlString baseURL:nil];
        radio.frame = constrainedFrame;
        view = radio;
    } else if ([dataType isEqualToString:@"dropdown"]) {
        SCHBSBPageContentsViewSpiritWebView *dropdown = [[SCHBSBPageContentsViewSpiritWebView alloc] init];
        NSString *dataBinding = [node attributeWithName:@"data-binding"];
        
        NSMutableString *htmlString = [NSMutableString stringWithFormat:@"<body><form><select name='%@'>", dataBinding];
        
        SCHBSBTreeNode *childNode = node.firstChild;
        
        while (childNode != nil) {
            NSString *dataKey = [childNode attributeWithName:@"data-key"];
            NSString *dataValue = [childNode attributeWithName:@"data-value"];
            
            if (dataKey && dataValue) {
                [htmlString appendFormat:@"<option value='%@'>%@</option>", dataValue, dataKey];
            }
            
            childNode = childNode.nextSibling;
        }
        
        [htmlString appendString:@"</select></form></body>"];
        
        [dropdown synchronouslyLoadHTMLString:htmlString baseURL:nil];
        dropdown.frame = constrainedFrame;
        view = dropdown;
    } else {
        UIButton *aButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        aButton.frame = constrainedFrame;
        [aButton setTitle:@"Hello World" forState:UIControlStateNormal];
        view = aButton;
    }
    
    return view;
}

@end

@implementation SCHBSBPageContentsViewSpiritWebView

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        if ([self respondsToSelector:@selector(scrollView)]) {
            UIScrollView *aScrollView = [self scrollView];
            [aScrollView setBounces:NO];
            [aScrollView setScrollEnabled:NO];
        }
        
        self.delegate = self;
    }
    
    return self;
}

- (void)synchronouslyLoadHTMLString:(NSString *)string baseURL:(NSURL *)baseURL
{
    [self loadHTMLString:string baseURL:baseURL];    
    CFRunLoopRunInMode((CFStringRef)NSDefaultRunLoopMode, 0.1, NO);
}

- (void)scrollViewDidScroll:(UIScrollView *)aScrollView
{
    // Only required for iOS < 4.0
    [aScrollView setContentOffset: CGPointMake(aScrollView.contentOffset.x, 0)];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    CFRunLoopRef runLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];
	CFRunLoopStop(runLoop);
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error
{
    CFRunLoopRef runLoop = [[NSRunLoop currentRunLoop] getCFRunLoop];
	CFRunLoopStop(runLoop);
}

+ (Class)layerClass
{
    return [SCHBSBViewSpiritRenderableLayer class];
}

@end

@implementation SCHBSBPageContentsViewSpiritTextField

+ (Class)layerClass
{
    return [SCHBSBViewSpiritRenderableLayer class];
}

@end

@implementation SCHBSBViewSpiritRenderableLayer

- (void)renderInContext:(CGContextRef)ctx
{
    if (self == self.presentationLayer) {
        [self.modelLayer renderInContext:ctx];
    } else {
        [super renderInContext:ctx];
    }
}

@end
