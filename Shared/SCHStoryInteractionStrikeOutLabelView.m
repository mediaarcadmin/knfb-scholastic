//
//  SCHStoryInteractionStrikeOutLabelView.m
//  Scholastic
//
//  Created by Neil Gall on 07/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionStrikeOutLabelView.h"


@implementation SCHStoryInteractionStrikeOutLabelView

@synthesize strikeOutColor;
@synthesize strikedOut;

- (void)dealloc
{
    [strikeOutColor release];
    [super dealloc];
}

- (void)setStrikedOut:(BOOL)aStrikedOut
{
    strikedOut = aStrikedOut;
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    if (strikedOut) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGRect textRect = [self textRectForBounds:self.bounds limitedToNumberOfLines:self.numberOfLines];
        
        CGContextSetStrokeColorWithColor(context, [self.strikeOutColor CGColor]);
        CGContextSetLineWidth(context, 2.0);
        CGContextMoveToPoint(context, CGRectGetMinX(textRect), CGRectGetMidY(textRect)+2);
        CGContextAddLineToPoint(context, CGRectGetMaxX(textRect), CGRectGetMidY(textRect)+2);
        CGContextStrokePath(context);
    }
}

@end
