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

static void blockApplier(void *info, const CGPathElement *element)
{
    void (^block)(const CGPathElement *) = info;
    block(element);
}


void SCHCGPathApplyBlock(CGPathRef path, void (^block)(const CGPathElement *))
{
    CGPathApply(path, block, blockApplier);
}

CGRect SCHAspectFitSizeInTargetRect(CGSize sourceSize, CGRect targetRect)
{
    CGFloat xscale = targetRect.size.width / sourceSize.width;
    CGFloat yscale = targetRect.size.height / sourceSize.height;
    CGFloat scale = MIN(xscale, yscale);
    CGFloat width = sourceSize.width*scale;
    CGFloat height = sourceSize.height*scale;
    return CGRectMake(targetRect.origin.x+(targetRect.size.width-width)/2,
                      targetRect.origin.y+(targetRect.size.height-height)/2,
                      width, height);
}

