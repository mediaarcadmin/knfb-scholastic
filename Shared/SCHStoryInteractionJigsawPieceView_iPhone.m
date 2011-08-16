//
//  SCHStoryInteractionJigsawPieceView_iPhone.m
//  Scholastic
//
//  Created by Neil Gall on 15/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionJigsawPieceView_iPhone.h"
#import "SCHGeometry.h"

@implementation SCHStoryInteractionJigsawPieceView_iPhone

@synthesize image;
@synthesize solutionPosition;
@synthesize homePosition;

- (void)dealloc
{
    CGImageRelease(image), image = NULL;
    [super dealloc];
}

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super initWithFrame:frame])) {
        self.contentMode = UIViewContentModeCenter;
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
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
    if (self.image) {
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

@end
