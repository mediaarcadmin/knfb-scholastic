//
//  SCHBSBReplacedElementPlaceholder
//  Scholastic
//
//  Created by Matt Farrugia on 10/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElement.h"
#import <libEucalyptus/THRoundRects.h>
#import <libEucalyptus/EucUIViewViewSpiritElement.h>

@implementation SCHBSBReplacedElement

@synthesize pointSize;
@synthesize delegate;
@synthesize nodeId;

- (void)dealloc
{
    delegate = nil;
    [nodeId release], nodeId = nil;
    [super dealloc];
}

- (CGSize)intrinsicSize
{
    return CGSizeZero; // Subclasses should override with something more sensisble
}

- (void)renderInRect:(CGRect)rect inContext:(CGContextRef)context
{
    CGContextSaveGState(context);
    
    CGContextSetStrokeColor(context, (CGFloat[4]){ 0.5f, 0.5f, 0.5f, 1.0f });
    CGContextSetFillColor(context, (CGFloat[4]){ 1.0f, 1.0f, 1.0f, 1.0f });
    CGContextSetLineWidth(context, 2);
    
    CGRect drawingRect = CGRectInset(rect, 1, 1);
    CGFloat radius = MIN(drawingRect.size.width * 0.5f, drawingRect.size.height * 0.5f);
    radius = MIN(5.0f, radius);
    THAddRoundedRectToPath(context, drawingRect, radius, radius);
    
    CGContextDrawPath(context, kCGPathFillStroke);
    
    CGContextRestoreGState(context);
}

@end
