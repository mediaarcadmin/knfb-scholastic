//
//  SCHStoryInteractionWhoSaidItNameView.m
//  Scholastic
//
//  Created by Neil Gall on 30/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionWhoSaidItNameView.h"
#import "SCHStoryInteractionDraggableTargetView.h"

@implementation SCHStoryInteractionWhoSaidItNameView

@synthesize attachedTarget;

- (void)moveToHomePosition
{
    [super moveToHomePosition];
    self.attachedTarget = nil;
}

- (BOOL)attachedToCorrectTarget
{
    return self.attachedTarget != nil && self.matchTag == self.attachedTarget.matchTag;
}

- (void)beginDrag
{
    [super beginDrag];
    self.attachedTarget = nil;
}

@end
