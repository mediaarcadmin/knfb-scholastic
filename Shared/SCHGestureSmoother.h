//
//  SCHGestureSmoother.h
//  Scholastic
//
//  Created by Neil Gall on 23/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SCHGestureSmoother : NSObject

+ (SCHGestureSmoother *)smoother;

- (void)addPoint:(CGPoint)point;
- (CGPoint)smoothedPoint;

@end
