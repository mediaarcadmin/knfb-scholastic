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
@property (nonatomic, assign) CGPoint dragOrigin;

- (void)beginDrag;
- (void)endDrag:(BOOL)cancelled;

@end

@implementation SCHStoryInteractionDraggableView

@synthesize matchTag;
@synthesize delegate;
@synthesize touchOffset;
@synthesize dragOrigin;

#pragma mark - touch support

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
    
    CGPoint snapPoint;
    if (self.delegate && [self.delegate draggableView:self shouldSnapFromPosition:self.center toPosition:&snapPoint]) {
        self.center = snapPoint;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    // if we don't drop on a target, return to original position
    [self endDrag:NO];

    if (delegate) {
        [delegate draggableView:self didMoveToPosition:self.center];
    }
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endDrag:YES];
}

#pragma mark - dragging

- (void)beginDrag
{
    self.dragOrigin = self.center;
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
                             self.center = self.dragOrigin;
                         }
                     }];
}

@end
