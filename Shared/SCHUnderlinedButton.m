//
//  SCHUnderlinedButton.m
//  Scholastic
//
//  Created by Matt Farrugia on 27/05/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHUnderlinedButton.h"

@implementation SCHUnderlinedButton

- (void)setHighlighted:(BOOL)newHighlighted
{
    [super setHighlighted:newHighlighted];
    [self setNeedsDisplay];
}

- (void) drawRect:(CGRect)rect {
    CGRect textRect = self.titleLabel.frame;
    
    // need to put the line at top of descenders (negative value)
    CGFloat descender = self.titleLabel.font.descender + 1;
    
    CGContextRef contextRef = UIGraphicsGetCurrentContext();
    
    // set to same colour as text
    if ([self isHighlighted] && self.titleLabel.highlightedTextColor &&
        self.enabled == YES) {
        CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.highlightedTextColor.CGColor);
    } else {
        CGContextSetStrokeColorWithColor(contextRef, self.titleLabel.textColor.CGColor);
    }
    
    CGContextMoveToPoint(contextRef, textRect.origin.x, textRect.origin.y + textRect.size.height + descender);
    
    CGContextAddLineToPoint(contextRef, textRect.origin.x + textRect.size.width, textRect.origin.y + textRect.size.height + descender);
    
    CGContextClosePath(contextRef);
    
    CGContextDrawPath(contextRef, kCGPathStroke);
}

@end
