//
//  SCHStoryInteractionDraggableTargetView.m
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionDraggableTargetView.h"

@implementation SCHStoryInteractionDraggableTargetView

@synthesize matchTag;
@synthesize centerOffset;
@synthesize occupied;

- (CGPoint)targetCenterInView:(UIView *)view
{
    CGPoint c;
    if (view == self.superview) {
        c = self.center;
    } else {
        c = [self convertPoint:self.center toView:view];
    }
    return CGPointMake(c.x + self.centerOffset.x, c.y + self.centerOffset.y);
}

@end
