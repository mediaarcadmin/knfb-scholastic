//
//  DragFromTableGestureRecognizer.m
//  ScrollerTest
//
//  Created by Neil Gall on 01/08/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHDragFromScrollViewGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface SCHDragFromScrollViewGestureRecognizer ()

@property (nonatomic, assign) CGPoint startPoint;

@end

@implementation SCHDragFromScrollViewGestureRecognizer

@synthesize dragContainerView;
@synthesize startPoint;

- (void)dealloc
{
    [dragContainerView release], dragContainerView = nil;
    [super dealloc];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.startPoint = [[touches anyObject] locationInView:self.dragContainerView];
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.state == UIGestureRecognizerStateBegan || self.state == UIGestureRecognizerStateChanged) {
        [super touchesMoved:touches withEvent:event];
    } else {
        CGPoint p = [[touches anyObject] locationInView:self.dragContainerView];
        CGFloat dx = fabs(p.x - self.startPoint.x);
        CGFloat dy = fabs(p.y - self.startPoint.y);
        if (dx < 10 && dy > 10) {
            self.state = UIGestureRecognizerStateCancelled;
        }
        if (dy < 10 && dx > 10) {
            self.state = UIGestureRecognizerStateBegan;
        }
    }
}

@end
