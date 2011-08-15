//
//  SCHGeometry.h
//  Scholastic
//
//  Created by Neil Gall on 20/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <CoreGraphics/CoreGraphics.h>

// Square of distance from p1 to p2
CGFloat SCHCGPointDistanceSq(CGPoint p1, CGPoint p2);

// like CGPathApply() but with a block instead of an applier function
void SCHCGPathApplyBlock(CGPathRef path, void (^block)(const CGPathElement *));

// return an adjusted rect centered within the target rect but aspect-adjusted
// to match the aspect ratio of a source size
CGRect SCHAspectFitSizeInTargetRect(CGSize sourceSize, CGRect targetRect);