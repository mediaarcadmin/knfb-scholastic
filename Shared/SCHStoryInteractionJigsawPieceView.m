//
//  SCHStoryInteractionJigsawPieceView.m
//  Scholastic
//
//  Created by Neil Gall on 12/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionJigsawPieceView.h"

@implementation SCHStoryInteractionJigsawPieceView

@synthesize image;

- (void)dealloc
{
    CGImageRelease(image), image = NULL;
    [super dealloc];
}

- (void)setImage:(CGImageRef)newImage
{
    CGImageRef oldImage = image;
    image = CGImageRetain(newImage);
    CGImageRelease(oldImage);
    [self setBackgroundColor:[UIColor clearColor]];
    [self setNeedsDisplay];
}

- (void)drawRect:(CGRect)rect
{
    if (image) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, CGRectGetHeight(self.bounds));
        CGContextScaleCTM(context, 1, -1);
        CGContextDrawImage(context, self.bounds, self.image);
    }
}

@end
