//
//  SCHGeometry.m
//  Scholastic
//
//  Created by Neil Gall on 20/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHGeometry.h"

CGFloat SCHCGPointDistanceSq(CGPoint p1, CGPoint p2)
{
    CGFloat dx = p1.x - p2.x;
    CGFloat dy = p1.y - p2.y;
    return dx*dx + dy*dy;
}
