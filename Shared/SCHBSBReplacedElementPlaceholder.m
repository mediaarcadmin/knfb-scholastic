//
//  SCHBSBReplacedElementPlaceholder
//  Scholastic
//
//  Created by Matt Farrugia on 10/08/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElementPlaceholder.h"
#import <libEucalyptus/THRoundRects.h>
#import <libEucalyptus/EucUIViewViewSpiritElement.h>

@implementation SCHBSBReplacedElementPlaceholder

@synthesize pointSize;
@synthesize delegate;
@synthesize nodeId;

- (void)dealloc
{
    delegate = nil;
    [nodeId release], nodeId = nil;
    [super dealloc];
}

- (id)initWithPointSize:(CGFloat)point;
{
    if(self = [super init]) {
        pointSize = point;
    }
    return self;
}

- (CGSize)intrinsicSize
{
    return CGSizeMake(self.pointSize, self.pointSize); // Subclasses should override with something more sensisble
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
