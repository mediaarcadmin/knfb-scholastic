//
//  SCHStoryInteractionDraggableTargetView.m
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionDraggableTargetView.h"

@implementation SCHStoryInteractionDraggableTargetView

@synthesize centerOffset;
@synthesize occupied;

- (CGPoint)targetCenter
{
    return CGPointMake(self.center.x + self.centerOffset.x, self.center.y + self.centerOffset.y);
}

@end
