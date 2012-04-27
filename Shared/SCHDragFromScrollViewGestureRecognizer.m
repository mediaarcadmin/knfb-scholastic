//
//  DragFromTableGestureRecognizer.m
//  ScrollerTest
//
//  Created by Neil Gall on 01/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDragFromScrollViewGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

#define kTouchAndHoldDelay 0.4f
#define kGestureDetectMotionThreshold 10.0f

@interface SCHDragFromScrollViewGestureRecognizer ()

@property (nonatomic, assign) CGPoint startPoint;

@end

@implementation SCHDragFromScrollViewGestureRecognizer

@synthesize dragContainerView;
@synthesize startPoint;
@synthesize direction;

- (void)dealloc
{
    [dragContainerView release], dragContainerView = nil;
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.startPoint = [[touches anyObject] locationInView:self.dragContainerView];
    [super touchesBegan:touches withEvent:event];
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [self performSelector:@selector(didTouchAndHold) withObject:nil afterDelay:kTouchAndHoldDelay];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];

    if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
        [super touchesMoved:touches withEvent:event];
    } else {
        CGPoint p = [[touches anyObject] locationInView:self.dragContainerView];
        CGFloat dx = fabs(p.x - self.startPoint.x);
        CGFloat dy = fabs(p.y - self.startPoint.y);
        if ([self shouldCancelWithMotion:dx:dy]) {
            self.state = UIGestureRecognizerStateCancelled;
        }
        if ([self shouldBeginGestureWithMotion:dx:dy]) {
            self.state = UIGestureRecognizerStateBegan;
        }
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [NSObject cancelPreviousPerformRequestsWithTarget:self];
    [super touchesCancelled:touches withEvent:event];
}

- (void)didTouchAndHold
{
    self.state = UIGestureRecognizerStateBegan;
}

- (BOOL)shouldCancelWithMotion:(CGFloat)dx :(CGFloat)dy
{
    if (self.direction == kSCHDragFromScrollViewHorizontally) {
        return dx < kGestureDetectMotionThreshold && dy > kGestureDetectMotionThreshold;
    } else {
        return dy < kGestureDetectMotionThreshold && dx > kGestureDetectMotionThreshold;
    }
}

- (BOOL)shouldBeginGestureWithMotion:(CGFloat)dx :(CGFloat)dy
{
    if (self.direction == kSCHDragFromScrollViewHorizontally) {
        return dy < kGestureDetectMotionThreshold && dx > kGestureDetectMotionThreshold;
    } else {
        return dx < kGestureDetectMotionThreshold && dy > kGestureDetectMotionThreshold;
    }
}

@end
