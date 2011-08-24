//
//  SCHGestureSmoother.m
//  Scholastic
//
//  Created by Neil Gall on 23/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHGestureSmoother.h"

#define kSmoothPoints 5

@interface SCHGestureSmoother ()
@property (nonatomic, assign) CGPoint *points;
@property (nonatomic, assign) NSInteger numberOfPoints;
@end

@implementation SCHGestureSmoother

@synthesize points;
@synthesize numberOfPoints;

+ (SCHGestureSmoother *)smoother
{
    return [[[SCHGestureSmoother alloc] init] autorelease];
}

- (id)init
{
    self = [super init];
    if (self) {
        self.points = malloc(sizeof(CGPoint)*kSmoothPoints);
        self.numberOfPoints = 0;
    }
    return self;
}

- (void)dealloc
{
    free(points);
    [super dealloc];
}

- (void)addPoint:(CGPoint)point
{
    if (self.numberOfPoints < kSmoothPoints) {
        self.points[self.numberOfPoints++] = point;
    } else {
        memmove(self.points, self.points+1, sizeof(CGPoint)*(kSmoothPoints-1));
        self.points[kSmoothPoints-1] = point;
    }
}

- (CGPoint)smoothedPoint
{
    CGFloat tx = 0, ty = 0;
    for (CGPoint *p = self.points, *e = p+self.numberOfPoints; p < e; ++p) {
        tx += p->x;
        ty += p->y;
    }
    return CGPointMake(tx / self.numberOfPoints, ty / self.numberOfPoints);
}

@end
