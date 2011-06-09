//
//  SCHStoryInteractionDraggableView.m
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionDraggableView.h"
#import "SCHStoryInteractionDraggableTargetView.h"

@interface SCHStoryInteractionDraggableView ()

@property (nonatomic, assign) CGPoint touchOffset;
@property (nonatomic, assign) CGPoint originalCenter;
@property (nonatomic, copy) NSArray *targets;

- (void)beginDrag;
- (void)endDrag:(BOOL)cancelled;

@end

@implementation SCHStoryInteractionDraggableView

@synthesize matchTag;
@synthesize centerOffset;
@synthesize snapDistanceSq;
@synthesize targets;
@synthesize touchOffset;
@synthesize originalCenter;
@synthesize attachedTarget;

- (void)dealloc
{
    [targets release];
    [super dealloc];
}

- (void)setDragTargets:(NSArray *)dragTargets
{
    self.originalCenter = self.center;
    self.targets = dragTargets;
    [self setUserInteractionEnabled:YES];
}

#pragma mark - touch support

static CGFloat distanceSq(CGPoint p1, CGPoint p2)
{
    CGFloat dx = p1.x-p2.x;
    CGFloat dy = p1.y-p2.y;
    return dx*dx + dy*dy;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.superview];
    self.touchOffset = CGPointMake(self.center.x - point.x, self.center.y - self.center.y);
    [self beginDrag];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint point = [[touches anyObject] locationInView:self.superview];
    self.center = CGPointMake(point.x + self.touchOffset.x, point.y + self.touchOffset.y);
    
    self.attachedTarget.occupied = NO;
    self.attachedTarget = nil;
    for (SCHStoryInteractionDraggableTargetView *target in self.targets) {
        if (target.occupied) {
            continue;
        }
        CGPoint selfCenter = CGPointMake(self.center.x + self.centerOffset.x, self.center.y + self.centerOffset.y);
        if (distanceSq(target.targetCenter, selfCenter) < self.snapDistanceSq) {
            self.center = CGPointMake(target.targetCenter.x - self.centerOffset.x, target.targetCenter.y - self.centerOffset.y);
            self.attachedTarget = target;
            self.attachedTarget.occupied = YES;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if we don't drop on a target, return to original position
    [self endDrag:(attachedTarget == nil)];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endDrag:YES];
}

#pragma mark - dragging

- (void)beginDrag
{
    [self.superview bringSubviewToFront:self];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         self.alpha = 0.8;
                     }];
}

- (void)endDrag:(BOOL)cancelled
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.transform = CGAffineTransformIdentity;
                         self.alpha = 1;
                         if (cancelled) {
                             self.center = self.originalCenter;
                         }
                     }];
}

@end
