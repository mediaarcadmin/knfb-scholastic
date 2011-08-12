//
//  SCHStoryInteractionJigsawPreviewView.m
//  Scholastic
//
//  Created by Neil Gall on 12/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionJigsawPreviewView.h"
#import "SCHStoryInteractionJigsawPaths.h"

@implementation SCHStoryInteractionJigsawPreviewView

@synthesize image;
@synthesize paths;
@synthesize edgeColor;

- (void)dealloc
{
    [image release], image = nil;
    [paths release], paths = nil;
    [edgeColor release], edgeColor = nil;
    [super dealloc];
}

- (void)setImage:(UIImage *)newImage
{
    UIImage *oldImage = image;
    image = [newImage retain];
    [oldImage release];
    [self setNeedsDisplay];
}

- (void)setPaths:(SCHStoryInteractionJigsawPaths *)newPaths
{
    SCHStoryInteractionJigsawPaths *oldPaths = paths;
    paths = [newPaths retain];
    [oldPaths release];
    [self setNeedsDisplay];
}

- (void)setEdgeColor:(UIColor *)newColor
{
    UIColor *oldColor = edgeColor;
    edgeColor = [newColor retain];
    [oldColor release];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    CGRect bounds = self.bounds;
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -CGRectGetHeight(bounds));

    if (self.image) {
        CGContextDrawImage(context, bounds, [self.image CGImage]);
    }
    
    if (self.paths) {
        CGContextSaveGState(context);
        CGContextSetStrokeColorWithColor(context, [self.edgeColor CGColor]);
        CGContextSetLineWidth(context, 2.0/CGRectGetWidth(bounds));
        CGContextScaleCTM(context, CGRectGetWidth(bounds), CGRectGetHeight(bounds));
        
        for (NSInteger pathIndex = 0, pathCount = [self.paths numberOfPaths]; pathIndex < pathCount; ++pathIndex) {
            CGPathRef path = [self.paths pathAtIndex:pathIndex];
            CGContextAddPath(context, path);
        }
        
        CGContextDrawPath(context, kCGPathStroke);
        CGContextRestoreGState(context);
    }
}


@end
