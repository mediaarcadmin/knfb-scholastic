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

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
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

- (CGRect)puzzleBounds
{
    if (self.image != nil) {
        // aspect fit the image in the center of the view
        CGSize imageSize = self.image.size;
        CGFloat scale = MIN(CGRectGetWidth(self.bounds) / imageSize.width,
                            CGRectGetHeight(self.bounds) / imageSize.height);
        CGSize actualSize = CGSizeMake(imageSize.width*scale, imageSize.height*scale);
        return CGRectMake((CGRectGetWidth(self.bounds)-actualSize.width)/2,
                          (CGRectGetHeight(self.bounds)-actualSize.height)/2,
                          actualSize.width, actualSize.height);
    } else {
        return self.bounds;
    }
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];

    CGRect bounds = [self puzzleBounds];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextScaleCTM(context, 1, -1);
    CGContextTranslateCTM(context, 0, -CGRectGetHeight(self.bounds));

    if (self.image) {
        CGContextDrawImage(context, bounds, [self.image CGImage]);
    }
    
    if (self.paths) {
        CGContextSaveGState(context);
        CGContextSetStrokeColorWithColor(context, [self.edgeColor CGColor]);
        CGContextSetLineWidth(context, 2.0/CGRectGetWidth(bounds));
        CGContextTranslateCTM(context, CGRectGetMinX(bounds), CGRectGetMinY(bounds));
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
