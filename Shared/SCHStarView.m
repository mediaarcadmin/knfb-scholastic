//
//  SCHStarView.m
//  Scholastic
//
//  Created by Neil Gall on 22/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStarView.h"


@implementation SCHStarView

@synthesize fillColor;
@synthesize borderColor;
@synthesize targetPoint;

- (void)dealloc
{
    [fillColor release];
    [borderColor release];
    [super dealloc];
}


- (void)drawRect:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGFloat outerRadius = MIN(CGRectGetWidth(rect), CGRectGetHeight(rect)) / 2;
    CGFloat innerRadius = outerRadius * 0.6;
    CGPoint center = CGPointMake(CGRectGetMidX(rect), CGRectGetMidY(rect));
    
    CGContextSetFillColorWithColor(context, [self.fillColor CGColor]);
    CGContextSetStrokeColorWithColor(context, [self.borderColor CGColor]);
    CGContextSetLineWidth(context, MAX(2, outerRadius/15));

    CGContextMoveToPoint(context, center.x+outerRadius, center.y);
    
    BOOL outerPoint = YES;
    for (CGFloat angle = 0; angle < M_PI*2; angle += M_PI*2/10) {
        CGFloat radius = outerPoint ? outerRadius : innerRadius;
        CGContextAddLineToPoint(context, center.x + radius*cos(angle), center.y + radius*sin(angle));
        outerPoint = !outerPoint;
    }
    
    CGContextDrawPath(context, kCGPathFillStroke);
}

- (void)animateToTargetPoint
{
    self.center = self.targetPoint;
    self.alpha = 0;
}

@end
