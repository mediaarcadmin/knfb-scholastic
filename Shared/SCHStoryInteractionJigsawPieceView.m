//
//  SCHStoryInteractionJigsawPieceView.m
//  Scholastic
//
//  Created by Neil Gall on 12/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionJigsawPieceView.h"
#import "SCHGeometry.h"

@implementation SCHStoryInteractionJigsawPieceView

@synthesize image;
@synthesize solutionPosition;

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

- (BOOL)isInCorrectPosition
{
    static const CGFloat kSnapDistanceSq = 900;
    return SCHCGPointDistanceSq(self.center, self.solutionPosition) < kSnapDistanceSq;
}

- (void)beginDrag
{
    [super beginDrag];
    self.layer.shadowColor = [[UIColor blackColor] CGColor];
    self.layer.shadowRadius = 8;
    self.layer.shadowOpacity = 0.8;
}

- (void)endDragWithTouch:(UITouch *)touch cancelled:(BOOL)cancelled
{
    [super endDragWithTouch:touch cancelled:cancelled];
    self.layer.shadowRadius = 0;
    self.layer.shadowOpacity = 0;
}

@end
