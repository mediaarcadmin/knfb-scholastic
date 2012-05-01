//
//  SCHStoryInteractionJigsawPieceView_iPhone.m
//  Scholastic
//
//  Created by Neil Gall on 15/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionJigsawPieceView_iPhone.h"
#import "SCHGeometry.h"

@implementation SCHStoryInteractionJigsawPieceView_iPhone {
    UIGestureRecognizer *dragFromScrollGestureRecognizer;
}

@synthesize image;
@synthesize solutionPosition;
@synthesize pieceFrame;
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

- (void)didMoveToSuperview
{
    [super didMoveToSuperview];
    [self setNeedsDisplay];
}

- (void)setImage:(CGImageRef)newImage
{
    CGImageRef oldImage = image;
    image = CGImageRetain(newImage);
    CGImageRelease(oldImage);
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

- (BOOL)shouldSnapToSolutionPositionFromPosition:(CGPoint)position
{
    CGFloat distanceSq = SCHCGPointDistanceSq(position, self.solutionPosition);
    return distanceSq < 500;
}

- (void)moveToHomePosition
{
    self.center = self.homePosition;
}

- (void)addDragFromScrollerGestureRecognizerWithTarget:(id)target
                                                action:(SEL)action
                                             container:(UIView *)containerView
                                             direction:(enum SCHDragFromScrollViewGestureRecognizerDirection)direction
{
    if (dragFromScrollGestureRecognizer) {
        [self removeGestureRecognizer:dragFromScrollGestureRecognizer];
    }
    
    SCHDragFromScrollViewGestureRecognizer *drag = [[SCHDragFromScrollViewGestureRecognizer alloc] initWithTarget:target action:action];
    drag.dragContainerView = containerView;
    drag.direction = direction;
    [self addGestureRecognizer:drag];
    dragFromScrollGestureRecognizer = drag;
    [drag release];
}

@end
