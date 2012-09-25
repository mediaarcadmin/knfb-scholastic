//
//  SCHBSBReplacedElementNavigateButton.m
//  Scholastic
//
//  Created by Matt Farrugia on 06/09/2012.
//  Copyright (c) 2012 BitWink. All rights reserved.
//

#import "SCHBSBReplacedElementNavigateButton.h"

@implementation SCHBSBReplacedElementNavigateButton

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.opaque = NO;
    }
    return self;
}

- (BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self setNeedsDisplay];
    return [super beginTrackingWithTouch:touch withEvent:event];
}

- (void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    [self setNeedsDisplay];
    [super endTrackingWithTouch:touch withEvent:event];
}

- (void)cancelTrackingWithEvent:(UIEvent *)event;
{
    [self setNeedsDisplay];
    [super cancelTrackingWithEvent:event];
}

- (void)drawRect:(CGRect)rect
{
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    CGRect bounds = self.bounds;
    CGContextClearRect(ctx, bounds);
    
    CGFloat idealSpan = 44;
    CGFloat stroke = 2;
    CGFloat xInset = ceilf(stroke/2.0f - 0.5f);
        
    CGFloat width = MIN(idealSpan, bounds.size.width - xInset);
    CGFloat height = MIN(idealSpan, bounds.size.height);
    CGFloat span = floorf(MIN(width, height));
    
    CGRect buttonRect = CGRectMake(0, 0, span, span);
    buttonRect.origin.y = floorf((CGRectGetHeight(bounds) - span)/2.0f);
    buttonRect.origin.x = xInset;
    
    CGFloat triangleSpan = floorf(CGRectGetWidth(buttonRect)*0.5f);
    CGFloat minX = floorf((CGRectGetWidth(buttonRect) - triangleSpan)*0.7f);
    CGFloat minY = floorf((CGRectGetWidth(buttonRect) - triangleSpan)*0.5f);
    CGFloat maxY = minY + triangleSpan;
    CGFloat mid = floorf(CGRectGetMidY(buttonRect));
    CGPoint pointA = CGPointMake(buttonRect.origin.x + minX, buttonRect.origin.y + minY);
    CGPoint pointB = CGPointMake(buttonRect.origin.x + minX, buttonRect.origin.y + maxY);
    CGPoint pointC = CGPointMake(buttonRect.origin.x + maxY, mid);
    
    CGContextSetRGBFillColor(ctx, 0, 1, 0, 1);
    CGContextFillEllipseInRect(ctx, buttonRect);
    
    CGContextSetRGBStrokeColor(ctx, 0, 0, 0, 0.8f);
    CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.8f);
    CGContextSetLineWidth(ctx, stroke);
    CGContextStrokeEllipseInRect(ctx, buttonRect);
    
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, pointA.x, pointA.y);
    CGPathAddLineToPoint(path, NULL, pointB.x, pointB.y);
    CGPathAddLineToPoint(path, NULL, pointC.x, pointC.y);
    CGPathCloseSubpath(path);
    
    CGContextAddPath(ctx, path);
    CGContextFillPath(ctx);
    CGPathRelease(path);
    
    if (self.isTracking) {
        CGContextSetBlendMode(ctx, kCGBlendModeSourceAtop);
        CGContextSetRGBFillColor(ctx, 0, 0, 0, 0.5f);
        CGContextFillRect(ctx, rect);
    }
}

@end
