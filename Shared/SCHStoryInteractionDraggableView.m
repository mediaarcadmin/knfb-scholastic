//
//  SCHStoryInteractionDraggableView.m
//  Scholastic
//
//  Created by Neil Gall on 03/06/2011.
//  Copyright 2011 BitWink. All rights reserved.
//

#import "SCHStoryInteractionDraggableView.h"
#import "SCHStoryInteractionDraggableTargetView.h"

#define kMaxTapTime 0.2

@interface SCHStoryInteractionDraggableView ()

@property (nonatomic, assign) CGPoint touchOffset;
@property (nonatomic, assign) CGPoint dragOrigin;
@property (nonatomic, assign) NSTimeInterval touchStartTime;
@property (nonatomic, assign) BOOL tapSupported;
@property (nonatomic, assign) BOOL dragging;

- (void)beginDrag;
- (void)endDragWithTouch:(UITouch *)touch cancelled:(BOOL)cancelled;

@end

@implementation SCHStoryInteractionDraggableView

@synthesize matchTag;
@synthesize delegate;
@synthesize homePosition;
@synthesize touchOffset;
@synthesize dragOrigin;
@synthesize touchStartTime;
@synthesize tapSupported;
@synthesize dragging;

- (void)setDelegate:(NSObject<SCHStoryInteractionDraggableViewDelegate> *)aDelegate
{
    delegate = aDelegate;
    tapSupported = [aDelegate respondsToSelector:@selector(draggableViewWasTapped:)];
}

- (void)moveToHomePosition
{
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.center = self.homePosition;
                     }];
}

#pragma mark - touch support

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    UITouch *touch = [touches anyObject];
    CGPoint point = [touch locationInView:self.superview];
    self.touchOffset = CGPointMake(self.center.x - point.x, self.center.y - self.center.y);
    self.dragging = NO;
    
    if (self.tapSupported) {
        self.touchStartTime = touch.timestamp;
        [self performSelector:@selector(beginDrag) withObject:nil afterDelay:kMaxTapTime];
    } else {
        [self beginDrag];
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!self.dragging) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginDrag) object:nil];
        [self beginDrag];
    }
    
    CGPoint point = [[touches anyObject] locationInView:self.superview];
    self.center = CGPointMake(point.x + self.touchOffset.x, point.y + self.touchOffset.y);
    
    CGPoint snapPoint;
    if (self.delegate && [self.delegate draggableView:self shouldSnapFromPosition:self.center toPosition:&snapPoint]) {
        self.center = snapPoint;
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endDragWithTouch:[touches anyObject] cancelled:NO];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self endDragWithTouch:[touches anyObject] cancelled:YES];
}

#pragma mark - dragging

- (void)beginDrag
{
    self.dragging = YES;
    self.dragOrigin = self.center;
    [self.superview bringSubviewToFront:self];
    [UIView animateWithDuration:0.25
                     animations:^{
                         self.transform = CGAffineTransformMakeScale(1.1, 1.1);
                         self.alpha = 0.8;
                     }];
    
    if (delegate) {
        [self.delegate draggableViewDidStartDrag:self];
    }
}

- (void)endDragWithTouch:(UITouch *)touch cancelled:(BOOL)cancelled
{
    if (self.dragging) {
        [UIView animateWithDuration:0.25
                         animations:^{
                             self.transform = CGAffineTransformIdentity;
                             self.alpha = 1;
                             if (cancelled) {
                                 self.center = self.dragOrigin;
                             }
                         }];
        if (delegate) {
            [delegate draggableView:self didMoveToPosition:(cancelled ? self.dragOrigin : self.center)];
        }
        self.dragging = NO;
        return;
    } 
    
    if (self.tapSupported) {
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(beginDrag) object:nil];
        if (delegate && touch.timestamp - self.touchStartTime < kMaxTapTime) {
            [self.delegate draggableViewWasTapped:self];
        }
    }
}

@end
